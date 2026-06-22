# DynamoDB Module — Architecture & Operations Guide

## Overview

The `dynamodb` module is a **fully self-contained, standalone Terraform module** that provisions and automates the Amazon Connect configuration tables. It has no dependency on any other module in this repository — it needs only an AWS account, a region abbreviation, and a project name prefix.

The module creates six DynamoDB configuration tables used by Amazon Connect contact flows, a shared S3 bucket as the ingestion point, a Lambda function that processes uploaded CSV files, and an optional GitLab CI/CD IAM role so pipelines can push data without storing long-lived AWS credentials.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│  GitLab CI/CD Pipeline                                              │
│                                                                     │
│  data/agent-configuration/agents.csv  ──┐                          │
│  data/DNIS-mapping/dnis.csv           ──┤                          │
│  data/ivr-parameters-/params.csv      ──┤  git push → main branch  │
│  data/ivr-pilot-phone-numbers/...     ──┤                          │
│  data/office-hours-/hours.csv         ──┤                          │
│  data/prompts/prompts.csv             ──┘                          │
└────────────────────────┬────────────────────────────────────────────┘
                         │ OIDC token (no stored keys)
                         ▼
┌────────────────────────────────────┐
│  AWS STS                           │
│  AssumeRoleWithWebIdentity         │
│  → temporary credentials (1 hr)    │
└────────────────────────┬───────────┘
                         │
                         ▼
┌────────────────────────────────────┐
│  S3 Bucket                         │
│  ls-connect-uw2-ddb-csv            │
│                                    │
│  agent-configuration/agents.csv    │
│  DNIS-mapping/dnis.csv             │
│  ivr-parameters-/params.csv        │
│  ivr-pilot-phone-numbers/...       │
│  office-hours-/hours.csv           │
│  prompts/prompts.csv               │
└────────────────────────┬───────────┘
                         │ s3:ObjectCreated event
                         ▼
┌────────────────────────────────────┐
│  Lambda Function                   │
│  ls-connect-uw2-ddb-csv-loader     │
│                                    │
│  1. Extracts folder name from key  │
│  2. Looks up table config in       │
│     TABLE_ROUTING env var          │
│  3. Parses CSV, validates rows     │
│  4. Scans existing DynamoDB keys   │
│  5. Batch-writes all valid rows    │
│  6. Deletes orphans (sync_mode)    │
└────────────────────────┬───────────┘
                         │
          ┌──────────────┼──────────────────────────┐
          ▼              ▼              ▼            ▼
  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐  ...
  │  agent-      │ │  DNIS-       │ │  ivr-        │
  │  configuration│ │  mapping     │ │  parameters- │
  └──────────────┘ └──────────────┘ └──────────────┘
```

---

## AWS Resources Created

| Resource | Name | Purpose |
|---|---|---|
| `aws_dynamodb_table` × 6 | `ls-connect-<key>-uw2` | Configuration tables for Connect contact flows |
| `aws_s3_bucket` | `ls-connect-uw2-ddb-csv` | CSV ingestion bucket (versioned, TLS-only) |
| `aws_lambda_function` | `ls-connect-uw2-ddb-csv-loader` | Processes CSV uploads into DynamoDB |
| `aws_iam_role` | `ls-connect-uw2-ddb-csv-role` | Lambda execution role |
| `aws_cloudwatch_log_group` | `/aws/lambda/ls-connect-uw2-ddb-csv-loader` | Lambda execution logs |
| `aws_s3_bucket_notification` | — | Triggers Lambda on `.csv` object creation |
| `aws_iam_openid_connect_provider` | — | GitLab OIDC provider (created once per account) |
| `aws_iam_role` | `ls-connect-uw2-ddb-gitlab-upload-role` | Role GitLab CI/CD assumes via OIDC |

> Names above reflect the example values `project_name = "ls"` and `aws_region_abbr = "uw2"`.

---

## Naming Convention

All resource names follow the pattern:

```
<project_name>-connect-<suffix>-<aws_region_abbr>
```

### DynamoDB Tables

| Table key | Resulting table name |
|---|---|
| `agent-configuration` | `ls-connect-agent-configuration-uw2` |
| `DNIS-mapping` | `ls-connect-DNIS-mapping-uw2` |
| `ivr-parameters-` | `ls-connect-ivr-parameters--uw2` |
| `ivr-pilot-phone-numbers` | `ls-connect-ivr-pilot-phone-numbers-uw2` |
| `office-hours-` | `ls-connect-office-hours--uw2` |
| `prompts` | `ls-connect-prompts-uw2` |

> The trailing dash in `ivr-parameters-` and `office-hours-` is intentional — it produces the double-dash (`--`) visible in those table names.

### Shared Resources

```
ls-connect-uw2-ddb-csv            ← S3 bucket
ls-connect-uw2-ddb-csv-loader     ← Lambda function
ls-connect-uw2-ddb-csv-role       ← Lambda IAM role
ls-connect-uw2-ddb-gitlab-upload-role  ← GitLab OIDC role
```

---

## The Six Configuration Tables

### 1. `ls-connect-agent-configuration-uw2`

Stores per-agent configuration referenced by contact flows at runtime.

| Attribute | Type | Role |
|---|---|---|
| `AgentId` | String | Hash key (primary key) |

---

### 2. `ls-connect-DNIS-mapping-uw2`

Maps inbound DNIS (Dialed Number Identification Service) phone numbers to contact flow behaviour.

| Attribute | Type | Role |
|---|---|---|
| `DNIS` | String | Hash key (primary key) |

---

### 3. `ls-connect-ivr-parameters--uw2`

Holds global IVR parameters (feature flags, queue names, thresholds) read by contact flows.

| Attribute | Type | Role |
|---|---|---|
| `ParameterKey` | String | Hash key (primary key) |

---

### 4. `ls-connect-ivr-pilot-phone-numbers-uw2`

Stores phone numbers enrolled in pilot or beta contact flows.

| Attribute | Type | Role |
|---|---|---|
| `PhoneNumber` | String | Hash key (primary key) |

---

### 5. `ls-connect-office-hours--uw2`

Defines operating hours per office or queue, used by contact flows to route calls.

| Attribute | Type | Role |
|---|---|---|
| `OfficeId` | String | Hash key (primary key) |

---

### 6. `ls-connect-prompts-uw2`

Catalogue of audio prompts referenced by name from contact flows.

| Attribute | Type | Role |
|---|---|---|
| `PromptId` | String | Hash key (primary key) |

---

## Standalone Usage

This module has no dependency on the KMS, S3, Kinesis, or Connect-Instance modules. You can deploy it independently against any Amazon Connect instance or in any account.

### Minimum required inputs

```hcl
module "connect_tables" {
  source = "git::https://gitlab.com/mygroup/big-connect.git//modules/dynamodb?ref=v1.0.0"

  project_name    = "ls"
  aws_region_abbr = "uw2"

  tables = {
    "agent-configuration" = { hash_key = "AgentId" }
    # ... add remaining tables
  }

  tags = { ... }
}
```

### With KMS encryption

Pass any KMS key ARN — it does not need to come from the `kms` module:

```hcl
module "connect_tables" {
  source = "..."

  project_name      = "ls"
  aws_region_abbr   = "uw2"
  kms_master_key_id = "arn:aws:kms:us-west-2:123456789012:key/mrk-abc123"

  tables = { ... }
  tags   = { ... }
}
```

---

## Deploying the Example

```bash
cd examples/dynamodb

cp example.tfvars terraform.tfvars
# Edit terraform.tfvars — set project_name, gitlab_project_path, and tags

terraform init
terraform plan
terraform apply
```

After apply, note these outputs — you will need them for GitLab:

```
table_names            = { agent-configuration = "ls-connect-agent-configuration-uw2", ... }
csv_bucket_name        = "ls-connect-uw2-ddb-csv"
gitlab_upload_role_arn = "arn:aws:iam::123456789012:role/ls-connect-uw2-ddb-gitlab-upload-role"
```

---

## CSV Upload Format

### File layout in the repository

```
data/
  agent-configuration/
    agents.csv
  DNIS-mapping/
    dnis.csv
  ivr-parameters-/
    params.csv
  ivr-pilot-phone-numbers/
    pilot-numbers.csv
  office-hours-/
    hours.csv
  prompts/
    prompts.csv
```

The top-level folder name **must exactly match** the table key in the Terraform `tables` map. The Lambda uses the folder name to look up which table to write into.

### CSV rules

- First row must be a header row matching the DynamoDB attribute names.
- The hash key column must be present and non-empty in every row.
- Empty cells are dropped (attribute is not stored).
- Columns listed in `csv_number_attributes` are stored as DynamoDB `Number`; all others are stored as `String`.
- Duplicate primary keys within a single CSV: the first occurrence is kept and a warning is logged.

### Example — `agent-configuration/agents.csv`

```csv
AgentId,SkillGroup,Priority
agent-001,billing,1
agent-002,sales,2
agent-003,billing,1
```

---

## Upsert Mode vs Sync Mode

Each table independently supports two data loading behaviours controlled by the `sync_mode` flag.

| Mode | `sync_mode` | Behaviour |
|---|---|---|
| **Upsert** (default) | `false` | Rows in the CSV are written. Rows already in DynamoDB but absent from the CSV are **kept**. |
| **Sync** | `true` | Rows in the CSV are written. Rows already in DynamoDB but absent from the CSV are **deleted**. |

Use `sync_mode = true` when the CSV represents the complete desired state of the table (e.g., a nightly full extract). Use the default for incremental updates where you only want to add or overwrite specific rows.

---

## Automated Pipeline — GitLab CI/CD

### How authentication works (no stored keys)

```
GitLab pipeline
    │
    │  generates a short-lived OIDC JWT (id_token)
    ▼
AWS STS AssumeRoleWithWebIdentity
    │
    │  validates JWT against the GitLab OIDC provider registered in AWS
    │  issues temporary credentials (1 hour TTL)
    ▼
aws s3 cp  →  ls-connect-uw2-ddb-csv
```

No `AWS_ACCESS_KEY_ID` or `AWS_SECRET_ACCESS_KEY` are stored in GitLab.

### Setup steps

1. **Deploy Terraform.** The module creates the OIDC provider and IAM role automatically.

2. **Set three CI/CD variables** in GitLab (Settings → CI/CD → Variables):

   | Variable | Value |
   |---|---|
   | `AWS_ROLE_ARN` | Terraform output: `gitlab_upload_role_arn` |
   | `AWS_DEFAULT_REGION` | e.g. `us-west-2` |
   | `CSV_BUCKET_NAME` | Terraform output: `csv_bucket_name` |

3. **Commit CSV files** under `data/<table-key>/` and merge to `main`. The pipeline triggers automatically.

### Pipeline trigger rules

The pipeline runs **only** when:
- the commit is on the `main` branch, **and**
- at least one file matching `data/**/*.csv` changed in that commit.

No CSV change = no pipeline run = no unnecessary AWS calls.

### What the pipeline does

```yaml
for each data/<table-key>/ directory:
  for each *.csv file in that directory:
    aws s3 cp data/<table-key>/file.csv
              s3://<CSV_BUCKET_NAME>/<table-key>/file.csv
```

Each uploaded file immediately triggers the Lambda via S3 event notification.

### Lambda processing steps

1. Extracts the S3 folder name from the object key.
2. Looks up the table config (`table_name`, `hash_key`, `range_key`, `number_attributes`, `sync_mode`) from the `TABLE_ROUTING` environment variable.
3. Downloads the CSV from S3, decodes it (handles Excel BOM).
4. Validates every row — skips rows with missing primary key columns or invalid number values.
5. Deduplicates rows by primary key (keeps first occurrence).
6. Scans the existing DynamoDB table for all current primary keys.
7. Batch-writes all valid rows (inserts and overwrites).
8. If `sync_mode = true`, deletes any keys found in DynamoDB that were not present in the CSV.
9. Logs a structured summary: `inserted | updated | deleted | skipped | csv_duplicates`.

---

## Module Inputs

| Variable | Type | Required | Default | Description |
|---|---|---|---|---|
| `project_name` | string | yes | — | Short prefix (e.g. `ls`). Used in all resource names. |
| `aws_region_abbr` | string | yes | — | Region abbreviation (e.g. `uw2`). Used in all resource names. |
| `tables` | map(object) | yes | — | Map of table definitions. See below. |
| `kms_master_key_id` | string | no | `null` | KMS key ARN. When null, AWS-managed keys are used. |
| `csv_retention_days` | number | no | `90` | Days before uploaded CSVs expire from S3. |
| `lambda_timeout_seconds` | number | no | `300` | Lambda execution timeout (1–900 s). |
| `lambda_memory_mb` | number | no | `256` | Lambda memory in MB. |
| `lambda_log_retention_days` | number | no | `30` | CloudWatch log retention in days. |
| `gitlab_ci_upload.enabled` | bool | no | `false` | Create the GitLab OIDC upload role. |
| `gitlab_ci_upload.project_path` | string | no | — | GitLab project path (e.g. `mygroup/myrepo`). |
| `gitlab_ci_upload.branch` | string | no | `main` | Branch allowed to assume the role. |
| `gitlab_ci_upload.gitlab_url` | string | no | `https://gitlab.com` | GitLab instance URL. |
| `gitlab_oidc_provider_arn` | string | no | `null` | Existing OIDC provider ARN. Prevents creating a duplicate. |
| `tags` | map(string) | yes | — | Must include all 8 required enterprise tag keys. |

### Table object fields

| Field | Type | Default | Description |
|---|---|---|---|
| `hash_key` | string | required | Primary key attribute name. |
| `hash_key_type` | string | `"S"` | `S`, `N`, or `B`. |
| `range_key` | string | `null` | Sort key attribute name. |
| `range_key_type` | string | `null` | `S`, `N`, or `B`. |
| `billing_mode` | string | `"PAY_PER_REQUEST"` | `PAY_PER_REQUEST` or `PROVISIONED`. |
| `read_capacity` | number | `null` | Required only when `PROVISIONED`. |
| `write_capacity` | number | `null` | Required only when `PROVISIONED`. |
| `ttl_attribute_name` | string | `null` | Attribute used for TTL expiry. |
| `point_in_time_recovery_enabled` | bool | `true` | Enable PITR. |
| `csv_number_attributes` | list(string) | `[]` | CSV columns to store as Number type. |
| `sync_mode` | bool | `false` | Delete orphaned records not in the CSV. |
| `global_secondary_indexes` | list(object) | `[]` | GSI definitions. |

---

## Module Outputs

| Output | Description |
|---|---|
| `table_names` | Map of table key → table name. |
| `table_arns` | Map of table key → table ARN. |
| `table_ids` | Map of table key → table ID. |
| `csv_bucket_name` | S3 bucket name for CSV uploads. |
| `csv_bucket_arn` | S3 bucket ARN. |
| `csv_loader_function_name` | Lambda function name. |
| `csv_loader_function_arn` | Lambda function ARN. |
| `csv_loader_log_group_name` | CloudWatch log group name. |
| `gitlab_upload_role_arn` | IAM role ARN for GitLab OIDC. `null` when GitLab upload is disabled. |

---

## Requirements

| Tool | Version |
|---|---|
| Terraform | `>= 1.5.0` |
| AWS Provider | `>= 5.0.0` |
| Archive Provider | `>= 2.0.0` |
| Python (Lambda runtime) | `3.12` |
