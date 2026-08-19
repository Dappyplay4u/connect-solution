# ---------------------------------------------------------------------------
# TFC — QA (us-east-1)
#
# All S3 buckets and Kinesis streams were manually created before Terraform
# and imported into state. storage_overrides is the single place to declare:
#   - bucket_name / stream_arn  → which existing resource to use (skips creation)
#   - bucket_prefix / prefix    → the path Connect was already configured with
#
# Read current state values with:
#   terraform state show 'module.connect.aws_connect_instance_storage_config.call_recordings'
#   terraform state show 'module.connect.aws_connect_instance_storage_config.media_streams'
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

# ── KMS keys (shared Truist standard keys — always bring-your-own) ───────────
existing_kms_s3_arn      = "arn:aws:kms:us-east-1:<account_id>:key/<s3-key-id>"
existing_kms_kinesis_arn = "arn:aws:kms:us-east-1:<account_id>:key/<kinesis-key-id>"
existing_kms_connect_arn = "arn:aws:kms:us-east-1:<account_id>:key/<connect-key-id>"

# ── Storage overrides — all S3 + Kinesis names and Connect config paths ───────
storage_overrides = {
  call_recordings = {
    bucket_name   = "tfc-retail-connect-tccivr-qa-recordings-ue1"
    bucket_prefix = "connect/retail-qa-ue1/CallRecordings"
  }
  scheduled_reports = {
    bucket_name   = "tfc-retail-connect-tccivr-qa-reports-ue1"
    # bucket_prefix omitted — module default "scheduled-reports" already matches
  }
  chat_transcripts = {
    bucket_name   = "truistmessaging-connectdata-qa"
    bucket_prefix = "connect/retail-qa-ue1/ChatTranscripts"
  }
  contact_trace_records = {
    stream_arn = "arn:aws:kinesis:us-east-1:<account_id>:stream/<ctr-stream-name>"
  }
  media_streams = {
    prefix = "my-connect-retail-qa-ue1-contact-"
  }
}

# ── Alerting ─────────────────────────────────────────────────────────────────
alarm_sns_topic_arns = [
  # "arn:aws:sns:us-east-1:<account_id>:tfc-connect-alerts-qa",
]

key_admin_arns = [
  # "arn:aws:iam::<account_id>:role/G-ROLE-AWS-RETAILCONNECTTEST-FSA",
]
