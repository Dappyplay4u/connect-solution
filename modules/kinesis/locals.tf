###############################################################################
# Kinesis Module — Locals
#
# Stream name pattern:
#   "${local.prefix}-${each.value.account}-connect-${local.lob}-${each.value.stream_name}-datastream-${local.aws_region_abbr}"
#   example: tfc-retail-connect-tccivr-agent-events-datastream-ue1
#
# Firehose name pattern:
#   "${local.prefix}-${local.account}-connect-${local.lob}-agent-events-deliverystreams-${local.aws_region_abbr}"
#   example: tfc-retail-connect-tccivr-agent-events-deliverystreams-ue1
###############################################################################

locals {
  prefix          = var.project_name
  account         = var.account
  lob             = var.lob
  sdlc_env        = var.sdlc_env
  aws_region_abbr = var.aws_region_abbr

  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.region
  partition  = data.aws_partition.current.partition

  stream_definitions = {
    contact_trace_records = {
      stream_name = "agent-events"
      account     = local.account
      lob         = local.lob
      description = "Amazon Connect Contact Trace Records"
    }
    media_streams = {
      stream_name = "media-streams"
      account     = local.account
      lob         = local.lob
      description = "Amazon Connect Media Streams"
    }
  }

  # Only create streams that were not provided as existing
  streams_to_create = {
    for k, v in local.stream_definitions : k => v
    if (k == "contact_trace_records" && var.existing_ctr_arn == "") ||
       (k == "media_streams" && var.existing_media_arn == "")
  }

  # Resolved ARNs — use existing if provided, else fall through to created stream
  resolved_ctr_arn   = coalesce(var.existing_ctr_arn, try(aws_kinesis_stream.this["contact_trace_records"].arn, ""))
  resolved_media_arn = coalesce(var.existing_media_arn, try(aws_kinesis_stream.this["media_streams"].arn, ""))

  common_tags = merge(var.tags, {
    sdlc_env = local.sdlc_env
  })
}
