###############################################################################
# KMS Module — Locals
#
# name_prefix = "${var.project_name}-${var.account}-connect-${var.lob}"
#               example: tfc-retail-connect-tccivr
###############################################################################

locals {
  prefix   = var.project_name
  account  = var.account
  lob      = var.lob
  sdlc_env = var.sdlc_env

  name_prefix = "${local.prefix}-${local.account}-connect-${local.lob}"

  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.region
  partition  = data.aws_partition.current.partition

  default_service_principals = {
    s3      = ["s3.amazonaws.com", "connect.amazonaws.com"]
    kinesis = ["kinesis.amazonaws.com", "firehose.amazonaws.com"]
    connect = ["connect.amazonaws.com", "logs.${local.region}.amazonaws.com"]
  }

  resolved_keys = {
    for k, v in var.kms_keys :
    k => merge(v, {
      service_principals = length(v.service_principals) > 0 ? v.service_principals : lookup(local.default_service_principals, k, [])
    })
  }

  common_tags = merge(var.tags, {
    Name     = local.name_prefix
    sdlc_env = local.sdlc_env
  })
}
