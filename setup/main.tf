# ----------------------------------------------------------------------------------------------
# AWS Provider
# ----------------------------------------------------------------------------------------------
provider "aws" {
  region = "ap-northeast-1"
}

# ----------------------------------------------------------------------------------------------
# Terraform Settings
# ----------------------------------------------------------------------------------------------
terraform {
  backend "s3" {
    bucket = "onecloud-reserved-bucket1"
    region = "ap-northeast-1"
    key    = "fargate-microservice/setup.tfstate"
  }

  required_version = ">= 0.12"
}

# ----------------------------------------------------------------------------------------------
# ECR - Frontend
# ----------------------------------------------------------------------------------------------
resource "aws_ecr_repository" "frontend" {
  name                 = "onecloud-fargate-frontend"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

# ----------------------------------------------------------------------------------------------
# ECR - Frontend Image
# ----------------------------------------------------------------------------------------------
resource "null_resource" "frontend" {
  triggers = {
    file_content_md5 = md5(file("scripts/dockerbuild.sh"))
  }

  provisioner "local-exec" {
    command = "sh ${path.module}/scripts/dockerbuild.sh"

    environment = {
      FOLDER_PATH    = "../frontend"
      AWS_REGION     = local.region
      AWS_ACCOUNT_ID = local.account_id
      REPO_URL       = aws_ecr_repository.frontend.repository_url
      CONTAINER_NAME = "frontend"
    }
  }
}

# ----------------------------------------------------------------------------------------------
# ECR - Backend API
# ----------------------------------------------------------------------------------------------
resource "aws_ecr_repository" "backend_api" {
  name                 = "onecloud-fargate-backend-api"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

# ----------------------------------------------------------------------------------------------
# ECR - Backend API Image
# ----------------------------------------------------------------------------------------------
resource "null_resource" "backend_api" {
  triggers = {
    file_content_md5 = md5(file("scripts/dockerbuild.sh"))
  }

  provisioner "local-exec" {
    command = "sh ${path.module}/scripts/dockerbuild.sh"

    environment = {
      FOLDER_PATH    = "../backend/api"
      AWS_REGION     = local.region
      AWS_ACCOUNT_ID = local.account_id
      REPO_URL       = aws_ecr_repository.backend_api.repository_url
      CONTAINER_NAME = "backend_auth"
    }
  }
}

# ----------------------------------------------------------------------------------------------
# ECR - Backend Auth
# ----------------------------------------------------------------------------------------------
resource "aws_ecr_repository" "backend_auth" {
  name                 = "onecloud-fargate-backend-auth"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

# ----------------------------------------------------------------------------------------------
# ECR - Backend Auth Image
# ----------------------------------------------------------------------------------------------
resource "null_resource" "backend_auth" {
  triggers = {
    file_content_md5 = md5(file("scripts/dockerbuild.sh"))
  }

  provisioner "local-exec" {
    command = "sh ${path.module}/scripts/dockerbuild.sh"

    environment = {
      FOLDER_PATH    = "../backend/auth"
      AWS_REGION     = local.region
      AWS_ACCOUNT_ID = local.account_id
      REPO_URL       = aws_ecr_repository.backend_auth.repository_url
      CONTAINER_NAME = "backend_auth"
    }
  }
}

# ----------------------------------------------------------------------------------------------
# ECR - Backend Worker
# ----------------------------------------------------------------------------------------------
resource "aws_ecr_repository" "backend_worker" {
  name                 = "onecloud-fargate-backend-worker"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

# ----------------------------------------------------------------------------------------------
# ECR - Backend Worker Image
# ----------------------------------------------------------------------------------------------
resource "null_resource" "backend_worker" {
  triggers = {
    file_content_md5 = md5(file("scripts/dockerbuild.sh"))
  }

  provisioner "local-exec" {
    command = "sh ${path.module}/scripts/dockerbuild.sh"

    environment = {
      FOLDER_PATH    = "../backend/worker"
      AWS_REGION     = local.region
      AWS_ACCOUNT_ID = local.account_id
      REPO_URL       = aws_ecr_repository.backend_worker.repository_url
      CONTAINER_NAME = "backend_worker"
    }
  }
}
