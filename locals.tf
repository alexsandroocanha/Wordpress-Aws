locals {
  db_host = "${aws_db_instance.wp.address}:3306"
  efs_dns = aws_efs_file_system.wp.dns_name
}
