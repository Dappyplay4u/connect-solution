###############################################################################
# Kinesis Module — Complete Example
#
# Run from this directory:
#   cp example.tfvars terraform.tfvars
#   terraform init
#   terraform plan
#   terraform apply
#
# Resulting stream names:
#   tfc-retail-connect-tccivr-agent-events-datastream-ue1
#   tfc-retail-connect-tccivr-media-streams-datastream-ue1
# Resulting firehose:
#   tfc-retail-connect-tccivr-agent-events-deliverystreams-ue1
###############################################################################

module "kinesis" {
  source = "../../modules/kinesis"

  aws_region      = var.aws_region
  project_name    = var.project_name
  account         = var.account
  lob             = var.lob
  sdlc_env        = var.sdlc_env
  aws_region_abbr = var.aws_region_abbr

  kms_key_id  = var.kms_key_id
  kms_key_arn = var.kms_key_arn

  stream_mode            = "ON_DEMAND"
  retention_period_hours = 24

  enable_firehose_ctr                 = true
  ctr_s3_bucket_arn                   = var.ctr_s3_bucket_arn
  firehose_buffering_size_mb          = 5
  firehose_buffering_interval_seconds = 300

  enable_cloudwatch_alarms        = true
  iterator_age_alarm_threshold_ms = 60000
  alarm_sns_topic_arns            = var.alarm_sns_topic_arns

  tags = local.required_tags
}
