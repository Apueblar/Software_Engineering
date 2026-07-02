terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# ---------------------------------------------
# Variables
# ---------------------------------------------

variable "ami_id" {
  description = "Ubuntu 22.04 LTS AMI for us-east-1"
  type        = string
  default     = "ami-0c7217cdde317cfec"
}

variable "key_name" {
  description = "EC2 key pair name in AWS console"
  type        = string
  default     = "lab08-keypair"
}

variable "github_token" {
  description = "GitHub Personal Access Token (PAT)"
  type        = string
  sensitive   = true
}

variable "github_user" {
  description = "Your GitHub username"
  type        = string
  default     = "pwr-cloudprogramming"
}

variable "github_repo" {
  description = "Name of your private GitHub repository"
  type        = string
  default     = "clprog2026-a04-thu1304"
}

# ---------------------------------------------
# 3.1  Secret – SSH deploy key
# ---------------------------------------------

resource "aws_secretsmanager_secret" "github_key" {
  name                    = "myproject/privkey"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "github_key_value" {
  secret_id     = aws_secretsmanager_secret.github_key.id
  secret_string = file("repo_key")
}

# ---------------------------------------------
# Challenge 1 – Secret: GitHub Access Token
# ---------------------------------------------

resource "aws_secretsmanager_secret" "github_token" {
  name                    = "myproject/github_token"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "github_token_value" {
  secret_id     = aws_secretsmanager_secret.github_token.id
  secret_string = var.github_token
}

# ---------------------------------------------
# Challenge 2 – Read secret back into Terraform
# ---------------------------------------------

data "aws_secretsmanager_secret_version" "github_token_read" {
  secret_id  = aws_secretsmanager_secret.github_token.id
  depends_on = [aws_secretsmanager_secret_version.github_token_value]
}

# ---------------------------------------------
# 3.2  EC2 instance
# Uncomment the user_data line for the exercise you are running.
# ---------------------------------------------

resource "aws_instance" "webserver" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  key_name      = var.key_name

  iam_instance_profile = "LabInstanceProfile"

  # -- Section 3.2 – SSH deploy key -----------------------------------------
  user_data = file("setup.sh")

  # -- Challenge 1 – SSH deploy key + HTTPS clone with token ----------------
  # user_data = file("setup_challenge1.sh")

  # -- Challenge 2 – token injected via templatefile() ----------------------
  # user_data = templatefile("setup_challenge2.sh.tpl", {
  #   github_token = data.aws_secretsmanager_secret_version.github_token_read.secret_string
  #   github_user  = var.github_user
  #   github_repo  = var.github_repo
  # })

  tags = {
    Name = "lab08-webserver"
  }
}

# ---------------------------------------------
# Outputs
# ---------------------------------------------

output "instance_public_ip" {
  value = aws_instance.webserver.public_ip
}