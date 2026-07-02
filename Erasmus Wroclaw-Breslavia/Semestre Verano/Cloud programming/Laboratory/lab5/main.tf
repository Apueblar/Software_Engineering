terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.1"
    }
  }
  required_version = ">= 1.2.0"
}

// Provider
provider "aws" {
  region = "us-east-1"
}

// Virtual Private Cloud creation
module "my_vpc" {
  source         = "terraform-aws-modules/vpc/aws"
  name           = "my-vpc-APR"
  cidr           = "10.0.0.0/16"
  azs            = ["us-east-1b"]
  public_subnets = ["10.0.101.0/24"]
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

// Security groups
resource "aws_security_group" "allow_ssh_http" {
  name        = "allow_ssh_http"
  description = "Allow SSH and HTTP inbound traffic and all outbound traffic"
  vpc_id      = module.my_vpc.vpc_id
  tags = {
    Name = "allow-ssh-http"
  }
}

// Security rules
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_ssh_http.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # all ports
}
resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.allow_ssh_http.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 8080
  to_port           = 8081
}
resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.allow_ssh_http.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

// Create EC2 instance
resource "aws_instance" "tf-web-server" {
  ami                         = "ami-084568db4383264d4"
  instance_type               = "t2.micro"
  key_name                    = "vockey"
  subnet_id                   = module.my_vpc.public_subnets[0]
  associate_public_ip_address = "true"
  vpc_security_group_ids      = [aws_security_group.allow_ssh_http.id]
  user_data                   = file("${path.module}/userdata.sh")
  user_data_replace_on_change = true
  tags = {
    Name = "My-Terraform-Web-Server"
  }
}
