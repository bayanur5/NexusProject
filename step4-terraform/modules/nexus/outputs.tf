output "nexus_public_ip" {
  description = "Public IP of Nexus instance"
  value       = aws_instance.nexus.public_ip
}

output "nexus_private_ip" {
  description = "Private IP of Nexus instance"
  value       = aws_instance.nexus.private_ip
}