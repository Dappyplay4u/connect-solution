###############################################################################
# KMS Module — Complete Example
#
# Run from this directory:
#   cp example.tfvars terraform.tfvars
#   terraform init
#   terraform plan
#   terraform apply
#
# Resulting KMS aliases:
#   alias/tfc-retail-connect-tccivr-s3
#   alias/tfc-retail-connect-tccivr-kinesis
#   alias/tfc-retail-connect-tccivr-connect
###############################################################################

module "kms" {
  source = "../../modules/kms"

  aws_region   = var.aws_region
  project_name = var.project_name
  account      = var.account
  lob          = var.lob
  sdlc_env     = var.sdlc_env

  key_admin_arns = var.key_admin_arns

  kms_keys = {
    s3      = {}
    kinesis = {}
    connect = {}
  }

  tags = local.required_tags
}
