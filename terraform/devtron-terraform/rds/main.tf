resource "aws_db_instance" "this" {
  count             = var.create_db ? 1 : 0

  identifier        = "devtron-db-${var.unique_suffix}"
  engine            = "postgres"
  engine_version    = "16"
  instance_class    = var.instance_class
  allocated_storage = 20
  
  # Requirement: Encryption
  storage_encrypted = true

  db_name  = "devtron"
  username = "dbadmin"
  password = var.db_password # Mark as sensitive in variables

  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = [var.rds_sg_id]
  
  skip_final_snapshot = true
  publicly_accessible = false

  tags = {
    Name        = "${var.name_tag}-rds-${var.unique_suffix}"
    Environment = var.env
  }
}