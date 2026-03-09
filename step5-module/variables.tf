variable "region" {
  description = "AWS region to deploy Nexus"
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "VPC ID for the Nexus instance"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.small"
}

variable "key_name" {
  description = "SSH key name"
  type        = string
}

variable "my_ip" {
  description = "Your public IP for SSH access"
  type        = string
}

variable "private_key_path" {
  description = "Path to your private SSH key"
  type        = string
}