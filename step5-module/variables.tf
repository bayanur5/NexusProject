region             = "us-east-1"
ami_id             = "ami-0002d342352f6f232"   # replace with your Packer-built AMI
instance_type      = "t2.small"
vpc_id             = "vpc-0abc1234def567890"  # replace with your VPC
public_subnet_ids  = ["subnet-0abcd1234ef567890"] # replace with your public subnet
key_name           = "my-laptop-key"          # your SSH key name in AWS
my_ip              = "97.242.60.240/32"      # your current public IP