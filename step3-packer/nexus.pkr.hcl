source "amazon-ebs" "nexus" {
  region         = "us-east-1"
  instance_type  = "t2.micro"
  ssh_username   = "ubuntu"
  ami_name       = "nexus-ami-{{timestamp}}"

  source_ami_filter {
    owners      = ["099720109477"] # Official Ubuntu AMIs
    filters {
      name = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
    }
    most_recent = true
  }
}

build {
  sources = ["source.amazon-ebs.nexus"]

  provisioner "shell" {
    inline = [
      # Install prerequisites
      "sudo apt-get update -y",
      "sudo apt-get install -y openjdk-11-jdk wget netcat",

      # Download and extract Nexus
      "wget -O /tmp/nexus.tar.gz https://download.sonatype.com/nexus/3/latest-unix.tar.gz",
      "sudo tar -xvzf /tmp/nexus.tar.gz -C /opt",
      "sudo mv /opt/nexus-* /opt/nexus-3.90.1-01",

      # Create nexus user and set permissions
      "sudo useradd -r -m -d /opt/nexus-3.90.1-01 -s /bin/bash nexus",
      "sudo chown -R nexus:nexus /opt/nexus-3.90.1-01",

      # Create systemd service with correct path
      "sudo bash -c 'cat <<EOF > /etc/systemd/system/nexus.service\n[Unit]\nDescription=Nexus Repository Manager\nAfter=network.target\n[Service]\nType=forking\nUser=nexus\nExecStart=/opt/nexus-3.90.1-01/bin/nexus start\nExecStop=/opt/nexus-3.90.1-01/bin/nexus stop\nRestart=on-failure\n[Install]\nWantedBy=multi-user.target\nEOF'",

      # Enable and start Nexus
      "sudo systemctl daemon-reload",
      "sudo systemctl enable nexus",
      "sudo systemctl start nexus"
    ]
  }

  provisioner "shell" {
    inline = ["echo 'Nexus setup complete and will start automatically on boot.'"]
  }
}

post-processor "manifest" {}