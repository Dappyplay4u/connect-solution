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
    ID of the Amazon Connect instance.
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
# Quick Connects
# ---------------------------------------------------------------------------

variable "quick_connects" {
  description = <<-EOT
    Map of quick connect definitions. Each key becomes part of the resource name:
    <name_prefix>-<key>.

    type            PHONE_NUMBER, QUEUE, or AGENT.

    PHONE_NUMBER    routes an agent transfer to an external phone number.
                    Required field: phone_number (E.164 format, e.g. +15551234567).

    QUEUE           routes an agent transfer to an internal queue.
                    Required fields: contact_flow_id, queue_id.

    AGENT           routes an agent transfer directly to another agent.
                    Required fields: contact_flow_id, user_id.
  EOT
  type = map(object({
    description     = optional(string, "")
    type            = string
    phone_number    = optional(string, null)
    contact_flow_id = optional(string, null)
    queue_id        = optional(string, null)
    user_id         = optional(string, null)
  }))

  validation {
    condition = alltrue([
      for k, v in var.quick_connects :
      contains(["PHONE_NUMBER", "QUEUE", "AGENT"], v.type)
    ])
    error_message = "Each quick connect type must be PHONE_NUMBER, QUEUE, or AGENT."
  }

  validation {
    condition = alltrue([
      for k, v in var.quick_connects :
      (v.type == "PHONE_NUMBER" && v.phone_number != null) ||
      (v.type == "QUEUE" && v.contact_flow_id != null && v.queue_id != null) ||
      (v.type == "AGENT" && v.contact_flow_id != null && v.user_id != null)
    ])
    error_message = "PHONE_NUMBER requires phone_number; QUEUE requires contact_flow_id and queue_id; AGENT requires contact_flow_id and user_id."
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
