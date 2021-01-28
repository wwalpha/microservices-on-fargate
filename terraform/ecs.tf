# ----------------------------------------------------------------------------------------------
# ECR
# ----------------------------------------------------------------------------------------------
resource "aws_ecr_repository" "fargate" {
  name                 = "onecloud-fargate"
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
  family                = aws_ecs_cluster.fargate.name
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
  desired_count                      = 2
  launch_type                        = "FARGATE"
  platform_version                   = "1.4.0"
  task_definition                    = aws_ecs_task_definition.frontend.arn
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  network_configuration {
    assign_public_ip = false
    subnets          = var.vpc_subnet_ids
    security_groups  = var.vpc_security_groups
  }
  scheduling_strategy = "REPLICA"

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend.arn
    container_name   = "onecloud-fargate-microservice"
    container_port   = 80
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}

# # ----------------------------------------------------------------------------------------------
# # Application AutoScaling ScalableTarget - ECS
# # ----------------------------------------------------------------------------------------------
# resource "aws_appautoscaling_target" "frontend_target" {
#   max_capacity       = 4
#   min_capacity       = 1
#   resource_id        = "service/${aws_ecs_cluster.example.name}/${aws_ecs_service.example.name}"
#   scalable_dimension = "ecs:service:DesiredCount"
#   service_namespace  = "ecs"
# }

# # ----------------------------------------------------------------------------------------------
# # Application AutoScaling Policy - ECS
# # ----------------------------------------------------------------------------------------------
# resource "aws_appautoscaling_policy" "ecs_policy" {
#   name               = "scale-down"
#   policy_type        = "StepScaling"
#   resource_id        = aws_appautoscaling_target.ecs_target.resource_id
#   scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
#   service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

#   step_scaling_policy_configuration {
#     adjustment_type         = "ChangeInCapacity"
#     cooldown                = 60
#     metric_aggregation_type = "Maximum"

#     step_adjustment {
#       metric_interval_upper_bound = 0
#       scaling_adjustment          = -1
#     }
#   }
# }
