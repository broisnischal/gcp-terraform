# resource "google_project_service" "container" {
#   service = "container.googleapis.com"
# }

# data "google_client_config" "provider" {}

# resource "google_service_account" "kubernetes_cluster" {
#   account_id   = "kubernetes-cluster"
#   display_name = "Kubernetes Cluster Service Account"
#   #   depends_on   = [google_project_service.container]
# }


# resource "google_project_iam_member" "storage_admin" {
#   project = var.project
#   role    = "roles/storage.objectAdmin"
#   member  = "serviceAccount:${google_service_account.kubernetes_cluster.email}"
# }


# resource "google_container_cluster" "primary" {
#   name                     = "cluster"
#   location                 = var.region
#   initial_node_count       = 3
#   remove_default_node_pool = true
#   cluster_autoscaling {
#     enabled = true
#     resource_limits {
#       resource_type = "cpu"
#       minimum       = 1
#       maximum       = 3
#     }
#     resource_limits {
#       resource_type = "memory"
#       minimum       = 1
#       maximum       = 3
#     }
#   }

#   depends_on = [google_project_service.container]
# }

# resource "google_container_node_pool" "primary_nodes" {
#   name       = "${google_container_cluster.primary.name}-node-pool"
#   cluster    = google_container_cluster.primary.name
#   location   = var.region
#   node_count = 1
#   autoscaling {
#     min_node_count = 1
#     max_node_count = 3
#   }
#   node_config {
#     image_type      = "COS"
#     preemptible     = true
#     disk_size_gb    = 10
#     machine_type    = var.machine_type
#     service_account = google_service_account.kubernetes_cluster.email
#     oauth_scopes = [
#       "https://www.googleapis.com/auth/cloud-platform",
#       "https://www.googleapis.com/auth/logging.write",
#       "https://www.googleapis.com/auth/monitoring"
#     ]
#   }
# }

resource "google_project_service" "container" {
  service = "container.googleapis.com"
}

data "google_client_config" "provider" {}

resource "google_service_account" "kubernetes_cluster" {
  account_id   = "kubernetes-cluster"
  display_name = "Kubernetes Cluster Service Account"
  # Uncomment if necessary to ensure proper ordering
  # depends_on   = [google_project_service.container]
}

resource "google_project_iam_member" "storage_admin" {
  project = var.project
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.kubernetes_cluster.email}"
}

resource "google_project_iam_member" "kubernetes_cluster_role" {
  project = var.project
  role    = "roles/container.admin"
  member  = "serviceAccount:${google_service_account.kubernetes_cluster.email}"
}

resource "google_container_cluster" "primary" {
  name                     = "cluster"
  location                 = var.region
  initial_node_count       = 1 # Initial node count for cluster
  remove_default_node_pool = true

  cluster_autoscaling {
    enabled = true
    resource_limits {
      resource_type = "cpu"
      minimum       = 1
      maximum       = 3
    }
    resource_limits {
      resource_type = "memory"
      minimum       = 1
      maximum       = 3
    }
  }

  depends_on = [google_project_service.container]
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "${google_container_cluster.primary.name}-node-pool"
  cluster    = google_container_cluster.primary.id # Reference cluster by id
  location   = var.region
  node_count = 1 # Start with one node

  autoscaling {
    min_node_count = 1
    max_node_count = 3
  }

  node_config {
    image_type      = "COS"
    preemptible     = true
    disk_size_gb    = 10
    machine_type    = var.machine_type
    service_account = google_service_account.kubernetes_cluster.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring"
    ]
  }

  depends_on = [google_container_cluster.primary]
}
