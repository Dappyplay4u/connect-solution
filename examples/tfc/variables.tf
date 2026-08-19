###############################################################################
# TFC Business Unit — Variables
###############################################################################

variable "aws_region" {
  description = "AWS region (e.g. us-east-1)"
  type        = string
}

# ── Naming ────────────────────────────────────────────────────────────────────

variable "project_spec" {
  description = "Short project specifier for the instance alias (e.g. retail)"
  type        = string
}

variable "project_name" {
  description = "Short project name prefix (e.g. tfc)"
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
  description = "Short region abbreviation (e.g. ue1, uw2)"
  type        = string
}

# ── Bring-your-own resources ──────────────────────────────────────────────────

variable "existing_kms_s3_arn" {
  type    = string
  default = ""
}

variable "existing_kms_kinesis_arn" {
  type    = string
  default = ""
}

variable "existing_kms_connect_arn" {
  type    = string
  default = ""
}

variable "existing_s3_call_recordings_id" {
  type    = string
  default = ""
}

variable "existing_s3_scheduled_reports_id" {
  type    = string
  default = ""
}

variable "existing_s3_chat_transcripts_id" {
  type    = string
  default = ""
}

variable "existing_kinesis_ctr_arn" {
  type    = string
  default = ""
}

variable "existing_kinesis_media_arn" {
  type    = string
  default = ""
}

# ── Storage prefix overrides ──────────────────────────────────────────────────
# Only needed in regions where resources were manually created with
# different naming. Leave null in regions where this module creates them fresh.

variable "call_recordings_bucket_prefix" {
  description = "S3 folder prefix for call recordings. Null = module default 'call-recordings'."
  type        = string
  default     = null
}

variable "scheduled_reports_bucket_prefix" {
  description = "S3 folder prefix for scheduled reports. Null = module default 'scheduled-reports'."
  type        = string
  default     = null
}

variable "chat_transcripts_bucket_prefix" {
  description = "S3 folder prefix for chat transcripts. Null = module default 'chat-transcripts'."
  type        = string
  default     = null
}

variable "media_streams_prefix" {
  description = "Kinesis Video Stream prefix. Null = module default '<name_prefix>-media'."
  type        = string
  default     = null
}

# ── Supporting ────────────────────────────────────────────────────────────────

variable "key_admin_arns" {
  type    = list(string)
  default = []
}

variable "alarm_sns_topic_arns" {
  type    = list(string)
  default = []
}
