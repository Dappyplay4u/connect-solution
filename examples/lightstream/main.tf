###############################################################################
# LightStream Business Unit — Connect Instance Example
#
# Naming pattern : lightstream-dev-connect-lightstream-<env>-<region_abbr>
# Instance alias : lightstream-<env>-<region_abbr>
#
# Run from this directory:
#   terraform init
#   terraform plan -var-file="envs/dev-ue1/terraform.tfvars"
#   terraform apply -var-file="envs/dev-ue1/terraform.tfvars"
###############################################################################

module "connect" {
  source = "../../modules/connect-instance"

  # ── Region ──────────────────────────────────────────────────────────────────
  aws_region = var.aws_region

  # ── Naming ──────────────────────────────────────────────────────────────────
  project_spec    = var.project_spec    # lightstream
  project_name    = var.project_name    # lightstream
  account         = var.account         # dev | prod
  lob             = var.lob             # lightstream
  sdlc_env        = var.sdlc_env        # dev | prod | qa | test
  aws_region_abbr = var.aws_region_abbr # ue1 | uw2

  # ── Connect feature flags ────────────────────────────────────────────────────
  auto_resolve_best_voices_enabled = true
  media_stream_retention_hours     = 24
  log_retention_days               = 365

  # ── KMS keys (still separate — KMS is infrastructure, not a storage config) ──
  existing_kms_s3_arn      = var.existing_kms_s3_arn
  existing_kms_kinesis_arn = var.existing_kms_kinesis_arn
  existing_kms_connect_arn = var.existing_kms_connect_arn

  # ── Storage config overrides ─────────────────────────────────────────────────
  storage_overrides = var.storage_overrides

  # ── KMS admin ARNs ───────────────────────────────────────────────────────────
  key_admin_arns = var.key_admin_arns

  # ── Kinesis settings ─────────────────────────────────────────────────────────
  kinesis_stream_mode     = "ON_DEMAND"
  kinesis_retention_hours = 24
  enable_firehose_ctr     = true

  # ── CloudWatch alarm notifications ───────────────────────────────────────────
  alarm_sns_topic_arns = var.alarm_sns_topic_arns
}
