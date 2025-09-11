# ----------------- VPC ------------------

resource "aws_vpc" "vpc-wordpress" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "vpc-wordpress"
  }
}

# ---------- Subnets us-east-1a ----------

resource "aws_subnet" "publica1" {
  vpc_id                  = aws_vpc.vpc-wordpress.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Publica-01"
  }
}

resource "aws_subnet" "privada1" {
  vpc_id                  = aws_vpc.vpc-wordpress.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "Privada-01"
  }
}

# ---------- Subnets us-east-1b ----------

resource "aws_subnet" "publica2" {
  vpc_id                  = aws_vpc.vpc-wordpress.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "Publica-02"
  }
}

resource "aws_subnet" "privada2" {
  vpc_id                  = aws_vpc.vpc-wordpress.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = "Privada-02"
  }
}

# -------------- Internet Gateway -------------------

resource "aws_internet_gateway" "GatewayWordpress" {
  vpc_id = aws_vpc.vpc-wordpress.id

  tags = {
    Name = "GatewayWordpress"
  }
}

# -------------- Elastic IPs (um por NAT) -------------------

resource "aws_eip" "nat_a" {
  domain = "vpc"

  tags = {
    Name = "EIP-NAT-1a"
  }
}

resource "aws_eip" "nat_b" {
  domain = "vpc"
  tags = {
    Name = "EIP-NAT-1b"
  }
}

# ------------------------ NATs-----------------------------

resource "aws_nat_gateway" "nat_a" {
  allocation_id = aws_eip.nat_a.id
  subnet_id     = aws_subnet.publica1.id
  depends_on    = [aws_internet_gateway.GatewayWordpress]

  tags = {
    Name = "GatewayNat-1a"
  }
}

resource "aws_nat_gateway" "nat_b" {
  allocation_id = aws_eip.nat_b.id
  subnet_id     = aws_subnet.publica2.id
  depends_on    = [aws_internet_gateway.GatewayWordpress]

  tags = {
    Name = "GatewayNat-1b"
  }
}

# -------------- Route Tables -------------------

resource "aws_route_table" "Publica" {
  vpc_id = aws_vpc.vpc-wordpress.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.GatewayWordpress.id
  }

  tags = {
    Name = "Publica"
  }
}

resource "aws_route_table" "privada1" {
  vpc_id = aws_vpc.vpc-wordpress.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_a.id
  }

  tags = {
    Name = "Privada-01"
  }
}

resource "aws_route_table" "privada2" {
  vpc_id = aws_vpc.vpc-wordpress.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_b.id # NAT da AZ 1b
  }

  tags = {
    Name = "Privada-02"
  }
}

# -------------- Associações-------------------

resource "aws_route_table_association" "assoc_publica1" {
  subnet_id      = aws_subnet.publica1.id
  route_table_id = aws_route_table.Publica.id
}

resource "aws_route_table_association" "assoc_publica2" {
  subnet_id      = aws_subnet.publica2.id
  route_table_id = aws_route_table.Publica.id
}

resource "aws_route_table_association" "assoc_privada1" {
  subnet_id      = aws_subnet.privada1.id
  route_table_id = aws_route_table.privada1.id
}

resource "aws_route_table_association" "assoc_privada2" {
  subnet_id      = aws_subnet.privada2.id
  route_table_id = aws_route_table.privada2.id
}
