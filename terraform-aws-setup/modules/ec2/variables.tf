variable "ami_name" {
  description = "AMI name filter for fetching the AMI"
  type        = string
  default     = "ami-linux-docker-v2"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_id" {
  description = "Public Subnet ID"
  type        = string
}

variable "private_subnet_id" {
  description = "Private Subnet ID"
  type        = string
}

variable "allowed_ip" {
  description = "Your IP address to allow SSH access"
  type        = string
}
