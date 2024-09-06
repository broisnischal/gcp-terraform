variable "name" { default = "client" }

variable "image" { type = string }

variable "environment" {
  type    = string
  default = "production"
}

variable "domain" { type = string }
