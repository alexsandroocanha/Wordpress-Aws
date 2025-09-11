output "rds_endpoint" {
  value = aws_db_instance.wp.address
}

output "efs_host" {
  value       = aws_efs_file_system.wp.dns_name
  description = "Host do EFS no formato fs-XXXXXXXX.efs.<regiao>.amazonaws.com"
}

output "alb_dns_name" {
  value = aws_lb.wp.dns_name
}
