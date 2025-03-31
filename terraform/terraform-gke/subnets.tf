# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork
resource "google_compute_subnetwork" "private" {
  name                     = "private"
  ip_cidr_range            = "10.0.0.0/18"
  region                   = var.region_name
  network                  = google_compute_network.main.id
  private_ip_google_access = true

  secondary_ip_range {
    range_name    =var.ip_range_pods_name
    ip_cidr_range = var.ip_cidr_pods_range
  }
  secondary_ip_range {
    range_name    = var.ip_range_services_name
    ip_cidr_range = var.ip_cidr_service_range
  }
}
