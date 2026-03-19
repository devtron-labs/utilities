output "ci_logs_bucket_arn" {
  value = var.create_buckets ? aws_s3_bucket.ci_logs[0].arn : var.existing_ci_logs_arn
}

output "microservice_logs_bucket_arn" {
  value = var.create_buckets ? aws_s3_bucket.microservice_logs[0].arn : var.existing_ms_logs_arn
}

output "ci_cache_bucket_arn" {
  value = (var.create_buckets && var.create_ci_cache_bucket) ? aws_s3_bucket.ci_cache[0].arn : var.existing_cache_arn
}

output "backups_bucket_arn" {
  value = (var.create_buckets && var.create_backups_bucket) ? aws_s3_bucket.backups[0].arn : var.existing_backups_arn
}