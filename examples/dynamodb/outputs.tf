output "table_names" {
  description = "Map of table key → DynamoDB table name."
  value       = module.connect_tables.table_names
}

output "table_arns" {
  description = "Map of table key → DynamoDB table ARN."
  value       = module.connect_tables.table_arns
}

output "csv_bucket_name" {
  description = "Shared S3 bucket. Upload CSVs into a sub-folder matching the table key (e.g. phone-routing/data.csv)."
  value       = module.connect_tables.csv_bucket_name
}

output "csv_loader_function_name" {
  description = "Shared CSV loader Lambda function name."
  value       = module.connect_tables.csv_loader_function_name
}

output "csv_loader_log_group_name" {
  description = "CloudWatch log group for monitoring all CSV load jobs."
  value       = module.connect_tables.csv_loader_log_group_name
}

output "gitlab_upload_role_arn" {
  description = "Set this as AWS_ROLE_ARN in your GitLab CI/CD variables."
  value       = module.connect_tables.gitlab_upload_role_arn
}
