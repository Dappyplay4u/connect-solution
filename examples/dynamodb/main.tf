module "connect_tables" {
  source = "../../modules/dynamodb"

  # ---------------------------------------------------------------------------
  # Naming — produces: ls-connect-<table-key>-uw2
  # ---------------------------------------------------------------------------
  project_name    = var.project_name
  aws_region_abbr = var.aws_region_abbr

  # ---------------------------------------------------------------------------
  # Tables — each key maps to a Connect configuration table:
  #   table name:   <project_name>-connect-<key>-<aws_region_abbr>
  #   S3 folder:    <key>/your-file.csv
  # ---------------------------------------------------------------------------
  tables = {

    # ls-connect-agent-configuration-uw2
    "agent-configuration" = {
      hash_key      = "AgentId"
      hash_key_type = "S"
      billing_mode  = "PAY_PER_REQUEST"
    }

    # ls-connect-DNIS-mapping-uw2
    "DNIS-mapping" = {
      hash_key      = "DNIS"
      hash_key_type = "S"
      billing_mode  = "PAY_PER_REQUEST"
    }

    # ls-connect-ivr-parameters--uw2  (trailing dash in key preserves double-dash)
    "ivr-parameters-" = {
      hash_key      = "ParameterKey"
      hash_key_type = "S"
      billing_mode  = "PAY_PER_REQUEST"
    }

    # ls-connect-ivr-pilot-phone-numbers-uw2
    "ivr-pilot-phone-numbers" = {
      hash_key      = "PhoneNumber"
      hash_key_type = "S"
      billing_mode  = "PAY_PER_REQUEST"
    }

    # ls-connect-office-hours--uw2  (trailing dash in key preserves double-dash)
    "office-hours-" = {
      hash_key      = "OfficeId"
      hash_key_type = "S"
      billing_mode  = "PAY_PER_REQUEST"
    }

    # ls-connect-prompts-uw2
    "prompts" = {
      hash_key      = "PromptId"
      hash_key_type = "S"
      billing_mode  = "PAY_PER_REQUEST"
    }

  }

  # ---------------------------------------------------------------------------
  # Shared CSV loader settings
  # ---------------------------------------------------------------------------
  csv_retention_days        = 90
  lambda_timeout_seconds    = 300
  lambda_memory_mb          = 256
  lambda_log_retention_days = 30

  # Optional — pass a KMS key ARN from your kms module if encryption is required
  kms_master_key_id = var.kms_master_key_id

  # ---------------------------------------------------------------------------
  # GitLab CI/CD automated upload
  # Creates an IAM role GitLab assumes via OIDC.
  # Set AWS_ROLE_ARN = <gitlab_upload_role_arn output> in GitLab CI/CD variables.
  # ---------------------------------------------------------------------------
  gitlab_ci_upload = {
    enabled      = true
    gitlab_url   = "https://gitlab.com"
    project_path = var.gitlab_project_path
    branch       = "main"
  }

  # ---------------------------------------------------------------------------
  # Tags
  # ---------------------------------------------------------------------------
  tags = local.required_tags
}
