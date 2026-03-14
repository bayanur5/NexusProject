output "nexus_public_ip" {
  value = module.nexus.nexus_ec2_public_ip
}

output "nexus_private_ip" {
  value = module.nexus.nexus_ec2_private_ip
}