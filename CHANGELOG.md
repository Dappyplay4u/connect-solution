# Changelog

All notable changes to this project will be documented in this file.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
Versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

---

## [v1.0.0] — 2026-06-16

### Added

#### Repository structure
- `modules/connect-instance/` — self-contained Amazon Connect instance module (creates KMS, S3, Kinesis as child modules)
- `modules/kinesis/` — Kinesis Data Streams + optional Firehose CTR → S3 delivery
- `modules/kms/` — KMS keys and aliases for S3, Kinesis, and Connect
- `modules/s3/` — S3 buckets for call recordings, scheduled reports, and chat transcripts
- `examples/connect-instance/` — complete working example for the connect-instance module
- `examples/kinesis/` — standalone example for the kinesis module
- `examples/kms/` — standalone example for the kms module
- `examples/s3/` — standalone example for the s3 module

#### Naming convention
- `instance_alias` pattern: `${var.project_spec}-${var.sdlc_env}-${var.aws_region_abbr}`
  - resolves to: `retail-prod-ue1`
- S3 bucket pattern: `${local.prefix}-${local.account}-connect-${local.lob}-${local.sdlc_env}-${suffix}-${local.aws_region_abbr}`
  - resolves to: `tfc-retail-connect-tccivr-prod-recordings-ue1`
- Kinesis stream pattern: `${local.prefix}-${each.value.account}-connect-${local.lob}-${each.value.stream_name}-datastream-${local.aws_region_abbr}`
  - resolves to: `tfc-retail-connect-tccivr-agent-events-datastream-ue1`
- Kinesis Firehose pattern: `${local.prefix}-${local.account}-connect-${local.lob}-agent-events-deliverystreams-${local.aws_region_abbr}`
  - resolves to: `tfc-retail-connect-tccivr-agent-events-deliverystreams-ue1`
- KMS alias pattern: `alias/${local.prefix}-${local.account}-connect-${local.lob}-${purpose}`
  - resolves to: `alias/tfc-retail-connect-tccivr-s3`

#### Variables introduced
| Variable | Description | Example |
|---|---|---|
| `project_spec` | Short specifier used only in instance alias | `retail` |
| `project_name` | Short prefix used in all resource names | `tfc` |
| `account` | Account identifier segment | `retail` / `sales` |
| `lob` | Line of business identifier | `tccivr` |
| `sdlc_env` | Deployment environment | `prod` / `qa` / `test` |
| `aws_region_abbr` | Short region abbreviation | `ue1` / `ue2` / `uw1` |

#### Infrastructure features
- KMS key rotation enabled on all keys
- S3 buckets: versioning, KMS SSE, TLS-enforced bucket policy, public access blocked
- S3 lifecycle: STANDARD_IA at 90 days, GLACIER at 365 days, expiry at 2555 days (~7 years)
- Kinesis streams: `contact_trace_records` (`agent-events`) and `media_streams`
- Firehose: Hive-compatible partitioning (`year=/month=/day=/hour=`) for Athena/Glue
- CloudWatch iterator-age alarms on all Kinesis streams
- 8-tag validation enforced on all modules
- All child module sources use relative paths (`../kms`, `../s3`, `../kinesis`)

---

## Module Compatibility Matrix

| Module | Terraform | AWS Provider |
|---|---|---|
| `connect-instance` | `>= 1.5.0` | `>= 5.0.0` |
| `kinesis` | `>= 1.5.0` | `>= 5.0.0` |
| `kms` | `>= 1.5.0` | `>= 5.0.0` |
| `s3` | `>= 1.5.0` | `>= 5.0.0` |

---

## GitLab Usage

Reference a specific version in your Terraform source:

```hcl
module "kinesis" {
  source = "git::https://gitlab.com/<group>/big-connect.git//modules/kinesis?ref=v1.0.0"

  project_name    = "tfc"
  account         = "retail"
  lob             = "tccivr"
  sdlc_env        = "prod"
  aws_region_abbr = "ue1"
  ...
}
```
