source "amazon-ebs" "nexus" {
  region         = "us-east-1"
  instance_type  = "t2.micro"
  ssh_username   = "ubuntu"
  ami_name       = "nexus-ami-{{timestamp}}"

  source_ami_filter {
    owners      = ["099720109477"] # Ubuntu official
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
      "sudo apt-get update -y",
      "sudo apt-get install -y openjdk-11-jdk wget",
      "wget -O /tmp/nexus.tar.gz https://download.sonatype.com/nexus/3/latest-unix.tar.gz",
      "sudo tar -xvzf /tmp/nexus.tar.gz -C /opt",
      "sudo mv /opt/nexus-* /opt/nexus-3.90.1-01",
      "sudo useradd -r -m -d /opt/nexus-3.90.1-01 -s /bin/bash nexus || true",
      "sudo chown -R nexus:nexus /opt/nexus-3.90.1-01",
      "sudo bash -c 'cat <<EOF > /etc/systemd/system/nexus.service\n[Unit]\nDescription=Nexus Repository Manager\nAfter=network.target\n[Service]\nType=forking\nUser=nexus\nExecStart=/opt/nexus-3.90.1-01/bin/nexus start\nExecStop=/opt/nexus-3.90.1-01/bin/nexus stop\nRestart=on-failure\n[Install]\nWantedBy=multi-user.target\nEOF'",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable nexus",
      "sudo systemctl start nexus"
    ]
  }

  provisioner "shell" {
    inline = ["echo 'Nexus AMI build complete.'"]
  }
}

post-processor "manifest" {}