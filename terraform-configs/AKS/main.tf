# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.48.0"
    }
  }
}

# Configure the Azure provider
provider "azurerm" {
  features {}
}

# Create a resource group for the AKS cluster
resource "azurerm_resource_group" "aks_rg" {
  name     = var.rg_name
  location = var.location
}

# Create the AKS cluster
resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = var.cluster_name
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  sku_tier            = "Paid"
  kubernetes_version  = "1.26" # Specify Kubernetes version
  dns_prefix = "devtron-prod"
  # Add ssh access configurations for nodes
  linux_profile {
    admin_username = "ubuntu"
    ssh_key {
      key_data = "ssh-rsa <key-here>"
    }
  }
  default_node_pool {
    name                         = "defaultpool"
    node_count                   = 1
    min_count                    = 1
    max_count                    = 1
    vm_size                      = "Standard_DS2_v2"
    os_disk_size_gb              = 30
    only_critical_addons_enabled = true
    enable_auto_scaling          = true
  }
  identity {
    type = "SystemAssigned"
  }
  tags = {
    Environment = "Production"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "devtron_pool" {
  name                  = var.devtron_pool_name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks_cluster.id
  node_count            = 1
  min_count             = 1
  max_count             = 5
  vm_size               = "Standard_D4as_v5"
  enable_auto_scaling   = true
  # Add labels on nodes
  node_labels = {
    lifeCycle = "ondemand"
    purpose   = "prod"
  }
  # Specify configuration for kubelet
  kubelet_config {
    cpu_manager_policy = "static"
  }
  tags = {
      Environment = "Production"
      purpose = "prod"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "ci_pool" {
  name                  = var.ci_pool_name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks_cluster.id
  node_count            = 1
  min_count             = 1
  max_count             = 10
  vm_size               = "Standard_D8s_v5"
  enable_auto_scaling   = true
  # enable_node_public_ip = true
  priority              = "Spot"
  spot_max_price        = 0.8
  eviction_policy       = "Delete"
  # Add labels on nodes
  node_labels = {
    purpose   = "ci"
    "kubernetes.azure.com/scalesetpriority" = "spot"
  }
  # Add node taints
  node_taints = [ "kubernetes.azure.com/scalesetpriority=spot:NoSchedule" ]
  # Specify configuration for kubelet
  kubelet_config {
    cpu_manager_policy = "static"
  }
  tags = {
    Environment = "Production"
  }
}

resource "azurerm_storage_account" "devtron_blob_storage" {
  name = var.storage_account_name
  resource_group_name = var.rg_name
  location = var.location
  account_tier = "Standard"
  account_replication_type = "LRS"
  allow_nested_items_to_be_public = false
  public_network_access_enabled = false
  blob_properties {
    versioning_enabled = true
  }
  network_rules {
    default_action = "Deny"
    bypass = [ "AzureServices" ]
  }
}
