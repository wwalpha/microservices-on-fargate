# ----------------------------------------------------------------------------------------------
# Application Load Balancer - Public
# ----------------------------------------------------------------------------------------------
resource "aws_lb" "public" {
  name               = "onecloud-fargate-public"
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
# Load Balancer Listener Rule - Backend Public
# ----------------------------------------------------------------------------------------------
resource "aws_lb_listener_rule" "backend_public" {
  priority     = 1
  listener_arn = aws_lb_listener.frontend.arn

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_public.arn
  }
}

# ----------------------------------------------------------------------------------------------
# Application Load Balancer - private
# ----------------------------------------------------------------------------------------------
resource "aws_lb" "private" {
  name               = "onecloud-fargate-private"
  internal           = true
  load_balancer_type = "application"
  security_groups    = var.vpc_security_groups
  subnets            = var.public_subnet_ids
}

# ----------------------------------------------------------------------------------------------
# Load Balancer Listener - Private
# ----------------------------------------------------------------------------------------------
resource "aws_lb_listener" "private" {
  load_balancer_arn = aws_lb.private.arn
  port              = "8090"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_private.arn
  }
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
