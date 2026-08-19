# ---------------------------------------------------------------------------
# TFC — PROD (us-east-1)
#
# No pre-existing manually-created resources in this region.
# Module creates all S3 / Kinesis / KMS with standard naming.
# No prefix overrides needed.
# ---------------------------------------------------------------------------

# ── Region ──────────────────────────────────────────────────────────────────
aws_region      = "us-east-1"
aws_region_abbr = "ue1"

# ── Naming ──────────────────────────────────────────────────────────────────
# Produces: tfc-retail-connect-tccivr-prod-<suffix>-ue1
project_spec = "retail"
project_name = "tfc"
account      = "retail"
lob          = "tccivr"
sdlc_env     = "prod"

# ── Bring-your-own: leave empty → module auto-creates all resources ──────────
existing_kms_s3_arn              = ""
existing_kms_kinesis_arn         = ""
existing_kms_connect_arn         = ""
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
#   media_streams     → "tfc-retail-connect-tccivr-prod-ue1-media"

# ── Alerting ─────────────────────────────────────────────────────────────────
alarm_sns_topic_arns = [
  # "arn:aws:sns:us-east-1:<account_id>:tfc-connect-alerts-prod",
]

# ── KMS key administrators ────────────────────────────────────────────────────
key_admin_arns = [
  # "arn:aws:iam::<account_id>:role/G-ROLE-AWS-RETAILCONNECTPROD-FSA",
]
