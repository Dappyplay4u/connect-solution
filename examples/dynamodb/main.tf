module "connect_tables" {
  source = "../../modules/dynamodb"

  # ---------------------------------------------------------------------------
  # Naming
  # ---------------------------------------------------------------------------
  project_name    = var.project_name
  account         = var.account
  lob             = var.lob
  sdlc_env        = var.sdlc_env
  aws_region_abbr = var.aws_region_abbr

  # ---------------------------------------------------------------------------
  # Tables
  # Each key becomes:
  #   - the table name suffix:  <name_prefix>-<key>
  #   - the S3 upload folder:   <key>/your-file.csv
  # ---------------------------------------------------------------------------
  tables = {

    phone-routing = {
      hash_key      = "phone_number"
      hash_key_type = "S"
      billing_mode  = "PAY_PER_REQUEST"

      global_secondary_indexes = [
        {
          name            = "contact-flow-index"
          hash_key        = "contact_flow_id"
          hash_key_type   = "S"
          projection_type = "ALL"
        }
      ]
    }

    blocked-numbers = {
      hash_key      = "phone_number"
      hash_key_type = "S"
      billing_mode  = "PAY_PER_REQUEST"
    }

    agent-routing = {
      hash_key      = "agent_id"
      hash_key_type = "S"
      range_key     = "skill"
      range_key_type = "S"
      billing_mode  = "PAY_PER_REQUEST"

      # priority_level values in the CSV are numbers
      csv_number_attributes = ["priority_level"]
    }

  }

  # ---------------------------------------------------------------------------
  # Shared CSV loader settings
  # ---------------------------------------------------------------------------
  csv_retention_days        = 90
  lambda_timeout_seconds    = 300
  lambda_memory_mb          = 256
  lambda_log_retention_days = 30

  # Optional KMS key — pass one from the kms module if encryption is required
  kms_master_key_id = var.kms_master_key_id

  # ---------------------------------------------------------------------------
  # GitLab CI/CD automated upload
  # Terraform creates an IAM role GitLab assumes via OIDC.
  # Set AWS_ROLE_ARN = <gitlab_upload_role_arn output> in GitLab CI/CD variables.
  # ---------------------------------------------------------------------------
  gitlab_ci_upload = {
    enabled      = true
    gitlab_url   = "https://gitlab.com"
    project_path = var.gitlab_project_path   # e.g. "mygroup/myrepo"
    branch       = "main"
  }

  # ---------------------------------------------------------------------------
  # Tags
  # ---------------------------------------------------------------------------
  tags = local.required_tags
}
