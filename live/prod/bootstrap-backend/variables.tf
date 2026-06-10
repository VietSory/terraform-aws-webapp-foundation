variable "aws_region" {
  description = "AWS region used for this Terraform project"
  type        = string
  default     = "ap-southeast-1"
}

variable "aws_profile" {
  description = "AWS CLI profile used by Terraform"
  type        = string
  default     = "default"
}

variable "project_name" {
  description = "Repository or project name used in naming and tagging"
  type        = string
  default     = "terraform-aws-webapp-foundation"
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
  default     = "prod"
}

variable "state_bucket_prefix" {
  description = "Prefix for globally unique S3 bucket storing Terraform state"
  type        = string
  default     = "tf-prod-webapp-foundation-state-"
}

variable "lock_table_name" {
  description = "DynamoDB table name used for Terraform state locking"
  type        = string
  default     = "tf-prod-webapp-foundation-locks"
}
