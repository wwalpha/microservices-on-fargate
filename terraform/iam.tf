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
# AWS ECS Task Execution Policy - XRay Write Access
# ----------------------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "xray_write_access" {
  role       = aws_iam_role.ecs_task_exec.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

# ----------------------------------------------------------------------------------------------
# AWS ECS Task Execution Policy
# ----------------------------------------------------------------------------------------------
resource "aws_iam_role_policy" "inline" {
  name   = "inline-policy"
  role   = aws_iam_role.ecs_task_exec.id
  policy = file("iam/inline-policy.json")
}
