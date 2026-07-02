output "quick_connect_ids" {
  description = "Map of quick connect key → Connect quick_connect_id. Pass these to a routing profile module."
  value       = { for k, v in aws_connect_quick_connect.this : k => v.quick_connect_id }
}

output "quick_connect_arns" {
  description = "Map of quick connect key → ARN."
  value       = { for k, v in aws_connect_quick_connect.this : k => v.arn }
}

output "quick_connect_names" {
  description = "Map of quick connect key → resource name as created in Connect."
  value       = { for k, v in aws_connect_quick_connect.this : k => v.name }
}

output "instance_id" {
  description = "The Connect instance ID used by this module."
  value       = local.instance_id
}
