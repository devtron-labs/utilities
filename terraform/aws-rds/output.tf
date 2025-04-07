output "db_endpoint" {
  value       = aws_db_instance.this.endpoint
  description = "RDS endpoint"
}

output "db_identifier" {
  value       = aws_db_instance.this.identifier
}
output "default_db_security_group_id" {
  description = "List of security group IDs used by the DB"
  value       = length(var.vpc_security_group_ids) == 0 ? [aws_security_group.default[0].id] : var.vpc_security_group_ids
}
