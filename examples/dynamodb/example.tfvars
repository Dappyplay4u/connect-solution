# ---------------------------------------------------------------------------
# Naming
# Produces table names: ls-connect-<key>-uw2
# ---------------------------------------------------------------------------
project_name    = "ls"
aws_region_abbr = "uw2"

# ---------------------------------------------------------------------------
# Bring-your-own resources (leave commented out to auto-create)
# ---------------------------------------------------------------------------

# Pass ARNs for any tables that already exist — those tables are skipped
# during creation but the Lambda still gets IAM access to write to them.
# Keys must match the entries in the tables block in main.tf.
# existing_table_arns = {
#   "agent-configuration"     = "arn:aws:dynamodb:us-west-2:<account_id>:table/ls-connect-agent-configuration-uw2"
#   "DNIS-mapping"            = "arn:aws:dynamodb:us-west-2:<account_id>:table/ls-connect-DNIS-mapping-uw2"
#   "ivr-parameters-"         = "arn:aws:dynamodb:us-west-2:<account_id>:table/ls-connect-ivr-parameters--uw2"
#   "ivr-pilot-phone-numbers" = "arn:aws:dynamodb:us-west-2:<account_id>:table/ls-connect-ivr-pilot-phone-numbers-uw2"
#   "office-hours-"           = "arn:aws:dynamodb:us-west-2:<account_id>:table/ls-connect-office-hours--uw2"
#   "prompts"                 = "arn:aws:dynamodb:us-west-2:<account_id>:table/ls-connect-prompts-uw2"
# }

# Pass an existing IAM role for the Lambda CSV loader (must already have the
# required S3, DynamoDB, and CloudWatch permissions).
# existing_iam_role_arn = "arn:aws:iam::<account_id>:role/<existing-role-name>"

# ---------------------------------------------------------------------------
# Optional — uncomment if your account requires a KMS key or permission boundary
# ---------------------------------------------------------------------------
# kms_master_key_id           = "arn:aws:kms:us-west-2:<account_id>:key/<key-id>"
# iam_permission_boundary_arn = "arn:aws:iam::<account_id>:policy/EnterprisePermissionBoundary"

# ---------------------------------------------------------------------------
# Required enterprise tags
# ---------------------------------------------------------------------------
business_application_id   = "APP-12345"
cost_center               = "CC-9876"
created_by                = "terraform"
technical_support_by      = "platform-team"
application_group         = "contact-center"
technical_environment     = "qa"
security_data_application = "false"
business_application_code = "CCIVR"
