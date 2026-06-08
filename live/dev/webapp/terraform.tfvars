aws_region  = "ap-southeast-1"
aws_profile = "default"

project_name = "terraform-aws-webapp-foundation"
environment  = "dev"

vpc_cidr                 = "10.20.0.0/16"
public_subnet_cidr       = "10.20.1.0/24"
private_db_subnet_a_cidr = "10.20.11.0/24"
private_db_subnet_b_cidr = "10.20.12.0/24"

availability_zone_a = "ap-southeast-1a"
availability_zone_b = "ap-southeast-1b"

ec2_instance_type = "t3.micro"

rds_instance_class = "db.t3.micro"
rds_multi_az       = false

static_assets_bucket_prefix = "tf-dev-webapp-foundation-assets-"
