# ---------------------------------------------------------------------------
# Naming
# Produces table names: ls-connect-<key>-uw2
# ---------------------------------------------------------------------------
project_name    = "ls"
aws_region_abbr = "uw2"

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
