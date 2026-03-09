# AWS Region
variable "region" {
  description = "AWS region to deploy Nexus"
  type        = string
  default     = "us-east-1"
}

# Nexus AMI ID (from Packer build)
variable "ami_id" {
  description = "AMI ID for Nexus EC2 instance"
  type        = string
}

# EC2 instance type
variable "instance_type" {
  description = "EC2 instance type for Nexus"
  type        = string
  default     = "t2.small"
}

# VPC where Nexus will be launched
variable "vpc_id" {
  description = "VPC ID to launch Nexus in"
  type        = string
}

# Public subnets for EC2 instance
variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

# SSH key name for connecting to EC2
variable "key_name" {
  description = "Name of the SSH key for EC2 instance"
  type        = string
}

# Your public IP for SSH access
variable "my_ip" {
  description = "Your laptop public IP with /32 suffix for SSH access"
  type        = string
}