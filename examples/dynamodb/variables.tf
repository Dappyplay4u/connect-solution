variable "aws_region" {
  description = "AWS region to deploy into (e.g. us-east-1)."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Short project/team name (e.g. tfc)."
  type        = string
}

variable "account" {
  description = "AWS account short-name (e.g. retail)."
  type        = string
}

variable "lob" {
  description = "Line-of-business identifier (e.g. tccivr)."
  type        = string
}

variable "sdlc_env" {
  description = "Deployment environment: prod, qa, or test."
  type        = string
}

variable "aws_region_abbr" {
  description = "Short region abbreviation (e.g. ue1 for us-east-1)."
  type        = string
  default     = "ue1"
}

variable "kms_master_key_id" {
  description = "Optional KMS key ARN for encrypting the table, S3 bucket, and Lambda logs."
  type        = string
  default     = null
}

variable "gitlab_project_path" {
  description = "GitLab project path allowed to assume the CSV upload IAM role (e.g. mygroup/myrepo)."
  type        = string
}

# ---------------------------------------------------------------------------
# Tags
# ---------------------------------------------------------------------------

variable "business_application_id" {
  type = string
}

variable "cost_center" {
  type = string
}

variable "created_by" {
  type = string
}

variable "technical_support_by" {
  type = string
}

variable "application_group" {
  type = string
}

variable "technical_environment" {
  type = string
}

variable "security_data_application" {
  type = string
}

variable "business_application_code" {
  type = string
}
