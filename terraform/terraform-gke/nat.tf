# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat
resource "google_compute_router_nat" "nat" {
  name   = var.nat_name
  router = google_compute_router.router.name
  region = var.region_name

  source_subnetwork_ip_ranges_to_nat = var.source_subnetwork_ip_ranges_to_nat_value
  nat_ip_allocate_option             = var.nat_ip_allocate_option_value

  subnetwork {
    name                    = google_compute_subnetwork.private.id
    source_ip_ranges_to_nat = [var.source_ip_ranges_to_nat_value]
  }

  nat_ips = [google_compute_address.nat.self_link]
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address
resource "google_compute_address" "nat" {
  name         =var.nat_name
  address_type = var.address_type_value
  network_tier = var.network_tier_value

  depends_on = [google_project_service.compute]
}
