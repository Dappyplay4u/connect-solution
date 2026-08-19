###############################################################################
# TFC Business Unit — Connect Instance Example
#
# Naming pattern : tfc-retail-connect-tccivr-<env>-<region_abbr>
# Instance alias : retail-<env>-<region_abbr>
#
# Run from this directory:
#   terraform init
#   terraform plan -var-file="envs/qa-ue1/terraform.tfvars"
#   terraform apply -var-file="envs/qa-ue1/terraform.tfvars"
###############################################################################

module "connect" {
  source = "../../modules/connect-instance"

  # ── Region ──────────────────────────────────────────────────────────────────
  aws_region = var.aws_region

  # ── Naming ──────────────────────────────────────────────────────────────────
  project_spec    = var.project_spec    # used in instance alias: retail-qa-ue1
  project_name    = var.project_name    # tfc
  account         = var.account         # retail
  lob             = var.lob             # tccivr
  sdlc_env        = var.sdlc_env        # prod | qa | test
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
  # Only set fields that differ from the module defaults.
  # Read current values from state before setting:
  #   terraform state show 'module.connect.aws_connect_instance_storage_config.call_recordings'
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
