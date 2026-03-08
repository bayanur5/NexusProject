variable "region" {
  type        = string
  description = "AWS region"
}

variable "ami_id" {
  type        = string
  description = "AMI ID for Nexus instance"
}

variable "instance_type" {
  type        = string
  default     = "t2.medium"
  description = "EC2 instance type"
}

variable "key_name" {
  type        = string
  description = "Name of the SSH key pair"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID where to launch the instance"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for security group"
}

variable "allowed_cidrs" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "CIDR blocks allowed to access Nexus"
}