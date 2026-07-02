terraform {
required_providers {
 aws = {
 source = "hashicorp/aws"
 version = ">= 5.1"
 }
}
required_version = ">= 1.2.0"
}
provider "aws" {
 region = "us-east-1"
}
module "my_vpc" {
 source = "terraform-aws-modules/vpc/aws"
 name = "ecs-lab"
 cidr = "10.0.0.0/16"
 azs            = ["us-east-1a", "us-east-1b"]
 public_subnets = ["10.0.101.0/24", "10.0.102.0/24"]
 tags = {
 Terraform = "true"
 Environment = "dev"
 }
}

resource "aws_security_group" "allow_http" {
 name = "allow_http"
 description = "Allow HTTP inbound traffic and all outbound traffic"
 vpc_id = module.my_vpc.vpc_id
 tags = {
 Name = "Allow HTTP"
 }
}
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
 security_group_id = aws_security_group.allow_http.id
 cidr_ipv4 = "0.0.0.0/0"
 ip_protocol = "-1" # all ports
}
resource "aws_vpc_security_group_ingress_rule" "allow_http" {
 security_group_id = aws_security_group.allow_http.id
 cidr_ipv4 = "0.0.0.0/0"
 ip_protocol = "tcp"
 from_port = 8080
 to_port = 8080
}

resource "aws_ecr_repository" "pythonflasksample" {
 name = "pythonflasksample"
 image_scanning_configuration {
 scan_on_push = true
 }
 tags = {
 Name = "PythonFlaskSample"
 }
}

resource "aws_ecs_cluster" "ecs_pfs" {
 name = "ecs_pfs"
}

resource "aws_ecs_service" "ecs_svc_pfs" {
 name = "ecs_svc_pfs"
 cluster = aws_ecs_cluster.ecs_pfs.id
 task_definition = aws_ecs_task_definition.ecs_task_pfs.arn
 launch_type = "FARGATE"
 network_configuration {
 subnets = [module.my_vpc.public_subnets[0]]
 assign_public_ip = true
 security_groups = [aws_security_group.allow_http.id]
 }
 desired_count = 1
 
 load_balancer {
  target_group_arn = aws_lb_target_group.app_tg_pfs.arn
  container_name = "pfs-container"
  container_port = 8080
 }
 depends_on = [aws_lb_listener.http_listener_pfs]
}

resource "aws_ecs_task_definition" "ecs_task_pfs" {
    family = "ecs_task_pfs"
    network_mode = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    memory = "1024"
    cpu = "512"
    task_role_arn = "arn:aws:iam::394807094315:role/LabRole"
    execution_role_arn = "arn:aws:iam::394807094315:role/LabRole"
    container_definitions = <<-EOF
    [
        {
            "name": "pfs-container",
            "image": "394807094315.dkr.ecr.us-east-1.amazonaws.com/pythonflasksample:latest",
            "memory": 1024,
            "cpu": 512,
            "essential": true,
            "portMappings": [
                {
                    "containerPort": 8080,
                    "hostPort": 8080
                }
            ],
            "environment": [
                {
                 "name":"USER_NAME", "value": "Bob"
                }
            ]
        }
    ]
    EOF
    }

resource "aws_lb" "app_lb_pfs" {
 name = "app-lb-pfs"
 internal = false
 load_balancer_type = "application"
 security_groups = [aws_security_group.allow_http.id]
 subnets = module.my_vpc.public_subnets
 enable_deletion_protection = false
}

resource "aws_lb_target_group" "app_tg_pfs" {
port = 8080
 protocol = "HTTP"
 vpc_id = module.my_vpc.vpc_id
 target_type = "ip"
 health_check {
 path = "/"
 protocol = "HTTP"
 matcher = "200"
 interval = 30
 timeout = 5
 healthy_threshold = 2
 unhealthy_threshold = 2
 }
}

resource "aws_lb_listener" "http_listener_pfs" {
 load_balancer_arn = aws_lb.app_lb_pfs.arn
 port = 8080
 protocol = "HTTP"
 default_action {
 type = "forward"
 target_group_arn = aws_lb_target_group.app_tg_pfs.arn
 }
}
