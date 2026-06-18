data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}

data "archive_file" "csv_loader" {
  type        = "zip"
  source_file = "${path.module}/lambda/csv_loader.py"
  output_path = "${path.module}/lambda/csv_loader.zip"
}
