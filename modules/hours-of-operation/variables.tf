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
# Hours of Operation
# ---------------------------------------------------------------------------

variable "hours_of_operation" {
  description = <<-EOT
    Map of hours-of-operation definitions. Each key becomes part of the
    resource name: <name_prefix>-<key>.

    time_zone   IANA timezone string, e.g. America/New_York.
    config      One block per operating window. A resource can have multiple
                config blocks — one per day, or one block per day group that
                shares the same open/close times.
                Days not listed are treated as closed.
  EOT
  type = map(object({
    description = optional(string, "")
    time_zone   = string
    config = list(object({
      day = string
      start_time = object({
        hours   = number
        minutes = number
      })
      end_time = object({
        hours   = number
        minutes = number
      })
    }))
  }))

  validation {
    condition = alltrue(flatten([
      for k, v in var.hours_of_operation : [
        for c in v.config :
        contains(["MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY", "SUNDAY"], c.day)
      ]
    ]))
    error_message = "Each config day must be one of MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY, SUNDAY."
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
