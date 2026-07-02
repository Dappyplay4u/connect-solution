###############################################################################
# S3 Module — Variables
###############################################################################

variable "aws_region" {
  description = "AWS region (e.g. us-east-1)"
  type        = string
  default     = "us-east-1"
}

# ── Naming ────────────────────────────────────────────────────────────────────

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

  validation {
    condition     = contains(["prod", "qa", "test"], var.sdlc_env)
    error_message = "sdlc_env must be one of: prod, qa, test."
  }
}

variable "aws_region_abbr" {
  description = "Short region abbreviation (e.g. ue1 = us-east-1, uw1 = us-west-1)"
  type        = string
}

# ── Encryption ────────────────────────────────────────────────────────────────

variable "kms_key_arn" {
  description = "KMS key ARN used for S3 server-side encryption (from kms module output: s3_key_arn)"
  type        = string
}

# ── Bucket Behaviour ──────────────────────────────────────────────────────────

variable "force_destroy" {
  description = "Allow Terraform to destroy non-empty buckets. Set true only in non-prod."
  type        = bool
  default     = false
}

variable "enable_access_logging" {
  description = "Create a dedicated access-log bucket and enable logging on all data buckets"
  type        = bool
  default     = true
}

# ── Lifecycle ─────────────────────────────────────────────────────────────────

variable "lifecycle_ia_transition_days" {
  description = "Days after object creation before transitioning to STANDARD_IA"
  type        = number
  default     = 90
}

variable "lifecycle_glacier_transition_days" {
  description = "Days after object creation before transitioning to GLACIER"
  type        = number
  default     = 365
}

variable "lifecycle_expiration_days" {
  description = "Days after object creation before permanent expiration (0 = no expiry)"
  type        = number
  default     = 2555 # ~7 years
}

variable "noncurrent_version_expiration_days" {
  description = "Days before non-current object versions are expired"
  type        = number
  default     = 90
}
