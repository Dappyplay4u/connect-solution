output "hours_of_operation_ids" {
  description = "Map of hours-of-operation key → Connect ID. Pass these to other queue deployments if needed."
  value       = module.hours.hours_of_operation_ids
}

output "hours_of_operation_names" {
  description = "Map of hours-of-operation key → name as created in Connect."
  value       = module.hours.hours_of_operation_names
}

output "queue_ids" {
  description = "Map of queue key → Connect queue ID. Pass these to the routing-profile module."
  value       = module.queues.queue_ids
}

output "queue_arns" {
  description = "Map of queue key → Connect queue ARN."
  value       = module.queues.queue_arns
}

output "queue_names" {
  description = "Map of queue key → Connect queue name."
  value       = module.queues.queue_names
}

output "instance_id" {
  description = "The Connect instance ID used by this deployment."
  value       = module.queues.instance_id
}
