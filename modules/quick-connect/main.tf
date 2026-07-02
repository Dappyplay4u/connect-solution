resource "aws_connect_quick_connect" "this" {
  for_each = var.quick_connects

  instance_id = local.instance_id
  name        = "${local.name_prefix}-${each.key}"
  description = each.value.description

  quick_connect_config {
    quick_connect_type = each.value.type

    dynamic "phone_config" {
      for_each = each.value.type == "PHONE_NUMBER" ? [1] : []
      content {
        phone_number = each.value.phone_number
      }
    }

    dynamic "queue_config" {
      for_each = each.value.type == "QUEUE" ? [1] : []
      content {
        contact_flow_id = each.value.contact_flow_id
        queue_id        = each.value.queue_id
      }
    }

    dynamic "agent_config" {
      for_each = each.value.type == "AGENT" ? [1] : []
      content {
        contact_flow_id = each.value.contact_flow_id
        user_id         = each.value.user_id
      }
    }
  }

  tags = merge(local.common_tags, { qc_key = each.key })
}
