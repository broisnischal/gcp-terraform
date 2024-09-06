locals {
  config_name = "client-config"
}

resource "kubernetes_deployment" "api" {
  metadata {
    name = "client"
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "client"
      }
    }

    template {
      metadata {
        labels = {
          app = "client"
        }
      }

      spec {
        container {
          name  = "client"
          image = var.image

          env_from {
            secret_ref {
              name = local.config_name
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

resource "kubernetes_service" "client" {
  metadata {
    name = "client"
  }

  spec {
    selector = {
      app = "client"
    }

    port {
      name        = "http"
      port        = 3000
      target_port = 3000
    }

    type = "LoadBalancer"
  }

  #   depends_on = [kubernetes_deployment.api]
}


resource "kubernetes_horizontal_pod_autoscaler" "client" {
  metadata {
    name = "client"
  }
  spec {
    max_replicas = 2
    min_replicas = 2
    scale_target_ref {
      kind = "Deployment"
      name = "client"
    }
  }

}
