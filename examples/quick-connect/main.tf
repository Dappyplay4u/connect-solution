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

    # QUEUE-type — auto-populated from existing Connect queues via data source
    local.queue_quick_connects,

    # PHONE_NUMBER-type — uncomment and populate as needed
    # {
    #   external-fraud-line = {
    #     description  = "Transfer to external fraud support line"
    #     type         = "PHONE_NUMBER"
    #     phone_number = "+15551234567"
    #   }
    # },

    # AGENT-type — uncomment and populate as needed
    # {
    #   senior-agent = {
    #     description     = "Transfer to senior agent for escalations"
    #     type            = "AGENT"
    #     contact_flow_id = "<transfer-to-agent-flow-id>"
    #     user_id         = "<connect-user-id>"
    #   }
    # },

  )

  tags = local.required_tags
}
