output "vpc_id" {
  value = local.effective_vpc_id
}

output "private_subnet_ids" {
  value = local.final_private_subnet_ids
}

output "public_subnet_ids" {
  value = local.final_public_subnet_ids
}

output "rds_sg_id" {
  value = aws_security_group.rds_sg.id
}
output "db_subnet_group_name" {
  description = "The name of the RDS subnet group"
  value       = aws_db_subnet_group.db_subnets.name
}