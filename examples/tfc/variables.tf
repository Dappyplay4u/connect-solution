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

# ── KMS keys — still separate (KMS is infrastructure, not a storage config) ───

variable "existing_kms_s3_arn" {
  description = "Existing KMS key ARN for S3 encryption. Leave empty to auto-create."
  type        = string
  default     = ""
}

variable "existing_kms_kinesis_arn" {
  description = "Existing KMS key ARN for Kinesis encryption. Leave empty to auto-create."
  type        = string
  default     = ""
}

variable "existing_kms_connect_arn" {
  description = "Existing KMS key ARN for Connect CW logs. Leave empty to auto-create."
  type        = string
  default     = ""
}

# ── Storage config overrides ──────────────────────────────────────────────────
# Only set fields that differ from the module defaults.
# Omit entirely in regions where resources are newly created by this module.

variable "storage_overrides" {
  type = object({
    call_recordings = optional(object({
      bucket_name   = optional(string)
      bucket_prefix = optional(string)
    }), {})
    scheduled_reports = optional(object({
      bucket_name   = optional(string)
      bucket_prefix = optional(string)
    }), {})
    chat_transcripts = optional(object({
      bucket_name   = optional(string)
      bucket_prefix = optional(string)
    }), {})
    contact_trace_records = optional(object({
      stream_arn = optional(string)
    }), {})
    media_streams = optional(object({
      prefix                 = optional(string)
      retention_period_hours = optional(number)
    }), {})
  })
  default = {}
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
