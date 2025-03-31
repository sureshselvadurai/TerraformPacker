# 🚀 Packer AMI Build Setup Guide

## 📄 Prerequisites

### Install Packer

For MacOs, install it directly:

```bash
brew tap hashicorp/tap
brew install hashicorp/tap/packer
```

### Generate SSH Key
```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/custom_aws_key_devops
```

```bash
(.venv) sureshrajaselvadurai@Sureshs-MacBook-Air terraform-aws-setup % eval "$(ssh-agent -s)"                                             
ssh-add /Users/sureshrajaselvadurai/.ssh/devops_a10
Agent pid 29756
Enter passphrase for /Users/sureshrajaselvadurai/.ssh/devops_a10: 
```
### 📝 `[amazon-linux-docker.json](packer-ami/amazon-linux-docker.json)variables.json`
### 📝  [ubuntu-docker.json](packer-ami/ubuntu-docker.json)
Add the ssh path

```json
    {
      "type": "file",
      "source": "/Users/sureshrajaselvadurai/.ssh/devops_a10.pub",
      "destination": "/tmp/custom_aws_key_devops.pub"
    },
```
### 🚀 Run Packer Build
```bash
packer build amazon-linux-docker.json
```

# Terraform AWS Setup

This project provisions the following AWS resources:

- A VPC with public and private subnets.
- An internet gateway for external access.
- One Bastion Host in the public subnet (only accessible from a specific IP).
- Six EC2 instances in the private subnet (using an AMI created via Packer).
- Security groups for Bastion and EC2 instances.

## 🛠️ Requirements

- Terraform >= 1.x
- AWS CLI configured with valid credentials

## 📜 Steps to Deploy

1. [main.tf](terraform-aws-setup/main.tf)
Update with the image IDs and the local rsa

```yaml
# Define AMI IDs (replace with the actual AMI IDs created using Packer)
variable "ubuntu_ami" {
  default = "ami-039d29d91ce481686"  # Replace with your Ubuntu AMI ID
}

variable "amazon_linux_ami" {
  default = "ami-0ee62b2996a1d66cb"  # Replace with your Amazon Linux AMI ID
}

# Uploading SSH Public Key to create the Key Pair
resource "aws_key_pair" "custom_key_pair" {
  key_name   = "devops_a10"  # Replace with the desired name for your key pair
  public_key = file("/Users/sureshrajaselvadurai/.ssh/devops_a10.pub")  # Path to your local .pub key file
}
```

- Initialize Terraform:
```bash
terraform init
```

- Plan/review Terraform:
```bash
terraform plan
```

- Apply Terraform:
```bash
terraform plan
```

4️⃣ Retrieve Terraform Outputs
Terraform will output the instance IPs. Note these for updating the Ansible inventory.
```aiignore
amazon_linux_instance_ips = [
  "3.89.163.3",
  "3.85.104.172",
  "18.208.142.202",
]
ansible_controller_ip = "54.226.86.75"
ubuntu_instance_ips = [
  "54.91.39.251",
  "54.82.54.188",
  "50.17.16.37",
]

```
⚙️ Ansible Setup
Update :[inventory.ini](terraform-aws-setup/inventory.ini)

```aiignore
[ubuntu]
UBUNTU_IP_1 ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/custom_aws_key_devops
UBUNTU_IP_2 ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/custom_aws_key_devops
UBUNTU_IP_3 ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/custom_aws_key_devops

[amazon]
AMAZON_IP_1 ansible_user=ec2-user ansible_ssh_private_key_file=~/.ssh/custom_aws_key_devops
AMAZON_IP_2 ansible_user=ec2-user ansible_ssh_private_key_file=~/.ssh/custom_aws_key_devops
AMAZON_IP_3 ansible_user=ec2-user ansible_ssh_private_key_file=~/.ssh/custom_aws_key_devops

```

🚀 Running the Ansible Playbook
Execute the following command:
```aiignore
ansible-playbook -i inventory.ini playbook.yaml
```

Documentation report: [Assignment10_Documented_Report.pdf](reference_docs/Assignment10_Documented_Report.pdf)