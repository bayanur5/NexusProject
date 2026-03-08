terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# Security Group for Nexus
resource "aws_security_group" "nexus_sg" {
  name        = "nexus-security-group"
  description = "Allow SSH and Nexus access"

  ingress {
    description = "SSH Access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Nexus Web UI"
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

  tags = {
    Name = "nexus-security-group"
  }
}

# EC2 Instance using AMI built by Packer
resource "aws_instance" "nexus_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.nexus_sg.id]

  tags = {
    Name = "nexus-server"
  }
}

# Output EC2 Public IP
output "nexus_public_ip" {
  description = "Public IP of Nexus Server"
  value       = aws_instance.nexus_server.public_ip
}

# Output Nexus URL
output "nexus_url" {
  description = "Nexus UI URL"
  value       = "http://${aws_instance.nexus_server.public_ip}:8081"
}