# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_service
resource "google_project_service" "compute" {
  service = "compute.googleapis.com"
}

resource "google_project_service" "container" {
  service = "container.googleapis.com"
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network
resource "google_compute_network" "main" {
  name                            = var.instance_name
  routing_mode                    = var.routing_mode_type
  auto_create_subnetworks         = var.auto_create_subnetworks_value
  mtu                             = var.mtu_value
  delete_default_routes_on_create = var.delete_default_routes_on_create_value

  depends_on = [
    google_project_service.compute,
    google_project_service.container
  ]
}
