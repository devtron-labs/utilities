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
subnet_ids            = ["subnet-id", "subnet-id"]
vpc_id                = "vpc-id"

tags = {
  Project = "DevOps"
  Env     = "Dev"
  Team    = "backend"
}