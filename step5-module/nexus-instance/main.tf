provider "aws" {
  region = var.region
}

resource "aws_security_group" "nexus_sg" {
  name        = "nexus-sg"
  description = "Allow access to Nexus"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidrs
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nexus-sg"
  }
}

resource "aws_instance" "nexus" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = var.subnet_id
  security_groups = [aws_security_group.nexus_sg.name]

  tags = {
    Name = "nexus-instance"
  }
}