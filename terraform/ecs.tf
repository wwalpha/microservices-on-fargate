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
# ECR - Backend Public
# ----------------------------------------------------------------------------------------------
resource "aws_ecr_repository" "backend_public" {
  name                 = "onecloud-fargate-backend-public"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

# ----------------------------------------------------------------------------------------------
# ECR - Backend Private
# ----------------------------------------------------------------------------------------------
resource "aws_ecr_repository" "backend_private" {
  name                 = "onecloud-fargate-backend-private"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

# ----------------------------------------------------------------------------------------------
# ECS Cluster
# ----------------------------------------------------------------------------------------------
resource "aws_ecs_cluster" "fargate" {
  name = "onecloud-fargate-microservice"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# ----------------------------------------------------------------------------------------------
# ECS Service - Frontend Task Definition
# ----------------------------------------------------------------------------------------------
resource "aws_ecs_task_definition" "frontend" {
  family                = "onecloud-fargate-frontend"
  container_definitions = file("taskdef/frontend.json")
  task_role_arn         = aws_iam_role.ecs_task_exec.arn
  execution_role_arn    = aws_iam_role.ecs_task_exec.arn
  network_mode          = "awsvpc"
  requires_compatibilities = [
    "FARGATE"
  ]
  cpu    = "512"
  memory = "1024"
}

# ----------------------------------------------------------------------------------------------
# ECS Service - Frontend
# ----------------------------------------------------------------------------------------------
resource "aws_ecs_service" "frontend" {
  name                               = "frontend"
  cluster                            = aws_ecs_cluster.fargate.id
  desired_count                      = 1
  launch_type                        = "FARGATE"
  platform_version                   = "1.4.0"
  task_definition                    = "arn:aws:ecs:${local.region}:${local.account_id}:task-definition/${aws_ecs_task_definition.frontend.family}:${local.task_definition_frontend_revision}"
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  network_configuration {
    assign_public_ip = false
    subnets          = var.private_subnet_ids
    security_groups  = var.vpc_security_groups
  }
  scheduling_strategy = "REPLICA"

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend.arn
    container_name   = "onecloud-fargate-frontend"
    container_port   = 80
  }
}

# ----------------------------------------------------------------------------------------------
# ECS Service - Backend Public Task Definition
# ----------------------------------------------------------------------------------------------
resource "aws_ecs_task_definition" "backend_public" {
  family                = "onecloud-fargate-backend-public"
  container_definitions = file("taskdef/backend_public.json")
  task_role_arn         = aws_iam_role.ecs_task_exec.arn
  execution_role_arn    = aws_iam_role.ecs_task_exec.arn
  network_mode          = "awsvpc"
  requires_compatibilities = [
    "FARGATE"
  ]
  cpu    = "512"
  memory = "1024"
}

# ----------------------------------------------------------------------------------------------
# ECS Service - Backend Public
# ----------------------------------------------------------------------------------------------
resource "aws_ecs_service" "backend_public" {
  name                               = "backend_public"
  cluster                            = aws_ecs_cluster.fargate.id
  desired_count                      = 1
  launch_type                        = "FARGATE"
  platform_version                   = "1.4.0"
  task_definition                    = "arn:aws:ecs:${local.region}:${local.account_id}:task-definition/${aws_ecs_task_definition.backend_public.family}:${local.task_definition_backend_public_revision}"
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  network_configuration {
    assign_public_ip = false
    subnets          = var.private_subnet_ids
    security_groups  = var.vpc_security_groups
  }
  scheduling_strategy = "REPLICA"

  load_balancer {
    target_group_arn = aws_lb_target_group.backend_public.arn
    container_name   = "onecloud-fargate-backend-public"
    container_port   = 8080
  }
}

# ----------------------------------------------------------------------------------------------
# ECS Service - Backend Private Task Definition
# ----------------------------------------------------------------------------------------------
resource "aws_ecs_task_definition" "backend_private" {
  family                = "onecloud-fargate-backend-private"
  container_definitions = file("taskdef/backend_private.json")
  task_role_arn         = aws_iam_role.ecs_task_exec.arn
  execution_role_arn    = aws_iam_role.ecs_task_exec.arn
  network_mode          = "awsvpc"
  requires_compatibilities = [
    "FARGATE"
  ]
  cpu    = "512"
  memory = "1024"
}

# ----------------------------------------------------------------------------------------------
# ECS Service - Backend Private With ALB
# ----------------------------------------------------------------------------------------------
resource "aws_ecs_service" "backend_private_with_alb" {
  name                               = "backend_private_with_alb"
  cluster                            = aws_ecs_cluster.fargate.id
  desired_count                      = 2
  launch_type                        = "FARGATE"
  platform_version                   = "1.4.0"
  task_definition                    = "arn:aws:ecs:${local.region}:${local.account_id}:task-definition/${aws_ecs_task_definition.backend_private.family}:${local.task_definition_backend_private_revision}"
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  network_configuration {
    assign_public_ip = false
    subnets          = var.private_subnet_ids
    security_groups  = var.vpc_security_groups
  }
  scheduling_strategy = "REPLICA"

  load_balancer {
    target_group_arn = aws_lb_target_group.backend_private.arn
    container_name   = "onecloud-fargate-backend-private"
    container_port   = 8090
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}

# ----------------------------------------------------------------------------------------------
# Application AutoScaling ScalableTarget - ECS
# ----------------------------------------------------------------------------------------------
resource "aws_appautoscaling_target" "backend_private_with_alb" {
  max_capacity       = 4
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.fargate.name}/${aws_ecs_service.backend_private_with_alb.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# ----------------------------------------------------------------------------------------------
# Application AutoScaling Policy - ECS
# ----------------------------------------------------------------------------------------------
resource "aws_appautoscaling_policy" "ecs_policy" {
  name               = "ScaleOut_CPU_80"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.backend_private_with_alb.resource_id
  scalable_dimension = aws_appautoscaling_target.backend_private_with_alb.scalable_dimension
  service_namespace  = aws_appautoscaling_target.backend_private_with_alb.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
}


# ----------------------------------------------------------------------------------------------
# ECS Service - Backend Private
# ----------------------------------------------------------------------------------------------
resource "aws_ecs_service" "backend_private" {
  name                               = "backend_private"
  cluster                            = aws_ecs_cluster.fargate.id
  desired_count                      = 1
  launch_type                        = "FARGATE"
  platform_version                   = "1.4.0"
  task_definition                    = "arn:aws:ecs:${local.region}:${local.account_id}:task-definition/${aws_ecs_task_definition.backend_private.family}:${local.task_definition_backend_private_revision}"
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  scheduling_strategy                = "REPLICA"

  service_registries {
    registry_arn = aws_service_discovery_service.microservice.arn
  }

  network_configuration {
    assign_public_ip = false
    subnets          = var.private_subnet_ids
    security_groups  = var.vpc_security_groups
  }
}
