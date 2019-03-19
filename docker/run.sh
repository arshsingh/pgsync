#!/bin/sh
# runs pgsync to sync from the "FROM" DB to the "TO" DB
set -e
: ${FROM_USER:?}
: ${FROM_PASS:?}
: ${FROM_HOST:?}
: ${FROM_PORT:?}
: ${FROM_DB:?}
: ${TO_USER:?}
: ${TO_PASS:?}
: ${TO_HOST:?}
: ${TO_PORT:?}
: ${TO_DB:?}
EXTRA_OPTS=""

if [ ! -z "$SCHEMA_ONLY" ]; then
  echo '[INFO] restoring schema only'
  EXTRA_OPTS="--schema-only --no-constraints"
fi

echo "Run started at $(date)"
pgsync \
  $EXTRA_OPTS \
  --from "postgres://$FROM_USER:$FROM_PASS@$FROM_HOST:$FROM_PORT/$FROM_DB" \
  --to "postgres://$TO_USER:$TO_PASS@$TO_HOST:$TO_PORT/$TO_DB" \
  --to-safe

