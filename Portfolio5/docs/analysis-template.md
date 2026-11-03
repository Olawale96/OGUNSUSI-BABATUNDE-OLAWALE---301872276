
# Portfolio 5 — Distributed and Cloud Databases: Implementation Results and Critical Analysis

## 1. Implementation Environment

| Configuration | Actual result |
|---|---|
| Operating system | Windows 64-bit |
| Docker Engine | 29.9.2 |
| Docker Compose | 5.6.1 |
| PostgreSQL container image | postgres:16 |
| Actual PostgreSQL container version | 16.15 |
| Test date | 3 November 2026 |
| Docker-reported memory | 8,170,397,696 bytes (approximately 7.61 GiB) |
| Publisher container | mun-srrms-publisher |
| Subscriber container | mun-srrms-subscriber |
| Publisher host port | 55432 |
| Subscriber host port | 55433 |

Two separate PostgreSQL 16 instances were deployed through Docker Compose. Each instance used its own persistent Docker volume.

Both containers reported a healthy status during the practical experiment.

The database lab used the isolated database `mun_srrms_dist` and did not operate on the authoritative PostgreSQL 18.6 database used in Portfolios 1 and 2.

## 2. Logical Replication Architecture

The implementation uses a PostgreSQL logical replication publisher/subscriber architecture.

The publisher contains the `distributed_demo` schema and `registration_events` table.

The subscriber contains a matching table definition. The publication and subscription distribute qualifying table changes from the publisher to the subscriber.

### 2.1 Publisher Configuration

Actual configuration observations:

| Setting | Actual value |
|---|---|
| `wal_level` | logical |
| Publication | mun_srrms_events_pub |
| Publication scope | Specific table |
| Replication role | repl_user |
| Replication permission | Enabled |
| Published table | distributed_demo.registration_events |

The `repl_user` role was created with LOGIN and REPLICATION privileges. CONNECT, schema USAGE and table SELECT privileges were granted.

The publication was created specifically for the demonstration registration-events table rather than for every table in the database.

### 2.2 Subscriber Configuration

The subscriber contained the matching `distributed_demo.registration_events` table.

The subscription was created using:

`mun_srrms_events_sub`

The subscription referenced:

`mun_srrms_events_pub`

The subscription was enabled, and automatic creation of the publisher replication slot succeeded.

The subscription creation output included:

`CREATE SUBSCRIPTION`

The replication slot created on the publisher was:

`mun_srrms_events_sub`

## 3. Replication Monitoring Results

The publisher and subscriber monitoring queries verified the state of the logical replication connection.

### 3.1 Actual Publisher Statistics

| Metric | Observed value |
|---|---|
| Replication slot | mun_srrms_events_sub |
| Logical output plugin | pgoutput |
| Slot type | logical |
| Slot active | true |
| Application name | mun_srrms_events_sub |
| Connection state | streaming |
| Synchronisation mode | async |

The publisher reported the following WAL positions:

| Position | Actual LSN |
|---|---|
| sent_lsn | 0/196E690 |
| write_lsn | 0/196E690 |
| flush_lsn | 0/196E690 |
| replay_lsn | 0/196E690 |

### 3.2 Actual Subscriber Statistics

The subscription was enabled.

The subscriber worker was observed with PID 390.

Its initial verification returned:

- received_lsn: 0/196E1E0
- latest_end_lsn: 0/196E1E0

A subsequent monitoring query returned:

- received_lsn: 0/196E690
- latest_end_lsn: 0/196E690

The matching publisher and subscriber LSN observations indicate that the subscriber had caught up to the publisher's reported WAL position at that observation time.

No quantitative replication-lag benchmark was conducted.

## 4. Replication Experiments

Three data-manipulation experiments were conducted against the publisher, with corresponding verification queries on the subscriber.

### 4.1 INSERT Replication

The demonstration event used:

| Field | Value |
|---|---|
| Event ID | 2001 |
| Matriculation number | MUN/DEMO/2001 |
| Initial event type | course_registered |

A preliminary publisher query returned zero rows for event ID 2001.

The publisher INSERT returned:

`INSERT 0 1`

The subscriber subsequently returned the event with the expected matriculation number and event type.

**Result:** INSERT replication succeeded.

A second attempt to insert event ID 2001 was rejected by the publisher's primary-key constraint. This was expected database behaviour and did not create a duplicate record.

### 4.2 UPDATE Replication

The publisher changed the event type from `course_registered` to `course_dropped`.

Actual publisher result:

`UPDATE 1`

The subsequent subscriber query returned:

| Field | Subscriber value |
|---|---|
| Event ID | 2001 |
| Matriculation number | MUN/DEMO/2001 |
| Event type | course_dropped |

The original event timestamp remained unchanged because the update statement modified only the event type.

**Result:** UPDATE replication succeeded.

### 4.3 DELETE Replication

The publisher deleted event ID 2001.

Actual publisher result:

`DELETE 1`

The subsequent subscriber query returned zero rows for event ID 2001.

**Result:** DELETE replication succeeded.

### 4.4 Replication Assessment

All three operations were successfully distributed from the publisher to the subscriber.

The practical work demonstrates table-level logical replication using PostgreSQL's publication/subscription architecture.

The connection was asynchronous. The publisher did not require subscriber acknowledgement before completing each transaction.

Although the subscriber caught up to the observed publisher WAL position, no controlled replication-delay measurement was performed.

## 5. Backup and Restoration Results

The practical exercise used PostgreSQL's custom-format logical backup.

### 5.1 Backup Creation

The source database was:

`mun_srrms_dist`

The backup command used:

`pg_dump -U postgres -d mun_srrms_dist -Fc`

The backup file was:

`mun_srrms_dist_backup.dump`

The backup was created inside the publisher container and subsequently copied to the Windows project directory using `docker cp`.

Actual Windows backup file size:

3,634 bytes.

The archive was inspected using `pg_restore --list`.

Actual archive characteristics:

| Attribute | Observed result |
|---|---|
| Format | CUSTOM |
| Compression | gzip |
| Dumped from PostgreSQL | 16.15 |
| Dumped by pg_dump | 16.15 |
| TOC entries | 13 |

The archive listing identified the demonstration schema, table, table data, primary-key constraint, publication and publication-table association.

Before the backup, demonstration event 3001 was inserted into the publisher and its successful replication was verified on the subscriber.

### 5.2 Restoration

A separate database was created:

`mun_srrms_restore_test`

The backup was restored using `pg_restore`.

The restoration command completed without reported errors.

### 5.3 Actual Restoration Verification

The verification query returned:

| Attribute | Actual result |
|---|---|
| Current database | mun_srrms_restore_test |
| Restored event count | 1 |
| Event ID | 3001 |
| Matriculation number | MUN/DEMO/3001 |
| Event type | course_registered |

The restored database also contained the expected integrity constraints:

- `registration_events_pkey`: PRIMARY KEY (event_id).
- `registration_events_event_type_check`: CHECK constraint restricting permitted event types.

The supplied backup/restore verification SQL was also executed against the restored database and returned one restored event row.

### 5.4 Backup and Recovery Assessment

The experiment demonstrates that a PostgreSQL custom-format logical backup can be created, transferred, inspected and restored into a separate database.

The restoration preserved the demonstration table data and its integrity constraints.

However, this does not demonstrate point-in-time recovery, continuous WAL archiving, automatic disaster recovery, independent-site recovery or a production recovery-time objective.

No measured restoration duration or data-loss window was recorded.

## 6. Logical Replication Versus Physical Streaming Replication

Logical replication and physical streaming replication solve different architectural problems.

Logical replication publishes selected table-level changes to subscribers. It is appropriate for selective data distribution, data integration, migrations and workloads requiring particular tables to be shared between databases.

Physical streaming replication transfers WAL records to a physical standby. The standby maintains a physical copy of the primary database and is commonly used for high availability, read-only access and recovery.

The Portfolio 5 laboratory implements logical replication only.

It does not implement a physical streaming standby or an automatic failover manager.

The difference matters because a logical subscriber is not automatically ready to replace the publisher as a complete primary database. Schema changes are not automatically replicated, and unreplicated database objects, sequences or other operational dependencies require separate management.

## 7. High Availability Design for MUN-SRRMS

Official enrolment and result records require strong consistency and controlled transaction processing.

A suitable production design would use:

- A managed or self-managed PostgreSQL primary.
- A synchronous standby in a separate failure domain where the latency and availability trade-offs are acceptable.
- An additional asynchronous replica where geographically separated recovery is required.
- Automated health monitoring and carefully controlled failover procedures.
- Regular base backups and WAL archiving.
- Point-in-time recovery and periodic restore testing.
- Defined access-control, auditing and operational incident procedures.

Synchronous replication can reduce the risk of acknowledged transactions being lost during a primary failure, depending on the configured acknowledgement policy.

However, synchronous replication can increase commit latency and can affect write availability when the required standby is unavailable.

Asynchronous replication generally allows the primary to commit without waiting for subscriber acknowledgement, but acknowledged changes may not yet have reached the replica at failure time.

The correct choice depends on business-impact analysis, failure scenarios and institutionally approved recovery objectives.

## 8. Sharding Strategy

Sharding horizontally distributes data across multiple database nodes.

For a future MUN-SRRMS deployment, a high-volume student-learning-activity workload could be partitioned using a stable student identifier.

A candidate shard key could be:

`hashed student_id`

This distributes records across shards more evenly than a simple monotonically increasing identifier.

However, the final key must be selected using actual query patterns, data distribution and uniqueness requirements.

For example, student-centred activity queries should ideally target a single shard. Queries across all students or multiple departments may require distributed aggregation and additional network communication.

Time-based partitioning may also be appropriate for historical activity events, particularly when older records require archival or retention management.

Core enrolment and result data should not be sharded prematurely. Cross-shard joins, transactions, uniqueness and operational administration may introduce complexity that outweighs the expected benefits.

The Portfolio 5 practical work does not implement a sharded PostgreSQL cluster.

## 9. CAP and Consistency Considerations

The CAP theorem concerns the trade-off between consistency and availability during network partitions in distributed systems.

It should not be simplified into a permanent choice of two properties under every operating condition.

For official student registration and results, MUN-SRRMS should prioritise data correctness.

During a network partition, the system should not accept conflicting enrolment or result updates from independently writable nodes without appropriate coordination.

Non-critical features such as notification preferences, profile displays and cached learning dashboards may tolerate temporary staleness.

These updates can be reconciled through controlled synchronisation mechanisms.

The architecture should therefore apply consistency requirements according to the business criticality of each workload.

## 10. MongoDB Distribution and Cloud Architecture

The Portfolio 4 MongoDB implementation used a standalone local MongoDB service.

This does not constitute a replica set or a sharded cluster.

A production MongoDB deployment requiring availability would normally use a replica set with multiple members and controlled primary election.

Sharding could be introduced for collections with demonstrated data-volume or throughput requirements. In a standard sharded MongoDB deployment, shards are normally deployed as replica sets, with query routing through `mongos` and metadata managed by config servers.

For cloud deployment, MUN-SRRMS could use a managed PostgreSQL service with multi-zone standby, automated backups and point-in-time recovery.

MongoDB profile services could use MongoDB Atlas or an equivalent managed database service.

Both services should be deployed using private networking where available, TLS, least-privilege identities, secrets management, audit logging, backup policies and continuous monitoring.

The application tier should use service interfaces rather than allowing unrestricted client access to database instances.

No actual cloud deployment was conducted as part of this portfolio.

## 11. Proposed RPO and RTO Objectives

Recovery Point Objective (RPO) defines the maximum acceptable period of data loss, expressed in time.

Recovery Time Objective (RTO) defines the maximum acceptable time required to restore a service after disruption.

The following are proposed design objectives for discussion, not institutionally approved requirements or experimentally measured results.

| Workload | Proposed RPO | Proposed RTO |
|---|---|---|
| Official enrolments and results | Up to 1 minute | Up to 60 minutes |
| Student profile preferences | Up to 15 minutes | Up to 4 hours |
| Learning activity summaries | Up to 30 minutes | Up to 8 hours |

The institution should approve final targets through a business-impact analysis involving academic operations, IT management, security, finance and relevant stakeholders.

Recovery design must be tested against the selected targets through timed backup restoration, WAL recovery, failover exercises and monitoring.

These proposed values must not be presented as demonstrated performance of the local Docker environment.

## 12. Cloud Versus Self-Managed Database Evaluation

| Criterion | Self-managed database | Managed cloud database |
|---|---|---|
| Infrastructure control | Greater control | More provider-managed |
| Maintenance | Institutional responsibility | Shared with provider |
| Scaling | Requires internal planning and capacity | Often offers managed scaling options |
| High availability | Must be designed and maintained | Commonly supported through managed configurations |
| Backup administration | Institution manages backup infrastructure | Provider tooling may simplify backup management |
| Cost | Hardware, licences/support and staff | Consumption and service charges |
| Data residency | Direct infrastructure control | Depends on region and provider arrangements |
| Vendor lock-in | Lower provider dependence | Potentially higher |
| Operational skills | Greater internal DBA workload | Requires cloud service and vendor-specific knowledge |

Managed cloud services can reduce infrastructure administration and improve access to managed availability features.

However, they introduce considerations around service cost, data residency, provider dependence, connectivity, security configuration and contractual obligations.

A Nigerian university should verify applicable data-protection obligations and institutional policy before selecting deployment regions and service providers.

## 13. Security and Operational Considerations

The local replication environment uses coursework demonstration credentials contained in the Compose configuration.

These are local laboratory credentials and must not be reused in a production deployment.

A production deployment should introduce:

- Strong authentication and credential rotation.
- Secrets management rather than passwords embedded in configuration files.
- Least-privilege replication and application accounts.
- TLS-protected inter-database communication.
- Network restrictions and private database endpoints.
- Database activity monitoring and audit logging.
- Encrypted backups and controlled restoration permissions.
- Monitoring for replication-slot growth, lag and disconnected subscribers.
- Documented operational incident and recovery procedures.

Replication slots require particular attention because an inactive subscriber can prevent required WAL segments from being recycled, creating storage pressure on the publisher.

Operational monitoring should include replication-slot status, retained WAL and subscriber health.

## 14. Limitations

The practical environment ran two PostgreSQL 16 containers on one physical computer.

The publisher and subscriber therefore do not represent independent sites or independent physical failure domains.

The demonstration used a small registration-events table and a limited number of test records.

No production load test, controlled replication-lag benchmark or throughput measurement was conducted.

The laboratory implemented logical replication, not physical streaming replication.

No automatic failover, point-in-time recovery test, sharded cluster or managed cloud deployment was implemented.

The backup and restore experiment verified one successful logical restoration but did not establish disaster-recovery service levels.

These limitations define the boundary between the practical implementation and the proposed production architecture.

## 15. Technical Reflection

The laboratory provided practical experience in configuring PostgreSQL logical replication, creating a publication and subscription, monitoring a replication slot and verifying data distribution between independent database instances.

The INSERT, UPDATE and DELETE experiments demonstrated that publisher-side table changes were applied to the subscriber.

The monitoring results exposed the asynchronous nature of the connection and the use of WAL positions to observe replication progress.

The backup and restore experiment demonstrated that a custom-format database backup could be copied and successfully restored into a separate database, preserving the demonstration record and important constraints.

The practical work also highlighted operational issues that are not immediately visible in a single-database design, including replication-slot retention, asynchronous data visibility, DDL coordination, security, network failure and recovery planning.

For production MUN-SRRMS, the first priority should be to establish a resilient authoritative PostgreSQL architecture for enrolments and results, with tested backup and standby recovery procedures.

Logical replication should be introduced where selective data distribution or integration provides a clear operational benefit.

MongoDB can continue to support flexible profile extensions and learning activity summaries, provided that the PostgreSQL source of truth and cross-database synchronisation rules remain explicit.

## 16. Conclusion

Portfolio 5 successfully demonstrated a distributed PostgreSQL publisher/subscriber environment using Docker Compose.

The local implementation verified PostgreSQL logical replication through INSERT, UPDATE and DELETE operations, subscription monitoring and replication-slot inspection.

It also demonstrated custom-format logical backup, archive inspection and successful restoration into a separate database.

The architecture evaluation distinguished logical replication from physical standby replication, examined sharding strategies, discussed CAP-related consistency decisions and proposed a cloud-based deployment approach.

The practical results establish functional replication and restoration in a controlled local environment. They do not establish production-scale availability, automatic failover, independent-site disaster recovery, cloud performance or approved institutional recovery objectives.

The resulting architecture provides a technically grounded foundation for future MUN-SRRMS distributed and cloud database deployment.
