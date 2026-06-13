variable "project_name" {
  description = "Project name used as resource prefix"
  type        = string
}

variable "bucket_prefix" {
  description = "Prefix for globally unique S3 bucket storing static assets"
  type        = string
}

variable "force_destroy" {
  description = "Whether Terraform can delete the bucket even when it contains objects"
  type        = bool
  default     = false
}

variable "lifecycle_enabled" {
  description = "Whether to manage an S3 lifecycle policy for retained object versions"
  type        = bool
  default     = true
}

variable "noncurrent_version_expiration_days" {
  description = "Number of days before noncurrent object versions expire"
  type        = number
  default     = 30
}

variable "abort_incomplete_multipart_upload_days" {
  description = "Number of days before incomplete multipart uploads are aborted"
  type        = number
  default     = 7
}
