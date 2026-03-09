packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/amazon"
    }
    ansible = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

source "amazon-ebs" "nexus-build" {
  region        = "us-east-1"
  instance_type = "t3.medium"
  ssh_username  = "ubuntu"
  ami_name      = "nexus-ami-{{timestamp}}"

  # Pick the latest Ubuntu 20.04 AMI
  most_recent = true

  filters = {
    name                = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
    virtualization-type = "hvm"
  }

  owners = ["099720109477"] # Canonical
}

build {
  sources = ["source.amazon-ebs.nexus-build"]

  provisioner "ansible" {
    playbook_file = "../step2-ansible/install_nexus.yml"
  }
}
