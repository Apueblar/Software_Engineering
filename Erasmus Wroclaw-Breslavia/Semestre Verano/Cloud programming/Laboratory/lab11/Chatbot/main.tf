# =============================================================================
# Chatbot — AWS ECS Fargate Deployment with Application Load Balancer
# Single main.tf following the demo pattern
# =============================================================================

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.1"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

# =============================================================================
# VPC — 2 AZs, 2 public subnets
# =============================================================================

module "my_vpc" {
  source         = "terraform-aws-modules/vpc/aws"
  name           = "ecs-chatbot"
  cidr           = "10.0.0.0/16"
  azs            = ["us-east-1a", "us-east-1b"]
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24"]
  database_subnets = ["10.0.201.0/24", "10.0.202.0/24"]
  create_database_subnet_group = false
  create_database_subnet_route_table = true
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

# =============================================================================
# Security Group — allow ports 3000 (frontend) and 5000 (backend)
# =============================================================================

resource "aws_security_group" "allow_http" {
  name        = "chatbot_allow_http"
  description = "Allow HTTP inbound traffic for chatbot frontend and backend"
  vpc_id      = module.my_vpc.vpc_id
  tags = {
    Name = "Chatbot Allow HTTP"
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_http.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # all ports
}

resource "aws_vpc_security_group_ingress_rule" "allow_frontend" {
  security_group_id = aws_security_group.allow_http.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 3000
  to_port           = 3000
}

resource "aws_vpc_security_group_ingress_rule" "allow_backend" {
  security_group_id = aws_security_group.allow_http.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 5000
  to_port           = 5000
}

# =============================================================================
# Database Subnet Group
# =============================================================================

resource "aws_db_subnet_group" "chatbot_db_subnet_group" {
  name       = "chatbot-db-subnet-group"
  subnet_ids = module.my_vpc.database_subnets
  tags = {
    Name = "Chatbot DB Subnet Group"
  }
}

# =============================================================================
# Security Group — Database
# =============================================================================

resource "aws_security_group" "allow_db" {
  name        = "chatbot_allow_db"
  description = "Allow MySQL inbound traffic from backend"
  vpc_id      = module.my_vpc.vpc_id
  tags = {
    Name = "Chatbot Allow DB"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_mysql" {
  security_group_id            = aws_security_group.allow_db.id
  referenced_security_group_id = aws_security_group.allow_http.id
  ip_protocol                  = "tcp"
  from_port                    = 3306
  to_port                      = 3306
}

# =============================================================================
# RDS MySQL Database
# =============================================================================

resource "aws_db_instance" "chatbot_db" {
  identifier             = "chatbot-mysql"
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  db_name                = "chatbotdb"
  username               = "admin"
  password               = "Chatbotdb2026!"
  parameter_group_name   = "default.mysql8.0"
  skip_final_snapshot    = true
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.allow_db.id]
  db_subnet_group_name   = aws_db_subnet_group.chatbot_db_subnet_group.name
}

# =============================================================================
# ECS Cluster
# =============================================================================

resource "aws_ecs_cluster" "ecs_chatbot" {
  name = "ecs_chatbot"
}

# =============================================================================
# ECS Task Definition — Backend (Spring Boot, port 5000)
# =============================================================================

resource "aws_ecs_task_definition" "ecs_task_backend" {
  family                   = "ecs_task_chatbot_backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  memory                   = "1024"
  cpu                      = "512"
  task_role_arn            = "arn:aws:iam::394807094315:role/LabRole"
  execution_role_arn       = "arn:aws:iam::394807094315:role/LabRole"
  container_definitions    = <<-EOF
    [
        {
            "name": "chatbot-backend",
            "image": "394807094315.dkr.ecr.us-east-1.amazonaws.com/chatbot-backend:latest",
            "memory": 1024,
            "cpu": 512,
            "essential": true,
            "portMappings": [
                {
                    "containerPort": 5000,
                    "hostPort": 5000
                }
            ],
            "environment": [
                {
                    "name": "DB_HOST",
                    "value": "${aws_db_instance.chatbot_db.endpoint}"
                },
                {
                    "name": "DB_NAME",
                    "value": "${aws_db_instance.chatbot_db.db_name}"
                },
                {
                    "name": "DB_USERNAME",
                    "value": "${aws_db_instance.chatbot_db.username}"
                },
                {
                    "name": "DB_PASSWORD",
                    "value": "${aws_db_instance.chatbot_db.password}"
                }
            ]
        }
    ]
    EOF
}

# =============================================================================
# ECS Task Definition — Frontend (SvelteKit, port 3000)
# PUBLIC_API_BASE_URL points to the ALB DNS on port 5000
# =============================================================================

resource "aws_ecs_task_definition" "ecs_task_frontend" {
  family                   = "ecs_task_chatbot_frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  memory                   = "1024"
  cpu                      = "512"
  task_role_arn            = "arn:aws:iam::394807094315:role/LabRole"
  execution_role_arn       = "arn:aws:iam::394807094315:role/LabRole"
  container_definitions    = <<-EOF
    [
        {
            "name": "chatbot-frontend",
            "image": "394807094315.dkr.ecr.us-east-1.amazonaws.com/chatbot-frontend:latest",
            "memory": 1024,
            "cpu": 512,
            "essential": true,
            "portMappings": [
                {
                    "containerPort": 3000,
                    "hostPort": 3000
                }
            ],
            "environment": [
                {
                    "name": "PUBLIC_API_BASE_URL",
                    "value": "http://${aws_lb.app_lb.dns_name}:5000/"
                }
            ]
        }
    ]
    EOF
}

# =============================================================================
# Application Load Balancer
# =============================================================================

resource "aws_lb" "app_lb" {
  name                       = "chatbot-lb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.allow_http.id]
  subnets                    = module.my_vpc.public_subnets
  enable_deletion_protection = false
}

# =============================================================================
# Target Groups
# =============================================================================

resource "aws_lb_target_group" "backend_tg" {
  name        = "chatbot-backend-tg"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = module.my_vpc.vpc_id
  target_type = "ip"
  health_check {
    path                = "/chat/all?username=healthcheck"
    protocol            = "HTTP"
    matcher             = "200,404"
    interval            = 60
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group" "frontend_tg" {
  name        = "chatbot-frontend-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = module.my_vpc.vpc_id
  target_type = "ip"
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# =============================================================================
# ALB Listeners
# =============================================================================

resource "aws_lb_listener" "http_listener_backend" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 5000
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_tg.arn
  }
}

resource "aws_lb_listener" "http_listener_frontend" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 3000
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_tg.arn
  }
}

# =============================================================================
# ECS Services
# =============================================================================

resource "aws_ecs_service" "ecs_svc_backend" {
  name            = "ecs_svc_chatbot_backend"
  cluster         = aws_ecs_cluster.ecs_chatbot.id
  task_definition = aws_ecs_task_definition.ecs_task_backend.arn
  launch_type     = "FARGATE"
  desired_count   = 1
  health_check_grace_period_seconds = 60

  network_configuration {
    subnets          = [module.my_vpc.public_subnets[0]]
    assign_public_ip = true
    security_groups  = [aws_security_group.allow_http.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.backend_tg.arn
    container_name   = "chatbot-backend"
    container_port   = 5000
  }

  depends_on = [aws_lb_listener.http_listener_backend]
}

resource "aws_ecs_service" "ecs_svc_frontend" {
  name            = "ecs_svc_chatbot_frontend"
  cluster         = aws_ecs_cluster.ecs_chatbot.id
  task_definition = aws_ecs_task_definition.ecs_task_frontend.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = [module.my_vpc.public_subnets[0]]
    assign_public_ip = true
    security_groups  = [aws_security_group.allow_http.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend_tg.arn
    container_name   = "chatbot-frontend"
    container_port   = 3000
  }

  depends_on = [aws_lb_listener.http_listener_frontend]
}

# =============================================================================
# Automation Script Generation (deploy.sh)
# =============================================================================

resource "local_file" "deploy_script" {
  filename = "${path.module}/deploy.sh"
  content  = <<-EOT
    #!/bin/bash
    set -e

    # Force ECS to pull the new images
    echo "Refreshing ECS Services..."
    aws ecs update-service --cluster ${aws_ecs_cluster.ecs_chatbot.name} --service ${aws_ecs_service.ecs_svc_backend.name} --force-new-deployment --region us-east-1
    aws ecs update-service --cluster ${aws_ecs_cluster.ecs_chatbot.name} --service ${aws_ecs_service.ecs_svc_frontend.name} --force-new-deployment --region us-east-1

    echo "Deployment complete! Visit http://${aws_lb.app_lb.dns_name}:3000"
  EOT
}

resource "local_file" "deploy_script_powershell" {
  filename = "${path.module}/deploy.ps1"
  content  = <<-EOT
    $ErrorActionPreference = "Stop"

    # Force ECS to pull the new images
    Write-Host "Refreshing ECS Services..."
    aws ecs update-service --cluster ${aws_ecs_cluster.ecs_chatbot.name} --service ${aws_ecs_service.ecs_svc_backend.name} --force-new-deployment --region us-east-1
    aws ecs update-service --cluster ${aws_ecs_cluster.ecs_chatbot.name} --service ${aws_ecs_service.ecs_svc_frontend.name} --force-new-deployment --region us-east-1

    Write-Host "Deployment complete! Visit http://${aws_lb.app_lb.dns_name}:3000"
  EOT
}

# =============================================================================
# Outputs
# =============================================================================

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.app_lb.dns_name
}

output "frontend_url" {
  description = "URL to access the chatbot frontend"
  value       = "http://${aws_lb.app_lb.dns_name}:3000"
}

output "backend_url" {
  description = "URL to access the chatbot backend API"
  value       = "http://${aws_lb.app_lb.dns_name}:5000"
}

output "rds_endpoint" {
  description = "RDS Database Endpoint"
  value       = aws_db_instance.chatbot_db.endpoint
}
