# ----------------------------------------------------------------------------------------------
# AWS ECS Task Role
# ----------------------------------------------------------------------------------------------
resource "aws_iam_role" "ecs_task" {
  name               = "OneCloud_ECSTaskRole"
  assume_role_policy = file("iam/ecs_task_principals.json")
  lifecycle {
    create_before_destroy = false
  }
}

# ----------------------------------------------------------------------------------------------
# AWS ECS Task Role Policy - CloudWatch Full Access
# ----------------------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "ecs_task_cloudwatch" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

# ----------------------------------------------------------------------------------------------
# AWS ECS Task Role Policy - XRay Daemon WriteAccess
# ----------------------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "ecs_task_xray" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

# ----------------------------------------------------------------------------------------------
# AWS ECS Task Role Policy - App Mesh Envoy Access
# ----------------------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "ecs_task_envoy" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = "arn:aws:iam::aws:policy/AWSAppMeshEnvoyAccess"
}

# ----------------------------------------------------------------------------------------------
# AWS ECS Task Execution Role
# ----------------------------------------------------------------------------------------------
resource "aws_iam_role" "ecs_task_exec" {
  name               = "OneCloud_ECSTaskExecutionRole"
  assume_role_policy = file("iam/ecs_task_principals.json")
  lifecycle {
    create_before_destroy = false
  }
}

# ----------------------------------------------------------------------------------------------
# AWS ECS Task Execution Policy - ECS Task Execution Policy
# ----------------------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "ecs_task_exec" {
  role       = aws_iam_role.ecs_task_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ----------------------------------------------------------------------------------------------
# AWS ECS Task Execution Policy
# ----------------------------------------------------------------------------------------------
resource "aws_iam_role_policy" "inline" {
  name   = "inline-policy"
  role   = aws_iam_role.ecs_task_exec.id
  policy = file("iam/inline-policy.json")
}
