output "nexus_ec2_public_ip" {
  value = aws_instance.nexus.public_ip
}

output "nexus_ec2_private_ip" {
  value = aws_instance.nexus.private_ip
}