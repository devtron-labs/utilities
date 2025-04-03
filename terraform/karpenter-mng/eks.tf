################################################################################
# Cluster
################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.24"

  cluster_name    = local.name
  cluster_version = local.cluster_version

  # Give the Terraform identity admin access to the cluster
  # which will allow it to deploy resources into the cluster
  authentication_mode                      = local.authentication_mode
  enable_cluster_creator_admin_permissions = true
  cluster_endpoint_public_access           = local.cluster_endpoint_public_access
  cluster_endpoint_public_access_cidrs     = local.cluster_endpoint_public_access_cidrs
  enable_irsa                              = local.enable_irsa

  # Conditionally install addons
  cluster_addons = {
    coredns                 = {}
    eks-pod-identity-agent  = {}
    kube-proxy              = {}
    vpc-cni                 = {}
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets


  eks_managed_node_groups =  {
    karpenter = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["c5.large"]

      min_size     = 1
      max_size     = 3
      desired_size = 2

      labels = {
        "karpenter.sh/controller" = "true"
      }
    }
  }

  node_security_group_tags = merge(local.tags, {
    "karpenter.sh/discovery" = local.name
  })

  tags = local.tags
}

output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks --region ${local.region} update-kubeconfig --name ${module.eks.cluster_name}"
}
