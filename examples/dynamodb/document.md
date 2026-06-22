# DynamoDB Connect Tables — Deployment & Manual Testing Guide

## What this deploys

Six Amazon Connect configuration tables, an S3 ingestion bucket, and a Lambda
function that automatically loads CSV files into the correct table whenever
a file is uploaded to S3.

```
You upload a CSV to S3
        │
        │  s3:ObjectCreated event (automatic)
        ▼
  Lambda (csv_loader)
  - reads the folder name from the S3 key
  - looks up which table that folder maps to
  - validates and loads all rows
  - logs a summary to CloudWatch
        │
        ▼
  DynamoDB table updated
```

No manual Lambda invocations needed. Upload the file and the rest is automatic.

---

## Resources created

| Resource | Name |
|---|---|
| DynamoDB table × 6 | `ls-connect-<key>-uw2` |
| S3 bucket | `ls-connect-uw2-ddb-csv` |
| Lambda function | `ls-connect-uw2-ddb-loader` |
| Lambda IAM role | `ls-connect-uw2-ddb-loader-role` |
| CloudWatch log group | `/aws/lambda/ls-connect-uw2-ddb-loader` |

> Names shown use example values `project_name = "ls"` and `aws_region_abbr = "uw2"`.

---

## The six tables

| Table key | Table name | Hash key |
|---|---|---|
| `agent-configuration` | `ls-connect-agent-configuration-uw2` | `AgentId` |
| `DNIS-mapping` | `ls-connect-DNIS-mapping-uw2` | `DNIS` |
| `ivr-parameters-` | `ls-connect-ivr-parameters--uw2` | `ParameterKey` |
| `ivr-pilot-phone-numbers` | `ls-connect-ivr-pilot-phone-numbers-uw2` | `PhoneNumber` |
| `office-hours-` | `ls-connect-office-hours--uw2` | `OfficeId` |
| `prompts` | `ls-connect-prompts-uw2` | `PromptId` |

---

## Step 1 — Deploy

```bash
cd examples/dynamodb

# Authenticate via SSO (enterprise)
aws sso login --profile <your-sso-profile>
export AWS_PROFILE=<your-sso-profile>

# Copy and fill in the tfvars
cp example.tfvars terraform.tfvars

# Deploy
terraform init
terraform plan
terraform apply
```

Note the outputs after apply — you will need `csv_bucket_name`:

```
Outputs:

csv_bucket_name            = "ls-connect-uw2-ddb-csv"
csv_loader_function_name   = "ls-connect-uw2-ddb-loader"
csv_loader_log_group_name  = "/aws/lambda/ls-connect-uw2-ddb-loader"
table_names = {
  "DNIS-mapping"             = "ls-connect-DNIS-mapping-uw2"
  "agent-configuration"      = "ls-connect-agent-configuration-uw2"
  "ivr-parameters-"          = "ls-connect-ivr-parameters--uw2"
  "ivr-pilot-phone-numbers"  = "ls-connect-ivr-pilot-phone-numbers-uw2"
  "office-hours-"            = "ls-connect-office-hours--uw2"
  "prompts"                  = "ls-connect-prompts-uw2"
}
```

---

## Step 2 — Upload a CSV to test

Sample files are already prepared in the `data/` folder.

### Via AWS CLI

```bash
BUCKET="ls-connect-uw2-ddb-csv"   # from terraform output

# Upload one table at a time to observe each load
aws s3 cp data/agent-configuration/sample.csv \
  s3://${BUCKET}/agent-configuration/sample.csv

aws s3 cp data/DNIS-mapping/sample.csv \
  s3://${BUCKET}/DNIS-mapping/sample.csv

aws s3 cp "data/ivr-parameters-/sample.csv" \
  "s3://${BUCKET}/ivr-parameters-/sample.csv"

aws s3 cp data/ivr-pilot-phone-numbers/sample.csv \
  s3://${BUCKET}/ivr-pilot-phone-numbers/sample.csv

aws s3 cp "data/office-hours-/sample.csv" \
  "s3://${BUCKET}/office-hours-/sample.csv"

aws s3 cp data/prompts/sample.csv \
  s3://${BUCKET}/prompts/sample.csv
```

### Via AWS Console

1. Open **S3** → find bucket `ls-connect-uw2-ddb-csv`
2. Create a folder matching the table key exactly (e.g. `agent-configuration`)
3. Upload the CSV file into that folder
4. The Lambda fires automatically within a few seconds

> The folder name **must exactly match** the table key in the Terraform `tables`
> map. A mismatch is logged as an error and no data is written.

---

## Step 3 — Verify the load

### Check CloudWatch Logs

```bash
LOG_GROUP="/aws/lambda/ls-connect-uw2-ddb-loader"

# Stream the most recent log events
aws logs tail "${LOG_GROUP}" --follow
```

A successful load looks like this:

```
Processing s3://ls-connect-uw2-ddb-csv/agent-configuration/sample.csv
  → table ls-connect-agent-configuration-uw2 (sync_mode=False)
Scanning ls-connect-agent-configuration-uw2 for existing keys …
Found 0 existing record(s)
LOAD COMPLETE | table=ls-connect-agent-configuration-uw2 |
  file=s3://ls-connect-uw2-ddb-csv/agent-configuration/sample.csv |
  inserted=4 | updated=0 | deleted=0 | skipped=0 | csv_duplicates=0
```

### Check DynamoDB directly

```bash
# Scan the table and count items
aws dynamodb scan \
  --table-name ls-connect-agent-configuration-uw2 \
  --select COUNT

# View all items
aws dynamodb scan \
  --table-name ls-connect-agent-configuration-uw2
```

Via Console: **DynamoDB** → **Tables** → select the table → **Explore table items**

---

## CSV format rules

### Column headers
The first row must be a header row. Column names must match the DynamoDB
attribute names exactly (case-sensitive).

### Hash key column
The hash key column (`AgentId`, `DNIS`, etc.) must be present and non-empty
in every data row. Rows missing the hash key are skipped and a warning is logged.

### Data types
All columns are stored as **String** by default. To store a column as
**Number**, add it to `csv_number_attributes` in the table definition.

### Empty cells
Empty cells are dropped — the attribute is not stored on that item.

### Duplicate primary keys
If the same hash key appears more than once in a CSV, the first row is kept
and a warning is logged for each duplicate.

---

## Upsert vs sync mode

| Mode | `sync_mode` | Behaviour |
|---|---|---|
| Upsert (default) | `false` | Rows in the CSV are written. Rows already in DynamoDB but not in this CSV are **kept**. |
| Full sync | `true` | Rows in the CSV are written. Rows already in DynamoDB but not in this CSV are **deleted**. |

To test sync mode, upload a CSV with fewer rows than already exist in the table
and check that the missing rows are removed.

---

## Troubleshooting

### Lambda was not triggered

- Confirm the file ends in `.csv` — the event filter is `*.csv` only.
- Confirm the file was uploaded into a **folder** (e.g. `agent-configuration/sample.csv`), not to the bucket root.
- Check that the S3 event notification is wired: S3 → bucket → Properties → Event notifications.

### "No table mapped to folder" error in logs

The folder name in S3 does not match any key in the `tables` variable.
Check spelling and casing — `DNIS-mapping` ≠ `dnis-mapping`.

### "Row missing hash_key" warning

A row in the CSV has an empty value in the hash key column.
Check for blank rows or missing values at the end of the file.

### Permission denied writing to DynamoDB

If a permissions boundary is attached, verify the boundary policy allows
`dynamodb:BatchWriteItem` and `dynamodb:Scan` on the specific table ARNs.

---

## Sample CSV files

All sample files are in the `data/` folder. They are ready to upload as-is.

```
data/
  agent-configuration/
    sample.csv       AgentId, AgentName, SkillGroup, Language, MaxConcurrentChats
  DNIS-mapping/
    sample.csv       DNIS, FlowName, QueueName, Description, Active
  ivr-parameters-/
    sample.csv       ParameterKey, ParameterValue, Description
  ivr-pilot-phone-numbers/
    sample.csv       PhoneNumber, PilotGroup, EnrolledDate, Notes
  office-hours-/
    sample.csv       OfficeId, OpenTime, CloseTime, Timezone, Weekdays, HolidaysClosed
  prompts/
    sample.csv       PromptId, PromptName, S3Location, Language, Description
```

---

## Phase 2 — Automation (after manual testing passes)

Once you have confirmed the pipeline works end-to-end, GitLab CI/CD can automate
the S3 upload so any CSV committed to the data repository is loaded automatically
on merge to `main`.

### What is needed

1. **A GitLab IAM role** — an IAM role the pipeline can assume via OIDC to call
   `s3:PutObject` on the CSV bucket. This is created separately once testing is
   complete (not part of this Terraform module).

2. **A `.gitlab-ci.yml`** placed at the **root** of the repository that holds the
   CSV data files (GitLab only reads it from the repo root, not from
   subdirectories). A template pipeline looks like this:

   ```yaml
   stages:
     - upload

   upload-csv:
     stage: upload
     image: amazon/aws-cli:latest

     id_tokens:
       GITLAB_OIDC_TOKEN:
         aud: https://gitlab.com

     script:
       - |
         CREDS=$(aws sts assume-role-with-web-identity \
           --role-arn "$AWS_ROLE_ARN" \
           --role-session-name "gitlab-csv-upload-${CI_PIPELINE_ID}" \
           --web-identity-token "$GITLAB_OIDC_TOKEN" \
           --duration-seconds 3600 \
           --output json)
         export AWS_ACCESS_KEY_ID=$(echo "$CREDS" | python3 -c "import sys,json; print(json.load(sys.stdin)['Credentials']['AccessKeyId'])")
         export AWS_SECRET_ACCESS_KEY=$(echo "$CREDS" | python3 -c "import sys,json; print(json.load(sys.stdin)['Credentials']['SecretAccessKey'])")
         export AWS_SESSION_TOKEN=$(echo "$CREDS" | python3 -c "import sys,json; print(json.load(sys.stdin)['Credentials']['SessionToken'])")
       - |
         for table_dir in data/*/; do
           table_key=$(basename "$table_dir")
           for csv_file in "${table_dir}"*.csv; do
             [ -f "$csv_file" ] || continue
             aws s3 cp "$csv_file" "s3://${CSV_BUCKET_NAME}/${table_key}/$(basename "$csv_file")"
           done
         done

     rules:
       - if: '$CI_COMMIT_BRANCH == "main"'
         changes:
           - "data/**/*.csv"
   ```

3. **Three CI/CD variables** set in GitLab (Settings → CI/CD → Variables):

   | Variable | Value |
   |---|---|
   | `AWS_ROLE_ARN` | ARN of the GitLab IAM upload role |
   | `AWS_DEFAULT_REGION` | `us-west-2` |
   | `CSV_BUCKET_NAME` | `ls-connect-uw2-ddb-csv` |

### How it works

- The pipeline triggers only when a `.csv` file under `data/` changes on `main`.
- It exchanges a short-lived GitLab OIDC token for temporary AWS credentials — no
  long-lived access keys are stored in GitLab.
- Each CSV is uploaded to `s3://<bucket>/<table-key>/<filename>`, which
  immediately fires the Lambda and loads the data into DynamoDB.
