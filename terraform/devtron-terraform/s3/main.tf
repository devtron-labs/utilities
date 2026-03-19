# s3/main.tf

# 1. CI Logs Bucket
resource "aws_s3_bucket" "ci_logs" {
  count  = var.create_buckets ? 1 : 0
  # Added terraform.workspace to ensure uniqueness across environments
  bucket = "ci-logs-${terraform.workspace}-${var.unique_suffix}"
}

# 2. Microservice Logs Bucket
resource "aws_s3_bucket" "microservice_logs" {
  count  = var.create_buckets ? 1 : 0
  bucket = "microservice-logs-${terraform.workspace}-${var.unique_suffix}"
}

# 3. CI Cache Bucket
resource "aws_s3_bucket" "ci_cache" {
  count  = (var.create_buckets && var.create_ci_cache_bucket) ? 1 : 0
  bucket = "ci-cache-${terraform.workspace}-${var.unique_suffix}"
}

# 4. Backups Bucket
resource "aws_s3_bucket" "backups" {
  count  = (var.create_buckets && var.create_backups_bucket) ? 1 : 0
  bucket = "backups-${terraform.workspace}-${var.unique_suffix}"
}

# --- Encryption (Controlled by a new var.enable_encryption) ---

resource "aws_s3_bucket_server_side_encryption_configuration" "ci_logs_enc" {
  # Added var.enable_encryption check
  count  = (var.create_buckets && var.enable_encryption) ? 1 : 0
  bucket = aws_s3_bucket.ci_logs[0].id
  rule {
    apply_server_side_encryption_by_default { sse_algorithm = "AES256" }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "ms_logs_enc" {
  count  = (var.create_buckets && var.enable_encryption) ? 1 : 0
  bucket = aws_s3_bucket.microservice_logs[0].id
  rule {
    apply_server_side_encryption_by_default { sse_algorithm = "AES256" }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "ci_cache_enc" {
  count  = (var.create_buckets && var.create_ci_cache_bucket && var.enable_encryption) ? 1 : 0
  bucket = aws_s3_bucket.ci_cache[0].id
  rule {
    apply_server_side_encryption_by_default { sse_algorithm = "AES256" }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "backups_enc" {
  count  = (var.create_buckets && var.create_backups_bucket && var.enable_encryption) ? 1 : 0
  bucket = aws_s3_bucket.backups[0].id
  rule {
    apply_server_side_encryption_by_default { sse_algorithm = "AES256" }
  }
}