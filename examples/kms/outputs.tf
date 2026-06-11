###############################################################################
# KMS Complete Example — Outputs
###############################################################################

output "key_arns" {
  description = "Map of key purpose → KMS Key ARN"
  value       = module.kms.key_arns
  sensitive   = true
}

output "alias_names" {
  description = "Map of key purpose → KMS Alias Name (e.g. alias/tfc-retail-connect-tccivr-s3)"
  value       = module.kms.alias_names
}

output "name_prefix" {
  description = "Base name prefix used by the module (e.g. tfc-retail-connect-tccivr)"
  value       = module.kms.name_prefix
}
