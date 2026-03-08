provider "aws" {
  region = var.region
}

resource "aws_instance" "nexus" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  tags = {
    Name = "Nexus-Instance"
  }
}