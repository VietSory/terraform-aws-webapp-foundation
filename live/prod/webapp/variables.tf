variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "ap-southeast-1"
}

variable "aws_profile" {
  description = "AWS CLI profile used by Terraform"
  type        = string
  default     = "default"
}

variable "project_name" {
  description = "Project name used as resource prefix"
  type        = string
  default     = "terraform-aws-webapp-foundation"
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
  default     = "prod"
}

variable "vpc_cidr" {
  description = "CIDR block for the project VPC"
  type        = string
  default     = "10.20.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public web subnet"
  type        = string
  default     = "10.20.1.0/24"
}

variable "private_db_subnet_a_cidr" {
  description = "CIDR block for private DB subnet A"
  type        = string
  default     = "10.20.11.0/24"
}

variable "private_db_subnet_b_cidr" {
  description = "CIDR block for private DB subnet B"
  type        = string
  default     = "10.20.12.0/24"
}

variable "availability_zone_a" {
  description = "Primary Availability Zone"
  type        = string
  default     = "ap-southeast-1a"
}

variable "availability_zone_b" {
  description = "Secondary Availability Zone required for RDS subnet group"
  type        = string
  default     = "ap-southeast-1b"
}

variable "ec2_instance_type" {
  description = "EC2 instance type for the web server"
  type        = string
  default     = "t3.micro"
}

variable "rds_instance_class" {
  description = "RDS instance class for MySQL database"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_multi_az" {
  description = "Whether RDS should run in Multi-AZ mode"
  type        = bool
  default     = false
}

variable "rds_backup_retention_period" {
  description = "Number of days to retain automated RDS backups"
  type        = number
  default     = 7
}

variable "rds_skip_final_snapshot" {
  description = "Whether to skip the final RDS snapshot on destroy"
  type        = bool
  default     = false
}

variable "rds_deletion_protection" {
  description = "Whether deletion protection is enabled for RDS"
  type        = bool
  default     = true
}

variable "rds_apply_immediately" {
  description = "Whether RDS changes are applied immediately"
  type        = bool
  default     = false
}

variable "static_assets_bucket_prefix" {
  description = "Prefix for globally unique S3 bucket storing static assets"
  type        = string
  default     = "tf-prod-webapp-foundation-assets-"
}

variable "static_assets_force_destroy" {
  description = "Whether Terraform can delete the static assets bucket even when it contains objects"
  type        = bool
  default     = false
}

variable "static_assets_lifecycle_enabled" {
  description = "Whether S3 lifecycle management is enabled for static assets"
  type        = bool
  default     = true
}

variable "static_assets_noncurrent_version_expiration_days" {
  description = "Number of days before noncurrent static asset versions expire"
  type        = number
  default     = 90
}

variable "static_assets_abort_incomplete_multipart_upload_days" {
  description = "Number of days before incomplete static asset uploads are aborted"
  type        = number
  default     = 7
}
