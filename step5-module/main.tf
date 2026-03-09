provider "aws" {
  region = var.region
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
  ami                         = var.ami_id
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

# Optional: Wait until Nexus is up on port 8081
resource "null_resource" "wait_for_nexus" {
  depends_on = [aws_instance.nexus]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = aws_instance.nexus.public_ip
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
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