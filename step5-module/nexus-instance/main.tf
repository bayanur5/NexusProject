# Automatically get the latest Ubuntu 22.04 LTS AMI in us-east-1
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]  # Official Canonical owner
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_instance" "nexus" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_name

  tags = {
    Name = "nexus-instance"
  }
}