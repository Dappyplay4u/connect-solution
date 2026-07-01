module "connect_tables" {
  source = "../../modules/dynamodb"

  project_name    = var.project_name
  aws_region_abbr = var.aws_region_abbr

  # ---------------------------------------------------------------------------
  # The six Amazon Connect configuration tables.
  #
  # Table name pattern:  <project_name>-connect-<key>-<aws_region_abbr>
  # S3 upload folder:    <key>/your-file.csv
  #
  # Sample CSV files for manual testing are in the data/ folder:
  #   data/agent-configuration/sample.csv
  #   data/DNIS-mapping/sample.csv
  #   data/ivr-parameters-/sample.csv
  #   data/ivr-pilot-phone-numbers/sample.csv
  #   data/office-hours-/sample.csv
  #   data/prompts/sample.csv
  # ---------------------------------------------------------------------------
  tables = {

    # ls-connect-agent-configuration-uw2
    "agent-configuration" = {
      hash_key = "AgentId"
    }

    # ls-connect-DNIS-mapping-uw2
    "DNIS-mapping" = {
      hash_key = "DNIS"
    }

    # ls-connect-ivr-parameters--uw2
    "ivr-parameters-" = {
      hash_key = "ParameterKey"
    }

    # ls-connect-ivr-pilot-phone-numbers-uw2
    "ivr-pilot-phone-numbers" = {
      hash_key = "PhoneNumber"
    }

    # ls-connect-office-hours--uw2
    "office-hours-" = {
      hash_key = "OfficeId"
    }

    # ls-connect-prompts-uw2
    "prompts" = {
      hash_key = "PromptId"
    }

  }

  existing_table_arns         = var.existing_table_arns
  existing_iam_role_arn       = var.existing_iam_role_arn
  kms_master_key_id           = var.kms_master_key_id
  iam_permission_boundary_arn = var.iam_permission_boundary_arn

  tags = local.required_tags
}
