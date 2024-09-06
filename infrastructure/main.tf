terraform {
  backend "gcs" {
    bucket = "learningtfnees-terraform-state"
    prefix = "production"
  }
}

module "kubernetes" {
  source       = "./modules/google-kubernetes-engine"
  project      = var.project_id
  region       = var.region
  machine_type = "e2-micro"
}

module "cert_manager" {
  source              = "./modules/kubernetes-cert-manager"
  kubernetes_endpoint = module.kubernetes.endpoint
  email               = var.email
}

module "ingress" {
  source              = "./modules/kubernetes-nginx-ingress"
  domain              = var.domain
  kubernetes_endpoint = module.kubernetes.endpoint
}

module "dns" {
  source = "./modules/domain-name-system"
  ip     = module.ingress.ip
  domain = var.domain
}

module "configuration" {
  source = "./modules/kubernetes-configuration"

  environment = var.environment

  base_domain = var.domain
  # client_url   = var.client_url
  #   api_url      = var.api_url

  kubernetes_endpoint = module.kubernetes.endpoint
}


module "api" {
  source      = "./modules/api"
  image       = var.api_image
  config_name = module.configuration.name
}


module "client" {
  source      = "./modules/client"
  image       = var.client_image
  environment = var.environment
  domain      = var.domain
}
