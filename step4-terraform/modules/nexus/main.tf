provider "aws" {
  region = var.region
}

# Create VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags       = merge(local.common_tags, { Name = "nexus-vpc" })
}

# Public subnets
resource "aws_subnet" "public" {
  for_each = toset(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  map_public_ip_on_launch = true
  tags              = merge(local.common_tags, { Name = "nexus-public-${each.value}" })
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

# Security Group for Nexus
resource "aws_security_group" "nexus_sg" {
  name   = "nexus-sg"
  vpc_id = aws_vpc.main.id

  # SSH from Bastion SG
  ingress {
    description     = "SSH from Bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [var.bastion_sg_id]
  }

  # Nexus Web UI
  ingress {
    description = "Nexus UI"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "nexus-sg" })
}

# EC2 instance using AMI data source
data "aws_ami" "nexus_ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["nexus-ami-*"]
  }
}

resource "aws_instance" "nexus" {
  ami                    = data.aws_ami.nexus_ami.id
  instance_type          = var.instance_type
  subnet_id              = values(aws_subnet.public)[0].id
  vpc_security_group_ids = [aws_security_group.nexus_sg.id]
  key_name               = var.key_name
  associate_public_ip_address = true
  tags                   = merge(local.common_tags, { Name = "nexus-instance" })
}