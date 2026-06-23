resource "aws_connect_hours_of_operation" "this" {
  for_each = var.hours_of_operation

  instance_id = local.instance_id
  name        = "${local.name_prefix}-${each.key}"
  description = each.value.description
  time_zone   = each.value.time_zone

  dynamic "config" {
    for_each = each.value.config
    content {
      day = config.value.day

      start_time {
        hours   = config.value.start_time.hours
        minutes = config.value.start_time.minutes
      }

      end_time {
        hours   = config.value.end_time.hours
        minutes = config.value.end_time.minutes
      }
    }
  }

  tags = merge(local.common_tags, { hoo_key = each.key })
}
