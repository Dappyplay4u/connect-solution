# ---------------------------------------------------------------------------
# Step 1 — Hours of Operation
#
# Two schedules are defined here and referenced by name in the queues below.
# Deploy this module first; its output IDs are passed directly to the queues.
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
# Queues are grouped by business category. Each group shares the same
# hours-of-operation and max_contacts setting. Descriptions are auto-generated
# from the queue key via local.queue_descriptions.
#
# To add a new queue: add its key to the appropriate list in locals.tf.
# No changes to this file are needed.
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

  queues = merge(

    # -------------------------------------------------------------------------
    # Customer Care → Standard Hours
    # -------------------------------------------------------------------------
    {
      for q in local.customer_care_queues : q => {
        description           = local.queue_descriptions[q]
        hours_of_operation_id = module.hours.hours_of_operation_ids["standard-business-hours"]
        max_contacts          = 100
        status                = "ENABLED"
      }
    },

    # -------------------------------------------------------------------------
    # Credit Card Services → Extended Hours
    # -------------------------------------------------------------------------
    {
      for q in local.credit_card_queues : q => {
        description           = local.queue_descriptions[q]
        hours_of_operation_id = module.hours.hours_of_operation_ids["extended-hours"]
        max_contacts          = 150
        status                = "ENABLED"
      }
    },

    # -------------------------------------------------------------------------
    # Loans → Standard Hours
    # -------------------------------------------------------------------------
    {
      for q in local.loans_queues : q => {
        description           = local.queue_descriptions[q]
        hours_of_operation_id = module.hours.hours_of_operation_ids["standard-business-hours"]
        max_contacts          = 75
        status                = "ENABLED"
      }
    },

    # -------------------------------------------------------------------------
    # Digital / Online Support → Extended Hours
    # -------------------------------------------------------------------------
    {
      for q in local.digital_queues : q => {
        description           = local.queue_descriptions[q]
        hours_of_operation_id = module.hours.hours_of_operation_ids["extended-hours"]
        max_contacts          = 120
        status                = "ENABLED"
      }
    },

    # -------------------------------------------------------------------------
    # Premier Customer Services → Standard Hours
    # -------------------------------------------------------------------------
    {
      for q in local.premier_queues : q => {
        description           = local.queue_descriptions[q]
        hours_of_operation_id = module.hours.hours_of_operation_ids["standard-business-hours"]
        max_contacts          = 50
        status                = "ENABLED"
      }
    },

    # -------------------------------------------------------------------------
    # Spanish Language Support → Extended Hours
    # -------------------------------------------------------------------------
    {
      for q in local.spanish_queues : q => {
        description           = local.queue_descriptions[q]
        hours_of_operation_id = module.hours.hours_of_operation_ids["extended-hours"]
        max_contacts          = 100
        status                = "ENABLED"
      }
    },

    # -------------------------------------------------------------------------
    # Fraud & Security → Extended Hours (24/7 schedule when available)
    # -------------------------------------------------------------------------
    {
      for q in local.fraud_security_queues : q => {
        description           = local.queue_descriptions[q]
        hours_of_operation_id = module.hours.hours_of_operation_ids["extended-hours"]
        max_contacts          = 200
        status                = "ENABLED"
      }
    },

    # -------------------------------------------------------------------------
    # Business & Commercial Services → Extended Hours
    # -------------------------------------------------------------------------
    {
      for q in local.business_commercial_queues : q => {
        description           = local.queue_descriptions[q]
        hours_of_operation_id = module.hours.hours_of_operation_ids["extended-hours"]
        max_contacts          = 100
        status                = "ENABLED"
      }
    },

    # -------------------------------------------------------------------------
    # Special Routing / IVR → Extended Hours (unlimited capacity)
    # -------------------------------------------------------------------------
    {
      for q in local.special_routing_queues : q => {
        description           = local.queue_descriptions[q]
        hours_of_operation_id = module.hours.hours_of_operation_ids["extended-hours"]
        max_contacts          = 0
        status                = "ENABLED"
      }
    },

  )

  tags = local.required_tags
}
