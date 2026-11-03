
# MUN-SRRMS Portfolio 5 — Distributed and Cloud Databases

## 1. Project Scope

This portfolio demonstrates PostgreSQL logical replication between two local PostgreSQL instances using Docker Compose, followed by logical backup, restoration and a critical evaluation of distributed and cloud database architectures.

**Case study:** Metropolitan University of Nigeria Student Registration and Result Management System (MUN-SRRMS).

**Publisher database:** `mun_srrms_dist`

**Subscriber database:** `mun_srrms_dist`

**Restore test database:** `mun_srrms_restore_test`

PostgreSQL remains the authoritative database for official student registration and results. MongoDB supports flexible profile extensions and learning activity information.

The practical replication environment uses isolated demonstration data. It does not replicate the actual Portfolio 1 database.

## 2. Verified Environment

| Component | Actual environment |
|---|---|
| Operating system | Windows 64-bit |
| Docker Engine | 29.9.2 |
| Docker Compose | 5.6.1 |
| PostgreSQL container image | postgres:16 |
| Actual container version | PostgreSQL 16.15 |
| Publisher host port | 55432 |
| Subscriber host port | 55433 |

## 3. Architecture

Two PostgreSQL instances run as separate Docker containers:

- `mun-srrms-publisher`: publishes registration-event changes.
- `mun-srrms-subscriber`: subscribes to the publication.

The publisher uses `wal_level=logical`, a dedicated replication role and a table-level publication.

The subscriber has a matching table definition and receives the published INSERT, UPDATE and DELETE operations.

The containers use separate persistent Docker volumes.

Logical replication is asynchronous in this lab. It is not physical streaming replication and does not provide automatic failover.

## 4. Prerequisites

- Docker Desktop and Docker Compose.
- At least 2 GB of available memory for the lab.
- Windows PowerShell.
- Sufficient free disk space for Docker images, volumes and backups.

The Compose file contains coursework-only demonstration credentials. Do not reuse these credentials outside the isolated lab or deploy them in production.

## 5. Start the Lab

Run from the project root:

```powershell
docker compose -f .\Portfolio5\docker-compose.yml up -d
```

Check both containers:

```powershell
docker compose -f .\Portfolio5\docker-compose.yml ps
```

Both services should report `healthy`.

Inspect initialisation logs:

```powershell
docker compose -f .\Portfolio5\docker-compose.yml logs --tail=30 publisher subscriber
```

The publisher initialisation script creates the schema, demonstration table, replication role and publication. The subscriber initialisation script creates the matching table.

## 6. Verify Publisher and Subscriber

Check publisher configuration:

```powershell
docker compose -f .\Portfolio5\docker-compose.yml exec -T publisher psql -U postgres -d mun_srrms_dist -c "SELECT current_setting('wal_level'); SELECT pubname FROM pg_publication;"
```

Check the subscriber table:

```powershell
docker compose -f .\Portfolio5\docker-compose.yml exec -T subscriber psql -U postgres -d mun_srrms_dist -c "SELECT schemaname, tablename FROM pg_tables WHERE schemaname = 'distributed_demo';"
```

## 7. Create the Logical Replication Subscription

The SQL directory is mounted at `/scripts` in the subscriber container.

Run this command once:

```powershell
docker compose -f .\Portfolio5\docker-compose.yml exec -T subscriber psql -U postgres -d mun_srrms_dist -f /scripts/02_create_subscription.sql
```

A successful execution creates the subscription and its publisher replication slot.

Do not execute the creation script a second time if the subscription already exists. Verify its status instead:

```powershell
docker compose -f .\Portfolio5\docker-compose.yml exec -T subscriber psql -U postgres -d mun_srrms_dist -c "SELECT subname, subenabled, subslotname, subpublications FROM pg_subscription;"
```

Inspect the subscriber worker:

```powershell
docker compose -f .\Portfolio5\docker-compose.yml exec -T subscriber psql -U postgres -d mun_srrms_dist -c "SELECT subname, pid, received_lsn, latest_end_lsn, latest_end_time FROM pg_stat_subscription;"
```

## 8. Replication Experiments

For meaningful evidence, execute INSERT, UPDATE and DELETE separately. After each publisher operation, query the subscriber before proceeding to the next operation.

### 8.1 INSERT

Check that event ID 2001 is initially absent:

```powershell
docker compose -f .\Portfolio5\docker-compose.yml exec -T publisher psql -U postgres -d mun_srrms_dist -c "SELECT * FROM distributed_demo.registration_events WHERE event_id = 2001;"
```

Insert on publisher:

```powershell
docker compose -f .\Portfolio5\docker-compose.yml exec -T publisher psql -U postgres -d mun_srrms_dist -c "INSERT INTO distributed_demo.registration_events(event_id, matric_number, event_type) VALUES (2001, 'MUN/DEMO/2001', 'course_registered');"
```

Verify on subscriber:

```powershell
docker compose -f .\Portfolio5\docker-compose.yml exec -T subscriber psql -U postgres -d mun_srrms_dist -c "SELECT * FROM distributed_demo.registration_events WHERE event_id = 2001;"
```

### 8.2 UPDATE

Update on publisher:

```powershell
docker compose -f .\Portfolio5\docker-compose.yml exec -T publisher psql -U postgres -d mun_srrms_dist -c "UPDATE distributed_demo.registration_events SET event_type = 'course_dropped' WHERE event_id = 2001;"
```

Verify on subscriber:

```powershell
docker compose -f .\Portfolio5\docker-compose.yml exec -T subscriber psql -U postgres -d mun_srrms_dist -c "SELECT * FROM distributed_demo.registration_events WHERE event_id = 2001;"
```

### 8.3 DELETE

Delete on publisher:

```powershell
docker compose -f .\Portfolio5\docker-compose.yml exec -T publisher psql -U postgres -d mun_srrms_dist -c "DELETE FROM distributed_demo.registration_events WHERE event_id = 2001;"
```

Verify on subscriber:

```powershell
docker compose -f .\Portfolio5\docker-compose.yml exec -T subscriber psql -U postgres -d mun_srrms_dist -c "SELECT * FROM distributed_demo.registration_events WHERE event_id = 2001;"
```

The final subscriber query should return zero rows.

Allow a short interval for asynchronous replication before verification. Do not invent or estimate a replication delay.

### 8.4 Monitoring

Publisher monitoring:

```powershell
docker compose -f .\Portfolio5\docker-compose.yml exec -T publisher psql -U postgres -d mun_srrms_dist -c "SELECT slot_name, plugin, slot_type, active FROM pg_replication_slots; SELECT application_name, state, sync_state, sent_lsn, write_lsn, flush_lsn, replay_lsn FROM pg_stat_replication;"
```

Subscriber monitoring:

```powershell
docker compose -f .\Portfolio5\docker-compose.yml exec -T subscriber psql -U postgres -d mun_srrms_dist -c "SELECT subname, subenabled FROM pg_subscription; SELECT subname, pid, received_lsn, latest_end_lsn, latest_end_time FROM pg_stat_subscription;"
```

## 9. Backup and Restore

A demonstration event is inserted before the backup so the restoration can be verified against a known record.

Publisher INSERT:

```powershell
docker compose -f .\Portfolio5\docker-compose.yml exec -T publisher psql -U postgres -d mun_srrms_dist -c "INSERT INTO distributed_demo.registration_events(event_id, matric_number, event_type) VALUES (3001, 'MUN/DEMO/3001', 'course_registered');"
```

Verify it on the subscriber before backup.

### 9.1 Create a Custom-Format Backup

Create the backup inside the publisher container:

```powershell
docker compose -f .\Portfolio5\docker-compose.yml exec -T publisher pg_dump -U postgres -d mun_srrms_dist -Fc -f /tmp/mun_srrms_dist_backup.dump
```

Inspect the archive:

```powershell
docker compose -f .\Portfolio5\docker-compose.yml exec publisher pg_restore --list /tmp/mun_srrms_dist_backup.dump
```

Create the local backup directory:

```powershell
New-Item -ItemType Directory -Force .\Portfolio5\backups
```

Copy the binary backup to Windows:

```powershell
docker cp mun-srrms-publisher:/tmp/mun_srrms_dist_backup.dump .\Portfolio5\backups\mun_srrms_dist_backup.dump
```

Use `docker cp` for binary transfer rather than ordinary PowerShell text redirection.

### 9.2 Restore into a Separate Database

Create a separate restore-test database:

```powershell
docker compose -f .\Portfolio5\docker-compose.yml exec -T publisher createdb -U postgres mun_srrms_restore_test
```

If repeating the restore experiment and the test database already exists, remove only that restore-test database before recreating it. Do not drop `mun_srrms_dist`.

Copy the backup into the publisher container:

```powershell
docker cp .\Portfolio5\backups\mun_srrms_dist_backup.dump mun-srrms-publisher:/tmp/mun_srrms_dist_backup.dump
```

Restore:

```powershell
docker compose -f .\Portfolio5\docker-compose.yml exec -T publisher pg_restore -U postgres -d mun_srrms_restore_test /tmp/mun_srrms_dist_backup.dump
```

### 9.3 Verify Restoration

Check database and row count:

```powershell
docker compose -f .\Portfolio5\docker-compose.yml exec -T publisher psql -U postgres -d mun_srrms_restore_test -P pager=off -c "SELECT current_database(), COUNT(*) AS restored_event_rows FROM distributed_demo.registration_events;"
```

Check event 3001:

```powershell
docker compose -f .\Portfolio5\docker-compose.yml exec -T publisher psql -U postgres -d mun_srrms_restore_test -P pager=off -c "SELECT * FROM distributed_demo.registration_events WHERE event_id = 3001;"
```

The supplied `05_backup_restore_checks.sql` file can be executed against the publisher by piping it from PowerShell because the `/scripts` directory is mounted in the subscriber service, not the publisher:

```powershell
Get-Content -Raw .\Portfolio5\sql\05_backup_restore_checks.sql | docker compose -f .\Portfolio5\docker-compose.yml exec -T publisher psql -U postgres -d mun_srrms_restore_test -P pager=off
```

## 10. Stop and Clean Up

Stop containers but retain database volumes:

```powershell
docker compose -f .\Portfolio5\docker-compose.yml down
```

Delete lab containers and volumes only when the lab data and final evidence are no longer required:

```powershell
docker compose -f .\Portfolio5\docker-compose.yml down -v
```

The second command permanently deletes the publisher and subscriber Docker volumes. It does not delete the backup file already copied into `Portfolio5\backups`.

## 11. Important Technical Boundaries

- The two PostgreSQL instances run on one computer, not independent sites.
- Logical replication distributes table-level row changes; it does not automatically replicate DDL.
- Logical replication is not physical streaming replication.
- Logical replication does not provide automatic failover.
- Replication is asynchronous in this lab.
- Replication slots require monitoring because retained WAL can consume publisher storage.
- The lab is not a sharded PostgreSQL cluster.
- No actual cloud deployment was conducted.
- The backup and restore test does not establish production RPO, RTO or disaster-recovery SLAs.
- The coursework credentials are demonstration-only and must not be used in production.

## 12. Evidence

Structured text transcriptions of actual terminal outputs are saved in `evidence/`. They are not raw terminal exports or screenshots. The genuine screenshots listed in `evidence/README.md` still need to be captured and added.

The local custom-format backup is stored separately in `backups/`.

The analysis in `docs/analysis-template.md` distinguishes observed experimental results from proposed production architecture and future testing.
