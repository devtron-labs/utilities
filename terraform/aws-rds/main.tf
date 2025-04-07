locals {
  effective_sg_ids = (
    length(var.vpc_security_group_ids) == 0 && length(aws_security_group.default) > 0
    ? [aws_security_group.default[0].id]
    : var.vpc_security_group_ids
  )
}

resource "aws_security_group" "default" {
  count       = length(var.vpc_security_group_ids) == 0 ? 1 : 0
  name        = "default-db-access-sg"
  description = "Security group with DB access ports open"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = [
      { port = 3306, description = "MySQL" },
      { port = 5432, description = "PostgreSQL" },
      { port = 27017, description = "MongoDB" },
      { port = 1433, description = "MSSQL" },
      { port = 1521, description = "Oracle" }
    ]
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"] # Update with restricted CIDR as needed
      description = ingress.value.description
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "default-db-sg"
  })
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.db_identifier}-subnet-group"
  subnet_ids = var.subnet_ids
  tags       = var.tags
}

resource "aws_db_instance" "this" {
  identifier               = var.db_identifier
  engine                   = var.engine
  engine_version           = var.engine_version
  instance_class           = var.instance_class
  allocated_storage        = var.allocated_storage
  db_name                  = var.db_name
  username                 = var.username
  password                 = var.password
  multi_az                 = var.multi_az
  publicly_accessible      = var.publicly_accessible
  db_subnet_group_name     = aws_db_subnet_group.this.name
  vpc_security_group_ids   = local.effective_sg_ids
  skip_final_snapshot      = true
  delete_automated_backups = true

  tags = var.tags
}
