# ---------------------------------------------------------------------------
# Naming
# ---------------------------------------------------------------------------
project_name    = "tfc"
account         = "retail"
lob             = "tccivr"
sdlc_env        = "prod"
aws_region_abbr = "ue1"

# ---------------------------------------------------------------------------
# Connect instance — uncomment ONE of the two options
# ---------------------------------------------------------------------------

# Option A: pass the instance ID directly
# instance_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

# Option B: look up by alias (module resolves the ID automatically)
instance_alias = "retail-prod-ue1"

# ---------------------------------------------------------------------------
# Required enterprise tags
# ---------------------------------------------------------------------------
business_application_id   = "APP-001"
cost_center               = "CC-1234"
created_by                = "terraform"
technical_support_by      = "cloud-ops"
application_group         = "contact-center"
technical_environment     = "production"
security_data_application = "confidential"
business_application_code = "RETAIL-CC"
