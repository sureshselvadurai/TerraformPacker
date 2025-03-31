provider "aws" {
  region = "us-east-1"
}

# Define AMI IDs (replace with the actual AMI IDs created using Packer)
variable "ubuntu_ami" {
  default = "ami-039d29d91ce481686"  # Replace with your Ubuntu AMI ID
}

variable "amazon_linux_ami" {
  default = "ami-0ee62b2996a1d66cb"  # Replace with your Amazon Linux AMI ID
}

variable "instance_type" {
  default = "t2.micro"
}

# Uploading SSH Public Key to create the Key Pair
resource "aws_key_pair" "custom_key_pair" {
  key_name   = "devops_a10"  # Replace with the desired name for your key pair
  public_key = file("/Users/sureshrajaselvadurai/.ssh/devops_a10.pub")  # Path to your local .pub key file
}

# Security Group for SSH Access
resource "aws_security_group" "ssh_access" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create 3 Ubuntu EC2 instances
resource "aws_instance" "ubuntu_instances" {
  count         = 3
  ami           = var.ubuntu_ami
  instance_type = var.instance_type
  key_name      = aws_key_pair.custom_key_pair.key_name  # Reference the created key pair

  security_groups = [aws_security_group.ssh_access.name]

  tags = {
    Name = "Ubuntu-Instance-${count.index + 1}"
    OS   = "ubuntu"
  }
}

# Create 3 Amazon Linux EC2 instances
resource "aws_instance" "amazon_linux_instances" {
  count         = 3
  ami           = var.amazon_linux_ami
  instance_type = var.instance_type
  key_name      = aws_key_pair.custom_key_pair.key_name  # Reference the created key pair

  security_groups = [aws_security_group.ssh_access.name]

  tags = {
    Name = "Amazon-Linux-Instance-${count.index + 1}"
    OS   = "amazon"
  }
}

# Create Ansible Controller EC2 instance (using Ubuntu AMI)
resource "aws_instance" "ansible_controller" {
  ami           = var.ubuntu_ami  # Using Ubuntu for Ansible Controller
  instance_type = var.instance_type
  key_name      = aws_key_pair.custom_key_pair.key_name  # Reference the created key pair
  security_groups = [aws_security_group.ssh_access.name]

  tags = {
    Name = "Ansible-Controller"
    Role = "ansible"
  }
}

output "ubuntu_instance_ips" {
  value = [for instance in aws_instance.ubuntu_instances : instance.public_ip]
  description = "Public IPs of Ubuntu EC2 instances"
}

output "amazon_linux_instance_ips" {
  value = [for instance in aws_instance.amazon_linux_instances : instance.public_ip]
  description = "Public IPs of Amazon Linux EC2 instances"
}

output "ansible_controller_ip" {
  value = aws_instance.ansible_controller.public_ip
  description = "Public IP of the Ansible Controller"
}
