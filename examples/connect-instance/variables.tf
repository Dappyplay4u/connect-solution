###############################################################################
# Connect Instance Complete Example — Variables
###############################################################################

variable "aws_region" {
  description = "AWS region (e.g. us-east-1)"
  type        = string
}

variable "project_spec" {
  description = "Short project specifier for the instance alias (e.g. retail)"
  type        = string
}

variable "project_name" {
  description = "Short project name / prefix (e.g. tfc)"
  type        = string
}

variable "account" {
  description = "Account identifier segment (e.g. retail, sales)"
  type        = string
}

variable "lob" {
  description = "Line of business identifier (e.g. tccivr)"
  type        = string
}

variable "sdlc_env" {
  description = "Deployment environment: prod | qa | test"
  type        = string
}

variable "aws_region_abbr" {
  description = "Short region abbreviation (e.g. ue1 = us-east-1)"
  type        = string
}

variable "key_admin_arns" {
  description = "IAM ARNs granted KMS key admin permissions"
  type        = list(string)
  default     = []
}

variable "alarm_sns_topic_arns" {
  description = "SNS topic ARNs for Kinesis CloudWatch alarm notifications"
  type        = list(string)
  default     = []
}

# ── Required Tags ──────────────────────────────────────────────────────────────

variable "business_application_id" { type = string }
variable "cost_center" { type = string }
variable "created_by" { type = string }
variable "technical_support_by" { type = string }
variable "application_group" { type = string }
variable "technical_environment" { type = string }
variable "security_data_application" { type = string }
variable "business_application_code" { type = string }
