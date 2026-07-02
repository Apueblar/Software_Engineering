[![Open in Codespaces](https://classroom.github.com/assets/launch-codespace-2972f46106e565e64193e422d61a12cf1da4916b45550586e14ef0a7c637dd04.svg)](https://classroom.github.com/open-in-codespaces?assignment_repo_id=23848151)
# Lab9 Report — ECS Fargate Deployment with Load Balancer

Authors:
- Álvaro Puebla Ruisánchez - 293867
- Enrique Ferrera Aznar - 293873

---

## 1. Configuration

### 1.1 Infrastructure Overview

The Chatbot application (Spring Boot backend + SvelteKit frontend) is deployed to **AWS ECS Fargate** using **Terraform**, following the demo `main.tf` pattern with an **Application Load Balancer (ALB)**.

All infrastructure is defined in a single file: [`Chatbot/main.tf`](Chatbot/main.tf).

### 1.2 AWS Resources Created

| Resource | Name / ID | Details |
|----------|-----------|---------|
| **Region** | `us-east-1` | N. Virginia |
| **VPC** | `ecs-chatbot` | CIDR `10.0.0.0/16`, 2 public subnets across `us-east-1a` and `us-east-1b` |
| **Security Group** | `chatbot_allow_http` | Inbound: ports 3000 (frontend) and 5000 (backend). Outbound: all |
| **ECR Repository (backend)** | `chatbot-backend` | Stores the Spring Boot Docker image |
| **ECR Repository (frontend)** | `chatbot-frontend` | Stores the SvelteKit Docker image |
| **ECS Cluster** | `ecs_chatbot` | Single cluster for both services |
| **ECS Task (backend)** | `ecs_task_chatbot_backend` | Fargate, 512 CPU / 1024 MiB, port 5000 |
| **ECS Task (frontend)** | `ecs_task_chatbot_frontend` | Fargate, 512 CPU / 1024 MiB, port 3000 |
| **ECS Service (backend)** | `ecs_svc_chatbot_backend` | 1 replica, attached to backend target group |
| **ECS Service (frontend)** | `ecs_svc_chatbot_frontend` | 1 replica, attached to frontend target group |
| **ALB** | `chatbot-lb` | Application Load Balancer, spans both public subnets |
| **Target Group (backend)** | `chatbot-backend-tg` | Port 5000, health check on `/chat/all?username=healthcheck` |
| **Target Group (frontend)** | `chatbot-frontend-tg` | Port 3000, health check on `/` |
| **Listener (backend)** | Port 5000 | Forwards to backend target group |
| **Listener (frontend)** | Port 3000 | Forwards to frontend target group |

### 1.3 Key Design Decisions

- **Single ALB with two listeners**: Port 3000 serves the frontend, port 5000 serves the backend API — mirrors the local Docker Compose port mapping.
- **Dynamic backend URL**: The frontend uses SvelteKit's `$env/dynamic/public` to read `PUBLIC_API_BASE_URL` at runtime. The ECS task definition sets this to `http://<ALB_DNS>:5000/`, resolved by Terraform via `aws_lb.app_lb.dns_name`.
- **LabRole**: Both task and execution roles use the AWS Academy `LabRole`.

### 1.4 Deployment Commands

```bash
# 1. Initialize Terraform
cd Chatbot
terraform init

# 2. Apply infrastructure
terraform apply

# 3. Authenticate Docker to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 394807094315.dkr.ecr.us-east-1.amazonaws.com

# 4. Build and push backend
docker build -t chatbot-backend ./backend
docker tag chatbot-backend:latest 394807094315.dkr.ecr.us-east-1.amazonaws.com/chatbot-backend:latest
docker push 394807094315.dkr.ecr.us-east-1.amazonaws.com/chatbot-backend:latest

# 5. Build and push frontend
docker build --build-arg PUBLIC_API_BASE_URL=http://placeholder/ -t chatbot-frontend ./frontend
docker tag chatbot-frontend:latest 394807094315.dkr.ecr.us-east-1.amazonaws.com/chatbot-frontend:latest
docker push 394807094315.dkr.ecr.us-east-1.amazonaws.com/chatbot-frontend:latest

# 6. Force ECS services to pull new images
aws ecs update-service --cluster ecs_chatbot --service ecs_svc_chatbot_backend --force-new-deployment --region us-east-1
aws ecs update-service --cluster ecs_chatbot --service ecs_svc_chatbot_frontend --force-new-deployment --region us-east-1
```

---

## 2. Getting Started from Scratch

To deploy the entire environment from a clean state, follow these steps in the `Chatbot` folder:

### Step 1: Infrastructure Deployment
Run Terraform to create the VPC, ECR repositories, ECS cluster, and Load Balancer. This will also generate a `deploy.sh` script tailored to your new infrastructure.

```powershell
cd Chatbot
terraform init
terraform apply -auto-approve
```

### Step 2: Application Deployment (ECR Build & Push)
Run the generated deployment script to build the images with Podman and push them to AWS.

```powershell
# On Windows (PowerShell):
.\deploy.ps1

# On Linux/macOS or Git Bash:
sh deploy.sh
```

---

## 3. Verification of the solution

*Once the deployment is complete, the application is accessible at the following URLs (provided by Terraform outputs):*

- **Frontend**: `http://<ALB_DNS>:3000`
- **Backend API**: `http://<ALB_DNS>:5000/chat/all?username=test`

### Application in Action

![Chatbot Verification](img/Screenshot_1.png)

---

## 4. Your feedback and reflections

### What do you think about using Terraform to build cloud configuration?

Terraform provides a declarative, reproducible way to manage cloud infrastructure. By defining all resources in a single `main.tf` file, we can version-control the entire infrastructure and recreate it from scratch at any time. The dependency resolution between resources (e.g., the frontend task definition automatically depends on the ALB DNS name) makes it easy to wire complex architectures together.

### Did you encounter any obstacles? Was there something difficult for you?

- **Service Startup Time**: Java Spring Boot applications can take up to 45-60 seconds to fully initialize in Fargate. We had to add a `health_check_grace_period_seconds = 60` to prevent the Load Balancer from killing the containers before they were ready.
- **Dynamic Frontend Configuration**: The frontend needs the Load Balancer's DNS name to communicate with the backend. We used SvelteKit's dynamic public environment variables to inject the backend URL into the ECS task at runtime.
- **Podman Integration**: Since the environment uses Podman instead of Docker, we automated the push process using a generated shell script that handles the registry login and image tagging correctly for Podman users.