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
  family             = local.task_def_family_frontend
  task_role_arn      = aws_iam_role.ecs_task.arn
  execution_role_arn = aws_iam_role.ecs_task_exec.arn
  network_mode       = "awsvpc"
  cpu                = "512"
  memory             = "1024"

  requires_compatibilities = [
    "FARGATE"
  ]

  container_definitions = templatefile(
    "taskdef/frontend.tpl",
    {
      aws_region      = local.region
      container_name  = local.task_def_family_frontend
      container_image = "${local.account_id}.dkr.ecr.${local.region}.amazonaws.com/onecloud-fargate-frontend:latest"
    }
  )

  provisioner "local-exec" {
    when    = destroy
    command = "sh ${path.module}/scripts/deregister-taskdef.sh ${self.family}"
  }
}

# ----------------------------------------------------------------------------------------------
# ECS Service - Frontend
# ----------------------------------------------------------------------------------------------
resource "aws_ecs_service" "frontend" {
  depends_on = [aws_lb_listener.frontend]

  name                               = "frontend"
  cluster                            = aws_ecs_cluster.fargate.id
  desired_count                      = 1
  launch_type                        = "FARGATE"
  platform_version                   = "1.4.0"
  task_definition                    = "arn:aws:ecs:${local.region}:${local.account_id}:task-definition/${aws_ecs_task_definition.frontend.family}:${local.task_definition_revision_frontend}"
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  scheduling_strategy                = "REPLICA"

  network_configuration {
    assign_public_ip = false
    subnets          = var.private_subnet_ids
    security_groups  = var.vpc_security_groups
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend.arn
    container_name   = "onecloud-fargate-frontend"
    container_port   = 80
  }

  provisioner "local-exec" {
    when    = destroy
    command = "sh ${path.module}/scripts/servicediscovery-drain.sh ${length(self.service_registries) != 0 ? split("/", self.service_registries[0].registry_arn)[1] : ""}"
  }
}

# ----------------------------------------------------------------------------------------------
# ECS Service - Backend API Task Definition
# ----------------------------------------------------------------------------------------------
resource "aws_ecs_task_definition" "backend_api" {
  family             = local.task_def_family_backend_api
  task_role_arn      = aws_iam_role.ecs_task.arn
  execution_role_arn = aws_iam_role.ecs_task_exec.arn
  network_mode       = "awsvpc"
  cpu                = "1024"
  memory             = "2048"

  requires_compatibilities = [
    "FARGATE"
  ]

  proxy_configuration {
    type           = "APPMESH"
    container_name = "envoy"
    properties = {
      "ProxyIngressPort" = "15000"
      "ProxyEgressPort"  = "15001"
      "AppPorts"         = "8080"
      "EgressIgnoredIPs" = "169.254.170.2,169.254.169.254"
      "IgnoredUID"       = "1337"
    }
  }

  container_definitions = templatefile(
    "taskdef/backend_api.tpl",
    {
      aws_region      = local.region
      container_name  = local.task_def_family_backend_api
      container_image = "${local.account_id}.dkr.ecr.${local.region}.amazonaws.com/onecloud-fargate-backend-api:latest"
      app_mesh_node   = "mesh/fargate-microservice-mesh/virtualNode/api-node"
      # app_mesh_resource = aws_appmesh_virtual_node.api.arn
    }
  )

  provisioner "local-exec" {
    when    = destroy
    command = "sh ${path.module}/scripts/deregister-taskdef.sh ${self.family}"
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
  task_definition                    = "arn:aws:ecs:${local.region}:${local.account_id}:task-definition/${aws_ecs_task_definition.backend_api.family}:${local.task_definition_revision_backend_api}"
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

  provisioner "local-exec" {
    when    = destroy
    command = "sh ${path.module}/scripts/servicediscovery-drain.sh ${split("/", self.service_registries[0].registry_arn)[1]}"
  }
}

# ----------------------------------------------------------------------------------------------
# ECS Service - Backend Auth Task Definition
# ----------------------------------------------------------------------------------------------
resource "aws_ecs_task_definition" "backend_auth" {
  family             = local.task_def_family_backend_auth
  task_role_arn      = aws_iam_role.ecs_task.arn
  execution_role_arn = aws_iam_role.ecs_task_exec.arn
  network_mode       = "awsvpc"
  cpu                = "1024"
  memory             = "2048"

  requires_compatibilities = [
    "FARGATE"
  ]

  proxy_configuration {
    type           = "APPMESH"
    container_name = "envoy"
    properties = {
      "ProxyIngressPort" = "15000"
      "ProxyEgressPort"  = "15001"
      "AppPorts"         = "8090"
      "EgressIgnoredIPs" = "169.254.170.2,169.254.169.254"
      "IgnoredUID"       = "1337"
    }
  }

  container_definitions = templatefile(
    "taskdef/backend_auth.tpl",
    {
      aws_region      = local.region
      container_name  = local.task_def_family_backend_auth
      container_image = "${local.account_id}.dkr.ecr.${local.region}.amazonaws.com/onecloud-fargate-backend-auth:latest"
      app_mesh_node   = "mesh/fargate-microservice-mesh/virtualNode/auth-node"
      # app_mesh_resource = aws_appmesh_virtual_node.api.arn
    }
  )

  provisioner "local-exec" {
    when    = destroy
    command = "sh ${path.module}/scripts/deregister-taskdef.sh ${self.family}"
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
  task_definition                    = "arn:aws:ecs:${local.region}:${local.account_id}:task-definition/${aws_ecs_task_definition.backend_auth.family}:${local.task_definition_revision_backend_auth}"
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

  provisioner "local-exec" {
    when    = destroy
    command = "sh ${path.module}/scripts/servicediscovery-drain.sh ${split("/", self.service_registries[0].registry_arn)[1]}"
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
  family             = local.task_def_family_backend_worker
  task_role_arn      = aws_iam_role.ecs_task.arn
  execution_role_arn = aws_iam_role.ecs_task_exec.arn
  network_mode       = "awsvpc"
  cpu                = "1024"
  memory             = "2048"

  requires_compatibilities = [
    "FARGATE"
  ]

  proxy_configuration {
    type           = "APPMESH"
    container_name = "envoy"
    properties = {
      "ProxyIngressPort" = "15000"
      "ProxyEgressPort"  = "15001"
      "AppPorts"         = "8090"
      "EgressIgnoredIPs" = "169.254.170.2,169.254.169.254"
      "IgnoredUID"       = "1337"
    }
  }

  container_definitions = templatefile(
    "taskdef/backend_worker.tpl",
    {
      aws_region      = local.region
      container_name  = local.task_def_family_backend_worker
      container_image = "${local.account_id}.dkr.ecr.${local.region}.amazonaws.com/onecloud-fargate-backend-worker:latest"
      app_mesh_node   = "mesh/fargate-microservice-mesh/virtualNode/worker-node"
      # app_mesh_resource = aws_appmesh_virtual_node.api.arn
    }
  )

  provisioner "local-exec" {
    when    = destroy
    command = "sh ${path.module}/scripts/deregister-taskdef.sh ${self.family}"
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
  task_definition                    = "arn:aws:ecs:${local.region}:${local.account_id}:task-definition/${aws_ecs_task_definition.backend_worker.family}:${local.task_definition_revision_backend_worker}"
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

  provisioner "local-exec" {
    when    = destroy
    command = "sh ${path.module}/scripts/servicediscovery-drain.sh ${split("/", self.service_registries[0].registry_arn)[1]}"
  }
}
