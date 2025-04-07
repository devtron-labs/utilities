variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "region" {
  description = "AWS region to create the S3 bucket in"
  type        = string
}

variable "versioning_enabled" {
  description = "Enable or disable versioning for the S3 bucket"
  type        = bool
  default     = false
}

variable "acl" {
  description = "Canned ACL to apply to the bucket (e.g., private, public-read)"
  type        = string
  default     = "private"
}

variable "tags" {
  description = "Tags to apply to the S3 bucket"
  type        = map(string)
  default     = {}
}
