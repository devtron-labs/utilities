# --- VPC Logic ---
resource "aws_vpc" "vpc" {
  count            = var.existing_vpc_id == "" ? 1 : 0
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name        = "${var.name_tag}-vpc"
    Environment = var.env
  }
}

locals {
  effective_vpc_id = var.existing_vpc_id != "" ? var.existing_vpc_id : aws_vpc.vpc[0].id
}

# --- Public Subnets ---
resource "aws_subnet" "public_subnets" {
  count                   = length(var.existing_public_subnet_ids) == 0 ? length(var.public_subnet_cidrs) : 0
  vpc_id                  = local.effective_vpc_id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.name_tag}-public-${count.index + 1}"
    Environment = var.env
  }
}

# --- Private Subnets ---
resource "aws_subnet" "private_subnets" {
  count             = length(var.existing_private_subnet_ids) == 0 ? length(var.private_subnet_cidrs) : 0
  vpc_id            = local.effective_vpc_id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name        = "${var.name_tag}-private-${count.index + 1}"
    Environment = var.env
  }
}

locals {
  final_public_subnet_ids  = length(var.existing_public_subnet_ids) > 0 ? var.existing_public_subnet_ids : aws_subnet.public_subnets[*].id
  final_private_subnet_ids = length(var.existing_private_subnet_ids) > 0 ? var.existing_private_subnet_ids : aws_subnet.private_subnets[*].id
  
  # NAT Gateway should only be created if we are creating a NEW VPC
  nat_count = (var.existing_vpc_id == "" && var.nat_strategy != "none") ? (var.nat_strategy == "1peraz" ? var.az_count : 1) : 0
}

# --- Internet Gateway ---
resource "aws_internet_gateway" "gw" {
  count  = var.existing_vpc_id == "" ? 1 : 0
  vpc_id = local.effective_vpc_id

  tags = {
    Name        = "${var.name_tag}-igw"
    Environment = var.env
  }
}

# --- NAT Gateway ---
resource "aws_eip" "nat" {
  count = local.nat_count
  tags  = { 
    Name        = "${var.name_tag}-nat-eip-${count.index + 1}"
    Environment = var.env 
  }
}

resource "aws_nat_gateway" "nat" {
  count         = local.nat_count
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = local.final_public_subnet_ids[count.index]
  depends_on    = [aws_internet_gateway.gw]

  tags = { 
    Name        = "${var.name_tag}-nat-${count.index + 1}"
    Environment = var.env
  }
}

# --- Route Tables ---
resource "aws_route_table" "public_rt" {
  count  = var.existing_vpc_id == "" ? 1 : 0
  vpc_id = local.effective_vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw[0].id
  }

  tags = {
    Name        = "${var.name_tag}-public-rt"
    Environment = var.env
  }
}

resource "aws_route_table_association" "public_subnet_asso" {
  count          = var.existing_vpc_id == "" ? length(local.final_public_subnet_ids) : 0
  subnet_id      = local.final_public_subnet_ids[count.index]
  route_table_id = aws_route_table.public_rt[0].id
}

resource "aws_route_table" "private_rt" {
  count  = local.nat_count
  vpc_id = local.effective_vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[count.index].id
  }

  tags = {
    Name        = "${var.name_tag}-private-rt-${count.index + 1}"
    Environment = var.env
  }
}

resource "aws_route_table_association" "private_subnet_asso" {
  count          = (var.existing_vpc_id == "" && local.nat_count > 0) ? length(local.final_private_subnet_ids) : 0
  subnet_id      = local.final_private_subnet_ids[count.index]
  route_table_id = element(aws_route_table.private_rt[*].id, count.index % local.nat_count)
}

# --- RDS SUPPORT RESOURCES ---

resource "aws_db_subnet_group" "db_subnets" {
  # Change name to avoid 409 conflict with existing manual resources
  name_prefix = "devtron-db-subnets-${terraform.workspace}"
  
  # NOTE: vpc_id is intentionally omitted as it's not a valid argument for this resource.
  # It is determined automatically by the subnet IDs.
  subnet_ids = local.final_private_subnet_ids

  tags = {
    Name        = "${var.name_tag}-db-subnet-group"
    Environment = var.env
  }
}

resource "aws_security_group" "rds_sg" {
  name_prefix = "devtron-rds-sg-${terraform.workspace}"
  description = "Allow Postgres traffic from VPC"
  vpc_id = local.effective_vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.name_tag}-rds-sg"
    Environment = var.env
  }
}
