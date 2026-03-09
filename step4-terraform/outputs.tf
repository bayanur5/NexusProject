output "nexus_ip" {
  value       = aws_instance.nexus_server.public_ip
  description = "Public IP of the Nexus server"
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnets" {
  value = aws_subnet.public[*].id
}