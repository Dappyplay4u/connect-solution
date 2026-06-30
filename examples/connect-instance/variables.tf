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

# ── Bring-your-own resources (leave "" to auto-create) ───────────────────────

variable "existing_kms_s3_arn" {
  description = "ARN of an existing KMS key for S3. Leave empty to auto-create."
  type        = string
  default     = ""
}

variable "existing_kms_kinesis_arn" {
  description = "ARN of an existing KMS key for Kinesis. Leave empty to auto-create."
  type        = string
  default     = ""
}

variable "existing_kms_connect_arn" {
  description = "ARN of an existing KMS key for Connect. Leave empty to auto-create."
  type        = string
  default     = ""
}

variable "existing_s3_call_recordings_id" {
  description = "ID of an existing S3 bucket for call recordings. Leave empty to auto-create."
  type        = string
  default     = ""
}

variable "existing_s3_scheduled_reports_id" {
  description = "ID of an existing S3 bucket for scheduled reports. Leave empty to auto-create."
  type        = string
  default     = ""
}

variable "existing_s3_chat_transcripts_id" {
  description = "ID of an existing S3 bucket for chat transcripts. Leave empty to auto-create."
  type        = string
  default     = ""
}

variable "existing_kinesis_ctr_arn" {
  description = "ARN of an existing Kinesis stream for CTR / agent events. Leave empty to auto-create."
  type        = string
  default     = ""
}

variable "existing_kinesis_media_arn" {
  description = "ARN of an existing Kinesis stream for media streams. Leave empty to auto-create."
  type        = string
  default     = ""
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
