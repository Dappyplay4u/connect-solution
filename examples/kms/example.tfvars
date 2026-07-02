###############################################################################
# KMS Complete Example — example.tfvars
#
# Copy to terraform.tfvars:
#   cp example.tfvars terraform.tfvars
#
# Resulting KMS aliases:
#   alias/tfc-retail-connect-tccivr-s3
#   alias/tfc-retail-connect-tccivr-kinesis
#   alias/tfc-retail-connect-tccivr-connect
###############################################################################

aws_region   = "us-east-1"
project_name = "tfc"
account      = "retail"
lob          = "tccivr"
sdlc_env     = "prod"

key_admin_arns = [
  # "arn:aws:iam::<account_id>:role/TerraformDeployRole",
]
