output "table_names" {
  description = "All six table names — use these to verify tables were created."
  value       = module.connect_tables.table_names
}

output "csv_bucket_name" {
  description = "Upload CSVs here to load data. Folder name must match the table key."
  value       = module.connect_tables.csv_bucket_name
}

output "csv_loader_function_name" {
  description = "Lambda function name — check CloudWatch logs here after each upload."
  value       = module.connect_tables.csv_loader_function_name
}

output "csv_loader_log_group_name" {
  description = "CloudWatch log group — tail this after uploading a CSV to see the load result."
  value       = module.connect_tables.csv_loader_log_group_name
}
