locals {
  tags = {
    Name        = "my-app"
    Environment = var.region
    Team        = "Project=Nexus"
  }
}