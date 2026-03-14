data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "nexus" {
  most_recent = true
  owners      = ["self"] # Your AWS account where Packer AMI was created
  filter {
    name   = "name"
    values = ["nexus-ami-*"]
  }
}