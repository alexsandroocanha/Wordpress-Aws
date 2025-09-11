resource "aws_instance" "bastion" {
  ami                         = "ami-0360c520857e3138f"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.publica1.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.minha_chave_aws.key_name
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  depends_on                  = [aws_security_group.bastion]

  tags        = var.ec2_tags
  volume_tags = var.ec2_tags
}

resource "aws_instance" "db_ec2" {
  ami                         = "ami-0360c520857e3138f"
  instance_type               = var.type-instance-ec2
  subnet_id                   = aws_subnet.privada1.id
  associate_public_ip_address = false
  key_name                    = aws_key_pair.minha_chave_aws.key_name
  vpc_security_group_ids      = [aws_security_group.db_ec2.id]
  depends_on                  = [aws_security_group.db_ec2]
  user_data = base64encode(<<-EOF
    #!/bin/bash
    sudo apt update && sudo apt -y upgrade
    sudo apt -y install ca-certificates curl gnupg

    sudo apt-get install -y docker.io
    sudo apt-get install -y docker-compose-v2



    sudo systemctl enable --now docker || true
    id ubuntu &>/dev/null && usermod -aG docker ubuntu || true

    mkdir -p /home/ubuntu/wordpress/{wp-content,certs}
    cd /home/ubuntu/wordpress

    cat > .env <<EOENV
    PROJECT_NAME=wpstack
    WORDPRESS_DB_HOST=${local.db_host}
    WORDPRESS_DB_NAME=wordpress
    WORDPRESS_DB_USER=admin
    WORDPRESS_DB_PASSWORD=alexsandro
    PHP_MEMORY_LIMIT=256M
    UPLOAD_MAX_FILESIZE=64M
    POST_MAX_SIZE=64M
    EOENV


    cat > docker-compose.yml <<'YAML'
    version: "3.9"

    services:
      wordpress:
        image: wordpress:latest
        container_name: $${PROJECT_NAME}-wp
        restart: unless-stopped
        env_file: .env
        environment:
          WORDPRESS_DB_HOST: $${WORDPRESS_DB_HOST}
          WORDPRESS_DB_USER: $${WORDPRESS_DB_USER}
          WORDPRESS_DB_PASSWORD: $${WORDPRESS_DB_PASSWORD}
          WORDPRESS_DB_NAME: $${WORDPRESS_DB_NAME}
          PHP_MEMORY_LIMIT: $${PHP_MEMORY_LIMIT}
          UPLOAD_MAX_FILESIZE: $${UPLOAD_MAX_FILESIZE}
          POST_MAX_SIZE: $${POST_MAX_SIZE}
        volumes:
          - ./wp-content:/var/www/html/wp-content
        ports:
          - "80:80"

    YAML

    sudo mount -t efs ${local.efs_dns}:/ /home/ubuntu/wordpress/wp-content || true
    grep -q "/home/ubuntu/wordpress/wp-content efs" /etc/fstab || \
      echo "${local.efs_dns}:/ /home/ubuntu/wordpress/wp-content efs _netdev,tls 0 0" | sudo tee -a /etc/fstab >/dev/null

    docker compose up -d
  EOF
  )
  tags        = var.ec2_tags
  volume_tags = var.ec2_tags
}

resource "aws_key_pair" "minha_chave_aws" {
  key_name   = "alex-key"
  public_key = file("${path.module}\\aws-ec2.pub")
}
