provider "aws" {
  region = var.region
}

# Security Group
resource "aws_security_group" "nexus_sg" {
  name        = "nexus-sg"
  description = "Allow SSH and Nexus HTTP"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
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
}

# Nexus EC2 instance
resource "aws_instance" "nexus" {
  ami                      = var.ami_id
  instance_type             = var.instance_type
  subnet_id                 = var.public_subnet_ids[0]
  key_name                  = var.key_name
  vpc_security_group_ids    = [aws_security_group.nexus_sg.id]
  associate_public_ip_address = true

  tags = {
    Name    = "nexus-server"
    Project = "NexusTest"
  }
}

output "nexus_public_ip" {
  value = aws_instance.nexus.public_ip
}