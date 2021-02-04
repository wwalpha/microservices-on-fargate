locals {
  account_id = data.aws_caller_identity.this.account_id
  region     = data.aws_region.this.name

  task_definition_revision_backend_api    = max(aws_ecs_task_definition.backend_api.revision, data.aws_ecs_task_definition.backend_api.revision)
  task_definition_revision_backend_auth   = max(aws_ecs_task_definition.backend_auth.revision, data.aws_ecs_task_definition.backend_auth.revision)
  task_definition_revision_backend_worker = max(aws_ecs_task_definition.backend_worker.revision, data.aws_ecs_task_definition.backend_worker.revision)
  task_definition_revision_frontend       = max(aws_ecs_task_definition.frontend.revision, data.aws_ecs_task_definition.frontend.revision)

  task_def_family_frontend       = "onecloud-fargate-frontend"
  task_def_family_backend_api    = "onecloud-fargate-backend-api"
  task_def_family_backend_auth   = "onecloud-fargate-backend-auth"
  task_def_family_backend_worker = "onecloud-fargate-backend-worker"
}

# ----------------------------------------------------------------------------------------------
# AWS Region
# ----------------------------------------------------------------------------------------------
data "aws_region" "this" {}

# ----------------------------------------------------------------------------------------------
# AWS Account
# ----------------------------------------------------------------------------------------------
data "aws_caller_identity" "this" {}

# ----------------------------------------------------------------------------------------------
# Task Definition
# ----------------------------------------------------------------------------------------------
data "aws_ecs_task_definition" "backend_api" {
  depends_on      = [aws_ecs_task_definition.backend_api]
  task_definition = aws_ecs_task_definition.backend_api.family
}

data "aws_ecs_task_definition" "backend_auth" {
  depends_on      = [aws_ecs_task_definition.backend_auth]
  task_definition = aws_ecs_task_definition.backend_auth.family
}

data "aws_ecs_task_definition" "backend_worker" {
  depends_on      = [aws_ecs_task_definition.backend_worker]
  task_definition = aws_ecs_task_definition.backend_worker.family
}

data "aws_ecs_task_definition" "frontend" {
  depends_on      = [aws_ecs_task_definition.frontend]
  task_definition = aws_ecs_task_definition.frontend.family
}

# ----------------------------------------------------------------------------------------------
# Container Images
# ----------------------------------------------------------------------------------------------
data "aws_ecr_image" "frontend" {
  repository_name = "onecloud-fargate-frontend"
  image_tag       = "latest"
}

data "aws_ecr_image" "backend_api" {
  repository_name = "onecloud-fargate-backend-api"
  image_tag       = "latest"
}

data "aws_ecr_image" "backend_auth" {
  repository_name = "onecloud-fargate-backend-auth"
  image_tag       = "latest"
}

data "aws_ecr_image" "backend_worker" {
  repository_name = "onecloud-fargate-backend-worker"
  image_tag       = "latest"
}
