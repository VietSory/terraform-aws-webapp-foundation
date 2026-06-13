module "vpc" {
  source = "../../../modules/vpc"

  project_name             = local.name_prefix
  vpc_cidr                 = var.vpc_cidr
  public_subnet_cidr       = var.public_subnet_cidr
  private_db_subnet_a_cidr = var.private_db_subnet_a_cidr
  private_db_subnet_b_cidr = var.private_db_subnet_b_cidr
  availability_zone_a      = var.availability_zone_a
  availability_zone_b      = var.availability_zone_b
}

module "security_groups" {
  source = "../../../modules/security_groups"

  project_name = local.name_prefix
  vpc_id       = module.vpc.vpc_id
}

module "ec2" {
  source = "../../../modules/ec2"

  project_name      = local.name_prefix
  subnet_id         = module.vpc.public_web_subnet_id
  security_group_id = module.security_groups.web_security_group_id
  instance_type     = var.ec2_instance_type
}

module "rds" {
  source = "../../../modules/rds"

  project_name              = local.name_prefix
  private_subnet_ids        = module.vpc.private_db_subnet_ids
  db_security_group_id      = module.security_groups.db_security_group_id
  instance_class            = var.rds_instance_class
  multi_az                  = var.rds_multi_az
  backup_retention_period   = var.rds_backup_retention_period
  skip_final_snapshot       = var.rds_skip_final_snapshot
  deletion_protection       = var.rds_deletion_protection
  apply_immediately         = var.rds_apply_immediately
}

module "s3" {
  source = "../../../modules/s3"

  project_name                            = local.name_prefix
  bucket_prefix                           = var.static_assets_bucket_prefix
  force_destroy                           = var.static_assets_force_destroy
  lifecycle_enabled                       = var.static_assets_lifecycle_enabled
  noncurrent_version_expiration_days      = var.static_assets_noncurrent_version_expiration_days
  abort_incomplete_multipart_upload_days = var.static_assets_abort_incomplete_multipart_upload_days
}
