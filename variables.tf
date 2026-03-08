variable "region" {
  description = "AWS region"
  type        = string
}

variable "ami_id" {
  description = "AMI built by Packer"
  type        = string
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}