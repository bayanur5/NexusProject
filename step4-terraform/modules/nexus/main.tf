provider "aws" {
  region = var.region
}

locals {
  common_tags = {
    Project     = "nexus-application"
    Team        = "Project"
    Environment = var.region
  }
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags       = merge(local.common_tags, { Name = "nexus-vpc" })
}

# Public subnets
resource "aws_subnet" "public" {
  for_each = toset(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, { Name = "nexus-public-${each.value}" })
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = merge(local.common_tags, { Name = "nexus-igw" })
}

# Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(local.common_tags, { Name = "nexus-public-rt" })
}

# Associate route table with public subnets
resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Security Group
resource "aws_security_group" "nexus_sg" {
  name   = "nexus-sg"
  vpc_id = aws_vpc.main.id

  # SSH access
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Nexus UI
  ingress {
    description = "Nexus UI"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "nexus-sg" })
}

# AMI data source
data "aws_ami" "nexus_ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["nexus-ami-*"]
  }
}

# Nexus EC2 instance
resource "aws_instance" "nexus" {
  ami                         = data.aws_ami.nexus_ami.id
  instance_type               = var.instance_type
  subnet_id                   = values(aws_subnet.public)[0].id
  vpc_security_group_ids      = [aws_security_group.nexus_sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  tags = merge(local.common_tags, { Name = "nexus-instance" })
}