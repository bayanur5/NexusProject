provider "aws" {
  region = var.region
}

# Fetch the latest Nexus AMI created by Packer
data "aws_ami" "nexus_latest" {
  most_recent = true
  owners      = ["self"]  # your AWS account
  filter {
    name   = "name"
    values = ["nexus-ami-*"]
  }
}

# Security Group for Nexus
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

# Nexus EC2 Instance
resource "aws_instance" "nexus" {
  ami                         = data.aws_ami.nexus_latest.id
  instance_type                = var.instance_type
  subnet_id                    = var.public_subnet_ids[0]
  key_name                     = var.key_name
  vpc_security_group_ids       = [aws_security_group.nexus_sg.id]
  associate_public_ip_address  = true

  tags = {
    Name    = "nexus-server"
    Project = "NexusTest"
  }
}

# Optional: wait until Nexus responds on port 8081
resource "null_resource" "wait_for_nexus" {
  depends_on = [aws_instance.nexus]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = aws_instance.nexus.public_ip
      user        = "ubuntu"
      private_key = file(var.private_key_path)
    }

    inline = [
      "echo 'Waiting for Nexus to start...'",
      "for i in $(seq 1 30); do",
      "  if nc -zv 127.0.0.1 8081; then",
      "    echo 'Nexus is up!'",
      "    exit 0",
      "  fi",
      "  sleep 10",
      "done",
      "echo 'Nexus did not start in time!'",
      "exit 1"
    ]
  }
}