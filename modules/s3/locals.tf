###############################################################################
# S3 Module — Locals
#
# Bucket name pattern:
#   "${local.prefix}-${local.account}-connect-${local.lob}-${local.sdlc_env}-${each.value.suffix}-${local.aws_region_abbr}"
#   example: tfc-retail-connect-tccivr-qa-recordings-ue1
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

  bucket_definitions = {
    call_recordings = {
      suffix      = "recordings"
      description = "Amazon Connect call recordings"
      prefix      = "call-recordings/"
    }
    scheduled_reports = {
      suffix      = "reports"
      description = "Amazon Connect scheduled reports"
      prefix      = "scheduled-reports/"
    }
    chat_transcripts = {
      suffix      = "transcripts"
      description = "Amazon Connect chat transcripts"
      prefix      = "chat-transcripts/"
    }
  }

  common_tags = merge(var.tags, {
    sdlc_env = local.sdlc_env
  })
}
