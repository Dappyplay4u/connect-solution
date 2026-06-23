# ---------------------------------------------------------------------------
# Step 1 — Hours of Operation
#
# Deploy this module first. Its output IDs are passed directly to the queues
# module below. Both modules reference the same Connect instance.
# ---------------------------------------------------------------------------

module "hours" {
  source = "../../modules/hours-of-operation"

  project_name    = var.project_name
  account         = var.account
  lob             = var.lob
  sdlc_env        = var.sdlc_env
  aws_region_abbr = var.aws_region_abbr

  instance_id    = var.instance_id
  instance_alias = var.instance_alias

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

  }

  tags = local.required_tags
}

# ---------------------------------------------------------------------------
# Step 2 — Queues
#
# hours_of_operation_id for each queue is supplied from module.hours above.
# To reference a pre-existing hours of operation (e.g. the Connect default
# "Basic Hours") pass its ID string directly instead.
# ---------------------------------------------------------------------------

module "queues" {
  source = "../../modules/connect-queue"

  project_name    = var.project_name
  account         = var.account
  lob             = var.lob
  sdlc_env        = var.sdlc_env
  aws_region_abbr = var.aws_region_abbr

  instance_id    = var.instance_id
  instance_alias = var.instance_alias

  queues = {

    billing = {
      description           = "Billing enquiries queue"
      hours_of_operation_id = module.hours.hours_of_operation_ids["standard-business-hours"]
      max_contacts          = 50
      status                = "ENABLED"
    }

    sales = {
      description           = "Sales enquiries queue"
      hours_of_operation_id = module.hours.hours_of_operation_ids["extended-hours"]
      max_contacts          = 100
      status                = "ENABLED"
    }

    support = {
      description           = "Technical support queue"
      hours_of_operation_id = module.hours.hours_of_operation_ids["standard-business-hours"]
      max_contacts          = 75
      status                = "ENABLED"
    }

    after-hours = {
      description           = "After hours overflow queue"
      hours_of_operation_id = module.hours.hours_of_operation_ids["extended-hours"]
      max_contacts          = 0
      status                = "ENABLED"
    }

  }

  tags = local.required_tags
}
