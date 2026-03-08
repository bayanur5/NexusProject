packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1.8"
    }
  }
}

variable "region" {
  default = "us-east-1"
}

source "amazon-ebs" "nexus-build" {
  region        = var.region
  instance_type = "t2.medium"
  ssh_username  = "ubuntu"

  ami_name = "nexus-ami-{{timestamp}}"

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }

    most_recent = true
    owners      = ["099720109477"]
  }
}

build {
  name = "nexus-ami-build"

  sources = [
    "source.amazon-ebs.nexus-build"
  ]

  provisioner "ansible" {
    playbook_file = "../step2-ansible/install_nexus.yml"
  }
}