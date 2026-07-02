module "quick_connect" {
  source = "../../modules/quick-connect"

  # ---------------------------------------------------------------------------
  # Naming
  # ---------------------------------------------------------------------------
  project_name    = var.project_name
  account         = var.account
  lob             = var.lob
  sdlc_env        = var.sdlc_env
  aws_region_abbr = var.aws_region_abbr

  # ---------------------------------------------------------------------------
  # Connect instance
  #
  # Option A — pass the instance ID directly:
  #   instance_id = var.instance_id
  #
  # Option B — let the module resolve the ID by alias:
  #   instance_alias = var.instance_alias
  #
  # Swap instances by changing instance_id or instance_alias in example.tfvars.
  # ---------------------------------------------------------------------------
  instance_id    = var.instance_id
  instance_alias = var.instance_alias

  # ---------------------------------------------------------------------------
  # Quick connects
  #
  # QUEUE-type quick connects are built automatically from data.aws_connect_queue.
  # Queues are looked up by their full name from the Connect instance — no manual
  # ID copying required.
  #
  # To exclude queues not yet created: add their keys to queues_to_skip in tfvars.
  # To add PHONE_NUMBER or AGENT types: merge them in below.
  # ---------------------------------------------------------------------------
  quick_connects = merge(
    local.queue_quick_connects,   # QUEUE       — from data.aws_connect_queue
    local.phone_quick_connects,   # PHONE_NUMBER — from local.phone_number_entries
    local.user_quick_connects,    # USER         — from local.user_entries
  )
}
