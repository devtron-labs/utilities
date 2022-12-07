# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account
resource "google_service_account" "kubernetes" {
  account_id = var.account_id_value
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_node_pool
resource "google_container_node_pool" "general" {
  name       = var.default_node_pool_name
  cluster    = google_container_cluster.primary.id
  node_count = var.default_node_pool_node_count


  management {
    auto_repair  = var.default_auto_repair_value
    auto_upgrade = var.default_auto_upgrade_value
  }

  node_config {
    preemptible  = var.default_preemptible_value
    machine_type = var.default_machine_type_name

    labels = {
      role = "general"
    }

    service_account = google_service_account.kubernetes.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}


#this block is to create one spot node pool you can create as many as want
resource "google_container_node_pool" "spot" {
  name    = "spot"
  cluster = google_container_cluster.primary.id
  

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  autoscaling {
    min_node_count = 0
    max_node_count = 10
  }

  node_config {
    preemptible  = true
    machine_type = "e2-small"
    disk_size_gb = "20"
    disk_type = "pd-standard"
#   image_type = ""
#   spot = "true"

    labels = {
      team = "devops"
    }

    taint {
      key    = "instance_type"
      value  = "spot"
      effect = "NO_SCHEDULE"
    }

    service_account = google_service_account.kubernetes.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}
