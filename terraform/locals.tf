locals {
  account_id = data.aws_caller_identity.this.account_id
  region     = data.aws_region.this.name

  task_definition_backend_api_revision    = max(aws_ecs_task_definition.backend_api.revision, data.aws_ecs_task_definition.backend_api.revision)
  task_definition_backend_auth_revision   = max(aws_ecs_task_definition.backend_auth.revision, data.aws_ecs_task_definition.backend_auth.revision)
  task_definition_backend_worker_revision = max(aws_ecs_task_definition.backend_worker.revision, data.aws_ecs_task_definition.backend_worker.revision)
  task_definition_frontend_revision       = max(aws_ecs_task_definition.frontend.revision, data.aws_ecs_task_definition.frontend.revision)
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
