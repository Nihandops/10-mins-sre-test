terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # updated provider version
    }
  }
}

provider "aws" {
  region = var.region
}

# Variables
variable "region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ami" {
  type    = string
  default = "ami-0c02fb55956c7d316" # valid Amazon Linux 2 AMI in us-east-1
}

variable "subnet_id" {
  type = string
}

# Security Group (restricted)
resource "aws_security_group" "sg" {
  name        = "restricted-sg"
  description = "Allow SSH only"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/32"] #
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Module
module "ec2_module" {
  source = "./modules/ec2"

  instance_type = var.instance_type
  ami           = var.ami
  subnet_id     = var.subnet_id
  security_group_ids = [aws_security_group.sg.id]
}

# Output
output "ec2_ip" {
  value = module.ec2_module.public_ip
}
