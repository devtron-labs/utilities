variable "unique_suffix" {
  type = string
}

variable "create_buckets" {
  type    = bool
  default = false
}

variable "create_ci_cache_bucket" {
  type = bool
}

variable "create_backups_bucket" {
  type = bool
}

# This fixes the "env" and "devtron_env" mismatch
variable "env" {
  type = string
}

# Existing ARNs
variable "existing_ci_logs_arn" {
  type    = string
  default = ""
}

variable "existing_ms_logs_arn" {
  type    = string
  default = ""
}

variable "existing_cache_arn" {
  type    = string
  default = ""
}

variable "existing_backups_arn" {
  type    = string
  default = ""
}
variable "enable_encryption" {
  description = "Flag to enable/disable server-side encryption for the buckets"
  type        = bool
  default     = false
}