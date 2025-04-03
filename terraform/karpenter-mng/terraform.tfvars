name = "terraform-new-cluster"
eks_auto_mode = true
cluster_version = "1.31"
region = "us-west-2"
vpc_cidr = "10.0.0.0/16"
azs = []
resource_tags = {
    team = "devops"
    environment = "notprod"
}
auth_mode = "API_AND_CONFIG_MAP"
public_access = true
public_access_cidr = []
enable_irsa = true