variable "ec2_tags" {
  description = "Tags da Instancia EC2"
  type        = map(string)
  sensitive   = true
}

variable "profile" {
  description = "Profile do SSO"
  type        = string
}

variable "region" {
  description = "Região das instancias"
  type        = string
}

variable "db_passwd" {
  description = "Senha do Banco de Dados"
  type        = string
  sensitive   = true
}

variable "ami-instance" {
  description = "AMI das instancias EC2"
  type        = string
  sensitive   = true
}

variable "type-instance-ec2" {
  default = "t2.micro"
}
