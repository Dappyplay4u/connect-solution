locals {
  prefix          = var.project_name
  account         = var.account
  lob             = var.lob
  sdlc_env        = var.sdlc_env
  aws_region_abbr = var.aws_region_abbr

  # Shared name prefix for all resources in this module
  name_prefix = "${local.prefix}-${local.account}-connect-${local.lob}-${local.sdlc_env}-${local.aws_region_abbr}"

  # Resolve instance_id — use the variable directly or look it up by alias
  instance_id = var.instance_id != null ? var.instance_id : data.aws_connect_instance.this[0].id

  common_tags = merge(var.tags, {
    sdlc_env = local.sdlc_env
  })
}
