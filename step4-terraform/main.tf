provider "aws" {
  region = var.region
}

module "nexus_instance" {
  source       = "../step5-module/nexus-instance"
  ami_id       = var.ami_id
  key_name     = var.key_name
  instance_type = var.instance_type
}