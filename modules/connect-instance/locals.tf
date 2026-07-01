###############################################################################
# Connect Instance Module — Locals
#
# instance_alias = "${var.project_spec}-${var.sdlc_env}-${var.aws_region_abbr}"
#                  example: retail-prod-ue1
#
# name_prefix    = "${var.project_name}-${var.account}-connect-${var.lob}-${var.sdlc_env}-${var.aws_region_abbr}"
#                  example: tfc-retail-connect-tccivr-prod-ue1
###############################################################################

locals {
  prefix          = var.project_name
  account         = var.account
  lob             = var.lob
  sdlc_env        = var.sdlc_env
  aws_region_abbr = var.aws_region_abbr

  instance_alias = "${var.project_spec}-${var.sdlc_env}-${var.aws_region_abbr}"
  name_prefix    = "${local.prefix}-${local.account}-connect-${local.lob}-${local.sdlc_env}-${local.aws_region_abbr}"

  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.region
  partition  = data.aws_partition.current.partition

  # Each KMS key is independently bring-your-own. Only the keys not provided
  # as existing are passed to the child module, so it never creates a key
  # you already supplied.
  kms_keys_to_create = merge(
    var.existing_kms_s3_arn      == "" ? { s3      = {} } : {},
    var.existing_kms_kinesis_arn == "" ? { kinesis = {} } : {},
    var.existing_kms_connect_arn == "" ? { connect = {} } : {},
  )

  # Resolved KMS ARNs — use existing if provided, else fall through to child
  # module. try() is required: a plain ternary still evaluates the module[0]
  # index even on the discarded branch, which errors when count = 0.
  kms_s3_arn      = var.existing_kms_s3_arn != "" ? var.existing_kms_s3_arn : try(module.kms[0].s3_key_arn, null)
  kms_s3_id       = var.existing_kms_s3_arn != "" ? var.existing_kms_s3_arn : try(module.kms[0].s3_key_id, null)
  kms_kinesis_arn = var.existing_kms_kinesis_arn != "" ? var.existing_kms_kinesis_arn : try(module.kms[0].kinesis_key_arn, null)
  kms_kinesis_id  = var.existing_kms_kinesis_arn != "" ? var.existing_kms_kinesis_arn : try(module.kms[0].kinesis_key_id, null)
  kms_connect_arn = var.existing_kms_connect_arn != "" ? var.existing_kms_connect_arn : try(module.kms[0].connect_key_arn, null)

  # Resolved S3 bucket IDs
  s3_call_recordings_id   = var.existing_s3_call_recordings_id != "" ? var.existing_s3_call_recordings_id : try(module.s3[0].call_recordings_bucket_id, null)
  s3_scheduled_reports_id = var.existing_s3_scheduled_reports_id != "" ? var.existing_s3_scheduled_reports_id : try(module.s3[0].scheduled_reports_bucket_id, null)
  s3_chat_transcripts_id  = var.existing_s3_chat_transcripts_id != "" ? var.existing_s3_chat_transcripts_id : try(module.s3[0].chat_transcripts_bucket_id, null)

  # Resolved Kinesis stream ARNs — each stream is independently controlled
  kinesis_ctr_arn   = var.existing_kinesis_ctr_arn != "" ? var.existing_kinesis_ctr_arn : try(module.kinesis[0].ctr_stream_arn, null)
  kinesis_media_arn = var.existing_kinesis_media_arn != "" ? var.existing_kinesis_media_arn : try(module.kinesis[0].media_stream_arn, null)

  # Whether to create child modules
  create_kms     = length(local.kms_keys_to_create) > 0 ? 1 : 0
  create_s3      = var.existing_s3_call_recordings_id == "" ? 1 : 0
  create_kinesis = (var.existing_kinesis_ctr_arn == "" || var.existing_kinesis_media_arn == "") ? 1 : 0

  common_tags = merge(var.tags, {
    sdlc_env       = local.sdlc_env
    instance_alias = local.instance_alias
  })
}
