# ---------------------------------------------------------------------------
# TFC — QA (us-east-1)
#
# Resources in this environment were manually created before Terraform.
# - existing_* variables point to those resources (skips re-creation)
# - *_bucket_prefix / media_streams_prefix preserve the original paths
#   that Connect was configured with, preventing a destructive drift
# ---------------------------------------------------------------------------

# ── Region ──────────────────────────────────────────────────────────────────
aws_region      = "us-east-1"
aws_region_abbr = "ue1"

# ── Naming ──────────────────────────────────────────────────────────────────
# Produces: tfc-retail-connect-tccivr-qa-<suffix>-ue1
project_spec = "retail"
project_name = "tfc"
account      = "retail"
lob          = "tccivr"
sdlc_env     = "qa"

# ── Bring-your-own: all resources pre-exist in this region ──────────────────
existing_kms_s3_arn      = "arn:aws:kms:us-east-1:<account_id>:key/<s3-key-id>"
existing_kms_kinesis_arn = "arn:aws:kms:us-east-1:<account_id>:key/<kinesis-key-id>"
existing_kms_connect_arn = "arn:aws:kms:us-east-1:<account_id>:key/<connect-key-id>"

# Pass the existing bucket names so Terraform does not try to create new ones
existing_s3_call_recordings_id   = "tfc-retail-connect-tccivr-qa-recordings-ue1"
existing_s3_scheduled_reports_id = "tfc-retail-connect-tccivr-qa-reports-ue1"
existing_s3_chat_transcripts_id  = "truistmessaging-connectdata-qa"

# Pass existing Kinesis stream ARNs
existing_kinesis_ctr_arn   = "arn:aws:kinesis:us-east-1:<account_id>:stream/<ctr-stream-name>"
existing_kinesis_media_arn = "arn:aws:kinesis:us-east-1:<account_id>:stream/<media-stream-name>"

# ── Storage prefix overrides ─────────────────────────────────────────────────
# The Connect instance in this region was configured with these paths.
# Overriding prevents Terraform from changing where recordings/transcripts land.
call_recordings_bucket_prefix  = "connect/retail-qa-ue1/CallRecordings"
chat_transcripts_bucket_prefix = "connect/retail-qa-ue1/ChatTranscripts"
media_streams_prefix           = "my-connect-retail-qa-ue1-contact-"
# scheduled_reports_bucket_prefix = null   # leave null → uses module default

# ── Alerting ─────────────────────────────────────────────────────────────────
alarm_sns_topic_arns = [
  # "arn:aws:sns:us-east-1:<account_id>:tfc-connect-alerts-qa",
]

# ── KMS key administrators ────────────────────────────────────────────────────
key_admin_arns = [
  # "arn:aws:iam::<account_id>:role/G-ROLE-AWS-RETAILCONNECTTEST-FSA",
]
