# resource "google_compute_global_address" "website_ip" {
#   name = "website-lb-ip"
# }

resource "google_project_service" "dns" {
  service = "dns.googleapis.com"
}

resource "google_dns_managed_zone" "zone" {
  name       = "testnischal"
  dns_name   = "${var.domain}."
  depends_on = [google_project_service.dns]
}


resource "google_dns_record_set" "client" {
  name         = google_dns_managed_zone.zone.dns_name
  managed_zone = google_dns_managed_zone.zone.name
  type         = "A"
  ttl          = 300
  rrdatas      = [var.ip]
}

resource "google_dns_record_set" "api" {
  name         = "api.${google_dns_managed_zone.zone.dns_name}"
  type         = "A"
  ttl          = 60
  managed_zone = google_dns_managed_zone.zone.name
  rrdatas      = [var.ip]
}
