# Find the newest Nexus AMI created by Packer
data "aws_ami" "nexus" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["nexus-ami-*"]
  }
}

# Get the public IP of the machine running Terraform
data "http" "my_ip" {
  url = "https://ifconfig.me/ip"
}

# Create security group for Nexus server
resource "aws_security_group" "nexus_sg" {
  name        = "nexus-sg"
  description = "Allow SSH and Nexus access"

  # Allow SSH access only from your current IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"]
  }

  # Allow web access to Nexus UI
  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow the instance to make outbound connections
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Launch EC2 instance using the Nexus AMI
resource "aws_instance" "nexus" {
  ami           = data.aws_ami.nexus.id
  instance_type = "t2.medium"
  key_name      = var.key_name

  # Attach the security group to the instance
  vpc_security_group_ids = [
    aws_security_group.nexus_sg.id
  ]

  # Add a name tag to the instance
  tags = {
    Name = "nexus-server"
  }
}