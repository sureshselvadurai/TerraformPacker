# Fetch the most recent AMI (Amazon Machine Image)
data "aws_ami" "selected_ami" {
  most_recent = true
  owners      = ["self"]  # Fetch AMIs owned by your account

  filter {
    name   = "name"
    values = [var.ami_name]  # Fetch the specific AMI based on the name variable
  }
}

# Bastion Host Security Group
resource "aws_security_group" "bastion_sg" {
  name        = "bastion-security-group"
  description = "Allow SSH from specific IP"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ip]  # Allow SSH access from your IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
  }
}

# Bastion Host EC2 Instance (Jump Box)
resource "aws_instance" "bastion_host" {
  ami              = data.aws_ami.selected_ami.id  # Use the dynamically fetched AMI ID
  instance_type    = var.instance_type
  subnet_id        = var.public_subnet_id  # Placed in the public subnet
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]  # Use the security group

  tags = {
    Name = "Bastion Host"
  }
}

# Output Bastion Host Public IP for accessing it
output "bastion_public_ip" {
  value = aws_instance.bastion_host.public_ip
}

# Private Instances Security Group
resource "aws_security_group" "private_sg" {
  name        = "private-instance-security-group"
  description = "Allow SSH from Bastion Host only"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.bastion_host.private_ip}/32"]  # Allow SSH from Bastion Host IP only
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
  }
}

# Private EC2 Instances (Private Subnet Instances)
resource "aws_instance" "private_instances" {
  count            = 6
  ami              = data.aws_ami.selected_ami.id
  instance_type    = var.instance_type
  subnet_id        = var.private_subnet_id
  vpc_security_group_ids = [aws_security_group.private_sg.id]  # Correct parameter for security groups in VPC

  tags = {
    Name = "Private Instance ${count.index + 1}"
  }
}

