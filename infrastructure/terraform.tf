terraform {
  required_version = ">= 1.0.3"
  required_providers {
    google     = "~> 4.0.0"
    kubernetes = "~> 2.0.0"
    helm       = "~> 2.0.0"
    random     = "~> 3.6.2"
  }
}
