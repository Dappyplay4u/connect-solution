variable "aws_region" {
  description = "AWS region to deploy into (e.g. us-east-1)."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Short project name prefix (e.g. tfc)."
  type        = string
}

variable "account" {
  description = "Account identifier used in resource naming (e.g. retail)."
  type        = string
}

variable "lob" {
  description = "Line-of-business identifier (e.g. tccivr)."
  type        = string
}

variable "sdlc_env" {
  description = "Deployment environment: prod, qa, or test."
  type        = string
}

variable "aws_region_abbr" {
  description = "Short region abbreviation (e.g. ue1 for us-east-1)."
  type        = string
}

# ---------------------------------------------------------------------------
# Connect instance — provide one of the two options below
# ---------------------------------------------------------------------------

variable "instance_id" {
  description = "Connect instance ID. Supply this when you have the ID directly."
  type        = string
  default     = null
}

variable "instance_alias" {
  description = "Connect instance alias. Used to look up the instance ID automatically when instance_id is not provided."
  type        = string
  default     = null
}

# ---------------------------------------------------------------------------
# Queue quick connects
# ---------------------------------------------------------------------------

variable "transfer_to_queue_flow_id" {
  description = <<-EOT
    ID of the "Transfer to queue" contact flow in the Connect instance.
    All QUEUE-type quick connects share this flow.
    Find it in Connect console → Contact flows → filter by type "Transfer to queue".
    When null, no QUEUE-type quick connects are created.
  EOT
  type    = string
  default = null
}

variable "queues_to_skip" {
  description = <<-EOT
    List of queue keys to exclude from the data source lookup and quick connect creation.
    Use this for queues that exist in locals.tf but have not yet been created in Connect.
    Keys must match entries in the queue lists in locals.tf.
  EOT
  type    = list(string)
  default = []
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
