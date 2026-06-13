aws_region  = "ap-southeast-1"
aws_profile = "default"

project_name = "terraform-aws-webapp-foundation"
environment  = "prod"

vpc_cidr                 = "10.30.0.0/16"
public_subnet_cidr       = "10.30.1.0/24"
private_db_subnet_a_cidr = "10.30.11.0/24"
private_db_subnet_b_cidr = "10.30.12.0/24"

availability_zone_a = "ap-southeast-1a"
availability_zone_b = "ap-southeast-1b"

ec2_instance_type = "t3.small"
ec2_page_title    = "Terraform AWS Webapp Foundation"
ec2_badge_text    = "AWS Terraform Foundation - Prod"
ec2_headline      = "Production web application infrastructure"
ec2_description   = "This prod EC2 web server was provisioned from reusable Terraform modules."

rds_instance_class           = "db.t3.small"
rds_multi_az                 = true
rds_backup_retention_period = 7
rds_skip_final_snapshot     = false
rds_deletion_protection     = true
rds_apply_immediately       = false

static_assets_bucket_prefix                           = "tf-prod-webapp-foundation-assets-"
static_assets_force_destroy                           = false
static_assets_lifecycle_enabled                       = true
static_assets_noncurrent_version_expiration_days      = 90
static_assets_abort_incomplete_multipart_upload_days = 7
