# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster
resource "google_container_cluster" "primary" {
  name                     = var.cluster_name
  location                 = "${var.region_name}-a"
  remove_default_node_pool = var.remove_default_node_pool_value
  initial_node_count       = var.initial_node_count_default
  network                  = google_compute_network.main.self_link
  subnetwork               = google_compute_subnetwork.private.self_link
  logging_service          = "logging.googleapis.com/kubernetes"
  monitoring_service       = "monitoring.googleapis.com/kubernetes"
  networking_mode          = var.networking_mode_value

  # Optional, if you want multi-zonal cluster
  node_locations = [
    "${var.region_name}-b"
  ]

  addons_config {
    http_load_balancing {
      disabled = true
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
  }

  release_channel {
    channel = var.release_channel_value
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = var.ip_range_pods_name
    services_secondary_range_name = var.ip_range_services_name
  }

  private_cluster_config {
    enable_private_nodes    = var.enable_private_nodes_value
    enable_private_endpoint = var.enable_private_endpoint_value
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block_value
  }

  #Jenkins use case
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = var.cidr_block_value
      display_name = var.cidr_block_display_name
       }
     }
}
