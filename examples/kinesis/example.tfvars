###############################################################################
# Kinesis Complete Example — example.tfvars
#
# Copy to terraform.tfvars:
#   cp example.tfvars terraform.tfvars
#
# Resulting stream names:
#   tfc-retail-connect-tccivr-agent-events-datastream-ue1
#   tfc-retail-connect-tccivr-media-streams-datastream-ue1
# Resulting firehose:
#   tfc-retail-connect-tccivr-agent-events-deliverystreams-ue1
###############################################################################

aws_region      = "us-east-1"
project_name    = "tfc"
account         = "retail"
lob             = "tccivr"
sdlc_env        = "qa"
aws_region_abbr = "ue1"

kms_key_id  = "<kinesis-kms-key-id>"
kms_key_arn = "arn:aws:kms:us-east-1:<account_id>:key/<kinesis-key-id>"

ctr_s3_bucket_arn = "arn:aws:s3:::tfc-retail-connect-tccivr-qa-recordings-ue1"

alarm_sns_topic_arns = [
  # "arn:aws:sns:us-east-1:<account_id>:connect-alerts-qa",
]

# ── Required Tags ──────────────────────────────────────────────────────────────
business_application_id   = "APP-001"
cost_center               = "CC-1234"
created_by                = "platform-team"
technical_support_by      = "cloud-ops"
application_group         = "contact-center"
technical_environment     = "qa"
security_data_application = "confidential"
business_application_code = "RETAIL-CC"
