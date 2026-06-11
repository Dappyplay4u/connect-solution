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

  common_tags = merge(var.tags, {
    sdlc_env = local.sdlc_env
  })
}
