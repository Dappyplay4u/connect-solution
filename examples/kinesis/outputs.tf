###############################################################################
# Kinesis Complete Example — Outputs
###############################################################################

output "ctr_stream_arn" {
  description = "Kinesis CTR stream ARN"
  value       = module.kinesis.ctr_stream_arn
}

output "ctr_stream_name" {
  description = "Kinesis CTR stream name (e.g. tfc-retail-connect-tccivr-agent-events-datastream-ue1)"
  value       = module.kinesis.ctr_stream_name
}

output "media_stream_arn" {
  description = "Kinesis media stream ARN"
  value       = module.kinesis.media_stream_arn
}

output "media_stream_name" {
  description = "Kinesis media stream name (e.g. tfc-retail-connect-tccivr-media-streams-datastream-ue1)"
  value       = module.kinesis.media_stream_name
}

output "firehose_arn" {
  description = "Kinesis Firehose delivery stream ARN"
  value       = module.kinesis.firehose_arn
}

output "name_prefix" {
  description = "Base name prefix used by the module (e.g. tfc-retail-connect-tccivr)"
  value       = module.kinesis.name_prefix
}
