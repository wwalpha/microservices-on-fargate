locals {
  account_id = data.aws_caller_identity.this.account_id
  region     = data.aws_region.this.name

  task_definition_backend_public_revision  = max(aws_ecs_task_definition.backend_public.revision, data.aws_ecs_task_definition.backend_public.revision)
  task_definition_backend_private_revision = max(aws_ecs_task_definition.backend_private.revision, data.aws_ecs_task_definition.backend_private.revision)
  task_definition_frontend_revision        = max(aws_ecs_task_definition.frontend.revision, data.aws_ecs_task_definition.frontend.revision)
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
data "aws_ecs_task_definition" "backend_public" {
  task_definition = "${aws_ecs_task_definition.backend_public.family}"
}

data "aws_ecs_task_definition" "backend_private" {
  task_definition = "${aws_ecs_task_definition.backend_private.family}"
}

data "aws_ecs_task_definition" "frontend" {
  task_definition = "${aws_ecs_task_definition.frontend.family}"
}
