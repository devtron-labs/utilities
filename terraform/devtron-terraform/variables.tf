# ==========================================
# 1. AWS PROVIDER & AUTHENTICATION
# ==========================================

variable "aws_region" {
  type        = string
  description = "AWS region to deploy resources"
}

variable "aws_access_key" {
  description = "AWS Access Key"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS Secret Key"
  type        = string
  sensitive   = true
}

# ==========================================
# 2. NETWORKING (VPC & SUBNETS)
# ==========================================

# ==========================================
# 2. NETWORKING (VPC & SUBNETS)
# ==========================================

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16" # Added default
}

variable "name_tag" {
  type        = string
  description = "Prefix for naming resources"
}

variable "env" {
  type        = string
  description = "Environment name"
}

# Added defaults [] so it doesn't ask when using existing subnets
variable "public_subnet_cidrs" {
  type        = list(string)
  description = "List of Public subnet CIDRs"
  default     = []
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "List of Private subnet CIDRs"
  default     = []
}

variable "azs" {
  type        = list(string)
  description = "List of Availability Zones"
}

variable "nat_strategy" {
  type        = string
  description = "NAT strategy"
  default     = "none" # Added default
}

variable "az_count" {
  type        = number
  description = "Number of AZs"
  default     = 0 # Added default
}

# --- Existing Infrastructure IDs ---
variable "existing_vpc_id" {
  type    = string
  default = ""
}

variable "existing_public_subnet_ids" {
  type    = list(string)
  default = []
}

variable "existing_private_subnet_ids" {
  type    = list(string)
  default = []
}

# ==========================================
# 3. EKS CLUSTER SETTINGS
# ==========================================

variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "eks_version" {
  type        = string
  description = "Kubernetes version (e.g., 1.29)"
}

variable "nodegroup_instance_types" {
  type        = list(string)
  description = "Instance types for the managed node group (e.g., ['t3.medium'])"
}

variable "nodegroup_desired_size" {
  type        = number
  description = "Desired number of nodes (Set to 1 for Karpenter manager setup)"
}

variable "nodegroup_min_size" {
  type        = number
  description = "Minimum number of nodes"
}

variable "nodegroup_max_size" {
  type        = number
  description = "Maximum number of nodes"
}

# ==========================================
# 4. STORAGE (S3 BUCKETS)
# ==========================================

variable "unique_suffix" {
  type        = string
  description = "Unique string to prevent S3 bucket naming collisions"
}

variable "create_ci_cache_bucket" {
  type        = bool
  description = "Toggle to create the CI cache bucket"
  default     = true
}

variable "create_backups_bucket" {
  type        = bool
  description = "Toggle to create the backups bucket"
  default     = true
}


# ==========================================
# 5. DATABASE (RDS POSTGRES)
# ==========================================

variable "use_existing_db" {
  type        = bool
  description = "Set to true to skip RDS creation and use an existing instance"
  default     = false
}

variable "existing_db_id" {
  type        = string
  description = "The Identifier of an existing RDS instance"
  default     = ""
}

variable "devtron_env" {
  type    = string
  default = "prod"
}

variable "create_new_buckets" {
  type    = bool
  default = false
}

variable "existing_ci_logs_bucket_arn" { type = string }
variable "existing_ms_logs_bucket_arn" { type = string }
variable "existing_cache_bucket_arn"   { type = string }
variable "existing_backups_bucket_arn" { type = string }

variable "db_password" {
  type      = string
  sensitive = true
  default   = "RequiresPassword123!" # Or set in tfvars
}
variable "rds_instance_class" {
  description = "The instance type for the RDS database"
  type        = string
  default     = "db.t3.medium"
}
variable "enable_encryption" {
  description = "Toggle for S3 bucket encryption"
  type        = bool
  default     = false
}
variable "db_instance_class" {
  type        = string
  description = "The instance type for the RDS database (e.g., db.t3.medium)"
}