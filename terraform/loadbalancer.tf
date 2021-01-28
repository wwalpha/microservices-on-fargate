# ----------------------------------------------------------------------------------------------
# Application Load Balancer - Frontend
# ----------------------------------------------------------------------------------------------
resource "aws_lb" "frontend" {
  name               = "onecloud-fargate-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.vpc_security_groups
  subnets            = var.public_subnet_ids

  # listener {
  #   instance_port      = 8000
  #   instance_protocol  = "http"
  #   lb_port            = 443
  #   lb_protocol        = "https"
  #   ssl_certificate_id = "arn:aws:iam::123456789012:server-certificate/certName"
  # }
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
  load_balancer_arn = aws_lb.frontend.arn
  port              = "80"
  protocol          = "HTTP"
  # ssl_policy        = "ELBSecurityPolicy-2016-08"
  # certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

# ----------------------------------------------------------------------------------------------
# Load Balancer Target Group - Backend_Public
# ----------------------------------------------------------------------------------------------
resource "aws_lb_target_group" "backend_public" {
  name        = "onecloud-fargate-backend-public"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
}

# ----------------------------------------------------------------------------------------------
# Load Balancer Target Group - Backend_Private
# ----------------------------------------------------------------------------------------------
resource "aws_lb_target_group" "backend_private" {
  name        = "onecloud-fargate-backend-private"
  port        = 8090
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
}

