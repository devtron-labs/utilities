# --- VPC Module ---
module "vpc" {
  source = "./vpc"

  aws_region           = var.aws_region
  vpc_cidr             = var.vpc_cidr
  name_tag             = var.name_tag
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  azs                  = var.azs
  nat_strategy         = var.nat_strategy
  az_count             = var.az_count
  env                  = var.devtron_env

  vpc_id                      = var.existing_vpc_id
  existing_vpc_id             = var.existing_vpc_id
  existing_public_subnet_ids  = var.existing_public_subnet_ids
  existing_private_subnet_ids = var.existing_private_subnet_ids
}

# --- S3 Module ---
module "s3" {
  source = "./s3"

  create_buckets         = var.create_new_buckets 
  create_ci_cache_bucket = var.create_ci_cache_bucket
  create_backups_bucket  = var.create_backups_bucket
  unique_suffix          = var.unique_suffix
  env                    = var.env

  existing_ci_logs_arn   = var.existing_ci_logs_bucket_arn
  existing_ms_logs_arn   = var.existing_ms_logs_bucket_arn
  existing_cache_arn     = var.existing_cache_bucket_arn
  existing_backups_arn   = var.existing_backups_bucket_arn
}

# --- OIDC Bridge ---
resource "aws_iam_openid_connect_provider" "oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e27452241561741503b827036c2804314457713"] 
  url             = module.eks.oidc_url
}

# --- IAM Module ---
module "iam" {
  source    = "./iam"
  role_name = "devtron-custom-policy"
  cluster_name = var.cluster_name   
  aws_region   = var.aws_region    
  
  oidc_arn  = aws_iam_openid_connect_provider.oidc.arn
  oidc_url  = module.eks.oidc_url

  ci_logs_bucket_arn           = module.s3.ci_logs_bucket_arn
  microservice_logs_bucket_arn = module.s3.microservice_logs_bucket_arn
  ci_cache_bucket_arn          = module.s3.ci_cache_bucket_arn
  backups_bucket_arn           = module.s3.backups_bucket_arn
}

# --- EKS Module ---
module "eks" {
  source = "./eks"

  cluster_name       = var.cluster_name
  aws_region         = var.aws_region 
  eks_version        = var.eks_version
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  
  iam_role_arn       = module.iam.devtron_custom_role_arn
  node_role_arn      = module.iam.eks_node_role_arn
  
  # ADD THIS LINE HERE:
  ebs_csi_role_arn   = module.iam.ebs_csi_role_arn

  nodegroup_instance_types = ["t3.medium"]
  nodegroup_desired_size   = 1 
  nodegroup_min_size       = 1
  nodegroup_max_size       = 1
}


# --- RDS Module ---
module "rds" {
  source = "./rds"
  create_db            = !var.use_existing_db 
  unique_suffix        = var.unique_suffix
  env                  = var.env
  name_tag             = var.name_tag 
  db_password          = var.db_password
  db_subnet_group_name = module.vpc.db_subnet_group_name
  rds_sg_id            = module.vpc.rds_sg_id
  instance_class = var.rds_instance_class

}