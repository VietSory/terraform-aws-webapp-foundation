variable "project_name" {
  description = "Project name used as resource prefix"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs used by the RDS DB subnet group"
  type        = list(string)
}

variable "db_security_group_id" {
  description = "Security group ID attached to RDS"
  type        = string
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
}

variable "multi_az" {
  description = "Whether RDS runs in Multi-AZ mode"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Number of days to retain automated RDS backups"
  type        = number
  default     = 0
}

variable "skip_final_snapshot" {
  description = "Whether to skip a final snapshot when destroying the DB instance"
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "Whether deletion protection is enabled for the DB instance"
  type        = bool
  default     = false
}

variable "apply_immediately" {
  description = "Whether RDS changes are applied immediately or during the next maintenance window"
  type        = bool
  default     = true
}
