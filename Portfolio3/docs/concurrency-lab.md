# Two-session concurrency laboratory

## Preparation
1. For Experiments 1 and 2, open two independent PostgreSQL sessions connected to `mun_srrms`. For Experiment 3, reconnect both sessions to `mun_srrms_perf` before selecting the test registration pair and running the concurrent inserts.
2. Run `sql/02_isolation_setup.sql` once.
3. In both sessions, use fully qualified table names as shown below.
4. Execute the steps in the stated order. Do not run both sessions' statements as one batch.

## Experiment 1 — READ COMMITTED and a concurrent update

**Session A**
```sql
BEGIN;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT counter_value
FROM mun_srrms.transaction_demo_counter
WHERE counter_id = 1;
-- Leave this transaction open.
```

**Session B**
```sql
BEGIN;
UPDATE mun_srrms.transaction_demo_counter
SET counter_value = counter_value + 10
WHERE counter_id = 1;
COMMIT;
```

**Back in Session A**
```sql
SELECT counter_value
FROM mun_srrms.transaction_demo_counter
WHERE counter_id = 1;
COMMIT;
```

Expected principle: under PostgreSQL READ COMMITTED, each statement sees a snapshot taken at the start of that statement. Session A's second SELECT can therefore see Session B's committed update. Record the two values you actually observe.

## Experiment 2 — REPEATABLE READ snapshot

Reset the counter by running `sql/02_isolation_setup.sql` after both sessions have committed.

**Session A**
```sql
BEGIN;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT counter_value
FROM mun_srrms.transaction_demo_counter
WHERE counter_id = 1;
-- Keep this transaction open.
```

**Session B**
```sql
BEGIN;
UPDATE mun_srrms.transaction_demo_counter
SET counter_value = counter_value + 10
WHERE counter_id = 1;
COMMIT;
```

**Back in Session A**
```sql
SELECT counter_value
FROM mun_srrms.transaction_demo_counter
WHERE counter_id = 1;
COMMIT;
```

Expected principle: Session A continues to see its transaction snapshot, so its second SELECT should show the same value as its first SELECT, despite Session B's commit. Record your actual output.

## Experiment 3 — concurrent duplicate registration protection
**Important database separation:** Conduct this experiment in `mun_srrms_perf`, not the original `mun_srrms` database. Both sessions must be connected to `mun_srrms_perf`. Select and verify an available student/offering pair in that database before inserting.

Portfolio 1 defines `UNIQUE (student_id, offering_id)` on `mun_srrms.enrolment`. This prevents duplicate registrations at database level. Choose an existing valid student and offering pair that is not already enrolled. Obtain IDs with:

```sql
SELECT student_id, matric_number
FROM mun_srrms.student
ORDER BY student_id
LIMIT 10;

SELECT offering_id, course_id, semester_id, section_code
FROM mun_srrms.course_offering
ORDER BY offering_id
LIMIT 10;

SELECT e.student_id, e.offering_id
FROM mun_srrms.enrolment e
ORDER BY e.student_id, e.offering_id;
```

Use a pair confirmed absent from the final query. Replace `STUDENT_ID` and `OFFERING_ID` with actual integer IDs.

**Session A**
```sql
BEGIN;
INSERT INTO mun_srrms.enrolment(student_id, offering_id)
VALUES (STUDENT_ID, OFFERING_ID);
-- Do not commit yet.
```

**Session B**
```sql
BEGIN;
INSERT INTO mun_srrms.enrolment(student_id, offering_id)
VALUES (STUDENT_ID, OFFERING_ID);
-- This statement should wait while Session A holds the conflicting
-- uncommitted unique-key entry.
```

**Session A**
```sql
COMMIT;
```

Session B should then fail with a unique-constraint violation. Roll back Session B:
```sql
ROLLBACK;
```

Verify that only one row exists:
```sql
SELECT student_id, offering_id, COUNT(*)
FROM mun_srrms.enrolment
WHERE student_id = STUDENT_ID
  AND offering_id = OFFERING_ID
GROUP BY student_id, offering_id;
```

Use literal numeric IDs in place of the placeholders. If the chosen pair is already enrolled, choose another pair. Do not delete real enrolments to make the test work.

## Interpretation
Explain:
- why READ COMMITTED can show a newer value on a later statement;
- why REPEATABLE READ retains a stable transaction snapshot;
- why the unique constraint is safer than relying only on an application-side “check then insert”;
- what the user-facing registration system should do when a duplicate registration is rejected.

## Cleanup
The demo counter can be reset by rerunning `sql/02_isolation_setup.sql`. If you want to remove only the demo objects after completing the portfolio:
```sql
DROP TABLE IF EXISTS mun_srrms.transaction_demo_counter;
DROP TABLE IF EXISTS mun_srrms.transaction_demo_log;
```
Do not drop or truncate the operational tables.
