# ---------------------------------------------------------------------------
# LightStream — DEV (us-east-1)
#
# KMS keys pre-exist (shared Truist standard keys) — passed separately.
# S3 buckets and Kinesis streams were manually created with non-standard names
# and imported into state. storage_overrides declares the existing names and
# the Connect config paths to freeze in place.
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

# ── KMS keys (shared Truist standard keys — always bring-your-own) ───────────
existing_kms_s3_arn      = "arn:aws:kms:us-east-1:014848577183:key/<s3-key-id>"
existing_kms_kinesis_arn = "arn:aws:kms:us-east-1:014848577183:key/<kinesis-key-id>"
existing_kms_connect_arn = "arn:aws:kms:us-east-1:014848577183:key/<connect-key-id>"

# ── Storage overrides — all S3 + Kinesis names and Connect config paths ───────
storage_overrides = {
  call_recordings = {
    bucket_name   = "ls-connect-ue1-recordings"
    bucket_prefix = "connect/lightstream-dev-uw2/CallRecordings"
  }
  # scheduled_reports and chat_transcripts omitted — auto-created with standard names
  contact_trace_records = {
    stream_arn = "arn:aws:kinesis:us-east-1:014848577183:stream/<ctr-stream-name>"
  }
  media_streams = {
    prefix = "ls-connect-audiostream-uw2-"
  }
}

# ── Alerting ─────────────────────────────────────────────────────────────────
alarm_sns_topic_arns = [
  "arn:aws:sns:us-east-1:014848577183:ls-support-alerts",
]

key_admin_arns = [
  # "arn:aws:iam::014848577183:role/G-ROLE-AWS-RETAILCONNECTDEV-FSA",
]
