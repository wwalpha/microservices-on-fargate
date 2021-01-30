output "alb_internet" {
  value = aws_lb.public.dns_name
}

output "alb_internal" {
  value = aws_lb.private.dns_name
}
