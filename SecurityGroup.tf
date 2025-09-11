# ---------------EC2--------------------

resource "aws_security_group" "db_ec2" {
  name        = "db_ec2"
  vpc_id      = aws_vpc.vpc-wordpress.id
  description = "App instances behind ALB"

  ingress {
    description     = "SSH from bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "db_ec2" }
}


# -----------EC2-Bastion----------------

resource "aws_security_group" "bastion" {
  name        = "bastion"
  description = "desc"
  vpc_id      = aws_vpc.vpc-wordpress.id


  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion-ec2"
  }
}

# ----------------RDS------------------

resource "aws_security_group" "db_rds" {
  name        = "db_rds"
  description = "desc"
  vpc_id      = aws_vpc.vpc-wordpress.id

  ingress {
    description     = "MySQL"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.db_ec2.id]
  }

  tags = {
    Name = "sg-db-rds"
  }
}

# -----------------------EFS-----------------------------

resource "aws_security_group" "efs" {
  name        = "efs-sg"
  vpc_id      = aws_vpc.vpc-wordpress.id
  description = "EFS NFS from app SG"

  ingress {
    description     = "NFS from app"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.db_ec2.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "efs-sg" }
}


# -------------------SubnetGroup------------------------

resource "aws_db_subnet_group" "db_subnet" {
  name       = "wp-db-subnet-group"
  subnet_ids = [aws_subnet.privada1.id, aws_subnet.privada2.id]
  tags = {
    Name = "wp-db-subnet-group"
  }
}

# ---------------------------------------------------

resource "aws_security_group" "alb" {
  name   = "alb-sg"
  vpc_id = aws_vpc.vpc-wordpress.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "alb-sg" }
}
