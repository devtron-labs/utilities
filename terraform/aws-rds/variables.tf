variable "db_identifier" {
  description = "The DB instance identifier"
  type        = string
}

variable "engine" {
  description = "The database engine to use (e.g., mysql, postgres)"
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "The version of the DB engine"
  type        = string
  default     = "16.4"
}

variable "instance_class" {
  description = "The RDS instance type"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "The amount of storage (in GB)"
  type        = number
  default     = 20
}

variable "db_name" {
  description = "The name of the initial database"
  type        = string
}

variable "username" {
  description = "Master DB username"
  type        = string
}

variable "password" {
  description = "Master DB password"
  type        = string
  sensitive   = true
}

variable "multi_az" {
  description = "Whether to deploy RDS in Multi-AZ mode"
  type        = bool
  default     = false
}

variable "publicly_accessible" {
  description = "Whether the RDS instance is publicly accessible"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to assign to the RDS instance"
  type        = map(string)
  default     = {}
}

variable "vpc_security_group_ids" {
  description = "Optional: Provide security group IDs. If not set, a new security group will be created."
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "VPC id"
  type = string
  default = ""
}

variable "subnet_ids" {
  description = "List of subnet IDs for RDS subnet group"
  type        = list(string)
}