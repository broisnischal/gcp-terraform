locals {
  name = "application-config"
}

resource "kubernetes_secret" "k8s_config" {
  metadata {
    name = local.name
  }

  data = {
    NODE_ENV    = var.environment
    BASE_DOMAIN = var.base_domain
  }
}
