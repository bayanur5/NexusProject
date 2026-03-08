resource "aws_instance" "nexus" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  tags = {
    Name = "NexusInstance"
  }
}

output "instance_id" {
  value = aws_instance.nexus.id
}