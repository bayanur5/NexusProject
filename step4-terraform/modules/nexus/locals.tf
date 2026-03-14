locals {
  common_tags = {
    Environment = var.region
    Team        = "Project"
    Project     = "nexus-application"
  }
}