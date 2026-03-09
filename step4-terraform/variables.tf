variable "region" {
  description = "AWS region to deploy resources"
  default     = "us-east-1"
}

variable "key_name" {
  description = "Name of the SSH key pair"
}

variable "bastion_cidr" {
  description = "CIDR block of Bastion host to allow SSH access"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "List of public subnet CIDRs"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t3.medium"
}

variable "nexus_ami_id" {
  description = "AMI ID for Nexus server"
}