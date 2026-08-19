###############################################################################
# TFC Business Unit — Outputs
###############################################################################

output "instance_id" {
  value = module.connect.instance_id
}

output "instance_alias" {
  value = module.connect.instance_alias
}

output "name_prefix" {
  value = module.connect.name_prefix
}

output "s3_bucket_ids" {
  value = module.connect.s3_bucket_ids
}

output "kinesis_stream_arns" {
  value = module.connect.kinesis_stream_arns
}

output "contact_flow_log_group_name" {
  value = module.connect.contact_flow_log_group_name
}
