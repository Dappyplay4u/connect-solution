output "quick_connect_ids" {
  description = "Map of quick connect key → Connect quick_connect_id. Pass these to the routing profile module."
  value       = module.quick_connect.quick_connect_ids
}

output "quick_connect_arns" {
  description = "Map of quick connect key → ARN."
  value       = module.quick_connect.quick_connect_arns
}

output "quick_connect_names" {
  description = "Map of quick connect key → name as created in Connect."
  value       = module.quick_connect.quick_connect_names
}

output "instance_id" {
  description = "The Connect instance ID used by this deployment."
  value       = module.quick_connect.instance_id
}
