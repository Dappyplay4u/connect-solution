# ---------------------------------------------------------------------------
# DynamoDB Tables — one per entry in var.tables
# ---------------------------------------------------------------------------

resource "aws_dynamodb_table" "this" {
  for_each = var.tables

  name           = "${local.prefix}-connect-${each.key}-${local.aws_region_abbr}"
  billing_mode   = each.value.billing_mode
  hash_key       = each.value.hash_key
  range_key      = each.value.range_key
  read_capacity  = each.value.billing_mode == "PROVISIONED" ? each.value.read_capacity : null
  write_capacity = each.value.billing_mode == "PROVISIONED" ? each.value.write_capacity : null

  dynamic "attribute" {
    for_each = local.table_attributes[each.key]
    content {
      name = attribute.key
      type = attribute.value
    }
  }

  dynamic "global_secondary_index" {
    for_each = each.value.global_secondary_indexes
    content {
      name               = global_secondary_index.value.name
      hash_key           = global_secondary_index.value.hash_key
      range_key          = global_secondary_index.value.range_key
      projection_type    = global_secondary_index.value.projection_type
      non_key_attributes = global_secondary_index.value.projection_type == "INCLUDE" ? global_secondary_index.value.non_key_attributes : null
      read_capacity      = each.value.billing_mode == "PROVISIONED" ? global_secondary_index.value.read_capacity : null
      write_capacity     = each.value.billing_mode == "PROVISIONED" ? global_secondary_index.value.write_capacity : null
    }
  }

  dynamic "ttl" {
    for_each = each.value.ttl_attribute_name != null ? [each.value.ttl_attribute_name] : []
    content {
      attribute_name = ttl.value
      enabled        = true
    }
  }

  point_in_time_recovery {
    enabled = each.value.point_in_time_recovery_enabled
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = var.kms_master_key_id
  }

  tags = merge(local.common_tags, { table_key = each.key })
}

# ---------------------------------------------------------------------------
# S3 Bucket — single shared bucket for all tables
# ---------------------------------------------------------------------------

resource "aws_s3_bucket" "csv" {
  bucket = local.csv_bucket_name
  tags   = local.common_tags
}

resource "aws_s3_bucket_versioning" "csv" {
  bucket = aws_s3_bucket.csv.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "csv" {
  bucket = aws_s3_bucket.csv.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = local.use_kms ? "aws:kms" : "AES256"
      kms_master_key_id = local.use_kms ? var.kms_master_key_id : null
    }
    bucket_key_enabled = local.use_kms
  }
}

resource "aws_s3_bucket_public_access_block" "csv" {
  bucket                  = aws_s3_bucket.csv.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "csv" {
  bucket = aws_s3_bucket.csv.id

  rule {
    id     = "expire-csv-uploads"
    status = "Enabled"

    filter { prefix = "" }

    expiration {
      days = var.csv_retention_days
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

resource "aws_s3_bucket_policy" "csv" {
  bucket = aws_s3_bucket.csv.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "DenyInsecureTransport"
      Effect    = "Deny"
      Principal = "*"
      Action    = "s3:*"
      Resource = [
        aws_s3_bucket.csv.arn,
        "${aws_s3_bucket.csv.arn}/*",
      ]
      Condition = {
        Bool = { "aws:SecureTransport" = "false" }
      }
    }]
  })

  depends_on = [aws_s3_bucket_public_access_block.csv]
}

# ---------------------------------------------------------------------------
# IAM Role for CSV Loader Lambda
# ---------------------------------------------------------------------------

resource "aws_iam_role" "csv_loader" {
  name = local.iam_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy" "csv_loader" {
  name = local.iam_policy_name
  role = aws_iam_role.csv_loader.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ReadCsvFromS3"
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = "${aws_s3_bucket.csv.arn}/*"
      },
      {
        Sid    = "WriteItemsToAllTables"
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:BatchWriteItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
        ]
        Resource = [for k, v in aws_dynamodb_table.this : v.arn]
      },
      {
        Sid    = "WriteLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ]
        Resource = "${aws_cloudwatch_log_group.csv_loader.arn}:*"
      },
    ]
  })
}

resource "aws_iam_role_policy" "csv_loader_kms" {
  count = local.use_kms ? 1 : 0

  name = "${local.iam_policy_name}-kms"
  role = aws_iam_role.csv_loader.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid      = "DecryptWithKms"
      Effect   = "Allow"
      Action   = ["kms:GenerateDataKey", "kms:Decrypt"]
      Resource = var.kms_master_key_id
    }]
  })
}

# ---------------------------------------------------------------------------
# CloudWatch Log Group
# ---------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "csv_loader" {
  name              = local.log_group_name
  retention_in_days = var.lambda_log_retention_days
  kms_key_id        = var.kms_master_key_id

  tags = local.common_tags
}

# ---------------------------------------------------------------------------
# Lambda Function — shared CSV loader for all tables
# ---------------------------------------------------------------------------

resource "aws_lambda_function" "csv_loader" {
  function_name    = local.lambda_name
  filename         = data.archive_file.csv_loader.output_path
  source_code_hash = data.archive_file.csv_loader.output_base64sha256
  handler          = "csv_loader.handler"
  runtime          = "python3.12"
  role             = aws_iam_role.csv_loader.arn
  timeout          = var.lambda_timeout_seconds
  memory_size      = var.lambda_memory_mb

  environment {
    variables = {
      # Lambda extracts the S3 folder name from the object key and looks up
      # the matching table config in this JSON map.
      TABLE_ROUTING = local.table_routing
    }
  }

  depends_on = [aws_cloudwatch_log_group.csv_loader]

  tags = local.common_tags
}

# ---------------------------------------------------------------------------
# S3 → Lambda trigger
# ---------------------------------------------------------------------------

resource "aws_lambda_permission" "s3_invoke" {
  statement_id   = "AllowS3Invoke"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.csv_loader.function_name
  principal      = "s3.amazonaws.com"
  source_arn     = aws_s3_bucket.csv.arn
  source_account = local.account_id
}

resource "aws_s3_bucket_notification" "csv" {
  bucket = aws_s3_bucket.csv.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.csv_loader.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".csv"
  }

  depends_on = [aws_lambda_permission.s3_invoke]
}

# ---------------------------------------------------------------------------
# GitLab OIDC — automated CSV upload (optional)
# ---------------------------------------------------------------------------

# One OIDC provider per GitLab URL per AWS account. Set
# var.gitlab_oidc_provider_arn if one already exists in this account.
resource "aws_iam_openid_connect_provider" "gitlab" {
  count = local.create_oidc_provider ? 1 : 0

  url             = var.gitlab_ci_upload.gitlab_url
  client_id_list  = [var.gitlab_ci_upload.gitlab_url]
  # Thumbprint of the GitLab TLS certificate root CA.
  # Retrieve the current value with:
  #   openssl s_client -servername gitlab.com -connect gitlab.com:443 2>/dev/null \
  #     | openssl x509 -fingerprint -sha1 -noout | sed 's/.*=//' | tr -d ':'
  thumbprint_list = ["b3dd7606d2b5a8b4a13771dbecc9ee1cecafa38a"]

  tags = local.common_tags
}

resource "aws_iam_role" "gitlab_csv_upload" {
  count = local.enable_gitlab_upload ? 1 : 0

  name = local.gitlab_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = local.oidc_provider_arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringLike = {
          # Allows any pipeline job on the specified branch of the specified project
          "${local.gitlab_oidc_host}:sub" = "project_path:${var.gitlab_ci_upload.project_path}:ref_type:branch:ref:${var.gitlab_ci_upload.branch}"
        }
        StringEquals = {
          "${local.gitlab_oidc_host}:aud" = var.gitlab_ci_upload.gitlab_url
        }
      }
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy" "gitlab_csv_upload" {
  count = local.enable_gitlab_upload ? 1 : 0

  name = local.gitlab_policy_name
  role = aws_iam_role.gitlab_csv_upload[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "UploadCsvToS3"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
        ]
        Resource = [
          aws_s3_bucket.csv.arn,
          "${aws_s3_bucket.csv.arn}/*",
        ]
      }
    ]
  })
}
