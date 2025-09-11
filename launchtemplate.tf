resource "aws_launch_template" "wp" {
  name_prefix   = "lt-wp-"
  image_id      = "ami-0360c520857e3138f"
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.db_ec2.id]

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

  tag_specifications {
    resource_type = "instance"
    tags          = var.ec2_tags
  }
  tag_specifications {
    resource_type = "volume"
    tags          = var.ec2_tags
  }
}
