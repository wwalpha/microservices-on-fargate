# ----------------------------------------------------------------------------------------------
# Service Discovery Private DNS Namespace
# ----------------------------------------------------------------------------------------------
resource "aws_service_discovery_private_dns_namespace" "microservice" {
  name        = "microservice.local"
  description = "microservice.local"
  vpc         = var.vpc_id
}

# ----------------------------------------------------------------------------------------------
# Service Discovery Service
# ----------------------------------------------------------------------------------------------
resource "aws_service_discovery_service" "microservice" {
  name = "private.backend"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.microservice.id

    dns_records {
      ttl  = 60
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}
