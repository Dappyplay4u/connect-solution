module "hours_of_operation" {
  source = "../../modules/hours-of-operation"

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
  # Hours of Operation
  #
  # Each key becomes part of the resource name:
  #   <project_name>-<account>-connect-<lob>-<sdlc_env>-<aws_region_abbr>-<key>
  #
  # The IDs produced by this module are passed to the connect-queue module
  # via hours_of_operation_id on each queue definition.
  # ---------------------------------------------------------------------------
  hours_of_operation = {

    standard-business-hours = {
      description = "Monday to Friday 9am-6pm Eastern"
      time_zone   = "America/New_York"
      config = [
        { day = "MONDAY",    start_time = { hours = 9, minutes = 0 }, end_time = { hours = 18, minutes = 0 } },
        { day = "TUESDAY",   start_time = { hours = 9, minutes = 0 }, end_time = { hours = 18, minutes = 0 } },
        { day = "WEDNESDAY", start_time = { hours = 9, minutes = 0 }, end_time = { hours = 18, minutes = 0 } },
        { day = "THURSDAY",  start_time = { hours = 9, minutes = 0 }, end_time = { hours = 18, minutes = 0 } },
        { day = "FRIDAY",    start_time = { hours = 9, minutes = 0 }, end_time = { hours = 18, minutes = 0 } },
      ]
    }

    extended-hours = {
      description = "Monday to Saturday 8am-8pm Eastern"
      time_zone   = "America/New_York"
      config = [
        { day = "MONDAY",    start_time = { hours = 8, minutes = 0 }, end_time = { hours = 20, minutes = 0 } },
        { day = "TUESDAY",   start_time = { hours = 8, minutes = 0 }, end_time = { hours = 20, minutes = 0 } },
        { day = "WEDNESDAY", start_time = { hours = 8, minutes = 0 }, end_time = { hours = 20, minutes = 0 } },
        { day = "THURSDAY",  start_time = { hours = 8, minutes = 0 }, end_time = { hours = 20, minutes = 0 } },
        { day = "FRIDAY",    start_time = { hours = 8, minutes = 0 }, end_time = { hours = 20, minutes = 0 } },
        { day = "SATURDAY",  start_time = { hours = 8, minutes = 0 }, end_time = { hours = 20, minutes = 0 } },
      ]
    }

    after-hours-24x7 = {
      description = "24 hours, 7 days a week"
      time_zone   = "America/New_York"
      config = [
        { day = "MONDAY",    start_time = { hours = 0, minutes = 0 }, end_time = { hours = 23, minutes = 59 } },
        { day = "TUESDAY",   start_time = { hours = 0, minutes = 0 }, end_time = { hours = 23, minutes = 59 } },
        { day = "WEDNESDAY", start_time = { hours = 0, minutes = 0 }, end_time = { hours = 23, minutes = 59 } },
        { day = "THURSDAY",  start_time = { hours = 0, minutes = 0 }, end_time = { hours = 23, minutes = 59 } },
        { day = "FRIDAY",    start_time = { hours = 0, minutes = 0 }, end_time = { hours = 23, minutes = 59 } },
        { day = "SATURDAY",  start_time = { hours = 0, minutes = 0 }, end_time = { hours = 23, minutes = 59 } },
        { day = "SUNDAY",    start_time = { hours = 0, minutes = 0 }, end_time = { hours = 23, minutes = 59 } },
      ]
    }

  }

  tags = local.required_tags
}
