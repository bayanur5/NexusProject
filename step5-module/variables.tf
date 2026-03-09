variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "Nexus AMI ID"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.small"
}

variable "vpc_id" {
  description = "VPC ID for Nexus instance"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "key_name" {
  description = "SSH key name"
  type        = string
}

variable "my_ip" {
  description = "Your public IP for SSH access"
  type        = string
}