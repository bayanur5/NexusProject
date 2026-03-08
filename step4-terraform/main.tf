module "nexus_instance" {
  source      = "../step5-module/nexus-instance"
  region      = var.region
  ami_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
}