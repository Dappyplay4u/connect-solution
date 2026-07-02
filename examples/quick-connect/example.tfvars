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
# Transfer to agent contact flow
#
# All USER-type quick connects share this flow.
# Find it in: Connect console → Contact flows → filter type "Transfer to agent"
# ---------------------------------------------------------------------------
# transfer_to_agent_flow_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

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
# Users to skip
#
# List any usernames from locals.tf that do not yet exist in Connect.
# Those users are excluded from the data source lookup and no quick connect
# is created for them. Remove a username from this list once the user is created.
# ---------------------------------------------------------------------------
# users_to_skip = [
#   "john.doe@company.com",
# ]
