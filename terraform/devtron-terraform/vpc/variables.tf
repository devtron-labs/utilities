variable "aws_region"          { type = string }
variable "vpc_cidr"            { type = string }
variable "name_tag"            { type = string }
variable "public_subnet_cidrs" { type = list(string) }
variable "private_subnet_cidrs" { type = list(string) }
variable "azs"                 { type = list(string) }
variable "nat_strategy"        { type = string }
variable "az_count"            { type = number }
variable "env"                 { type = string }
variable "vpc_id" {
  type    = string
  default = ""
}

# --- Existing Infrastructure IDs ---
variable "existing_vpc_id" {
  type    = string
  default = ""
}

variable "existing_public_subnet_ids" {
  type    = list(string)
  default = []
}

variable "existing_private_subnet_ids" {
  type    = list(string)
  default = []
}


# Ensure a newline is at the end of this file