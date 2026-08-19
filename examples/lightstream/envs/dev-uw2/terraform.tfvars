# ---------------------------------------------------------------------------
# LightStream — DEV (us-west-2)
#
# No pre-existing resources in this region.
# Module auto-creates all S3 / Kinesis with standard naming.
# KMS keys are shared Truist standard keys (passed as existing).
# No prefix overrides needed.
# ---------------------------------------------------------------------------

# ── Region ──────────────────────────────────────────────────────────────────
aws_region      = "us-west-2"
aws_region_abbr = "uw2"

# ── Naming ──────────────────────────────────────────────────────────────────
# Produces: lightstream-dev-connect-lightstream-dev-uw2
project_spec = "lightstream"
project_name = "lightstream"
account      = "dev"
lob          = "lightstream"
sdlc_env     = "dev"

# ── Bring-your-own: KMS keys are shared Truist standard keys ────────────────
existing_kms_s3_arn      = "arn:aws:kms:us-west-2:014848577183:key/<s3-key-id>"
existing_kms_kinesis_arn = "arn:aws:kms:us-west-2:014848577183:key/<kinesis-key-id>"
existing_kms_connect_arn = "arn:aws:kms:us-west-2:014848577183:key/<connect-key-id>"

# ── Auto-create S3 and Kinesis ───────────────────────────────────────────────
# Leave empty → module creates with standard names:
#   lightstream-dev-connect-lightstream-dev-recordings-uw2
#   lightstream-dev-connect-lightstream-dev-reports-uw2
#   lightstream-dev-connect-lightstream-dev-transcripts-uw2
existing_s3_call_recordings_id   = ""
existing_s3_scheduled_reports_id = ""
existing_s3_chat_transcripts_id  = ""
existing_kinesis_ctr_arn         = ""
existing_kinesis_media_arn       = ""

# ── Storage prefix overrides ─────────────────────────────────────────────────
# Not set — module uses its defaults:
#   call_recordings   → "call-recordings"
#   scheduled_reports → "scheduled-reports"
#   chat_transcripts  → "chat-transcripts"
#   media_streams     → "lightstream-dev-connect-lightstream-dev-uw2-media"

# ── Alerting ─────────────────────────────────────────────────────────────────
alarm_sns_topic_arns = [
  # "arn:aws:sns:us-west-2:014848577183:ls-support-alerts",
]

# ── KMS key administrators ────────────────────────────────────────────────────
key_admin_arns = [
  # "arn:aws:iam::014848577183:role/G-ROLE-AWS-RETAILCONNECTDEV-FSA",
]
