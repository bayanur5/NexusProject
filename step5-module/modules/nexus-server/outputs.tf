output "nexus_public_ip" {
  description = "Public IP of Nexus server"
  value       = aws_instance.nexus.public_ip
}