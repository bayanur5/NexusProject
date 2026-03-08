variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID to launch"
  type        = string
}

variable "key_name" {
  description = "SSH key name"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.medium"
}