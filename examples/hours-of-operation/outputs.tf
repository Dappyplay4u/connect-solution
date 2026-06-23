output "hours_of_operation_ids" {
  description = "Map of hours-of-operation key → Connect ID. Pass these to the connect-queue module."
  value       = module.hours_of_operation.hours_of_operation_ids
}

output "hours_of_operation_arns" {
  description = "Map of hours-of-operation key → ARN."
  value       = module.hours_of_operation.hours_of_operation_arns
}

output "hours_of_operation_names" {
  description = "Map of hours-of-operation key → name as created in Connect."
  value       = module.hours_of_operation.hours_of_operation_names
}

output "instance_id" {
  description = "The Connect instance ID used by this deployment."
  value       = module.hours_of_operation.instance_id
}
