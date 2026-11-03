# Portfolio 5 — Distributed and Cloud Database Architecture

## 1. Proposed architecture
For MUN-SRRMS, PostgreSQL is the authoritative store for student identity, course registration, enrolment and official results. MongoDB stores flexible profile extensions and learning activity. The application accesses each through service interfaces rather than allowing uncontrolled direct writes from clients.

A production design can use:
- Managed PostgreSQL primary with synchronous or appropriately configured standby replicas for critical transactional workloads.
- Read replicas for read-heavy reporting, with explicit awareness of replication lag.
- MongoDB replica set for redundancy; sharding only when data volume and throughput justify operational complexity.
- Backups, point-in-time recovery, tested restore procedures and a separate disaster-recovery location.
- Private networking, TLS, least-privilege identities, secrets management, audit logs and monitoring.

## 2. Replication terminology
**Physical streaming replication:** PostgreSQL ships WAL records to a physical standby. It is used for high availability and read-only standby use. Synchronous replication can reduce acknowledged-commit data loss at the cost of write latency/availability dependencies; asynchronous replication can have non-zero data loss if the primary fails before WAL reaches the standby.

**Logical replication:** PostgreSQL publishes table-level row changes to subscribers. It is useful for selective data distribution, integration and upgrades. It does not replicate DDL automatically, and it is not a complete HA failover solution. The practical lab implements logical replication.

## 3. Sharding strategy
Sharding distributes data horizontally across multiple database nodes. For a university, possible shard keys include:
- `student_id` or a stable hashed student identifier for student-centred activity;
- `department_id` for department-scoped workloads, if access patterns are strongly department-local;
- time-based partitioning for high-volume activity/event records.

A good shard key distributes writes and keeps common queries targeted. A poor shard key can create hotspots or scatter-gather queries. Avoid sharding core enrolment/results prematurely: cross-shard joins, transactions, uniqueness and operational complexity can outweigh the benefits. PostgreSQL table partitioning is not the same as a distributed sharding cluster.

## 4. CAP and consistency
During a network partition, a distributed system cannot guarantee both strong consistency and full availability for all operations. For official registration and results, the university should prioritise correctness: avoid accepting conflicting enrolment or result updates when authoritative coordination is unavailable. Some non-critical services, such as profile preferences or cached dashboards, may tolerate temporary staleness and reconcile later.

Do not oversimplify CAP as a permanent choice of only two properties in all conditions. The trade-off is specifically exposed during partitions, and real systems make operation-specific choices.

## 5. MongoDB distribution
A MongoDB replica set maintains multiple copies of the same dataset and elects a primary. Sharding distributes collections across shards, normally with each shard deployed as a replica set and routing handled by `mongos` with config servers. Shard-key selection affects balancing and query targeting. The local Portfolio 4 standalone MongoDB exercise does not constitute a replica set or sharded deployment.

## 6. Cloud deployment plan
A managed service design could use a managed PostgreSQL service with multi-zone standby, automated backups and point-in-time recovery, plus MongoDB Atlas or an equivalent managed MongoDB service. The application tier should run in private subnets/VPC networking. Use TLS, private endpoints where available, role-based access, secrets vault, central logs, metrics and alerting.

Do not claim an actual cloud deployment unless you create it and capture evidence. Include cost, data residency, vendor lock-in, connectivity, backup retention and recovery objectives in the evaluation.

## 7. Backup and recovery
A backup is only useful if it can be restored. The lab uses `pg_dump -Fc` and `pg_restore` to restore into a separate test database. A production plan should combine automated base backups/WAL archiving or managed point-in-time recovery, encrypted off-site copies, retention policy, access controls and scheduled restore drills.

Define:
- **RPO:** maximum acceptable amount of data loss measured in time.
- **RTO:** maximum acceptable time to restore service.
Set targets based on university business impact and obtain institutional approval; do not invent official targets.

## 8. Evaluation
Compare:
- synchronous versus asynchronous replication;
- primary/standby versus read replicas;
- logical replication versus physical replication;
- replica sets versus sharding;
- local self-managed versus managed cloud databases.

Include the local lab's actual observed replication delay only if measured. The two containers share one host, so they do not prove site-level fault tolerance.

## 9. Reflection
Explain what the lab demonstrated, what it did not demonstrate, the operational skills required for a distributed deployment, and what you would implement first if MUN-SRRMS moved into production.
