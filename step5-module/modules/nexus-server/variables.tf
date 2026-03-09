variable "vpc_id" {
  description = "VPC ID where Nexus will be deployed"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "ami_id" {
  description = "Nexus AMI ID"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "key_name" {
  description = "SSH key name for EC2 access"
  type        = string
}

variable "security_group_ids" {
  description = "Security group IDs for Nexus server"
  type        = list(string)
}