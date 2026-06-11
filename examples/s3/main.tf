###############################################################################
# S3 Module — Complete Example
#
# Run from this directory:
#   cp example.tfvars terraform.tfvars
#   terraform init
#   terraform plan
#   terraform apply
#
# Resulting bucket names:
#   tfc-retail-connect-tccivr-prod-recordings-ue1
#   tfc-retail-connect-tccivr-prod-reports-ue1
#   tfc-retail-connect-tccivr-prod-transcripts-ue1
#   tfc-retail-connect-tccivr-prod-access-logs-ue1
###############################################################################

module "s3" {
  source = "../../modules/s3"

  aws_region      = var.aws_region
  project_name    = var.project_name
  account         = var.account
  lob             = var.lob
  sdlc_env        = var.sdlc_env
  aws_region_abbr = var.aws_region_abbr

  kms_key_arn   = var.kms_key_arn
  force_destroy = var.force_destroy

  enable_access_logging              = true
  lifecycle_ia_transition_days       = 90
  lifecycle_glacier_transition_days  = 365
  lifecycle_expiration_days          = 2555
  noncurrent_version_expiration_days = 90

  tags = local.required_tags
}
