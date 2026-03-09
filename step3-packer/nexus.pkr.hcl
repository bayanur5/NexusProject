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
  region                  = "us-east-1"
  instance_type            = "t2.micro"
  ssh_username             = "ubuntu"
  ami_name                 = "nexus-ami-{{timestamp}}"
  associate_public_ip_address = true

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["099720109477"]
    most_recent = true
  }
}

build {
  name    = "nexus-ami-build"
  sources = ["source.amazon-ebs.nexus-build"]

  provisioner "ansible" {
    playbook_file = "../step2-ansible/install_nexus.yml"
  }

  post-processor "manifest" {
    output = "manifest.json"
  }
}