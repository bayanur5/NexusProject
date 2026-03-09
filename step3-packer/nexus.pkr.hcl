# nexus.pkr.hcl

source "amazon-ebs" "nexus" {
  region           = "us-east-1"
  instance_type    = "t2.micro"
  ami_name         = "nexus-ami-{{timestamp}}"

  # Select latest Ubuntu Jammy AMI
  source_ami_filter {
    owners      = ["099720109477"]
    filters {
      name = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
    }
    most_recent = true
  }

  ssh_username = "ubuntu"
}

build {
  sources = ["source.amazon-ebs.nexus"]

  provisioner "shell" {
    inline = [
      # Update and install prerequisites
      "sudo apt-get update -y",
      "sudo apt-get install -y openjdk-11-jdk wget",

      # Download and extract Nexus
      "wget -O /tmp/nexus.tar.gz https://download.sonatype.com/nexus/3/latest-unix.tar.gz",
      "sudo tar -xvzf /tmp/nexus.tar.gz -C /opt",
      "sudo mv /opt/nexus-* /opt/nexus-3.90.1-01",

      # Create nexus user and set permissions
      "sudo useradd -r -m -d /opt/nexus-3.90.1-01 -s /bin/bash nexus",
      "sudo chown -R nexus:nexus /opt/nexus-3.90.1-01",
      "sudo mkdir -p /opt/sonatype-work",
      "sudo chown -R nexus:nexus /opt/sonatype-work",

      # Create systemd service
      "sudo bash -c 'cat <<EOF > /etc/systemd/system/nexus.service\n[Unit]\nDescription=Nexus Repository Manager\nAfter=network.target\n[Service]\nType=forking\nUser=nexus\nExecStart=/opt/nexus-3.90.1-01/bin/nexus start\nExecStop=/opt/nexus-3.90.1-01/bin/nexus stop\nRestart=on-abort\n[Install]\nWantedBy=multi-user.target\nEOF'",

      # Enable and start service
      "sudo systemctl daemon-reload",
      "sudo systemctl enable nexus",
      "sudo systemctl start nexus",

      # Optional check
      "sudo systemctl status nexus --no-pager"
    ]
  }

  provisioner "shell" {
    inline = [
      "echo 'Nexus setup complete.'"
    ]
  }
}

post-processor "manifest" {}