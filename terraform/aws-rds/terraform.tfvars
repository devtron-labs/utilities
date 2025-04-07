db_identifier         = "my-rds-instance"
engine                = "postgres"
engine_version        = "16.4"
instance_class        = "db.t3.micro"
allocated_storage     = 20
db_name               = "appdb"
username              = "postgres"
password              = "SuperSecure123!"
multi_az              = false
publicly_accessible   = false
subnet_ids            = ["subnet-05dfa6121f4c4e172", "subnet-0d3d3d6bfaee5d032"]
vpc_id                = "vpc-0ed9a2e7d0a825db2"

tags = {
  Project = "DevOps"
  Env     = "Dev"
  Team    = "backend"
}