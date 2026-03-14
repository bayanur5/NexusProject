// nexus.pkr.hcl
packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "t3.medium"
}

source "amazon-ebs" "nexus-build" {
  region        = var.aws_region
  instance_type = var.instance_type
  ssh_username  = "ubuntu"

  // Timestamped AMI name
  ami_name = "nexus-ami-${formatdate("20060102-150405", timestamp())}"

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["099720109477"]
    most_recent = true
  }

  associate_public_ip_address = true
}

build {
  name    = "nexus-ami-build"
  sources = ["source.amazon-ebs.nexus-build"]

  // Install Python 3 and Ansible inside the VM
  provisioner "shell" {
    inline = [
      "sudo rm -rf /var/lib/apt/lists/*",
      "sudo apt-get clean",
      "sudo apt-get update -o Acquire::AllowInsecureRepositories=true -y",
      "sudo apt-get install -y python3 python3-pip software-properties-common gnupg2 curl",
      "sudo add-apt-repository --yes --update ppa:ansible/ansible",
      "sudo apt-get update -y",
      "sudo apt-get install -y ansible"
    ]
  }

  // Run your Nexus playbook locally inside the VM
  provisioner "ansible-local" {
    playbook_file   = "../step2-ansible/nexus-install.yml"
    extra_arguments = ["--extra-vars", "ansible_python_interpreter=/usr/bin/python3"]
  }
}