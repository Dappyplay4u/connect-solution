###############################################################################
# Connect Instance Module — Complete Example
#
# Run from this directory:
#   cp example.tfvars terraform.tfvars
#   terraform init
#   terraform plan
#   terraform apply
#
# Resulting instance alias : retail-prod-ue1
# Resulting name prefix    : tfc-retail-connect-tccivr-prod-ue1
###############################################################################

module "connect" {
  source = "../../modules/connect-instance"

  # ── Region ──────────────────────────────────────────────────────────────────
  aws_region = var.aws_region

  # ── Naming ──────────────────────────────────────────────────────────────────
  # instance_alias → "${var.project_spec}-${var.sdlc_env}-${var.aws_region_abbr}"
  #                  e.g. retail-prod-ue1
  project_spec    = var.project_spec
  project_name    = var.project_name
  account         = var.account
  lob             = var.lob
  sdlc_env        = var.sdlc_env
  aws_region_abbr = var.aws_region_abbr

  # ── Connect feature flags ────────────────────────────────────────────────────
  auto_resolve_best_voices_enabled = true
  media_stream_retention_hours     = 24
  log_retention_days               = 365

  # ── Bring-your-own resources (leave "" to auto-create) ───────────────────────
  existing_kms_s3_arn              = var.existing_kms_s3_arn
  existing_kms_kinesis_arn         = var.existing_kms_kinesis_arn
  existing_kms_connect_arn         = var.existing_kms_connect_arn
  existing_s3_call_recordings_id   = var.existing_s3_call_recordings_id
  existing_s3_scheduled_reports_id = var.existing_s3_scheduled_reports_id
  existing_s3_chat_transcripts_id  = var.existing_s3_chat_transcripts_id
  existing_kinesis_ctr_arn         = var.existing_kinesis_ctr_arn
  existing_kinesis_media_arn       = var.existing_kinesis_media_arn

  # ── KMS admin ARNs ───────────────────────────────────────────────────────────
  key_admin_arns = var.key_admin_arns

  # ── Kinesis settings ─────────────────────────────────────────────────────────
  kinesis_stream_mode     = "ON_DEMAND"
  kinesis_retention_hours = 24
  enable_firehose_ctr     = true

  # ── CloudWatch alarm notifications ───────────────────────────────────────────
  alarm_sns_topic_arns = var.alarm_sns_topic_arns

  # ── Required tags ────────────────────────────────────────────────────────────
  tags = local.required_tags
}
