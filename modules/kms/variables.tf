###############################################################################
# KMS Module — Variables
###############################################################################

variable "aws_region" {
  description = "AWS region to deploy into (e.g. us-east-1)"
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

# ── KMS Key Configuration ─────────────────────────────────────────────────────

variable "kms_keys" {
  description = <<-EOT
    Map of KMS keys to create.
    Key name = logical purpose (e.g. "s3", "kinesis", "connect").
    - policy             : optional custom JSON key policy (null = use generated default)
    - service_principals : AWS service principals allowed to use the key
                           (empty list = module defaults per key name)
    - deletion_window    : pending-deletion window in days (7–30)
  EOT
  type = map(object({
    policy             = optional(string, null)
    service_principals = optional(list(string), [])
    deletion_window    = optional(number, 30)
  }))

  default = {
    s3      = {}
    kinesis = {}
    connect = {}
  }
}

variable "key_admin_arns" {
  description = "IAM principal ARNs granted key administration permissions"
  type        = list(string)
  default     = []
}
