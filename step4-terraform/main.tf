provider "aws" {
  region = var.region
}

module "nexus_instance" {
  source        = "../step5-module/nexus-instance"
  key_name      = var.key_name
  instance_type = var.instance_type
}