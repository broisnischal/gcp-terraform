resource "kubernetes_deployment" "api" {
  metadata {
    name = "api"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "api"
      }
    }
    template {
      metadata {
        labels = {
          "app" = "api"
        }
      }
      spec {
        container {
          name  = "api"
          image = var.image
          env_from {
            secret_ref {
              name = var.config_name
            }
          }
          port {
            container_port = 3000
          }
          liveness_probe {
            http_get {
              path = "/"
              port = 3000
            }
          }
          readiness_probe {
            http_get {
              path = "/"
              port = 3000
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "api" {
  metadata {
    name = "api"
  }
  spec {
    selector = {
      app = "api"
    }
    port {
      port        = 3000
      target_port = 3000
    }
  }
}

resource "kubernetes_horizontal_pod_autoscaler" "api" {
  metadata {
    name = "api"
  }
  spec {
    max_replicas = 2
    min_replicas = 2
    scale_target_ref {
      kind = "Deployment"
      name = "api-service"
    }
    # target_cpu_utilization_percentage = 75
  }
}
