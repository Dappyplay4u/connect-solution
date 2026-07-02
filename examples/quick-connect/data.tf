data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Look up the Connect instance by alias when instance_id is not provided directly.
data "aws_connect_instance" "this" {
  count          = var.instance_id == null ? 1 : 0
  instance_alias = var.instance_alias
}

# Look up every queue by its full Connect name.
# The name pattern mirrors the connect-queue module:
#   <project_name>-<account>-connect-<lob>-<sdlc_env>-<aws_region_abbr>-<queue_key>
#
# Any key listed in var.queues_to_skip is excluded from the lookup —
# use this for queues that haven't been created yet.
data "aws_connect_queue" "this" {
  for_each    = toset(local.queues_to_lookup)
  instance_id = local.resolved_instance_id
  name        = "${local.queue_name_prefix}-${each.key}"
}
