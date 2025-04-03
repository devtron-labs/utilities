variable "name" {
    description = "Name of the EKS cluster"
    type = string
    default = "terraform-eks-cluster"  
}

variable "eks_auto_mode" {
  description = "Set to true to create an auto-configured EKS cluster"
  type        = bool
  default     = false
}

variable "cluster_version" {
    description = "EKS Cluster version"
    type = string
    default = "1.31"
}

variable "region" {
    description = "AWS region"
    type = string
    default = "us-west-2"
}

variable "vpc_cidr"{
    description = "CIDR block for VPC"
    type = string
    default = "10.0.0.0/16"
}

variable "azs"{
    description = "List of available zone"
    type = list(string)
    default = []
}

variable "resource_tags"{
    description = "Tags to set for all AWS resources"
    type = map(string)
    default = {
        team = "devops"
        environment = "notprod" 
    }
}

variable "auth_mode" {
    description = "Define EKS authentication mode"
    type = string
    default = "API_AND_CONFIG_MAP"
}

variable "public_access" {
    description = "Enable Public Access of EKS cluster Endpoint"
    type = bool
    default = false
}

variable "public_access_cidr" {
    description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint"
    type = list(string)
    default = [ "0.0.0.0/0" ] 
}

variable "enable_irsa" {   
    description = "Determine whether IRSA is enabled"
    type = bool
    default = true
}