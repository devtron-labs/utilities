name = "terraform-manual-cluster"
cluster_version = "1.31"
region = "us-west-2"
vpc_cidr = "10.0.0.0/16"
availability_zones = []
resource_tags = {
    team = "devops"
    environment = "notprod"
}
auth_mode = "API_AND_CONFIG_MAP"
enable_irsa = true
public_access = true
private_access_cidrs = []