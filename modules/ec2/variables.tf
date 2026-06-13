variable "project_name" {
  description = "Project name used as resource prefix"
  type        = string
}

variable "subnet_id" {
  description = "Public subnet ID where EC2 web server is deployed"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID attached to EC2 web server"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "page_title" {
  description = "HTML title for the web server landing page"
  type        = string
  default     = "Terraform AWS Webapp Foundation"
}

variable "badge_text" {
  description = "Badge text shown on the web server landing page"
  type        = string
  default     = "AWS Terraform Foundation"
}

variable "headline" {
  description = "Headline shown on the web server landing page"
  type        = string
  default     = "Web application infrastructure deployed with Terraform"
}

variable "description" {
  description = "Short description shown on the web server landing page"
  type        = string
  default     = "This EC2 web server was provisioned from reusable Terraform modules."
}
