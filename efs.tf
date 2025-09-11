resource "aws_efs_file_system" "wp" {
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  encrypted        = true

  tags = {
    Name = "wp-efs"
  }
}

resource "aws_efs_mount_target" "wp_a" {
  file_system_id  = aws_efs_file_system.wp.id
  subnet_id       = aws_subnet.privada1.id
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_mount_target" "wp_b" {
  file_system_id  = aws_efs_file_system.wp.id
  subnet_id       = aws_subnet.privada2.id
  security_groups = [aws_security_group.efs.id]
}

