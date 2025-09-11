resource "aws_db_instance" "wp" {
  identifier            = "wp-mysql"
  allocated_storage     = 20
  max_allocated_storage = 100
  engine                = "mysql"
  engine_version        = "8.0"
  instance_class        = "db.t3.micro"

  db_name  = "wordpress"
  username = var.username_db
  password = var.db_passwd

  db_subnet_group_name   = aws_db_subnet_group.db_subnet.name
  vpc_security_group_ids = [aws_security_group.db_rds.id]
  publicly_accessible    = false

  storage_type            = "gp3"
  backup_retention_period = 7
  skip_final_snapshot     = true
  deletion_protection     = false
  parameter_group_name    = "default.mysql8.0"

  tags = {
    Name = "wp-rds"
  }
}