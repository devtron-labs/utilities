variable "role_name" {}
variable "cluster_name" {}
variable "aws_region" {}
variable "oidc_arn" {}
variable "oidc_url" {}

# These are for your existing S3 logic
variable "ci_logs_bucket_arn" {}
variable "microservice_logs_bucket_arn" {}
variable "ci_cache_bucket_arn" {}
variable "backups_bucket_arn" {}