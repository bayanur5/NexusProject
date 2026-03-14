provider "aws" {
  region = var.region
}

module "nexus" {
  source = "../modules/nexus"

  region              = var.region
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  instance_type       = var.instance_type
  key_name            = var.key_name

  # Use existing Bastion SG
  bastion_sg_id       = "sg-0dee6fb7195b27fbf"
}