resource "aws_connect_queue" "this" {
  for_each = var.queues

  instance_id           = local.instance_id
  name                  = "${local.name_prefix}-${each.key}"
  description           = each.value.description
  status                = each.value.status
  max_contacts          = each.value.max_contacts
  hours_of_operation_id = each.value.hours_of_operation_id

  quick_connect_ids = length(each.value.quick_connect_ids) > 0 ? each.value.quick_connect_ids : null

  outbound_caller_config {
    outbound_caller_id_name      = try(each.value.outbound_caller_config.outbound_caller_id_name, null)
    outbound_caller_id_number_id = try(each.value.outbound_caller_config.outbound_caller_id_number_id, null)
    outbound_flow_id             = try(each.value.outbound_caller_config.outbound_flow_id, null)
  }

  tags = merge(local.common_tags, { queue_key = each.key })
}
