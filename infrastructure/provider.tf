provider "google" {
  project     = var.project_id
  region      = var.region
  credentials = file(var.gcp_svc_key)
}

provider "kubernetes" {
  host                   = module.kubernetes.endpoint
  cluster_ca_certificate = module.kubernetes.cluster_ca_certificate
  token                  = module.kubernetes.token
}


provider "helm" {
  kubernetes {
    host                   = module.kubernetes.endpoint
    cluster_ca_certificate = module.kubernetes.cluster_ca_certificate
    token                  = module.kubernetes.token
  }
}

provider "random" {}
