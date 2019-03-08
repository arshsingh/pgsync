> Periodically synchronises the data from one PG DB to another

We're using a fork of a fork of pgsync. The version we're using is
https://github.com/ternandsparrow/pgsync/tree/ternandsparrow-patch-1 but the original is
https://github.com/ankane/pgsync. The `tomsaleeba-patch-1` fork doesn't add much but the reason we need the `arshsingh`
fork is that it adds support for opting out of sync-ing constraints on the DB. We have foreign keys present in our DB
but `pg_restore` (which `pgsync` uses under the covers) blindy tries to restore tables in alphabetical order. In our
case, this causes violations.  The `pgsync` tool has options for configuring groups of tables so we could go to the
effort of mapping all our tables to groups and then calling sync on each group in order but that's too much effort (and
it's brittle). We've chosen this fork so we can sync **without constraints**. This shouldn't matter because we're just a
read-only mirror of production SWARM.

## Usage

This container is intended to be used in a docker-compose stack. If you have the target DB in your stack and the source
DB is elsewhere, you can do something like:
```yaml
version: '3'
services:
  db:
    image: postgres:10
    environment:
      POSTGRES_DB: app_db
      POSTGRES_USER: writeuser
      POSTGRES_PASSWORD: pokemon
    restart: unless-stopped
  db-sync:
    image: ternandsparrow/pgsync:dev # TODO select a tag
    links:
      - db:db
    environment:
      FROM_USER: readonlyuser
      FROM_PASS: bananas
      FROM_HOST: db.example.com
      FROM_PORT: 5432
      FROM_DB: allthedata
      TO_USER: writeuser
      TO_PASS: pokemon
      TO_HOST: db
      TO_PORT: 5432
      TO_DB: app_db
      CRON_SCHEDULE: '1 1 * * *'
    restart: unless-stopped
    depends_on:
      - db
```

The periodic command that is run by `cron` will **only sync data**. This command will fail if the schema doesn't already exist. To fix this, after you've deployed the stack, you should do this manual, one-off step to create the schema:
```bash
docker exec -i example_db-sync_1 sh -c 'SCHEMA_ONLY=1 sh /run.sh'
```

If you're impatient and don't want to wait for the first data sync to get some data, you can trigger that using a manual step too:
```bash
docker exec -i example_db-sync_1 sh -c 'sh /run.sh'
```

## Run example docker-compose stack

This example creates two PG DBs. The first is loaded with some data that we want to sync. For the purposes of this
example, we override the entrypoint so we can do a schema sync, then data sync, then print the results. You shouldn't do
this when you deploy.

```bash
cd example/
docker-compose up --build
# when you see the output of the select statement:
#   db-sync_1  |    1 | one
#   db-sync_1  |    2 | two
#   db-sync_1  |    3 | three
#   db-sync_1  |    4 | four
# ... then ctrl+c
docker-compose down --volumes
```
