variable "project_id" {
  description = "The project ID to host the cluster in"
}
variable "region_name" {
  description = "The region to host the cluster in"
  default     = "europe-central1"
}

#cluster_info
variable "cluster_name" {
  description = "The name for the GKE cluster"
  default     = "gke-cluster"
}
variable "remove_default_node_pool_value"{
  description = "Define if We need to keep default node pool or not"
  default = "true"
}
variable "initial_node_count_default" {
  description = "Initial node count at the time of  cluster creation "
  default = "1"
}
variable "networking_mode_value" {
  description = "Determines whether alias IPs or routes will be used for pod IPs in the cluster."
  default     = "VPC_NATIVE"
}
variable "release_channel_value" {
  description = "Configuration options for the Release channel feature, which provide more control over automatic upgrades of your GKE clusters."
  default     = "REGULAR"
}

#private_cluster_config
variable "enable_private_nodes_value" {
  description = "Enables the private cluster feature, creating a private endpoint on the cluster."
  default     = "true"
}
variable "enable_private_endpoint_value" {
  description = "When true, the cluster's private endpoint is used as the cluster endpoint and access through the public endpoint is disabled. When false, either endpoint can be used. This field only applies to private clusters, when enable_private_nodes is true."
  default     = "true"
}
variable "master_ipv4_cidr_block_value" {
  description = "The IP range in CIDR notation to use for the hosted master network. This range will be used for assigning private IP addresses to the cluster master(s) and the ILB VIP. "
  default     = "172.16.0.0/28"
}

#master_authorized_networks_config.cidr_blocks
#The desired configuration options for master authorized networks. 
variable "cidr_block_value" {
  description = "External network that can access Kubernetes master through HTTPS. Must be specified in CIDR notation."
  default     = "10.0.0.0/18"
}
variable "cidr_block_display_name" {
  description = "Field for users to identify CIDR blocks."
  default     = "private-subnet-w-jenkins"
}

#nat_info
#A NAT service created in a router.
variable "nat_name" {
  description = "Name of the NAT service"
  default = "gke-nat"
}
variable "source_subnetwork_ip_ranges_to_nat_value" {
  description = "How NAT should be configured per Subnetwork."
  default = "LIST_OF_SUBNETWORKS"
}
variable "nat_ip_allocate_option_value" {
  description = "How external IPs should be allocated for this NAT. Valid values are - AUTO_ONLY for only allowing NAT IPs allocated by Google Cloud Platform, or MANUAL_ONLY for only user-allocated NAT IP addresses. "
  default = "MANUAL_ONLY"
}
#subnetwork block under Nat
variable "source_ip_ranges_to_nat_value" {
  description = "List of options for which source IPs in the subnetwork should have NAT enabled."
  default = "ALL_IP_RANGES"
}
#google_compute_address
#Represents an Address resource.
variable "address_type_value" {
  description = "The type of address to reserve"
  default = "EXTERNAL"
}
variable "network_tier_value" {
  description = "TThe networking tier used for configuring this address. If this field is not specified, it is assumed to be PREMIUM. "
  default = "PREMIUM"
}

#google_service_account
#Allows management of a Google Cloud service account.
variable "account_id_value" {
  description = " The account id that is used to generate the service account email address and a stable unique id. "
  default = "kubernetes"
}

#google_container_node_pool for deaf
#Manages a node pool in a Google Kubernetes Engine (GKE) cluster separately from the cluster control plane.
variable "default_node_pool_name" {
  description = "The name of the node pool. If left blank, Terraform will auto-generate a unique name."
  default = "general"
}
variable "default_node_pool_node_count" {
  description = " The number of nodes per instance group."
  default = "1"
}
#The management block supports:
variable "default_auto_repair_value" {
  description = "Whether the nodes will be automatically repaired."
  default = "true"
}
variable "default_auto_upgrade_value" {
  description = "Whether the nodes will be automatically upgraded."
  default = "true"
}
#The node_config block for 
variable "default_preemptible_value" {
  description = "Preemptible VMs are Compute Engine VM instances that are priced lower than standard VMs and provide no guarantee of availability. Preemptible VMs offer similar functionality to Spot VMs, but only last up to 24 hours after creation."
  default = "false"
}
variable "default_machine_type_name" {
  description = "The name of a Google Compute Engine machine type"
  default = "e2-medium"
}

#google_compute_router
variable "router_name" {
  description = "Router Name"
  default = "gke-router"
}

#google_compute_subnetwork
variable "subnetwork" {
  description = "The subnetwork created to host the cluster in"
  default     = "gke-subnet"
}
variable "ip_range_pods_name" {
  description = "The secondary ip range to use for pods"
  default     = "ip-range-pods"
}
variable "ip_range_services_name" {
  description = "The secondary ip range to use for services"
  default     = "ip-range-services"
}
variable "ip_cidr_pods_range"{
  description = "2nd ip range for pods"
  default = "10.48.0.0/14"
}
variable "ip_cidr_service_range"{
  description = "2nd ip range for service"
  default = "10.52.0.0/20"
}


#google_compute_network
variable "instance_name" {
  description = "Instance Name"
  default     = "gke-instance"
}
variable "routing_mode_type" {
  description = "The network-wide routing mode to use."
  default     = "REGIONAL"
}
variable "auto_create_subnetworks_value" {
  description = "When set to true, the network is created in auto subnet mode and it will create a subnet for each region automatically across the 10.128.0.0/9 address range. When set to false, the network is created in custom subnet mode so the user can explicitly connect subnetwork resources."
  default     = "false"
}
variable "mtu_value" {
  description = "Maximum Transmission Unit in bytes. The minimum value for this field is 1460 and the maximum value is 1500 bytes."
  default     = "1460"
}
variable "delete_default_routes_on_create_value" {
  description = "if set to true, default routes (0.0.0.0/0) will be deleted immediately after network creation. Defaults to false."
  default     = "false"
}

#log_bucket
variable "log_bucket_name" {
  description = "Bucket Name for log"
  default     = "${var.cluster_name}-log-bucket"
}

#cache_bucket
variable "cache_bucket_name" {
  description = "Bucket Name for cache"
  default     = "${var.cluster_name}-cache-bucket"
}

variable "bucket_storage_type" {
  description = "Bucket storage type for log bucket"
  default     = "STANDARD"
}
