vpc_cidr_block            = "10.0.0.0/16"
public_subnet_cidr_block  = "10.0.1.0/24"
private_subnet_cidr_block = "10.0.2.0/24"
availability_zone         = "us-east-1"

ami_id    = "ami-linux-docker-v2"
instance_type = "t2.micro"
allowed_ip = "104.244.24.68/32"

