variable "create_db" {
  type = bool
}

variable "unique_suffix" {
  type = string
}

variable "env" {
  type = string
}

variable "name_tag" {
  type = string
}

variable "instance_class" {
  description = "The database instance type"
  type        = string
  default     = "db.t3.medium"
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_subnet_group_name" {
  type = string
}

variable "rds_sg_id" {
  type = string
}

# Ensure there is an empty line right here at the end of the file