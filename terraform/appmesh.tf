# ----------------------------------------------------------------------------------------------
# App Mesh
# ----------------------------------------------------------------------------------------------
resource "aws_appmesh_mesh" "microservice" {
  name = "microservice_mesh"

  spec {
    egress_filter {
      type = "DROP_ALL"
    }
  }
}

# ----------------------------------------------------------------------------------------------
# App Mesh - Auth Virtual Node
# ----------------------------------------------------------------------------------------------
resource "aws_appmesh_virtual_node" "auth" {
  name      = "auth_node"
  mesh_name = aws_appmesh_mesh.microservice.id

  spec {
    listener {
      port_mapping {
        port     = 8090
        protocol = "http"
      }
    }

    service_discovery {
      aws_cloud_map {
        service_name   = aws_service_discovery_service.backend_auth.name
        namespace_name = aws_service_discovery_private_dns_namespace.microservice.name
      }
    }
  }
}

# ----------------------------------------------------------------------------------------------
# App Mesh - Auth Virtual Service
# ----------------------------------------------------------------------------------------------
resource "aws_appmesh_virtual_service" "auth" {
  name      = "${aws_service_discovery_service.backend_auth.name}.${aws_service_discovery_private_dns_namespace.microservice.name}"
  mesh_name = aws_appmesh_mesh.microservice.id

  spec {
    provider {
      virtual_node {
        virtual_node_name = aws_appmesh_virtual_node.auth.name
      }
    }
  }
}

# ----------------------------------------------------------------------------------------------
# App Mesh - Worker Virtual Node
# ----------------------------------------------------------------------------------------------
resource "aws_appmesh_virtual_node" "worker" {
  name      = "worker_node"
  mesh_name = aws_appmesh_mesh.microservice.id

  spec {
    listener {
      port_mapping {
        port     = 8090
        protocol = "http"
      }
    }

    service_discovery {
      aws_cloud_map {
        service_name   = aws_service_discovery_service.backend_worker.name
        namespace_name = aws_service_discovery_private_dns_namespace.microservice.name
      }
    }
  }
}

# ----------------------------------------------------------------------------------------------
# App Mesh - Worker Virtual Service
# ----------------------------------------------------------------------------------------------
resource "aws_appmesh_virtual_service" "worker" {
  name      = "${aws_service_discovery_service.backend_worker.name}.${aws_service_discovery_private_dns_namespace.microservice.name}"
  mesh_name = aws_appmesh_mesh.microservice.id

  spec {
    provider {
      virtual_node {
        virtual_node_name = aws_appmesh_virtual_node.worker.name
      }
    }
  }
}


# ----------------------------------------------------------------------------------------------
# App Mesh - API Virtual Node
# ----------------------------------------------------------------------------------------------
resource "aws_appmesh_virtual_node" "api" {
  name      = "api_node"
  mesh_name = aws_appmesh_mesh.microservice.id

  spec {
    backend {
      virtual_service {
        virtual_service_name = aws_appmesh_virtual_service.auth.name
      }
    }

    backend {
      virtual_service {
        virtual_service_name = aws_appmesh_virtual_service.worker.name
      }
    }

    listener {
      port_mapping {
        port     = 8080
        protocol = "http"
      }
    }

    service_discovery {
      aws_cloud_map {
        service_name   = aws_service_discovery_service.backend_api.name
        namespace_name = aws_service_discovery_private_dns_namespace.microservice.name
      }
    }
  }
}
