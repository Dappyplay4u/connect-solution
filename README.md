# big-connect

Terraform modules for deploying Amazon Connect and its supporting infrastructure (KMS, S3, Kinesis) on AWS. All modules follow a consistent naming convention and are versioned together in this repository.

---

## Repository structure

```
big-connect/
├── modules/
│   ├── connect-instance/   # Self-contained Connect instance (calls kms, s3, kinesis internally)
│   ├── kinesis/            # Kinesis Data Streams + Firehose CTR → S3
│   ├── kms/                # KMS keys and aliases (s3, kinesis, connect)
│   └── s3/                 # S3 buckets for recordings, reports, transcripts
├── examples/
│   ├── connect-instance/   # End-to-end example (creates all resources)
│   ├── kinesis/            # Standalone kinesis example
│   ├── kms/                # Standalone kms example
│   └── s3/                 # Standalone s3 example
├── CHANGELOG.md
├── VERSION
└── .gitignore
```

---

## Naming convention

All resource names are derived from six input variables:

| Variable | Description | Example |
|---|---|---|
| `project_spec` | Instance alias prefix | `retail` |
| `project_name` | Short name / resource prefix | `tfc` |
| `account` | Account identifier | `retail` / `sales` |
| `lob` | Line of business | `tccivr` |
| `sdlc_env` | Environment | `prod` / `qa` / `test` |
| `aws_region_abbr` | Short region code | `ue1` / `ue2` / `uw1` |

### Resolved name examples

| Resource | Pattern | Resolves to |
|---|---|---|
| Connect instance alias | `{project_spec}-{sdlc_env}-{aws_region_abbr}` | `retail-prod-ue1` |
| S3 bucket | `{project_name}-{account}-connect-{lob}-{sdlc_env}-{suffix}-{aws_region_abbr}` | `tfc-retail-connect-tccivr-prod-recordings-ue1` |
| Kinesis stream | `{project_name}-{account}-connect-{lob}-{stream_name}-datastream-{aws_region_abbr}` | `tfc-retail-connect-tccivr-agent-events-datastream-ue1` |
| Firehose | `{project_name}-{account}-connect-{lob}-agent-events-deliverystreams-{aws_region_abbr}` | `tfc-retail-connect-tccivr-agent-events-deliverystreams-ue1` |
| KMS alias | `alias/{project_name}-{account}-connect-{lob}-{purpose}` | `alias/tfc-retail-connect-tccivr-s3` |

---

## Usage

Reference a pinned version from GitLab in your Terraform source:

```hcl
module "connect" {
  source = "git::https://gitlab.com/<group>/big-connect.git//modules/connect-instance?ref=v1.0.0"

  project_spec    = "retail"
  project_name    = "tfc"
  account         = "retail"
  lob             = "tccivr"
  sdlc_env        = "prod"
  aws_region_abbr = "ue1"

  key_admin_arns       = ["arn:aws:iam::<account_id>:role/TerraformDeployRole"]
  alarm_sns_topic_arns = ["arn:aws:sns:us-east-1:<account_id>:connect-alerts-prod"]

  tags = {
    business_application_id   = "APP-001"
    cost_center               = "CC-1234"
    created_by                = "platform-team"
    technical_support_by      = "cloud-ops"
    application_group         = "contact-center"
    technical_environment     = "production"
    security_data_application = "confidential"
    business_application_code = "RETAIL-CC"
  }
}
```

To use individual modules standalone:

```hcl
module "kinesis" {
  source = "git::https://gitlab.com/<group>/big-connect.git//modules/kinesis?ref=v1.0.0"
  ...
}

module "kms" {
  source = "git::https://gitlab.com/<group>/big-connect.git//modules/kms?ref=v1.0.0"
  ...
}

module "s3" {
  source = "git::https://gitlab.com/<group>/big-connect.git//modules/s3?ref=v1.0.0"
  ...
}
```

---

## Running the examples

```bash
cd examples/connect-instance      # or kinesis / kms / s3
cp example.tfvars terraform.tfvars
# edit terraform.tfvars with your values
terraform init
terraform plan
terraform apply
```

---

## Requirements

| Tool | Version |
|---|---|
| Terraform | `>= 1.5.0` |
| AWS Provider | `>= 5.0.0` |

---

## Required tags

All modules enforce 8 mandatory tags via input validation:

```
business_application_id
cost_center
created_by
technical_support_by
application_group
technical_environment
security_data_application
business_application_code
```

---

## Versioning

This repository uses [Semantic Versioning](https://semver.org). The current version is in [`VERSION`](VERSION).

| Change type | Version bump |
|---|---|
| New optional variable, new output | `MINOR` — `v1.0.0 → v1.1.0` |
| Bug fix, no interface change | `PATCH` — `v1.0.0 → v1.0.1` |
| Rename / remove variable, restructure | `MAJOR` — `v1.0.0 → v2.0.0` |

See [`CHANGELOG.md`](CHANGELOG.md) for the full history.
