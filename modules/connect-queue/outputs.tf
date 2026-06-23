output "queue_ids" {
  description = "Map of queue key → Connect queue ID. Pass these to the routing-profile module."
  value       = { for k, v in aws_connect_queue.this : k => v.queue_id }
}

output "queue_arns" {
  description = "Map of queue key → Connect queue ARN."
  value       = { for k, v in aws_connect_queue.this : k => v.arn }
}

output "queue_names" {
  description = "Map of queue key → Connect queue name as created in Connect."
  value       = { for k, v in aws_connect_queue.this : k => v.name }
}

output "instance_id" {
  description = "The Connect instance ID used by this module."
  value       = local.instance_id
}
