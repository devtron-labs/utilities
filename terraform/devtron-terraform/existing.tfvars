# WHEN CREATE CLUSTER WITH EXISTING VPC AND SUBNETS

# --- AWS Credentials ---
# Note: It's better to export these as ENV vars, but if you want them here:
aws_access_key = "xxxxxxxxxx"
aws_secret_key = "xxxxxxxxxx"


# --- Provider Configuration ---
aws_region     = "ap-south-1"
# Note: Access/Secret keys should ideally be set via Environment Variables 
# or an AWS Profile for security, but can be added here if needed.

# --- Networking Configuration ---
vpc_cidr            = "10.0.0.0/16"
name_tag            = "devtron-vpc"
env                 = "STAGE" # Matches the 'env' variable in root variables.tf
azs                  = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
nat_strategy         = "1peraz"
az_count             = 1

existing_vpc_id             = "vpc-xxxxxxxxx" 
existing_public_subnet_ids  = ["subnet-xxxxxxxxxxxxxxxxx", "subnet-xxxxxxxxxxxxxxxxx"] 
existing_private_subnet_ids = ["subnet-xxxxxxxxxxxxxxxxx", "subnet-xxxxxxxxxxxxxxxxx"]

# --- S3 Storage Configuration ---
unique_suffix          = "devtron001"
create_new_buckets = false
enable_encryption      = true  # The toggle we added for encryption
create_ci_cache_bucket = true
create_backups_bucket  = true


# --- ARNs for existing buckets (Required because they are in variables.tf) ---
# If you are creating NEW buckets, leave these as empty strings.
existing_ci_logs_bucket_arn = ""
existing_ms_logs_bucket_arn = ""
existing_cache_bucket_arn   = ""
existing_backups_bucket_arn = ""

# --- EKS Cluster Configuration ---
cluster_name = "devtron-eks-cluster-new"
eks_version  = "1.34"

# --- Managed Node Group (Karpenter Manager) ---
# We use a small, fixed size here because Karpenter will spin up 
# separate "Worker" pools (Spot/On-Demand) later.
nodegroup_instance_types = ["m6a.large"]
nodegroup_desired_size   = 1
nodegroup_min_size       = 1
nodegroup_max_size       = 1

# --- Database Configuration ---
use_existing_db = true
existing_db_id  = ""

#db_instance_class = "db.m6a.large"
#db_password = "YourSecurePassword123!"