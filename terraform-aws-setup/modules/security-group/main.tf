resource "aws_security_group" "private_sg" {
  name        = "private-security-group"
  description = "Allow traffic within VPC"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "private_sg_id" {
  value = aws_security_group.private_sg.id
}
