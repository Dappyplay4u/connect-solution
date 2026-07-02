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
  # Option A — pass the instance ID directly (from connect-instance module
  #            output or an existing instance):
  #   instance_id = var.instance_id
  #
  # Option B — let the module resolve the ID by alias:
  #   instance_alias = var.instance_alias
  #
  # Only one is required. instance_id takes precedence if both are set.
  # ---------------------------------------------------------------------------
  instance_id    = var.instance_id
  instance_alias = var.instance_alias

  # ---------------------------------------------------------------------------
  # Quick Connects
  #
  # Each key becomes part of the resource name:
  #   <project_name>-<account>-connect-<lob>-<sdlc_env>-<aws_region_abbr>-<key>
  #
  # Three types are supported:
  #
  #   PHONE_NUMBER — transfers an agent to an external phone number.
  #                  Required: phone_number (E.164 format).
  #
  #   QUEUE        — transfers an agent to an internal Connect queue.
  #                  Required: contact_flow_id, queue_id.
  #                  Use the connect-queue module output for queue_id.
  #
  #   AGENT        — transfers an agent directly to another agent.
  #                  Required: contact_flow_id, user_id.
  #                  user_id is the Connect UserId (not the IAM user).
  # ---------------------------------------------------------------------------
  quick_connects = {

    # Transfer to an external support line
    external-support = {
      description  = "Transfer to external tier-2 support line"
      type         = "PHONE_NUMBER"
      phone_number = "+15551234567"
    }

    # Transfer to an internal sales queue
    sales-queue = {
      description     = "Transfer to the internal sales queue"
      type            = "QUEUE"
      contact_flow_id = "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
      queue_id        = "ffffffff-gggg-hhhh-iiii-jjjjjjjjjjjj"
    }

    # Transfer directly to a senior agent
    senior-agent = {
      description     = "Transfer to senior agent for escalations"
      type            = "AGENT"
      contact_flow_id = "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
      user_id         = "kkkkkkkk-llll-mmmm-nnnn-oooooooooooo"
    }

  }

  tags = local.required_tags
}
