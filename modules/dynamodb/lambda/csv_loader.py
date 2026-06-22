import boto3
import csv
import io
import json
import logging
import os
from decimal import Decimal, InvalidOperation

logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3 = boto3.client("s3")
dynamodb = boto3.resource("dynamodb")

TABLE_ROUTING = json.loads(os.environ["TABLE_ROUTING"])


def _row_pk(row, hash_key, range_key):
    """Return a hashable tuple representing the primary key of a row."""
    h = str(row.get(hash_key, ""))
    if range_key:
        return (h, str(row.get(range_key, "")))
    return (h,)


def _scan_existing_keys(table, hash_key, range_key):
    """
    Scan the DynamoDB table and return a set of all primary key tuples
    currently stored. Uses a projection to minimise read cost.
    """
    existing = set()
    expr_names = {"#hk": hash_key}
    proj = "#hk"
    if range_key:
        expr_names["#rk"] = range_key
        proj += ", #rk"

    kwargs = {
        "ProjectionExpression": proj,
        "ExpressionAttributeNames": expr_names,
    }
    while True:
        resp = table.scan(**kwargs)
        for item in resp.get("Items", []):
            h = str(item.get(hash_key, ""))
            pk = (h, str(item.get(range_key, ""))) if range_key else (h,)
            existing.add(pk)
        last = resp.get("LastEvaluatedKey")
        if not last:
            break
        kwargs["ExclusiveStartKey"] = last

    return existing


def _delete_keys(table, hash_key, range_key, keys_to_delete):
    """Batch-delete a set of primary key tuples from DynamoDB."""
    with table.batch_writer() as batch:
        for pk in keys_to_delete:
            key = {hash_key: pk[0]}
            if range_key:
                key[range_key] = pk[1]
            batch.delete_item(Key=key)
    return len(keys_to_delete)


def handler(event, context):
    for record in event["Records"]:
        bucket = record["s3"]["bucket"]["name"]
        key = record["s3"]["object"]["key"]

        parts = key.split("/")
        if len(parts) < 2:
            logger.error(
                "Object key '%s' has no folder prefix. Upload CSVs into a "
                "sub-folder matching the table key (e.g. agent-configuration/data.csv). "
                "Known folders: %s",
                key,
                list(TABLE_ROUTING.keys()),
            )
            continue

        folder = parts[0]
        config = TABLE_ROUTING.get(folder)
        if config is None:
            logger.error(
                "No table mapped to folder '%s'. Known folders: %s",
                folder,
                list(TABLE_ROUTING.keys()),
            )
            continue

        table_name        = config["table_name"]
        hash_key          = config["hash_key"]
        range_key         = config.get("range_key") or None
        number_attributes = set(config.get("number_attributes", []))
        sync_mode         = config.get("sync_mode", False)

        logger.info(
            "Processing s3://%s/%s → table %s (sync_mode=%s)",
            bucket, key, table_name, sync_mode,
        )

        # ── 1. Fetch and decode CSV ───────────────────────────────────────────
        response = s3.get_object(Bucket=bucket, Key=key)
        # utf-8-sig strips the BOM that Excel adds when saving as CSV
        content = response["Body"].read().decode("utf-8-sig")

        # ── 2. Parse CSV — detect duplicates, validate, build items ──────────
        reader = csv.DictReader(io.StringIO(content))
        valid_items   = []   # list of (pk_tuple, ddb_item_dict)
        seen_pks      = set()
        csv_pks       = set()
        duplicates    = 0
        rows_skipped  = 0

        for row in reader:
            pk = _row_pk(row, hash_key, range_key)

            # Reject rows missing primary key columns
            if not pk[0]:
                logger.warning(
                    "Row missing hash_key '%s' — skipping: %s", hash_key, row
                )
                rows_skipped += 1
                continue
            if range_key and not pk[1]:
                logger.warning(
                    "Row missing range_key '%s' — skipping: %s", range_key, row
                )
                rows_skipped += 1
                continue

            # Detect duplicate primary keys within the CSV itself
            if pk in seen_pks:
                logger.warning(
                    "DUPLICATE primary key %s found in CSV — "
                    "first occurrence was kept, this row is skipped",
                    pk,
                )
                duplicates += 1
                continue
            seen_pks.add(pk)

            # Build DynamoDB item — convert number columns, skip empty strings
            item = {}
            error = False
            for col, val in row.items():
                if val == "":
                    continue
                if col in number_attributes:
                    try:
                        item[col] = Decimal(val)
                    except InvalidOperation:
                        logger.error(
                            "Column '%s' value '%s' is not a valid number — "
                            "skipping row: %s",
                            col, val, row,
                        )
                        error = True
                        break
                else:
                    item[col] = val

            if error:
                rows_skipped += 1
                continue

            valid_items.append((pk, item))
            csv_pks.add(pk)

        # ── 3. Snapshot existing DynamoDB keys BEFORE the load ───────────────
        table = dynamodb.Table(table_name)
        logger.info("Scanning %s for existing keys …", table_name)
        existing_pks = _scan_existing_keys(table, hash_key, range_key)
        logger.info("Found %d existing record(s) in %s", len(existing_pks), table_name)

        # ── 4. Classify rows as inserts or updates ───────────────────────────
        inserts = csv_pks - existing_pks   # new keys not yet in DynamoDB
        updates = csv_pks & existing_pks   # keys that will overwrite existing items

        # ── 5. Write all valid rows to DynamoDB ──────────────────────────────
        with table.batch_writer() as batch:
            for _, item in valid_items:
                batch.put_item(Item=item)

        # ── 6. Handle orphaned records (in DynamoDB but not in the CSV) ──────
        orphaned_pks = existing_pks - csv_pks
        deleted = 0

        if sync_mode:
            if orphaned_pks:
                logger.info(
                    "sync_mode=true — deleting %d orphaned record(s) not present in CSV",
                    len(orphaned_pks),
                )
                deleted = _delete_keys(table, hash_key, range_key, orphaned_pks)
            else:
                logger.info("sync_mode=true — no orphaned records to delete")
        elif orphaned_pks:
            preview = [list(pk) for pk in list(orphaned_pks)[:20]]
            logger.info(
                "%d record(s) exist in DynamoDB but were NOT in the CSV "
                "(sync_mode=false so they were retained). "
                "Set sync_mode=true on this table to auto-delete them. "
                "First 20: %s",
                len(orphaned_pks),
                preview,
            )

        # ── 7. Post-load summary ──────────────────────────────────────────────
        logger.info(
            "LOAD COMPLETE | table=%s | file=s3://%s/%s | "
            "inserted=%d | updated=%d | deleted=%d | "
            "skipped=%d | csv_duplicates=%d",
            table_name, bucket, key,
            len(inserts), len(updates), deleted,
            rows_skipped, duplicates,
        )

    return {"statusCode": 200}
