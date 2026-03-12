# Get latest Nexus AMI created by Packer
data "aws_ami" "nexus" {
  most_recent = true

  filter {
    name   = "name"
    values = ["nexus-ami-*"]
  }

  owners = ["self"]
}

resource "aws_instance" "nexus" {

  ami           = data.aws_ami.nexus.id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public[0].id
  key_name      = var.key_name

  vpc_security_group_ids = [
    aws_security_group.nexus_sg.id
  ]

  associate_public_ip_address = true

  tags = merge(local.tags, {
    Name = "nexus-ec2"
  })
}