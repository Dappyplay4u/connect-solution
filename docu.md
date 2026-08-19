# Connect Module Playbook

Architecture, naming strategy, storage override pattern, and step-by-step instructions for engineers and GitLab Duo working across the Amazon Connect Terraform module library.

---

## Table of Contents

1. [Architecture](#1-architecture)
2. [The Naming Convention](#2-the-naming-convention)
3. [The Problem — Naming Drift on Imported Resources](#3-the-problem--naming-drift-on-imported-resources)
4. [The Solution — `storage_overrides`](#4-the-solution--storage_overrides)
5. [Per-BU Example Folders](#5-per-bu-example-folders)
6. [BU Pipeline Repos](#6-bu-pipeline-repos)
7. [GitLab Duo — Step-by-Step Guide](#7-gitlab-duo--step-by-step-guide)

---

## 1. Architecture

### Two-Repo Design

The system is split into two separate concerns. The module library is never deployed directly — BU pipeline repos consume it as a git source.

| Repo | Purpose | Owner |
|------|---------|-------|
| `connect-solution` (big-connect) | Shared Terraform module library for Amazon Connect | Cloud Engineering |
| `pipeline` (one per BU) | BU-specific IaC that calls the modules; holds Terraform state | Each Business Unit |

A BU pipeline repo references a module like this:

```hcl
module "connect" {
  source = "git::https://gitlab.example.com/org/connect-solution.git//modules/connect-instance?ref=main"

  project_name    = "tfc"
  account         = "retail"
  lob             = "tccivr"
  sdlc_env        = "qa"
  aws_region_abbr = "ue1"
  # ... storage_overrides, kms keys, etc.
}
```

### Module Directory

```
modules/
  connect-instance/   # Full Connect instance: KMS + S3 + Kinesis + instance + 5 storage configs
  s3/                 # Three S3 buckets: recordings, reports, transcripts
  kinesis/            # CTR + media Kinesis Data Streams + optional Firehose
  kms/                # Three KMS keys: S3, Kinesis, Connect
  dynamodb/           # DynamoDB tables + S3 CSV bucket + Lambda CSV loader
  connect-queue/      # Amazon Connect queues
  quick-connect/      # Quick connects (queue-type and user-type)
  hours-of-operation/ # Hours of operation

examples/
  connect-instance/   # Generic reference example
  tfc/                # TFC business unit (with envs/ subfolders)
  lightstream/        # LightStream business unit (with envs/ subfolders)
  dynamodb/           # DynamoDB data layer example
```

The `connect-instance` module is the primary module. It orchestrates `kms`, `s3`, and `kinesis` as child modules, then creates the Connect instance and wires all five `aws_connect_instance_storage_config` resources.

---

## 2. The Naming Convention

Every resource name is derived from five input variables. Nothing is hardcoded in the module logic.

```
name_prefix = "${project_name}-${account}-connect-${lob}-${sdlc_env}-${aws_region_abbr}"
```

| BU | Inputs | Resulting name_prefix |
|----|--------|-----------------------|
| TFC | `project_name=tfc`, `account=retail`, `lob=tccivr`, `sdlc_env=qa`, `aws_region_abbr=ue1` | `tfc-retail-connect-tccivr-qa-ue1` |
| LightStream | `project_name=lightstream`, `account=dev`, `lob=lightstream`, `sdlc_env=dev`, `aws_region_abbr=uw2` | `lightstream-dev-connect-lightstream-dev-uw2` |

Resources get a suffix appended to `name_prefix`:

| Resource | Full name pattern |
|----------|-------------------|
| S3 recordings | `…-recordings-{region_abbr}` |
| S3 reports | `…-reports-{region_abbr}` |
| S3 transcripts | `…-transcripts-{region_abbr}` |
| Kinesis CTR stream | `…-agent-events-datastream-{region_abbr}` |
| Connect instance alias | `{project_spec}-{sdlc_env}-{region_abbr}` |
| KVS media prefix | `{name_prefix}-media` |

### Connect Storage Config Defaults

The `connect-instance` module also configures five `aws_connect_instance_storage_config` resources. These tell Connect *where inside* each bucket to write data. Their defaults are:

| Storage config resource | Default attribute value |
|------------------------|------------------------|
| `call_recordings` `bucket_prefix` | `"call-recordings"` |
| `scheduled_reports` `bucket_prefix` | `"scheduled-reports"` |
| `chat_transcripts` `bucket_prefix` | `"chat-transcripts"` |
| `media_streams` KVS `prefix` | `"${name_prefix}-media"` |

These are configuration attributes — separate from the bucket name or stream ARN. Both the resource identity (name/ARN) *and* the config attribute (prefix) can drift independently when resources pre-exist.

---

## 3. The Problem — Naming Drift on Imported Resources

When Connect resources were provisioned manually before Terraform and then imported into state, a conflict emerges: the resource in AWS has a different name (or storage config path) than what the module would compute.

On the next `terraform plan`, Terraform compares the desired configuration against current state. Any difference becomes a planned change.

### Two Types of Drift

**Type 1 — Resource identity.** The actual bucket name or stream name differs from what the module would compute. Terraform plans to destroy the old resource and create a new one.

> Risk: Destroying an S3 bucket deletes all call recordings. Recreating a Kinesis stream breaks the Connect storage association.

**Type 2 — Storage config attributes.** The `bucket_prefix` (S3 folder path) or KVS `prefix` in `aws_connect_instance_storage_config` differs from the module default. Terraform plans to update the attribute.

> Risk: Changing `bucket_prefix` means new recordings go to a different S3 folder. Historical recordings stay at the old path. Changing the KVS `prefix` affects active calls.

### Real Examples Observed

| BU | Resource | Imported (existing) value | Module default (what Terraform wants to change to) |
|----|----------|--------------------------|---------------------------------------------------|
| TFC | `chat_transcripts` bucket name | `truistmessaging-connectdata-qa` | `tfc-retail-connect-tccivr-qa-transcripts-ue1` |
| TFC | `call_recordings` bucket_prefix | `connect/retail-qa-ue1/CallRecordings` | `call-recordings` |
| TFC | `media_streams` KVS prefix | `my-connect-retail-qa-ue1-contact-` | `tfc-retail-connect-tccivr-qa-ue1-media` |
| LightStream | `call_recordings` bucket_prefix | `connect/lightstream-dev-uw2/CallRecordings` | `call-recordings` |
| LightStream | `media_streams` KVS prefix | `ls-connect-audiostream-uw2-` | `lightstream-dev-connect-lightstream-dev-uw2-media` |

> **Never let Terraform apply these changes blindly.** The plan must show zero changes on `aws_connect_instance_storage_config` resources and on existing S3/Kinesis resources before applying in a region that has imported resources.

---

## 4. The Solution — `storage_overrides`

Rather than adding individual top-level variables for each BU deviation (which leads to unbounded variable sprawl), all storage-related overrides are consolidated into a single structured object variable: `storage_overrides`.

**Design principle:** a BU sets only the fields that differ from the module default. Every field is `optional()`, so existing callers that don't set `storage_overrides` at all continue to work without any tfvars changes.

```hcl
variable "storage_overrides" {
  type = object({

    # ── S3 storage configs ─────────────────────────────────────────────────
    call_recordings = optional(object({
      bucket_name   = optional(string) # use existing bucket → skips S3 module creation
      bucket_prefix = optional(string) # Connect folder path. default: "call-recordings"
    }), {})

    scheduled_reports = optional(object({
      bucket_name   = optional(string)
      bucket_prefix = optional(string) # default: "scheduled-reports"
    }), {})

    chat_transcripts = optional(object({
      bucket_name   = optional(string)
      bucket_prefix = optional(string) # default: "chat-transcripts"
    }), {})

    # ── Kinesis Data Stream (CTR / agent events) ───────────────────────────
    contact_trace_records = optional(object({
      stream_arn = optional(string)    # use existing KDS → skips Kinesis module creation
    }), {})

    # ── Kinesis Video Stream (media streams) ───────────────────────────────
    media_streams = optional(object({
      prefix                 = optional(string) # KVS prefix. default: "<name_prefix>-media"
      retention_period_hours = optional(number)
    }), {})

  })
  default = {}
}
```

### What Each Field Controls

| Resource | Field | Effect when set |
|----------|-------|----------------|
| `call_recordings`, `scheduled_reports`, `chat_transcripts` | `bucket_name` | Uses the named existing bucket in the Connect storage config. Prevents the S3 child module from creating a new bucket. **Required when bucket was manually created.** |
| `call_recordings`, `scheduled_reports`, `chat_transcripts` | `bucket_prefix` | Sets the S3 folder path in `aws_connect_instance_storage_config`. **Required when Connect was previously configured with a non-default path.** |
| `contact_trace_records` | `stream_arn` | Uses the given existing Kinesis Data Stream ARN. Prevents the Kinesis child module from creating a new stream. |
| `media_streams` | `prefix` | Sets the Kinesis Video Stream prefix in the Connect storage config. **Required when the instance was previously configured with a different prefix.** |
| `media_streams` | `retention_period_hours` | Overrides default KVS retention (24 hours). |

### Priority Chain

For each resolved value, the module checks three sources in order. The first non-null value wins:

```
1. storage_overrides.*.bucket_name       ← highest priority, explicit tfvars override
      ↓ (if null)
2. existing_s3_*_id variable             ← backward-compatible legacy variable
      ↓ (if empty)
3. module.s3[0].*                        ← module-created, lowest priority (new deployments)
```

The same three-level chain applies to `scheduled_reports`, `chat_transcripts`, and `contact_trace_records.stream_arn`.

### Extensibility Rule

When a new BU needs a new type of override:

1. Add an `optional()` field to the relevant sub-object in `modules/connect-instance/variables.tf`.
2. Add the resolved local in `modules/connect-instance/locals.tf`:
   ```hcl
   new_field = coalesce(try(var.storage_overrides.resource.new_field, null), "default_value")
   ```
3. Wire the resolved local into `modules/connect-instance/main.tf`.
4. Existing BU callers do not change their tfvars. The new field defaults to `null` for them.

> **KMS keys are not in `storage_overrides`.** KMS is infrastructure — shared across KMS-encrypted resources and managed independently. KMS keys remain in separate `existing_kms_*` variables.

---

## 5. Per-BU Example Folders

The module library contains one example folder per business unit under `examples/`. Each folder has its own `main.tf`, `variables.tf`, `provider.tf`, `outputs.tf`, and an `envs/` subdirectory with one `terraform.tfvars` per deployed region.

```
examples/
  tfc/
    main.tf
    variables.tf
    provider.tf
    outputs.tf
    envs/
      qa-ue1/terraform.tfvars    # QA  us-east-1 — all resources pre-exist (imported)
      prod-ue1/terraform.tfvars  # Prod us-east-1 — clean new deployment

  lightstream/
    main.tf
    variables.tf
    provider.tf
    outputs.tf
    envs/
      dev-ue1/terraform.tfvars   # Dev us-east-1 — some resources pre-exist
      dev-uw2/terraform.tfvars   # Dev us-west-2 — fully clean, no pre-existing resources
```

The `main.tf` in each BU folder is structurally identical — it calls `../../modules/connect-instance` and passes through all variables. What differs per BU is entirely in the `envs/` tfvars files.

---

### Scenario A — Region with Fully Imported Resources (TFC qa-ue1)

All S3 buckets and Kinesis streams were manually created and imported. Their names and Connect storage paths don't match module defaults.

```hcl
# examples/tfc/envs/qa-ue1/terraform.tfvars

aws_region      = "us-east-1"
aws_region_abbr = "ue1"

project_spec = "retail"
project_name = "tfc"
account      = "retail"
lob          = "tccivr"
sdlc_env     = "qa"

# KMS keys — always bring-your-own (shared Truist standard keys)
existing_kms_s3_arn      = "arn:aws:kms:us-east-1:<account_id>:key/<s3-key-id>"
existing_kms_kinesis_arn = "arn:aws:kms:us-east-1:<account_id>:key/<kinesis-key-id>"
existing_kms_connect_arn = "arn:aws:kms:us-east-1:<account_id>:key/<connect-key-id>"

# All S3 + Kinesis names and Connect config paths declared in one block.
# Values read from: terraform state show 'module.connect.aws_connect_instance_storage_config.*'
storage_overrides = {
  call_recordings = {
    bucket_name   = "tfc-retail-connect-tccivr-qa-recordings-ue1"
    bucket_prefix = "connect/retail-qa-ue1/CallRecordings"
  }
  scheduled_reports = {
    bucket_name   = "tfc-retail-connect-tccivr-qa-reports-ue1"
    # bucket_prefix omitted — module default "scheduled-reports" already matches state
  }
  chat_transcripts = {
    bucket_name   = "truistmessaging-connectdata-qa"   # pre-existing manually-created name
    bucket_prefix = "connect/retail-qa-ue1/ChatTranscripts"
  }
  contact_trace_records = {
    stream_arn = "arn:aws:kinesis:us-east-1:<account_id>:stream/<ctr-stream-name>"
  }
  media_streams = {
    prefix = "my-connect-retail-qa-ue1-contact-"
  }
}
```

---

### Scenario B — Region with No Pre-existing Resources (TFC prod-ue1 / LightStream dev-uw2)

No resources were manually created. The module creates everything from scratch with names derived from the naming formula. Nothing needs to be frozen.

```hcl
# examples/tfc/envs/prod-ue1/terraform.tfvars

aws_region      = "us-east-1"
aws_region_abbr = "ue1"

project_spec = "retail"
project_name = "tfc"
account      = "retail"
lob          = "tccivr"
sdlc_env     = "prod"

# KMS keys
existing_kms_s3_arn      = "arn:aws:kms:us-east-1:<account_id>:key/<s3-key-id>"
existing_kms_kinesis_arn = "arn:aws:kms:us-east-1:<account_id>:key/<kinesis-key-id>"
existing_kms_connect_arn = "arn:aws:kms:us-east-1:<account_id>:key/<connect-key-id>"

# storage_overrides not set — module creates with standard names:
#   tfc-retail-connect-tccivr-prod-recordings-ue1
#   tfc-retail-connect-tccivr-prod-reports-ue1
#   tfc-retail-connect-tccivr-prod-transcripts-ue1
#   KVS prefix: tfc-retail-connect-tccivr-prod-ue1-media
```

---

### Scenario C — Region with Partial Existing Resources (LightStream dev-ue1)

Some resources pre-exist (call_recordings bucket, CTR stream); others don't and should be auto-created. Only the pre-existing ones go in `storage_overrides`.

```hcl
# examples/lightstream/envs/dev-ue1/terraform.tfvars

aws_region      = "us-east-1"
aws_region_abbr = "ue1"

project_spec = "lightstream"
project_name = "lightstream"
account      = "dev"
lob          = "lightstream"
sdlc_env     = "dev"

# KMS keys — shared Truist standard keys
existing_kms_s3_arn      = "arn:aws:kms:us-east-1:014848577183:key/<s3-key-id>"
existing_kms_kinesis_arn = "arn:aws:kms:us-east-1:014848577183:key/<kinesis-key-id>"
existing_kms_connect_arn = "arn:aws:kms:us-east-1:014848577183:key/<connect-key-id>"

storage_overrides = {
  call_recordings = {
    bucket_name   = "ls-connect-ue1-recordings"              # pre-existing
    bucket_prefix = "connect/lightstream-dev-uw2/CallRecordings"
  }
  # scheduled_reports and chat_transcripts omitted — auto-created with standard names
  contact_trace_records = {
    stream_arn = "arn:aws:kinesis:us-east-1:014848577183:stream/<ctr-stream-name>"
  }
  media_streams = {
    prefix = "ls-connect-audiostream-uw2-"   # freeze existing KVS prefix
  }
}

alarm_sns_topic_arns = ["arn:aws:sns:us-east-1:014848577183:ls-support-alerts"]
```

---

## 6. BU Pipeline Repos

Each BU operates a separate pipeline repo. The structure mirrors the BU example folders in the module library.

```
pipeline/                        # BU-owned repo (e.g. tfc-connect-pipeline)
  .gitlab-ci.yml
  iac/
    main.tf                      # source = git::https://…/connect-solution.git//modules/…
    variables.tf                 # same variable definitions including storage_overrides object
  envs/
    qa-ue1/terraform.tfvars
    prod-ue1/terraform.tfvars
  data/                          # CSV data files for DynamoDB Lambda loader
    agent-configurations/
    DNIS-mapping/
    office-hours/
    prompts/
```

The `storage_overrides` variable must be declared in `iac/variables.tf` with the same object type as the module. The pipeline repo's tfvars files then use the same syntax shown in Scenarios A/B/C.

### GitLab CI Pipeline

| Stage | Job | What it does |
|-------|-----|-------------|
| `build`, `deploy`, `destroy` | `tf-deploy` component | Terraform plan / apply / destroy using OIDC auth. Reads tfvars from `envs/<env>/terraform.tfvars`. |
| `upload` | `upload_csv` | Uploads CSV files from `data/<table-key>/` to S3. Triggers Lambda which loads into DynamoDB. Runs on main when any CSV under `data/` changes. |

OIDC authentication uses GitLab's `id_tokens` block. The token is written to a file and the AWS SDK handles STS automatically via `AWS_WEB_IDENTITY_TOKEN_FILE` — no manual STS call required.

---

## 7. GitLab Duo — Step-by-Step Guide

This section is written directly for GitLab Duo. When working on any issue related to naming drift, storage configuration changes, or BU-specific overrides, follow this procedure exactly.

### 7.1 Fixing a Naming Drift Issue

**Step 1 — Read state first.**

Run the following for every affected resource. The output shows the actual current values configured in AWS — these are what must be preserved.

```bash
terraform state show 'module.connect.aws_connect_instance_storage_config.call_recordings'
terraform state show 'module.connect.aws_connect_instance_storage_config.scheduled_reports'
terraform state show 'module.connect.aws_connect_instance_storage_config.chat_transcripts'
terraform state show 'module.connect.aws_connect_instance_storage_config.media_streams'
```

**Step 2 — Extract the values that would change.**

From the state output, note:
- `bucket_name` — the actual S3 bucket name configured in Connect storage
- `bucket_prefix` — the S3 folder path configured in Connect storage
- `prefix` — the KVS prefix configured in the media_streams storage config

**Step 3 — Populate `storage_overrides` in the environment's tfvars.**

Use the Scenario A template. Only include sub-objects for resources where the values differ from the module default. Do not set a field to the default value explicitly — omit it.

**Step 4 — Run `terraform plan` and verify zero changes.**

The plan must show no changes on:
- `aws_connect_instance_storage_config.call_recordings`
- `aws_connect_instance_storage_config.scheduled_reports`
- `aws_connect_instance_storage_config.chat_transcripts`
- `aws_connect_instance_storage_config.media_streams`
- Any `aws_s3_bucket` or `aws_kinesis_stream` resource that pre-existed

If there are still planned changes, compare state output against tfvars values character-by-character. A trailing slash, a case difference, or an extra hyphen is enough to cause drift.

**Step 5 — Only apply when the plan is clean for the affected resources.**

---

### 7.2 Hard Rules

**Never** allow Terraform to destroy and recreate an S3 bucket to fix a name mismatch. Put the existing bucket name in `storage_overrides.*.bucket_name`. A bucket destroy deletes all recordings.

**Never** apply a `bucket_prefix` change to an existing Connect instance without understanding the impact. Changing the prefix means new recordings go to a different S3 folder. Historical recordings stay at the old path. Connect agents and reports may lose access to historical data.

**Never** apply a `media_streams.prefix` change on an active instance. The KVS prefix change is applied immediately and affects all active calls in progress.

**Never** add a new top-level module variable to handle a single BU override. Always extend the `storage_overrides` object with an `optional()` field instead.

**Never** set a field in `storage_overrides` to its default value explicitly. Omit it. Explicit defaults make tfvars harder to read and mask which values actually deviate from the module.

**Never** put KMS key ARNs inside `storage_overrides`. KMS keys go in `existing_kms_*` variables.

---

### 7.3 Quick Reference

| I need to… | Use this |
|-----------|---------|
| Use an existing S3 bucket instead of creating a new one | `storage_overrides.call_recordings.bucket_name` |
| Preserve the S3 folder path Connect is currently configured with | `storage_overrides.call_recordings.bucket_prefix` |
| Use an existing Kinesis Data Stream for CTR records | `storage_overrides.contact_trace_records.stream_arn` |
| Preserve the KVS prefix currently set in Connect | `storage_overrides.media_streams.prefix` |
| Use existing KMS keys | `existing_kms_s3_arn`, `existing_kms_kinesis_arn`, `existing_kms_connect_arn` |
| Deploy a completely new region with no pre-existing resources | Omit `storage_overrides` entirely. Only set naming vars and KMS keys. |
| Add a new override type for a new BU requirement | Add an `optional()` field to the `storage_overrides` object type in the module. Follow Section 4 extensibility procedure. |
| Read current storage config values from state | `terraform state show 'module.connect.aws_connect_instance_storage_config.<resource>'` |
