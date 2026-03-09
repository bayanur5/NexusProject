provider "aws" {
  region = "us-east-1"
}

locals {
  instance_type = "t2.small"
  tags = {
    Project = "NexusTest"
    Owner   = "Me"
  }
}

# Latest Nexus AMI from Packer
data "aws_ami" "latest_nexus" {
  most_recent = true
  owners      = ["self"]
  filter {
    name   = "name"
    values = ["nexus-ami*"]
  }
}

# Create a new VPC (automated)
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.tags, { Name = "nexus-vpc" })
}

# Create public subnet(s)
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  map_public_ip_on_launch = true

  tags = merge(local.tags, { Name = "nexus-public-${count.index}" })
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = merge(local.tags, { Name = "igw" })
}

# Route Table for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(local.tags, { Name = "public-rt" })
}

resource "aws_route_table_association" "public_assoc" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Security Group for Nexus
resource "aws_security_group" "nexus_sg" {
  name        = "nexus-sg"
  description = "Allow SSH and Nexus HTTP"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]   # SSH open to all for testing; restrict for production
  }

  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]   # Nexus web access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

# Launch Nexus instance via your module
module "nexus_test" {
  source = "../step5-module/modules/nexus-server"

  ami_id             = data.aws_ami.latest_nexus.id
  instance_type      = local.instance_type
  vpc_id             = aws_vpc.main.id
  public_subnet_ids  = aws_subnet.public[*].id
  security_group_ids = [aws_security_group.nexus_sg.id]

  key_name = "my-laptop-key"  # your SSH key
}

# Output
output "nexus_public_ip" {
  value = module.nexus_test.nexus_public_ip
}