packer {
  required_version = ">= 1.8.0"

  required_plugins {
    amazon = {
      version = ">= 1.8.0"
      source  = "github.com/hashicorp/amazon"
    }
    ansible = {
      version = ">= 1.1.4"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

source "amazon-ebs" "nexus-build" {
  region           = "us-east-1"
  instance_type    = "t3.medium"
  ssh_username     = "ubuntu"
  ami_name         = "nexus-ami-{{timestamp}}"

  source_ami_filter {
    owners      = ["099720109477"] # Canonical Ubuntu account
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
  }
}

build {
  name    = "nexus-build"
  sources = ["source.amazon-ebs.nexus-build"]

  provisioner "ansible" {
    playbook_file   = "../step2-ansible/install_nexus.yml"
    extra_arguments = ["-e", "ansible_python_interpreter=/usr/bin/python3"]
  }

  provisioner "shell" {
    inline = [
      "echo 'Nexus AMI build complete!'"
    ]
  }
}