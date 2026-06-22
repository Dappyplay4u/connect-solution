# ---------------------------------------------------------------------------
# DynamoDB Tables
# ---------------------------------------------------------------------------

output "table_names" {
  description = "Map of table key → DynamoDB table name."
  value       = { for k, v in aws_dynamodb_table.this : k => v.name }
}

output "table_arns" {
  description = "Map of table key → DynamoDB table ARN."
  value       = { for k, v in aws_dynamodb_table.this : k => v.arn }
}

# ---------------------------------------------------------------------------
# S3 CSV bucket
# ---------------------------------------------------------------------------

output "csv_bucket_name" {
  description = "Name of the S3 bucket. Upload CSVs into a sub-folder matching the table key, e.g. agent-configuration/agents.csv"
  value       = aws_s3_bucket.csv.bucket
}

output "csv_bucket_arn" {
  description = "ARN of the S3 CSV bucket."
  value       = aws_s3_bucket.csv.arn
}

output "csv_bucket_folders" {
  description = "Pre-created S3 folder paths. Upload CSVs into these folders to trigger the loader."
  value       = { for k in keys(var.tables) : k => "${aws_s3_bucket.csv.bucket}/${k}/" }
}

# ---------------------------------------------------------------------------
# Lambda loader
# ---------------------------------------------------------------------------

output "csv_loader_function_name" {
  description = "Name of the CSV loader Lambda function."
  value       = aws_lambda_function.csv_loader.function_name
}

output "csv_loader_function_arn" {
  description = "ARN of the CSV loader Lambda function."
  value       = aws_lambda_function.csv_loader.arn
}

output "csv_loader_log_group_name" {
  description = "CloudWatch log group for monitoring Lambda executions."
  value       = aws_cloudwatch_log_group.csv_loader.name
}
