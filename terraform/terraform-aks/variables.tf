variable "rg_name" {
  default = "devtron-rg"
  description = "Name for resource group to be created for this AKS cluster and related resources"
}

variable "sku_tier" {
  description = "The SKU tier for the AKS cluster (Free or Paid)"
  type        = string
  default     = "Free"
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
  default     = "devtron"
}

variable "location" {
  default = "Central India"
  description = "The Azure Region in which all resources for this AKS cluster and related resources should be provisioned"
}

variable "cluster_name" {
  default = "devtron-aks"
  description = "Name of AKS cluster to be created"
}

variable "od_pool_name" {
  default = "odpool"
  description = "Name of on-demand pool for production workloads"
}

variable "ci_pool_name" {
  default = "cipool"
  description = "Name of spot pool for general workloads"
}

variable "storage_account_name" {
  default = "devtron-storage"
  description = "Name of storage account to be created to use with devtron"
}
