variable "aws_region" {
  description = "AWS region to deploy into (e.g. us-west-2)."
  type        = string
  default     = "us-west-2"
}

variable "project_name" {
  description = "Short project name prefix used in all resource names (e.g. ls)."
  type        = string
}

variable "aws_region_abbr" {
  description = "Short region abbreviation used in resource names (e.g. uw2 for us-west-2)."
  type        = string
  default     = "uw2"
}

variable "existing_table_arns" {
  description = "Map of table key → ARN for tables that already exist. Leave empty to auto-create all tables."
  type        = map(string)
  default     = {}
}

variable "existing_iam_role_arn" {
  description = "ARN of an existing IAM role for the Lambda CSV loader. Leave null to auto-create."
  type        = string
  default     = null
}

variable "kms_master_key_id" {
  description = "Optional KMS key ARN. When null, AWS-managed encryption is used."
  type        = string
  default     = null
}

variable "iam_permission_boundary_arn" {
  description = "IAM permissions boundary ARN. Required in SSO-managed enterprise accounts."
  type        = string
  default     = null
}

# ---------------------------------------------------------------------------
# Required enterprise tags
# ---------------------------------------------------------------------------

variable "business_application_id"   { type = string }
variable "cost_center"               { type = string }
variable "created_by"                { type = string }
variable "technical_support_by"      { type = string }
variable "application_group"         { type = string }
variable "technical_environment"     { type = string }
variable "security_data_application" { type = string }
variable "business_application_code" { type = string }
