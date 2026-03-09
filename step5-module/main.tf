module "nexus_server" {
  source             = "./modules/nexus-server"
  vpc_id             = var.vpc_id
  public_subnet_ids  = var.public_subnet_ids
  ami_id             = var.ami_id
  instance_type      = var.instance_type
  key_name           = var.key_name
  security_group_ids = var.security_group_ids
}