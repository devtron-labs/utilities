variable "cluster_name" { type = string }
variable "aws_region"   { type = string }
variable "eks_version"  { type = string }
variable "vpc_id"       { type = string }

variable "public_subnet_ids"  { type = list(string) }
variable "private_subnet_ids" { type = list(string) }

variable "iam_role_arn"  { type = string }
variable "node_role_arn" { type = string }

variable "nodegroup_instance_types" { type = list(string) }
variable "nodegroup_desired_size"   { type = number }
variable "nodegroup_min_size"       { type = number }
variable "nodegroup_max_size"       { type = number }

variable "ebs_csi_role_arn" { 
  description = "IAM role ARN for the EBS CSI driver"
  type        = string 
}

# Press ENTER here to ensure there is a blank line at the bottom