# ----------------------------------------------------------------------------------------------
# ECR - Frontend
# ----------------------------------------------------------------------------------------------
resource "aws_ecr_repository" "frontend" {
  name                 = "onecloud-fargate-frontend"
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

# ----------------------------------------------------------------------------------------------
# ECR - Backend API
# ----------------------------------------------------------------------------------------------
resource "aws_ecr_repository" "backend_api" {
  name                 = "onecloud-fargate-backend-api"
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

# ----------------------------------------------------------------------------------------------
# ECR - Backend Auth
# ----------------------------------------------------------------------------------------------
resource "aws_ecr_repository" "backend_auth" {
  name                 = "onecloud-fargate-backend-auth"
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

# ----------------------------------------------------------------------------------------------
# ECR - Backend Worker
# ----------------------------------------------------------------------------------------------
resource "aws_ecr_repository" "backend_worker" {
  name                 = "onecloud-fargate-backend-worker"
  image_tag_mutability = "IMMUTABLE"
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
# ECS Service - Backend API Task Definition
# ----------------------------------------------------------------------------------------------
resource "aws_ecs_task_definition" "backend_api" {
  family                = local.task_def_family_backend_api
  container_definitions = file("taskdef/backend_api.json")
  task_role_arn         = aws_iam_role.ecs_task_exec.arn
  execution_role_arn    = aws_iam_role.ecs_task_exec.arn
  network_mode          = "awsvpc"
  requires_compatibilities = [
    "FARGATE"
  ]
  cpu    = "1024"
  memory = "2048"

  proxy_configuration {
    type           = "APPMESH"
    container_name = local.task_def_family_backend_api
    properties = {
      "ProxyIngressPort"   = "80"
      "ProxyEgressPort"    = "81"
      "AppPorts"           = "8080"
      "EgressIgnoredIPs"   = "169.254.170.2,169.254.169.254"
      "EgressIgnoredPorts" = ""
      "IgnoredGID"         = ""
      "IgnoredUID"         = "1336"
    }
  }
}

# ----------------------------------------------------------------------------------------------
# ECS Service - Backend Public
# ----------------------------------------------------------------------------------------------
resource "aws_ecs_service" "backend_api" {
  name                               = "backend_api"
  cluster                            = aws_ecs_cluster.fargate.id
  desired_count                      = 1
  launch_type                        = "FARGATE"
  platform_version                   = "1.4.0"
  task_definition                    = "arn:aws:ecs:${local.region}:${local.account_id}:task-definition/${aws_ecs_task_definition.backend_api.family}:${local.task_definition_backend_api_revision}"
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  network_configuration {
    assign_public_ip = false
    subnets          = var.private_subnet_ids
    security_groups  = var.vpc_security_groups
  }
  scheduling_strategy = "REPLICA"

  load_balancer {
    target_group_arn = aws_lb_target_group.backend_api.arn
    container_name   = "onecloud-fargate-backend-api"
    container_port   = 8080
  }

  service_registries {
    registry_arn = aws_service_discovery_service.backend_api.arn
  }
}

# ----------------------------------------------------------------------------------------------
# ECS Service - Backend Auth Task Definition
# ----------------------------------------------------------------------------------------------
resource "aws_ecs_task_definition" "backend_auth" {
  family                = local.task_def_family_backend_auth
  container_definitions = file("taskdef/backend_auth.json")
  task_role_arn         = aws_iam_role.ecs_task_exec.arn
  execution_role_arn    = aws_iam_role.ecs_task_exec.arn
  network_mode          = "awsvpc"
  requires_compatibilities = [
    "FARGATE"
  ]
  cpu    = "1024"
  memory = "2048"

  proxy_configuration {
    type           = "APPMESH"
    container_name = local.task_def_family_backend_auth
    properties = {
      "ProxyIngressPort"   = "80"
      "ProxyEgressPort"    = "81"
      "AppPorts"           = "8090"
      "EgressIgnoredIPs"   = "169.254.170.2,169.254.169.254"
      "EgressIgnoredPorts" = ""
      "IgnoredGID"         = ""
      "IgnoredUID"         = "1337"
    }
  }
}

# ----------------------------------------------------------------------------------------------
# ECS Service - Backend Auth
# ----------------------------------------------------------------------------------------------
resource "aws_ecs_service" "backend_auth" {
  name                               = "backend_auth"
  cluster                            = aws_ecs_cluster.fargate.id
  desired_count                      = 1
  launch_type                        = "FARGATE"
  platform_version                   = "1.4.0"
  task_definition                    = "arn:aws:ecs:${local.region}:${local.account_id}:task-definition/${aws_ecs_task_definition.backend_auth.family}:${local.task_definition_backend_auth_revision}"
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  network_configuration {
    assign_public_ip = false
    subnets          = var.private_subnet_ids
    security_groups  = var.vpc_security_groups
  }
  scheduling_strategy = "REPLICA"

  service_registries {
    registry_arn = aws_service_discovery_service.backend_auth.arn
  }
}

# ----------------------------------------------------------------------------------------------
# Application AutoScaling ScalableTarget - ECS
# ----------------------------------------------------------------------------------------------
resource "aws_appautoscaling_target" "backend_auth" {
  max_capacity       = 3
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.fargate.name}/${aws_ecs_service.backend_auth.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# ----------------------------------------------------------------------------------------------
# Application AutoScaling Policy - ECS
# ----------------------------------------------------------------------------------------------
resource "aws_appautoscaling_policy" "ecs_policy" {
  name               = "ScaleOut_CPU_80"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.backend_auth.resource_id
  scalable_dimension = aws_appautoscaling_target.backend_auth.scalable_dimension
  service_namespace  = aws_appautoscaling_target.backend_auth.service_namespace

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
# ECS Service - Backend Worker Task Definition
# ----------------------------------------------------------------------------------------------
resource "aws_ecs_task_definition" "backend_worker" {
  family                = local.task_def_family_backend_worker
  container_definitions = file("taskdef/backend_worker.json")
  task_role_arn         = aws_iam_role.ecs_task_exec.arn
  execution_role_arn    = aws_iam_role.ecs_task_exec.arn
  network_mode          = "awsvpc"
  requires_compatibilities = [
    "FARGATE"
  ]
  cpu    = "1024"
  memory = "2048"

  proxy_configuration {
    type           = "APPMESH"
    container_name = local.task_def_family_backend_worker
    properties = {
      "ProxyIngressPort"   = "80"
      "ProxyEgressPort"    = "81"
      "AppPorts"           = "8090"
      "EgressIgnoredIPs"   = "169.254.170.2,169.254.169.254"
      "EgressIgnoredPorts" = ""
      "IgnoredGID"         = ""
      "IgnoredUID"         = "1338"
    }
  }
}

# ----------------------------------------------------------------------------------------------
# ECS Service - Backend Worker
# ----------------------------------------------------------------------------------------------
resource "aws_ecs_service" "backend_worker" {
  name                               = "backend_worker"
  cluster                            = aws_ecs_cluster.fargate.id
  desired_count                      = 2
  launch_type                        = "FARGATE"
  platform_version                   = "1.4.0"
  task_definition                    = "arn:aws:ecs:${local.region}:${local.account_id}:task-definition/${aws_ecs_task_definition.backend_worker.family}:${local.task_definition_backend_worker_revision}"
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  scheduling_strategy                = "REPLICA"

  service_registries {
    registry_arn = aws_service_discovery_service.backend_worker.arn
  }

  network_configuration {
    assign_public_ip = false
    subnets          = var.private_subnet_ids
    security_groups  = var.vpc_security_groups
  }
}
