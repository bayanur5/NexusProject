resource "aws_instance" "nexus_server" {
  ami                         = var.nexus_ami_id
  instance_type                = var.instance_type
  subnet_id                    = aws_subnet.public[0].id
  key_name                     = var.key_name
  vpc_security_group_ids       = [aws_security_group.nexus_sg.id]  # <- use ID
  associate_public_ip_address  = true

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = local.tags
}