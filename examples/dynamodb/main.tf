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
  #   data/agent-configurations/sample.csv
  #   data/DNIS-mapping/sample.csv
  #   data/office-hours/sample.csv
  #   data/prompts/sample.csv
  # ---------------------------------------------------------------------------
  tables = {

    # ls-connect-agent-configurations-uw2
    "agent-configurations" = {
      hash_key              = "agentName"
      csv_number_attributes = ["agentExtensionId", "DID", "NLMSId"]
    }

    # ls-connect-DNIS-mapping-uw2
    "DNIS-mapping" = {
      hash_key = "TFN"
    }

    # ls-connect-ivr-parameters--uw2
    "ivr-parameters-" = {
      hash_key = "ParameterKey"
    }

    # ls-connect-ivr-pilot-phone-numbers-uw2
    "ivr-pilot-phone-numbers" = {
      hash_key = "PhoneNumber"
    }

    # ls-connect-office-hours-uw2
    "office-hours" = {
      hash_key      = "type"
      range_key     = "sequenceId"
      billing_mode  = "PROVISIONED"
      read_capacity = 10
      write_capacity = 5
    }

    # ls-connect-prompts-uw2
    "prompts" = {
      hash_key       = "category"
      range_key      = "promptName"
      billing_mode   = "PROVISIONED"
      read_capacity  = 10
      write_capacity = 5
    }

  }

  existing_table_arns         = var.existing_table_arns
  existing_iam_role_arn       = var.existing_iam_role_arn
  kms_master_key_id           = var.kms_master_key_id
  iam_permission_boundary_arn = var.iam_permission_boundary_arn
}
