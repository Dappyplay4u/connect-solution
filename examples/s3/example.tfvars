###############################################################################
# S3 Complete Example — example.tfvars
#
# Copy to terraform.tfvars:
#   cp example.tfvars terraform.tfvars
#
# Resulting bucket names:
#   tfc-retail-connect-tccivr-prod-recordings-ue1
#   tfc-retail-connect-tccivr-prod-reports-ue1
#   tfc-retail-connect-tccivr-prod-transcripts-ue1
#   tfc-retail-connect-tccivr-prod-access-logs-ue1
###############################################################################

aws_region      = "us-east-1"
project_name    = "tfc"
account         = "retail"
lob             = "tccivr"
sdlc_env        = "prod"
aws_region_abbr = "ue1"

kms_key_arn   = "arn:aws:kms:us-east-1:<account_id>:key/<key_id>"
force_destroy = false
