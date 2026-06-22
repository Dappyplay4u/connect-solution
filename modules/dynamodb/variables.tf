# ---------------------------------------------------------------------------
# Identity / naming
# ---------------------------------------------------------------------------

variable "project_name" {
  description = "Short project name used as a resource name prefix (e.g. ls)."
  type        = string
}

variable "aws_region_abbr" {
  description = "Short AWS region abbreviation used in resource naming (e.g. uw2 for us-west-2)."
  type        = string
}

# ---------------------------------------------------------------------------
# Tables
# ---------------------------------------------------------------------------

variable "tables" {
  description = <<-EOT
    Map of DynamoDB table definitions. Each key:
      - becomes the table name: <project_name>-connect-<key>-<aws_region_abbr>
      - becomes the S3 folder for CSV uploads: <key>/your-file.csv

    billing_mode: PAY_PER_REQUEST (default) or PROVISIONED.
    read_capacity / write_capacity: required only when billing_mode is PROVISIONED.
    csv_number_attributes: column names in the CSV to store as Number type; all others default to String.
    sync_mode: when true, rows not in the CSV are deleted (full replace). When false, only upserts.
  EOT
  type = map(object({
    hash_key                       = string
    hash_key_type                  = optional(string, "S")
    range_key                      = optional(string, null)
    range_key_type                 = optional(string, null)
    billing_mode                   = optional(string, "PAY_PER_REQUEST")
    read_capacity                  = optional(number, null)
    write_capacity                 = optional(number, null)
    ttl_attribute_name             = optional(string, null)
    point_in_time_recovery_enabled = optional(bool, true)
    csv_number_attributes          = optional(list(string), [])
    sync_mode                      = optional(bool, false)
    global_secondary_indexes = optional(list(object({
      name               = string
      hash_key           = string
      hash_key_type      = string
      range_key          = optional(string, null)
      range_key_type     = optional(string, null)
      projection_type    = string
      non_key_attributes = optional(list(string), [])
      read_capacity      = optional(number, null)
      write_capacity     = optional(number, null)
    })), [])
  }))

  validation {
    condition = alltrue([
      for k, v in var.tables :
      contains(["PAY_PER_REQUEST", "PROVISIONED"], v.billing_mode)
    ])
    error_message = "Each table billing_mode must be PAY_PER_REQUEST or PROVISIONED."
  }

  validation {
    condition = alltrue([
      for k, v in var.tables :
      contains(["S", "N", "B"], v.hash_key_type)
    ])
    error_message = "Each table hash_key_type must be S, N, or B."
  }

  validation {
    condition = alltrue(flatten([
      for k, v in var.tables : [
        for gsi in v.global_secondary_indexes :
        contains(["ALL", "KEYS_ONLY", "INCLUDE"], gsi.projection_type)
      ]
    ]))
    error_message = "Each GSI projection_type must be ALL, KEYS_ONLY, or INCLUDE."
  }
}

# ---------------------------------------------------------------------------
# Shared CSV loader settings
# ---------------------------------------------------------------------------

variable "kms_master_key_id" {
  description = "ARN of a KMS key for encrypting all tables, the S3 bucket, and Lambda logs. When null, AWS-managed keys are used."
  type        = string
  default     = null
}

variable "csv_retention_days" {
  description = "Days after which uploaded CSV objects are expired from S3."
  type        = number
  default     = 90
}

variable "lambda_timeout_seconds" {
  description = "Maximum execution time for the CSV loader Lambda in seconds."
  type        = number
  default     = 300
  validation {
    condition     = var.lambda_timeout_seconds >= 1 && var.lambda_timeout_seconds <= 900
    error_message = "lambda_timeout_seconds must be between 1 and 900."
  }
}

variable "lambda_memory_mb" {
  description = "Memory allocated to the CSV loader Lambda in MB."
  type        = number
  default     = 256
}

variable "lambda_log_retention_days" {
  description = "Days to retain CSV loader Lambda logs in CloudWatch."
  type        = number
  default     = 30
  validation {
    condition = contains(
      [1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653],
      var.lambda_log_retention_days
    )
    error_message = "lambda_log_retention_days must be a valid CloudWatch Logs retention period."
  }
}

# ---------------------------------------------------------------------------
# GitLab CI/CD — automated CSV upload via OIDC
# ---------------------------------------------------------------------------

variable "gitlab_ci_upload" {
  description = <<-EOT
    When enabled, creates an IAM role that GitLab CI/CD can assume via OIDC
    to upload CSV files to the S3 bucket without long-lived access keys.

    project_path: the GitLab project path allowed to assume the role
                  (e.g. "mygroup/myrepo"). Required when enabled = true.
    branch:       only pipelines running on this branch can assume the role.
    gitlab_url:   your GitLab instance URL. Defaults to https://gitlab.com.
  EOT
  type = object({
    enabled      = optional(bool, false)
    project_path = optional(string, null)
    branch       = optional(string, "main")
    gitlab_url   = optional(string, "https://gitlab.com")
  })
  default = { enabled = false }
}

variable "gitlab_oidc_provider_arn" {
  description = "ARN of an existing GitLab OIDC provider in this account. When null and gitlab_ci_upload.enabled is true, a new provider is created. Only one OIDC provider per URL is allowed per AWS account."
  type        = string
  default     = null
}

# ---------------------------------------------------------------------------
# Tags
# ---------------------------------------------------------------------------

variable "tags" {
  description = "Map of tags applied to all resources. Must include the 8 required enterprise tag keys."
  type        = map(string)
  default     = {}

  validation {
    condition = alltrue([
      contains(keys(var.tags), "business_application_id"),
      contains(keys(var.tags), "cost_center"),
      contains(keys(var.tags), "created_by"),
      contains(keys(var.tags), "technical_support_by"),
      contains(keys(var.tags), "application_group"),
      contains(keys(var.tags), "technical_environment"),
      contains(keys(var.tags), "security_data_application"),
      contains(keys(var.tags), "business_application_code"),
    ])
    error_message = "tags must include all 8 required tag keys."
  }
}
