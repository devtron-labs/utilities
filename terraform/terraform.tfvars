# Default values are already added in Variable.tf file . kindly modify accordingly if needed

#provide GCP's Project ID (Required)
project_id = "ankur-367417"

#provide a Region Default is "europe-central1"
region_name = "asia-south1"

#cluster_info

#The name for the GKE cluster
cluster_name = "gke-cluster"

#Define if We need to keep default node pool or not
remove_default_node_pool_value = "true"

#Initial node count at the time of  cluster creation
initial_node_count_default = "1"

#Determines whether alias IPs or routes will be used for pod IPs in the cluster.
networking_mode_value = "VPC_NATIVE"

#Configuration options for the Release channel feature, which provide more control over automatic upgrades of your GKE clusters.
release_channel_value = "REGULAR"


#private_cluster_config

#Enables the private cluster feature, creating a private endpoint on the cluster.
enable_private_nodes_value = "true"

#When true, the cluster's private endpoint is used as the cluster endpoint and access through the public endpoint is disabled. When false, either endpoint can be used. This field only applies to private clusters, when enable_private_nodes is true.
enable_private_endpoint_value = "true"

#The IP range in CIDR notation to use for the hosted master network. This range will be used for assigning private IP addresses to the cluster master(s) and the ILB VIP.
master_ipv4_cidr_block_value = "172.16.0.0/28"

#master_authorized_networks_config.cidr_blocks
#The desired configuration options for master authorized networks.
#External network that can access Kubernetes master through HTTPS. Must be specified in CIDR notation.
cidr_block_value = "10.0.0.0/18"

#Field for users to identify CIDR blocks.
cidr_block_display_name = "private-subnet-w-jenkins"

#nat_info
#A NAT service created in a router.

#Name of the NAT service
nat_name = "gke-nat"

#"How NAT should be configured per Subnetwork."
source_subnetwork_ip_ranges_to_nat_value = "LIST_OF_SUBNETWORKS"

#How external IPs should be allocated for this NAT. Valid values are - AUTO_ONLY for only allowing NAT IPs allocated by Google Cloud Platform, or MANUAL_ONLY for only user-allocated NAT IP addresses. "
nat_ip_allocate_option_value = "MANUAL_ONLY"

#subnetwork block under Nat
#List of options for which source IPs in the subnetwork should have NAT enabled."
source_ip_ranges_to_nat_value = "ALL_IP_RANGES"

#google_compute_address
#Represents an Address resource.

#"The type of address to reserve
address_type_value = "EXTERNAL"

#The networking tier used for configuring this address. If this field is not specified, it is assumed to be PREMIUM. 
network_tier_value = "PREMIUM"

#google_service_account
#Allows management of a Google Cloud service account.

#The account id that is used to generate the service account email address and a stable unique id. "
account_id_value = "kubernetes"

#google_container_node_pool for deaf
#Manages a node pool in a Google Kubernetes Engine (GKE) cluster separately from the cluster control plane.

#Name of the node pool. If left blank, Terraform will auto-generate a unique name.
default_node_pool_name = "general"

#The number of nodes per instance group.
default_node_pool_node_count = "1"

#The management block supports:

#Whether the nodes will be automatically repaired.
default_auto_repair_value = "true"

#Whether the nodes will be automatically upgraded
default_auto_upgrade_value = "true"

#The node_config block for 
#Preemptible VMs are Compute Engine VM instances that are priced lower than standard VMs and provide no guarantee of availability. Preemptible VMs offer similar functionality to Spot VMs, but only last up to 24 hours after creation."
default_preemptible_value = "false"

#The name of a Google Compute Engine machine type
default_machine_type_name = "e2-medium"


#google_compute_router

#Name of the router
router_name = "gke-router"


#google_compute_subnetwork
#The subnetwork created to host the cluster IN
subnetwork = "gke-subnet"

#The secondary ip range to use for pods
ip_range_pods_name = "ip-range-pods"

#The secondary ip range to use for services
ip_range_services_name = "ip-range-services"

#2nd ip range for pods
ip_cidr_pods_range = "10.48.0.0/14"

#2nd ip range for service
ip_cidr_service_range = "10.52.0.0/20"

#google_compute_network
#Name of Instance
instance_name = "gke-instance"

#The network-wide routing mode to use
routing_mode_type = "REGIONAL"

#When set to true, the network is created in auto subnet mode and it will create a subnet for each region automatically across the 10.128.0.0/9 address range. When set to false, the network is created in custom subnet mode so the user can explicitly connect subnetwork resources."
auto_create_subnetworks_value = "false"

#Maximum Transmission Unit in bytes. The minimum value for this field is 1460 and the maximum value is 1500 bytes.
mtu_value = "1460"

#if set to true, default routes (0.0.0.0/0) will be deleted immediately after network creation. Defaults to false.
delete_default_routes_on_create_value = "false"

