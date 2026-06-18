locals {
  prefix          = var.project_name
  account         = var.account
  lob             = var.lob
  sdlc_env        = var.sdlc_env
  aws_region_abbr = var.aws_region_abbr

  name_prefix = "${local.prefix}-${local.account}-connect-${local.lob}-${local.sdlc_env}-${local.aws_region_abbr}"

  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.region
  partition  = data.aws_partition.current.partition

  common_tags = merge(var.tags, {
    sdlc_env    = local.sdlc_env
    name_prefix = local.name_prefix
  })

  # Shared resource names — no table suffix since these serve all tables
  csv_bucket_name = "${local.name_prefix}-ddb-csv"
  lambda_name     = "${local.name_prefix}-ddb-csv-loader"
  iam_role_name   = "${local.name_prefix}-ddb-csv-role"
  iam_policy_name = "${local.name_prefix}-ddb-csv-policy"
  log_group_name  = "/aws/lambda/${local.lambda_name}"

  use_kms = var.kms_master_key_id != null

  # GitLab OIDC upload role
  enable_gitlab_upload = var.gitlab_ci_upload.enabled
  create_oidc_provider = local.enable_gitlab_upload && var.gitlab_oidc_provider_arn == null
  # Strip protocol from URL to get the host used in OIDC condition keys
  gitlab_oidc_host     = replace(replace(coalesce(var.gitlab_ci_upload.gitlab_url, "https://gitlab.com"), "https://", ""), "http://", "")
  oidc_provider_arn    = local.create_oidc_provider ? aws_iam_openid_connect_provider.gitlab[0].arn : coalesce(var.gitlab_oidc_provider_arn, "")
  gitlab_role_name     = "${local.name_prefix}-ddb-gitlab-upload-role"
  gitlab_policy_name   = "${local.name_prefix}-ddb-gitlab-upload-policy"

  # Per-table key attribute maps (hash key + range key + GSI keys, deduplicated by name).
  # DynamoDB only allows attribute blocks for attributes used as keys.
  table_attributes = {
    for k, v in var.tables : k => merge(
      { (v.hash_key) = v.hash_key_type },
      v.range_key != null ? { (v.range_key) = coalesce(v.range_key_type, "S") } : {},
      merge([
        for gsi in v.global_secondary_indexes : merge(
          { (gsi.hash_key) = gsi.hash_key_type },
          gsi.range_key != null ? { (gsi.range_key) = coalesce(gsi.range_key_type, "S") } : {}
        )
      ]...)
    )
  }

  # Routing config passed to Lambda as TABLE_ROUTING env var.
  # Lambda extracts the S3 folder name and looks up the matching entry.
  table_routing = jsonencode({
    for k, v in var.tables : k => {
      table_name        = "${local.name_prefix}-${k}"
      hash_key          = v.hash_key
      range_key         = coalesce(v.range_key, "")
      number_attributes = v.csv_number_attributes
      sync_mode         = v.sync_mode
    }
  })
}
