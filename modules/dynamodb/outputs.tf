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

output "table_ids" {
  description = "Map of table key → DynamoDB table ID."
  value       = { for k, v in aws_dynamodb_table.this : k => v.id }
}

# ---------------------------------------------------------------------------
# Shared S3 CSV bucket
# ---------------------------------------------------------------------------

output "csv_bucket_name" {
  description = "Name of the shared S3 bucket. Upload CSVs into a sub-folder matching the table key (e.g. agent-configuration/data.csv)."
  value       = aws_s3_bucket.csv.bucket
}

output "csv_bucket_arn" {
  description = "ARN of the shared S3 CSV bucket."
  value       = aws_s3_bucket.csv.arn
}

# ---------------------------------------------------------------------------
# Shared Lambda loader
# ---------------------------------------------------------------------------

output "csv_loader_function_name" {
  description = "Name of the shared CSV loader Lambda function."
  value       = aws_lambda_function.csv_loader.function_name
}

output "csv_loader_function_arn" {
  description = "ARN of the shared CSV loader Lambda function."
  value       = aws_lambda_function.csv_loader.arn
}

output "csv_loader_log_group_name" {
  description = "CloudWatch log group name for the CSV loader Lambda."
  value       = aws_cloudwatch_log_group.csv_loader.name
}

# ---------------------------------------------------------------------------
# GitLab OIDC upload role
# ---------------------------------------------------------------------------

output "gitlab_upload_role_arn" {
  description = "ARN of the IAM role GitLab CI/CD assumes to upload CSVs. Set AWS_ROLE_ARN to this value in your GitLab CI/CD variables."
  value       = local.enable_gitlab_upload ? aws_iam_role.gitlab_csv_upload[0].arn : null
}
