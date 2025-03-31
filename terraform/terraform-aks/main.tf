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
  tags = {
    deletion = "locked"
  }
}

# Add lock and block deletion of the created resource group
resource "azurerm_management_lock" "resource-group-lock" {
  name       = "resource-group-lock"
  scope      = azurerm_resource_group.aks_rg.id
  lock_level = "CanNotDelete"
  notes      = "Items can't be deleted in this resource group!"
}

# Create the AKS cluster
resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = var.cluster_name
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  sku_tier            = var.sku_tier
  kubernetes_version  = "1.31.6" 
  dns_prefix          = var.dns_prefix

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

resource "azurerm_kubernetes_cluster_node_pool" "od_pool" {
  name                  = var.od_pool_name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks_cluster.id
  node_count            = 1
  min_count             = 1
  max_count             = 2
  vm_size               = "Standard_D4as_v5"
  os_disk_size_gb       = 80
  enable_auto_scaling   = true

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
  os_disk_size_gb       = 50
  priority              = "Spot"
  spot_max_price        = 0.5
  eviction_policy       = "Delete"
  # Add labels on nodes
  node_labels = {
    purpose   = "ci"
    "kubernetes.azure.com/scalesetpriority" = "spot"
  }
  # Add node taints
  node_taints = [ "dedicated=ci:NoSchedule", "kubernetes.azure.com/scalesetpriority=spot:NoSchedule" ]
  # Specify configuration for kubelet
  kubelet_config {
    cpu_manager_policy = "static"
  }
  tags = {
    Environment = "Production"
  }
}

resource "azurerm_storage_account" "cd_blob_storage" {
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