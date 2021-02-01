# ----------------------------------------------------------------------------------------------
# Application Load Balancer - Public
# ----------------------------------------------------------------------------------------------
resource "aws_lb" "public" {
  name               = "onecloud-fargate-public"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.vpc_security_groups
  subnets            = var.public_subnet_ids
}

# ----------------------------------------------------------------------------------------------
# Load Balancer Target Group - Frontend
# ----------------------------------------------------------------------------------------------
resource "aws_lb_target_group" "frontend" {
  name        = "onecloud-fargate-frontend"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
}

# ----------------------------------------------------------------------------------------------
# Load Balancer Listener - Frontend
# ----------------------------------------------------------------------------------------------
resource "aws_lb_listener" "frontend" {
  load_balancer_arn = aws_lb.public.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

# ----------------------------------------------------------------------------------------------
# Load Balancer Target Group - Backend API
# ----------------------------------------------------------------------------------------------
resource "aws_lb_target_group" "backend_api" {
  name        = "onecloud-fargate-backend-api"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
}

# ----------------------------------------------------------------------------------------------
# Load Balancer Listener Rule - Backend API
# ----------------------------------------------------------------------------------------------
resource "aws_lb_listener_rule" "backend_api" {
  priority     = 1
  listener_arn = aws_lb_listener.frontend.arn

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_api.arn
  }
}

# ----------------------------------------------------------------------------------------------
# Application Load Balancer - private
# ----------------------------------------------------------------------------------------------
# resource "aws_lb" "private" {
#   name               = "onecloud-fargate-private"
#   internal           = true
#   load_balancer_type = "application"
#   security_groups    = var.vpc_security_groups
#   subnets            = var.public_subnet_ids
# }

# ----------------------------------------------------------------------------------------------
# Load Balancer Listener - Private
# ----------------------------------------------------------------------------------------------
# resource "aws_lb_listener" "private" {
#   load_balancer_arn = aws_lb.private.arn
#   port              = "8090"
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.backend_auth.arn
#   }
# }

# ----------------------------------------------------------------------------------------------
# Load Balancer Target Group - Backend Auth
# ----------------------------------------------------------------------------------------------
# resource "aws_lb_target_group" "backend_auth" {
#   name        = "onecloud-fargate-backend-auth"
#   port        = 8090
#   protocol    = "HTTP"
#   target_type = "ip"
#   vpc_id      = var.vpc_id
# }
