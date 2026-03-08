# Show instance ID from the module
output "instance_id" {
  value = module.nexus_instance.instance_id
}

# Show Nexus web URL after deployment
output "nexus_url" {
  value = "http://${module.nexus_instance.public_ip}:8081"
}