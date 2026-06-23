output "hours_of_operation_ids" {
  description = "Map of hours-of-operation key → Connect hours_of_operation_id. Pass these to the connect-queue module."
  value       = { for k, v in aws_connect_hours_of_operation.this : k => v.hours_of_operation_id }
}

output "hours_of_operation_arns" {
  description = "Map of hours-of-operation key → ARN."
  value       = { for k, v in aws_connect_hours_of_operation.this : k => v.arn }
}

output "hours_of_operation_names" {
  description = "Map of hours-of-operation key → resource name as created in Connect."
  value       = { for k, v in aws_connect_hours_of_operation.this : k => v.name }
}

output "instance_id" {
  description = "The Connect instance ID used by this module."
  value       = local.instance_id
}
