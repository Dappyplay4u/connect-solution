variable "aws_region" {
  description = "AWS region to deploy into (e.g. us-west-2)."
  type        = string
  default     = "us-west-2"
}

variable "project_name" {
  description = "Short project name used as a resource name prefix (e.g. ls)."
  type        = string
}

variable "aws_region_abbr" {
  description = "Short region abbreviation (e.g. uw2 for us-west-2)."
  type        = string
  default     = "uw2"
}

variable "kms_master_key_id" {
  description = "Optional KMS key ARN for encrypting the tables, S3 bucket, and Lambda logs."
  type        = string
  default     = null
}

variable "gitlab_project_path" {
  description = "GitLab project path allowed to assume the CSV upload IAM role (e.g. mygroup/myrepo)."
  type        = string
}

# ---------------------------------------------------------------------------
# Required enterprise tags
# ---------------------------------------------------------------------------

variable "business_application_id" { type = string }
variable "cost_center" { type = string }
variable "created_by" { type = string }
variable "technical_support_by" { type = string }
variable "application_group" { type = string }
variable "technical_environment" { type = string }
variable "security_data_application" { type = string }
variable "business_application_code" { type = string }
