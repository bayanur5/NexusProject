// ===========================
// Packer template for Nexus
// Compatible with older Packer versions (no launch_block_device)
// ===========================

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
  instance_type = "t3.medium"          // Temporary build instance
  ssh_username  = "ubuntu"
  ami_name      = "nexus-ami-{{timestamp}}"

  tags = {
    Name    = "nexus-ami"
    Project = "nexus"
  }

  // Base Ubuntu 22.04 image
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["099720109477"]   // Canonical
    most_recent = true
  }

  // ✅ Removed launch_block_device to support older Packer versions
}

build {
  sources = ["source.amazon-ebs.nexus-build"]

  // Provision with Ansible
  provisioner "ansible" {
    playbook_file = "/home/ubuntu/NexusProject/step2-ansible/install_nexus.yml"
  }
}