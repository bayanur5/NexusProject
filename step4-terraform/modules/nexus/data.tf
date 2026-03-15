# Get available AZs in the region
data "aws_availability_zones" "available" {
  state = "available"
}

# Find the latest Nexus AMI created by Packer
data "aws_ami" "nexus" {
  most_recent = true
  owners      = ["self"]   # Your AWS account

  filter {
    name   = "name"
    values = ["nexus-ami-*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}