# Output the EC2 instance ID
output "instance_id" {
  value = aws_instance.nexus.id
}

# Output the public IP of the Nexus server
output "public_ip" {
  value = aws_instance.nexus.public_ip
}