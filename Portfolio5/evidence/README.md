# Portfolio 5 — Evidence Register

Case study: Metropolitan University of Nigeria Student Registration and Result Management System (MUN-SRRMS).

## 1. Saved experimental evidence

| File | Description | Status |
|---|---|---|
| 01_docker_environment.txt | Docker containers, PostgreSQL initialisation and publisher configuration | Saved |
| 02_subscription_monitoring.txt | Logical publication, subscription, replication slot and worker monitoring | Saved |
| 03_dml_replication.txt | INSERT, UPDATE and DELETE replication observations | Saved |
| 04_backup_creation.txt | Custom-format pg_dump, archive inspection and file copy | Saved |
| 05_restore_verification.txt | Restore database, restored event and constraints | Saved |
| 06_environment_and_limitations.txt | Environment versions, Docker resources and limitations | Saved |

The text files are structured transcriptions of actual terminal
outputs. They are not raw terminal exports or screenshots.

## 2. Screenshots still required

- [ ] Docker Compose startup and both healthy containers.
- [ ] Publisher publication and replication-role configuration.
- [ ] Subscriber table and subscription creation.
- [ ] Subscription worker and replication-slot monitoring.
- [ ] Publisher INSERT and subscriber verification.
- [ ] Publisher UPDATE and subscriber verification.
- [ ] Publisher DELETE and subscriber verification.
- [ ] pg_dump completion and backup file size.
- [ ] Backup archive listing.
- [ ] pg_restore execution.
- [ ] Restored row count and event 3001.
- [ ] Restored primary-key and CHECK constraints.

## 3. Evidence integrity

- Capture genuine Docker and PostgreSQL terminal outputs.
- Show the relevant commands and corresponding results.
- Do not expose credentials or connection secrets.
- Do not invent replication delay, throughput, RPO, RTO or recovery-time measurements.
- Keep the backup file separately in the backups folder.
- Retain the Docker volumes until all required evidence is captured.

## 4. Experimental limitations

Both PostgreSQL instances ran on one computer.
The experiment used a small demonstration table.
No production load benchmark was conducted.
No measured replication-lag benchmark was conducted.
No physical standby failover was tested.
No independent-site disaster recovery was tested.
No sharded cluster or actual cloud deployment was created.

Logical replication is not physical streaming replication
and does not provide automatic failover.
