# variables.tf

variable "project_id" {
  description = "The ID of the GCP project"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "us-central1" # You can set a default or leave it out to require it during `terraform apply`
}

variable "gcp_svc_key" {
  description = "The path to the GCP service account key"
  type        = string
}

variable "environment" {
  type    = string
  default = "production"
}

variable "domain" { type = string }

variable "client_image" { type = string }
variable "api_image" { type = string }
variable "api_url" { type = string }

variable "client_url" { type = string }
variable "gke_zone" { type = string }
variable "google_cloud_project" { type = string }

variable "email" {
  type = string


}

# variable "gke_zone" { type = string }
