# DynamoDB Module

Terraform module that provisions multiple Amazon DynamoDB tables for Amazon Connect workloads, together with a fully automated CSV data-loading pipeline and optional GitLab CI/CD integration.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                        GitLab Repository                            │
│                                                                     │
│  data/phone-routing/update.csv  ──┐                                 │
│  data/blocked-numbers/jan.csv   ──┤  git push / merge to main       │
│  data/agent-routing/agents.csv  ──┘        │                        │
└────────────────────────────────────────────┼────────────────────────┘
                                             │
                                    GitLab CI/CD Pipeline
                                             │
                                    OIDC token exchange
                                             │
                                    ┌────────▼────────┐
                                    │   AWS STS        │
                                    │ AssumeRoleWith   │
                                    │ WebIdentity      │
                                    └────────┬────────┘
                                             │ Temporary credentials
                                             │ (no long-lived keys)
                                    ┌────────▼────────────────────────┐
                                    │         S3 CSV Bucket           │
                                    │                                 │
                                    │  phone-routing/update.csv  ─┐  │
                                    │  blocked-numbers/jan.csv  ──┤  │
                                    │  agent-routing/agents.csv ──┘  │
                                    └────────────────┬────────────────┘
                                                     │ s3:ObjectCreated (*.csv)
                                                     │ S3 Event Notification
                                          ┌──────────▼──────────┐
                                          │   Lambda Function    │
                                          │   (csv_loader.py)    │
                                          │                      │
                                          │ 1. Read TABLE_ROUTING│
                                          │ 2. Extract folder    │
                                          │    from S3 key       │
                                          │ 3. Look up table     │
                                          │    config            │
                                          │ 4. Parse CSV         │
                                          │ 5. BatchWriteItem    │
                                          └──────────┬──────────┘
                                                     │
                               ┌─────────────────────┼──────────────────────┐
                               │                     │                      │
                    ┌──────────▼──────┐   ┌──────────▼──────┐   ┌──────────▼──────┐
                    │  phone-routing  │   │ blocked-numbers  │   │  agent-routing  │
                    │  DynamoDB Table │   │  DynamoDB Table  │   │  DynamoDB Table │
                    └─────────────────┘   └──────────────────┘   └─────────────────┘
```

---

## Strategy

### Problem

Amazon Connect routing logic often depends on lookup tables — phone number to queue mappings, blocked caller lists, agent skill assignments. These tables need to be managed by non-engineers (operations teams, contact centre managers) using familiar tools like Excel or CSV files, without requiring a Terraform apply every time data changes.

### Design Decisions

#### 1. One S3 bucket, one Lambda, N tables

The naive approach is one S3 bucket and one Lambda per table. Instead, this module provisions a **single shared S3 bucket and a single Lambda** that serves all tables declared in `var.tables`.

- Fewer AWS resources to manage and monitor
- One CloudWatch log group shows all load activity in one place
- Adding a new table requires only a Terraform variable change — no new infrastructure

#### 2. Folder-based routing

Each table maps to an S3 folder prefix that matches its map key:

```
var.tables key       S3 folder             DynamoDB table
────────────────────────────────────────────────────────────────
phone-routing    →   phone-routing/     →  <name_prefix>-phone-routing
blocked-numbers  →   blocked-numbers/   →  <name_prefix>-blocked-numbers
agent-routing    →   agent-routing/     →  <name_prefix>-agent-routing
```

The Lambda extracts `key.split("/")[0]` from the S3 event to determine the target table. The routing map is baked into the Lambda as the `TABLE_ROUTING` environment variable at Terraform apply time, so the Lambda code itself has no hardcoded table names.

#### 3. TABLE_ROUTING environment variable

At apply time, Terraform serialises the routing config to JSON and injects it as a Lambda environment variable:

```json
{
  "phone-routing": {
    "table_name": "tfc-retail-connect-tccivr-prod-ue1-phone-routing",
    "hash_key":   "phone_number",
    "range_key":  "",
    "number_attributes": []
  },
  ...
}
```

Adding a new table in `var.tables` and running `terraform apply` automatically updates this environment variable — no Lambda code changes required.

#### 4. Upsert semantics

Every CSV upload performs a `BatchWriteItem` (PutItem) for each row. Items with the same primary key are **replaced**; new keys are inserted. Nothing is ever deleted by an upload. This means:

- Re-uploading a corrected CSV is safe — only changed rows are overwritten
- Stale rows remain until explicitly deleted via the AWS Console or CLI
- Partial uploads (a subset of rows) do not remove rows not in the CSV

#### 5. GitLab OIDC — no long-lived credentials

Rather than storing AWS access keys in GitLab CI/CD variables (a security risk), the module optionally provisions:

- An **IAM OIDC provider** that trusts GitLab's identity tokens
- An **IAM role** scoped to a specific GitLab project and branch
- A **least-privilege IAM policy** granting only `s3:PutObject`, `s3:GetObject`, and `s3:ListBucket` on the CSV bucket

The pipeline exchanges its GitLab OIDC token for short-lived AWS credentials via `sts:AssumeRoleWithWebIdentity`. Credentials expire automatically; there is nothing to rotate.

#### 6. Security defaults

| Control | Implementation |
|---|---|
| Encryption at rest | SSE-S3 by default; SSE-KMS when `kms_master_key_id` is provided |
| Encryption in transit | S3 bucket policy denies all non-TLS requests |
| Public access | All four S3 public-access-block settings enabled |
| S3 versioning | Enabled — every CSV upload is preserved as a version |
| DynamoDB PITR | Enabled by default on all tables |
| Lambda IAM | Scoped to specific table ARNs and the specific log group |
| GitLab role | Scoped to a single project path and branch via OIDC claims |

---

## Resources Deployed

| Resource | Count | Name pattern |
|---|---|---|
| `aws_dynamodb_table` | one per `tables` key | `<name_prefix>-<key>` |
| `aws_s3_bucket` | 1 shared | `<name_prefix>-ddb-csv` |
| `aws_s3_bucket_versioning` | 1 | — |
| `aws_s3_bucket_server_side_encryption_configuration` | 1 | — |
| `aws_s3_bucket_public_access_block` | 1 | — |
| `aws_s3_bucket_lifecycle_configuration` | 1 | — |
| `aws_s3_bucket_policy` | 1 | — |
| `aws_s3_bucket_notification` | 1 | — |
| `aws_lambda_function` | 1 shared | `<name_prefix>-ddb-csv-loader` |
| `aws_lambda_permission` | 1 | — |
| `aws_iam_role` (Lambda) | 1 | `<name_prefix>-ddb-csv-role` |
| `aws_iam_role_policy` (Lambda) | 1–2 | `<name_prefix>-ddb-csv-policy` |
| `aws_cloudwatch_log_group` | 1 | `/aws/lambda/<name_prefix>-ddb-csv-loader` |
| `aws_iam_openid_connect_provider` | 0 or 1 | — (optional, GitLab OIDC) |
| `aws_iam_role` (GitLab) | 0 or 1 | `<name_prefix>-ddb-gitlab-upload-role` |
| `aws_iam_role_policy` (GitLab) | 0 or 1 | `<name_prefix>-ddb-gitlab-upload-policy` |

---

## Naming Convention

All resource names follow the enterprise-wide convention inherited from the connect-instance module:

```
<project_name>-<account>-connect-<lob>-<sdlc_env>-<aws_region_abbr>
```

Example with `project_name=tfc`, `account=retail`, `lob=tccivr`, `sdlc_env=prod`, `aws_region_abbr=ue1`:

```
DynamoDB table:   tfc-retail-connect-tccivr-prod-ue1-phone-routing
S3 bucket:        tfc-retail-connect-tccivr-prod-ue1-ddb-csv
Lambda function:  tfc-retail-connect-tccivr-prod-ue1-ddb-csv-loader
IAM role:         tfc-retail-connect-tccivr-prod-ue1-ddb-csv-role
Log group:        /aws/lambda/tfc-retail-connect-tccivr-prod-ue1-ddb-csv-loader
```

---

## Usage

### Minimal — two tables, no GitLab automation

```hcl
module "connect_tables" {
  source = "../../modules/dynamodb"

  project_name    = "tfc"
  account         = "retail"
  lob             = "tccivr"
  sdlc_env        = "prod"
  aws_region_abbr = "ue1"

  tables = {
    phone-routing = {
      hash_key = "phone_number"
    }
    blocked-numbers = {
      hash_key = "phone_number"
    }
  }

  tags = local.required_tags
}
```

### With GitLab CI/CD automated upload

```hcl
module "connect_tables" {
  source = "../../modules/dynamodb"

  # ... naming and tables as above ...

  gitlab_ci_upload = {
    enabled      = true
    project_path = "mygroup/myrepo"
    branch       = "main"
    gitlab_url   = "https://gitlab.com"
  }

  tags = local.required_tags
}
```

Set the following in **GitLab → Settings → CI/CD → Variables**:

| Variable | Value |
|---|---|
| `AWS_ROLE_ARN` | `module.connect_tables.gitlab_upload_role_arn` output |
| `AWS_DEFAULT_REGION` | e.g. `us-east-1` |
| `CSV_BUCKET_NAME` | `module.connect_tables.csv_bucket_name` output |

### With KMS encryption

```hcl
module "connect_tables" {
  source = "../../modules/dynamodb"

  # ... naming, tables, gitlab_ci_upload ...

  kms_master_key_id = module.kms.connect_key_arn   # from kms module output

  tags = local.required_tags
}
```

---

## How to Load Data

Upload a CSV file into the folder that matches the table key:

```bash
# Load phone routing table
aws s3 cp phone-routing.csv s3://<csv_bucket_name>/phone-routing/phone-routing.csv

# Load blocked numbers table
aws s3 cp blocked.csv s3://<csv_bucket_name>/blocked-numbers/blocked.csv
```

The CSV must have a header row. The column name for the hash key must be present on every row. Empty cells are skipped. Columns listed in `csv_number_attributes` are stored as DynamoDB Number type; all others are String.

**Example CSV for `phone-routing` (hash_key = `phone_number`)**:

```csv
phone_number,contact_flow_id,queue_id,description
+15551234567,aaaa-0000-...,bbbb-0000-...,Main support line
+15559876543,cccc-0000-...,dddd-0000-...,Sales line
```

---

## How to Add a New Table

1. Add a new key to `var.tables` in your root module.
2. Run `terraform apply` — Terraform creates the DynamoDB table and updates `TABLE_ROUTING` on the Lambda.
3. Upload a CSV to `s3://<bucket>/<new-key>/file.csv`.

No Lambda code changes, no new S3 buckets, no new IAM roles.

---

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `project_name` | `string` | required | Short project name used in resource names |
| `account` | `string` | required | AWS account short-name |
| `lob` | `string` | required | Line-of-business identifier |
| `sdlc_env` | `string` | required | `prod`, `qa`, or `test` |
| `aws_region_abbr` | `string` | required | Short region abbreviation (e.g. `ue1`) |
| `tables` | `map(object)` | required | Map of table definitions — see variables.tf for full schema |
| `kms_master_key_id` | `string` | `null` | KMS key ARN for encryption; AWS-managed keys used when null |
| `csv_retention_days` | `number` | `90` | Days before CSV objects expire from S3 |
| `lambda_timeout_seconds` | `number` | `300` | Lambda execution timeout (1–900) |
| `lambda_memory_mb` | `number` | `256` | Lambda memory in MB |
| `lambda_log_retention_days` | `number` | `30` | CloudWatch log retention days |
| `gitlab_ci_upload` | `object` | `{enabled=false}` | GitLab OIDC upload configuration |
| `gitlab_oidc_provider_arn` | `string` | `null` | Existing OIDC provider ARN (if one already exists in the account) |
| `tags` | `map(string)` | required | Must include all 8 enterprise tag keys |

### `tables` map object schema

| Field | Type | Default | Description |
|---|---|---|---|
| `hash_key` | `string` | required | Partition key attribute name |
| `hash_key_type` | `string` | `"S"` | `S`, `N`, or `B` |
| `range_key` | `string` | `null` | Sort key attribute name |
| `range_key_type` | `string` | `null` | `S`, `N`, or `B` |
| `billing_mode` | `string` | `"PAY_PER_REQUEST"` | `PAY_PER_REQUEST` or `PROVISIONED` |
| `read_capacity` | `number` | `null` | Required when billing_mode is `PROVISIONED` |
| `write_capacity` | `number` | `null` | Required when billing_mode is `PROVISIONED` |
| `ttl_attribute_name` | `string` | `null` | TTL attribute name |
| `point_in_time_recovery_enabled` | `bool` | `true` | Enable PITR |
| `csv_number_attributes` | `list(string)` | `[]` | CSV columns stored as Number type |
| `global_secondary_indexes` | `list(object)` | `[]` | GSI definitions |

---

## Outputs

| Name | Description |
|---|---|
| `table_names` | Map of table key → DynamoDB table name |
| `table_arns` | Map of table key → DynamoDB table ARN |
| `table_ids` | Map of table key → DynamoDB table ID |
| `csv_bucket_name` | Shared S3 bucket name — upload CSVs here |
| `csv_bucket_arn` | Shared S3 bucket ARN |
| `csv_loader_function_name` | Lambda function name |
| `csv_loader_function_arn` | Lambda function ARN |
| `csv_loader_log_group_name` | CloudWatch log group for monitoring loads |
| `gitlab_upload_role_arn` | IAM role ARN for GitLab CI/CD (`null` when GitLab is disabled) |
| `name_prefix` | Computed name prefix shared by all resources |

---

## Monitoring

All CSV load activity is logged to CloudWatch. Stream logs in real time:

```bash
aws logs tail /aws/lambda/<csv_loader_function_name> --follow
```

A successful load produces:

```
Processing s3://<bucket>/phone-routing/update.csv → table tfc-retail-connect-tccivr-prod-ue1-phone-routing
Done — s3://<bucket>/phone-routing/update.csv → tfc-...-phone-routing: 142 written, 0 skipped
```

Rows are skipped when:
- The hash key column is empty or missing
- The range key column is empty or missing (when a range key is configured)
- A number-typed column contains a non-numeric value

---

## Requirements

| Tool | Version |
|---|---|
| Terraform | >= 1.5.0 |
| AWS Provider | >= 5.0.0 |
| Archive Provider | >= 2.0.0 |
| Python (Lambda runtime) | 3.12 (managed by AWS) |
