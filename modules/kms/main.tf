###############################################################################
# KMS Module — Main
# Creates one KMS key + alias per logical purpose (s3, kinesis, connect).
# Each key gets its own least-privilege policy with key rotation always on.
#
# alias pattern: alias/tfc-retail-connect-tccivr-<purpose>
###############################################################################

data "aws_iam_policy_document" "this" {
  for_each = local.resolved_keys

  statement {
    sid    = "EnableRootFullAccess"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:${local.partition}:iam::${local.account_id}:root"]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }

  dynamic "statement" {
    for_each = length(var.key_admin_arns) > 0 ? [1] : []

    content {
      sid    = "AllowKeyAdministration"
      effect = "Allow"

      principals {
        type        = "AWS"
        identifiers = var.key_admin_arns
      }

      actions = [
        "kms:Create*",
        "kms:Describe*",
        "kms:Enable*",
        "kms:List*",
        "kms:Put*",
        "kms:Update*",
        "kms:Revoke*",
        "kms:Disable*",
        "kms:Get*",
        "kms:Delete*",
        "kms:TagResource",
        "kms:UntagResource",
        "kms:ScheduleKeyDeletion",
        "kms:CancelKeyDeletion",
      ]
      resources = ["*"]
    }
  }

  dynamic "statement" {
    for_each = length(each.value.service_principals) > 0 ? [1] : []

    content {
      sid    = "AllowServiceUsage"
      effect = "Allow"

      principals {
        type        = "Service"
        identifiers = each.value.service_principals
      }

      actions = [
        "kms:Decrypt",
        "kms:Encrypt",
        "kms:GenerateDataKey*",
        "kms:ReEncrypt*",
        "kms:DescribeKey",
        "kms:CreateGrant",
        "kms:ListGrants",
        "kms:RevokeGrant",
      ]
      resources = ["*"]

      condition {
        test     = "StringEquals"
        variable = "aws:SourceAccount"
        values   = [local.account_id]
      }
    }
  }
}

resource "aws_kms_key" "this" {
  for_each = local.resolved_keys

  description             = "${local.name_prefix}-${each.key} key for Amazon Connect"
  deletion_window_in_days = each.value.deletion_window
  enable_key_rotation     = true
  multi_region            = false

  policy = each.value.policy != null ? each.value.policy : data.aws_iam_policy_document.this[each.key].json

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-${each.key}-key"
  })
}

resource "aws_kms_alias" "this" {
  for_each = local.resolved_keys

  name          = "alias/${local.name_prefix}-${each.key}"
  target_key_id = aws_kms_key.this[each.key].key_id
}
