# ---------------------------------------------------------------------------
# LightStream — DEV (us-east-1)
#
# KMS keys exist (shared Truist standard keys) — passed as existing.
# S3 and Kinesis were previously created manually with non-standard naming.
# existing_* variables point to those resources; prefix overrides preserve
# the paths that Connect was already configured with.
# ---------------------------------------------------------------------------

# ── Region ──────────────────────────────────────────────────────────────────
aws_region      = "us-east-1"
aws_region_abbr = "ue1"

# ── Naming ──────────────────────────────────────────────────────────────────
# Produces: lightstream-dev-connect-lightstream-dev-ue1
project_spec = "lightstream"
project_name = "lightstream"
account      = "dev"
lob          = "lightstream"
sdlc_env     = "dev"

# ── Bring-your-own: KMS keys are shared Truist standard keys ────────────────
existing_kms_s3_arn      = "arn:aws:kms:us-east-1:014848577183:key/<s3-key-id>"
existing_kms_kinesis_arn = "arn:aws:kms:us-east-1:014848577183:key/<kinesis-key-id>"
existing_kms_connect_arn = "arn:aws:kms:us-east-1:014848577183:key/<connect-key-id>"

# Pass existing S3 bucket names (manually created with old naming)
existing_s3_call_recordings_id   = "ls-connect-ue1-recordings"
existing_s3_scheduled_reports_id = ""
existing_s3_chat_transcripts_id  = ""

# Pass existing Kinesis stream ARNs
existing_kinesis_ctr_arn   = ""
existing_kinesis_media_arn = ""

# ── Storage config overrides ─────────────────────────────────────────────────
# Values read from: terraform state show 'module.connect.aws_connect_instance_storage_config.*'
storage_overrides = {
  call_recordings = {
    bucket_prefix = "connect/lightstream-dev-uw2/CallRecordings"
  }
  media_streams = {
    prefix = "ls-connect-audiostream-uw2-"
  }
}

# ── Alerting ─────────────────────────────────────────────────────────────────
alarm_sns_topic_arns = [
  "arn:aws:sns:us-east-1:014848577183:ls-support-alerts",
]

# ── KMS key administrators ────────────────────────────────────────────────────
key_admin_arns = [
  # "arn:aws:iam::014848577183:role/G-ROLE-AWS-RETAILCONNECTDEV-FSA",
]
