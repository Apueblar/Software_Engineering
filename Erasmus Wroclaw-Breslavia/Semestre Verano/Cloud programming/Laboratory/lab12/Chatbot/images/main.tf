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
# ECR Repositories
# =============================================================================

resource "aws_ecr_repository" "chatbot_backend" {
  name         = "chatbot-backend"
  force_delete = true
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Name = "ChatbotBackend"
  }
}

resource "aws_ecr_repository" "chatbot_frontend" {
  name         = "chatbot-frontend"
  force_delete = true
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Name = "ChatbotFrontend"
  }
}

# =============================================================================
# Automation Script Generation (build_and_push.sh)
# =============================================================================

resource "local_file" "build_script" {
  filename = "${path.module}/build_and_push.sh"
  content  = <<-EOT
    #!/bin/bash
    set -e

    REGISTRY_URL="394807094315.dkr.ecr.us-east-1.amazonaws.com"

    # Ensure Podman machine is started
    echo "Starting Podman machine..."
    podman machine start || true

    # Login to ECR
    echo "Logging in to ECR..."
    aws ecr get-login-password --region us-east-1 | podman login --username AWS --password-stdin $REGISTRY_URL

    # Build and Push Backend
    echo "Building Backend..."
    podman build -t chatbot-backend ../backend
    echo "Tagging Backend..."
    podman tag localhost/chatbot-backend:latest ${aws_ecr_repository.chatbot_backend.repository_url}:latest
    echo "Pushing Backend..."
    podman push ${aws_ecr_repository.chatbot_backend.repository_url}:latest

    # Build and Push Frontend
    echo "Building Frontend..."
    # We provide a dummy build-arg; SvelteKit will use the runtime PUBLIC_API_BASE_URL provided by ECS.
    podman build --build-arg PUBLIC_API_BASE_URL=http://dummy-url:5000/ -t chatbot-frontend ../frontend
    echo "Tagging Frontend..."
    podman tag localhost/chatbot-frontend:latest ${aws_ecr_repository.chatbot_frontend.repository_url}:latest
    echo "Pushing Frontend..."
    podman push ${aws_ecr_repository.chatbot_frontend.repository_url}:latest

    echo "Build and push complete!"
  EOT
}

resource "local_file" "build_script_powershell" {
  filename = "${path.module}/build_and_push.ps1"
  content  = <<-EOT
    $ErrorActionPreference = "Stop"

    $REGISTRY_URL = "394807094315.dkr.ecr.us-east-1.amazonaws.com"

    # Ensure Podman machine is started
    Write-Host "Starting Podman machine..."
    try {
        podman machine start
    } catch {
        # Ignore error if VM is already running
    }

    # Login to ECR using cmd.exe to avoid PowerShell pipe encoding issues
    Write-Host "Logging in to ECR..."
    cmd.exe /c "aws ecr get-login-password --region us-east-1 | podman login --username AWS --password-stdin $REGISTRY_URL"

    # Build and Push Backend
    Write-Host "Building Backend..."
    podman build -t chatbot-backend ../backend
    Write-Host "Tagging Backend..."
    podman tag localhost/chatbot-backend:latest ${aws_ecr_repository.chatbot_backend.repository_url}:latest
    Write-Host "Pushing Backend..."
    podman push ${aws_ecr_repository.chatbot_backend.repository_url}:latest

    # Build and Push Frontend
    Write-Host "Building Frontend..."
    podman build --build-arg PUBLIC_API_BASE_URL=http://dummy-url:5000/ -t chatbot-frontend ../frontend
    Write-Host "Tagging Frontend..."
    podman tag localhost/chatbot-frontend:latest ${aws_ecr_repository.chatbot_frontend.repository_url}:latest
    Write-Host "Pushing Frontend..."
    podman push ${aws_ecr_repository.chatbot_frontend.repository_url}:latest

    Write-Host "Build and push complete!"
  EOT
}

# =============================================================================
# Outputs
# =============================================================================

output "ecr_backend_url" {
  description = "ECR repository URL for the backend image"
  value       = aws_ecr_repository.chatbot_backend.repository_url
}

output "ecr_frontend_url" {
  description = "ECR repository URL for the frontend image"
  value       = aws_ecr_repository.chatbot_frontend.repository_url
}
