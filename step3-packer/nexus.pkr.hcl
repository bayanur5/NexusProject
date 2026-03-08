packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }

    ansible = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "t2.medium"
}

source "amazon-ebs" "nexus-build" {

  region        = var.aws_region
  instance_type = var.instance_type

  ssh_username = "ubuntu"

  ami_name = "nexus-ami-{{timestamp}}"

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }

    owners      = ["099720109477"]
    most_recent = true
  }

}

build {

  name = "nexus-ami-build"

  sources = [
    "source.amazon-ebs.nexus-build"
  ]

  provisioner "ansible" {
    playbook_file = "step2-ansible/install_nexus.yml"
    user          = "ubuntu"
  }

}