###############################################################################
# Connect Instance Complete Example — example.tfvars
#
# Copy to terraform.tfvars:
#   cp example.tfvars terraform.tfvars
#
# What this deploys (all auto-created):
#   KMS keys   →  alias/tfc-retail-connect-tccivr-s3 | -kinesis | -connect
#   S3 buckets →  tfc-retail-connect-tccivr-prod-recordings-ue1
#                 tfc-retail-connect-tccivr-prod-reports-ue1
#                 tfc-retail-connect-tccivr-prod-transcripts-ue1
#   Kinesis    →  tfc-retail-connect-tccivr-agent-events-datastream-ue1
#                 tfc-retail-connect-tccivr-media-streams-datastream-ue1
#   Firehose   →  tfc-retail-connect-tccivr-agent-events-deliverystreams-ue1
#   Connect    →  instance alias: retail-prod-ue1
#   CloudWatch →  /aws/connect/retail-prod-ue1
###############################################################################

# ── Region ────────────────────────────────────────────────────────────────────
aws_region = "us-east-1"

# ── Naming ────────────────────────────────────────────────────────────────────
project_spec    = "retail" # used in instance alias: retail-prod-ue1
project_name    = "tfc"    # short prefix used in all resource names
account         = "retail" # retail | sales
lob             = "tccivr" # line of business
sdlc_env        = "prod"   # prod | qa | test
aws_region_abbr = "ue1"    # ue1 | ue2 | uw1 | uw2 | ew1 | ec1

# ── Bring-your-own resources (leave "" to auto-create) ───────────────────────
existing_kms_s3_arn              = ""
existing_kms_kinesis_arn         = ""
existing_kms_connect_arn         = ""
existing_s3_call_recordings_id   = ""
existing_s3_scheduled_reports_id = ""
existing_s3_chat_transcripts_id  = ""
existing_kinesis_ctr_arn         = ""
existing_kinesis_media_arn       = ""

# ── KMS key administrators ────────────────────────────────────────────────────
key_admin_arns = [
  # "arn:aws:iam::<account_id>:role/TerraformDeployRole",
]

# ── CloudWatch alarm SNS topics ───────────────────────────────────────────────
alarm_sns_topic_arns = [
  # "arn:aws:sns:us-east-1:<account_id>:connect-alerts-prod",
]

# ── Required Tags ──────────────────────────────────────────────────────────────
business_application_id   = "APP-001"
cost_center               = "CC-1234"
created_by                = "platform-team"
technical_support_by      = "cloud-ops"
application_group         = "contact-center"
technical_environment     = "production"
security_data_application = "confidential"
business_application_code = "RETAIL-CC"
