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
# Transfer to queue contact flow
#
# All QUEUE-type quick connects share this flow.
# Find it in: Connect console → Contact flows → filter type "Transfer to queue"
# Then copy the ID from the URL or flow detail page.
# ---------------------------------------------------------------------------
# transfer_to_queue_flow_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

# ---------------------------------------------------------------------------
# Queues to skip
#
# List any queue keys from locals.tf that do not yet exist in Connect.
# Those queues are excluded from the data source lookup and no quick connect
# is created for them. Remove a key from this list once the queue is created.
# ---------------------------------------------------------------------------
# queues_to_skip = [
#   "CC_CD2_CardAcctInfoFD",
#   "CC_CD3_CardPinChangeFD",
# ]

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
