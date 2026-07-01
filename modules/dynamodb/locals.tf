locals {
  prefix          = var.project_name
  aws_region_abbr = var.aws_region_abbr

  # Shared prefix for all non-table resources (S3, Lambda, IAM, CloudWatch).
  # Table names follow: ${local.prefix}-connect-${each.key}-${local.aws_region_abbr}
  name_prefix = "${local.prefix}-connect-${local.aws_region_abbr}"

  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.region
  partition  = data.aws_partition.current.partition

  common_tags = var.tags

  csv_bucket_name = "${local.name_prefix}-ddb-csv"
  lambda_name     = "${local.name_prefix}-ddb-loader"
  iam_role_name   = "${local.name_prefix}-ddb-loader-role"
  iam_policy_name = "${local.name_prefix}-ddb-loader-policy"
  log_group_name  = "/aws/lambda/${local.lambda_name}"

  use_kms = var.kms_master_key_id != null

  # IAM — skip role + policy creation when an existing role ARN is supplied
  create_iam     = var.existing_iam_role_arn == null ? 1 : 0
  lambda_role_arn = coalesce(var.existing_iam_role_arn, try(aws_iam_role.csv_loader[0].arn, null))

  # Tables to create — excludes any key already present in existing_table_arns
  tables_to_create = {
    for k, v in var.tables : k => v
    if !contains(keys(var.existing_table_arns), k)
  }

  # Full ARN map covering both created and pre-existing tables.
  # Used by the Lambda IAM policy so it has access to all tables.
  all_table_arns = merge(
    { for k, v in aws_dynamodb_table.this : k => v.arn },
    var.existing_table_arns
  )

  # Per-table key attribute maps (hash + range + GSI keys, deduplicated).
  # DynamoDB only allows attribute blocks for key attributes.
  table_attributes = {
    for k, v in local.tables_to_create : k => merge(
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

  # Routing map injected into Lambda as TABLE_ROUTING environment variable.
  # Lambda extracts the S3 folder name from the object key and uses this map
  # to find the target table name and schema for that folder.
  table_routing = jsonencode({
    for k, v in var.tables : k => {
      table_name        = "${local.prefix}-connect-${k}-${local.aws_region_abbr}"
      hash_key          = v.hash_key
      range_key         = coalesce(v.range_key, "")
      number_attributes = v.csv_number_attributes
      sync_mode         = v.sync_mode
    }
  })
}
