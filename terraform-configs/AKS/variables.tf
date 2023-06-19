variable "rg_name" {
  default = "devtron-rg"
  description = "Name for resource group to be created for this AKS cluster and related resources"
}

variable "location" {
  default = "Central India"
  description = "The Azure Region in which all resources for this AKS cluster and related resources should be provisioned"
}

variable "cluster_name" {
  default = "devtron-aks"
  description = "Name of AKS cluster to be created"
}

variable "devtron_pool_name" {
  default = "devtronpool"
  description = "Name of devtron nodepool for microservices workloads"
}

variable "ci_pool_name" {
  default = "cipool"
  description = "Name of spot nodepool for ci workloads"
}

variable "storage_account_name" {
  default = "dtblbstr01"
  description = "Name of storage account to be created to use with devtron"
}
