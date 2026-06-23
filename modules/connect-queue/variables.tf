# ---------------------------------------------------------------------------
# Naming
# ---------------------------------------------------------------------------

variable "project_name" {
  description = "Short project name used as a resource name prefix (e.g. tfc)."
  type        = string
}

variable "account" {
  description = "Account identifier used in resource naming (e.g. retail)."
  type        = string
}

variable "lob" {
  description = "Line-of-business identifier used in resource naming (e.g. tccivr)."
  type        = string
}

variable "sdlc_env" {
  description = "Deployment environment: prod, qa, or test."
  type        = string
  validation {
    condition     = contains(["prod", "qa", "test"], var.sdlc_env)
    error_message = "sdlc_env must be prod, qa, or test."
  }
}

variable "aws_region_abbr" {
  description = "Short AWS region abbreviation used in resource naming (e.g. ue1 for us-east-1)."
  type        = string
}

# ---------------------------------------------------------------------------
# Connect Instance — pass one of the two options below
# ---------------------------------------------------------------------------

variable "instance_id" {
  description = <<-EOT
    ID of the Amazon Connect instance to create queues in.
    Pass the output from the connect-instance module, or supply any existing
    instance ID directly.
    When null, instance_alias must be provided and the ID is looked up automatically.
  EOT
  type    = string
  default = null

  validation {
    condition     = var.instance_id != null || var.instance_alias != null
    error_message = "Either instance_id or instance_alias must be provided."
  }
}

variable "instance_alias" {
  description = <<-EOT
    Alias of the Amazon Connect instance to look up when instance_id is not
    provided directly (e.g. retail-prod-ue1).
  EOT
  type    = string
  default = null
}

# ---------------------------------------------------------------------------
# Queues
# ---------------------------------------------------------------------------

variable "queues" {
  description = <<-EOT
    Map of queue definitions. Each key becomes part of the queue name:
    <name_prefix>-<key>.

    hours_of_operation_id   ID of the hours of operation to associate with
                            this queue. Use the output from the
                            hours-of-operation module, or pass an existing
                            ID (e.g. the Connect default "Basic Hours").

    max_contacts            Maximum contacts allowed in the queue at once.
                            0 = unlimited.
    status                  ENABLED (default) or DISABLED.
  EOT
  type = map(object({
    description           = optional(string, "")
    hours_of_operation_id = string
    max_contacts          = optional(number, 0)
    status                = optional(string, "ENABLED")
    quick_connect_ids     = optional(list(string), [])
    outbound_caller_config = optional(object({
      outbound_caller_id_name      = optional(string, null)
      outbound_caller_id_number_id = optional(string, null)
      outbound_flow_id             = optional(string, null)
    }), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.queues :
      contains(["ENABLED", "DISABLED"], v.status)
    ])
    error_message = "Each queue status must be ENABLED or DISABLED."
  }
}

# ---------------------------------------------------------------------------
# Tags
# ---------------------------------------------------------------------------

variable "tags" {
  description = "Tags applied to all resources. Must include the 8 required enterprise tag keys."
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
