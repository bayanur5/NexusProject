resource "aws_instance" "nexus" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_ids[0]
  key_name               = var.key_name
  vpc_security_group_ids = var.security_group_ids
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              sleep 30
              NEXUS_DIR=$(ls /opt | grep nexus-3)
              cd /opt/$NEXUS_DIR/bin
              sudo ./nexus start
              EOF

  tags = {
    Name        = "nexus-server"
    Environment = "dev"
    Team        = "Project"
  }
}