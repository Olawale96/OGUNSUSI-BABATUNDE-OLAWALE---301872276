
# Portfolio 3 — Transaction Processing and Concurrency Control: Results and Technical Analysis

## 1. Test Environment

| Configuration | Actual environment |
|---|---|
| Operating system | Windows 64-bit |
| DBMS | PostgreSQL 18.6 |
| Database client | psql command-line client |
| Database schema | mun_srrms |
| Transaction and isolation database | mun_srrms |
| Concurrent registration database | mun_srrms_perf |
| Test period | 31 October – 2 November 2026 |
| Database sessions | Two independent PostgreSQL sessions |

Two databases were used to separate the transaction-isolation demonstrations from the concurrent registration experiment.

The transaction-control and isolation experiments used dedicated demonstration tables in the original mun_srrms database. The concurrent duplicate-registration experiment used the separate mun_srrms_perf database to avoid modifying the original university registration records.

## 2. Transaction Control Results

The transaction examples were executed using the dedicated transaction_demo_log table.

### 2.1 COMMIT

A transaction was started, and a demonstration record was inserted.

The transaction completed successfully using COMMIT.

Actual PostgreSQL output:

- BEGIN
- INSERT 0 1
- COMMIT

The subsequent SELECT returned the committed record:

| demo_id | Event description |
|---:|---|
| 1 | Portfolio 3: committed transaction |

**Result:** The inserted record remained visible after the transaction committed.

### 2.2 ROLLBACK

A second transaction inserted a demonstration record but was explicitly rolled back.

Actual PostgreSQL output:

- BEGIN
- INSERT 0 1
- ROLLBACK

The subsequent SELECT returned zero rows for the rolled-back event.

**Result:** The uncommitted insertion was discarded.

### 2.3 SAVEPOINT

A transaction was used to demonstrate partial rollback.

The following operations were performed:

1. Insert a record before the savepoint.
2. Create SAVEPOINT before_optional_action.
3. Insert an optional demonstration record.
4. Execute ROLLBACK TO SAVEPOINT.
5. Insert another record after the savepoint.
6. Commit the transaction.

The actual output contained the following retained records:

| demo_id | Event description |
|---:|---|
| 3 | Portfolio 3: retained before savepoint |
| 5 | Portfolio 3: retained after savepoint |

The optional action associated with demo_id 4 was absent.

**Result:** Changes before the savepoint were retained, the optional insertion was undone, and the transaction committed successfully.

An important observation was that the identity sequence contained gaps. PostgreSQL identity sequences are not rolled back when a transaction or savepoint is rolled back. These gaps do not indicate that transaction atomicity failed.

### 2.4 Transaction Control Assessment

The results demonstrate practical transaction control through COMMIT, ROLLBACK and SAVEPOINT.

They show how PostgreSQL allows related database operations to be committed as a unit or partially reversed before the final transaction is completed.

## 3. Transaction Isolation Results

Two independent PostgreSQL sessions were used to examine concurrent updates to:

mun_srrms.transaction_demo_counter

The initial counter value was 100.

### 3.1 READ COMMITTED

Session A began a transaction using READ COMMITTED and retrieved the counter value.

Session B subsequently incremented the counter by 10 and committed.

Session A then executed another SELECT before committing its own transaction.

Actual observations:

| Operation | Observed value |
|---|---:|
| Session A first SELECT | 100 |
| Session B update | +10 |
| Session B committed value | 110 |
| Session A second SELECT | 110 |

Both sessions completed their transactions successfully.

**Interpretation:**

PostgreSQL READ COMMITTED uses a new statement-level snapshot for each SQL statement.

Consequently, Session A could see the committed update from Session B when it executed the second SELECT, even though Session A's transaction had started earlier.

This demonstrates that successive queries within the same READ COMMITTED transaction can observe different committed database states.

### 3.2 REPEATABLE READ

Before the second experiment, the counter was reset to 100.

Session A began a transaction using REPEATABLE READ and retrieved the initial value.

Session B then incremented the counter by 10 and committed.

Session A executed another SELECT before committing its transaction.

Actual observations:

| Operation | Observed value |
|---|---:|
| Session A first SELECT | 100 |
| Session B update | +10 |
| Session B committed value | 110 |
| Session A second SELECT | 100 |
| Fresh read after Session A committed | 110 |

Both transactions completed successfully.

**Interpretation:**

PostgreSQL REPEATABLE READ maintains a consistent transaction snapshot.

Session A continued seeing the original value of 100 even after Session B committed the new value of 110.

After Session A committed, a fresh database read returned 110.

This demonstrates the difference between statement-level snapshots under READ COMMITTED and transaction-level snapshot consistency under REPEATABLE READ.

### 3.3 Comparison of Isolation Levels

| Characteristic | READ COMMITTED | REPEATABLE READ |
|---|---|---|
| Initial value | 100 | 100 |
| Concurrent committed update | 110 | 110 |
| Second read in Session A | 110 | 100 |
| Snapshot behaviour | New snapshot per statement | Stable transaction snapshot |
| Transaction completion | Successful | Successful |

The experiment demonstrates the practical importance of selecting an isolation level according to the consistency requirements of a database operation.

SERIALIZABLE was not experimentally tested in this exercise, and no claim is made that it was executed.

## 4. Concurrent Duplicate Registration Test

The third experiment investigated whether PostgreSQL could prevent duplicate course registrations when two users attempted the same operation concurrently.

The experiment was conducted in mun_srrms_perf.

### 4.1 Test Data

| Attribute | Actual value |
|---|---|
| Student ID | 2 |
| Matriculation number | MUN/2026/0002 |
| Offering ID | 2 |
| Course code | MIT8102 |
| Database | mun_srrms_perf |

A preliminary query confirmed that this student and course-offering combination did not already exist.

### 4.2 Session A

Session A began a transaction and inserted the registration.

Actual result:

```text
BEGIN
INSERT 0 1
```

The transaction remained open without an immediate commit.

### 4.3 Session B

Session B attempted to insert the same student and offering combination.

The INSERT statement waited while PostgreSQL resolved the conflicting uncommitted unique-key entry held by Session A.

Session A subsequently executed COMMIT.

Session B then returned the following error:

```text
ERROR: duplicate key value violates unique constraint
"enrolment_student_offering_unique"

DETAIL:
Key (student_id, offering_id)=(2, 2) already exists.
```

Session B was rolled back successfully.

### 4.4 Final Verification

The final verification query returned:

| student_id | offering_id | registration_count |
|---:|---:|---:|
| 2 | 2 | 1 |

The integrity-check script also confirmed:

- The enrolment_student_offering_unique constraint existed.
- No duplicate student/offering combinations were found.
- Registration counts were consistent with the committed test insertion.

### 4.5 Demonstration Cleanup

After collecting the experimental results, the demonstration registration was removed from mun_srrms_perf.

Post-cleanup verification returned:

```text
DELETE 1

count
-------
40004
```

The performance database therefore returned to its original enrolment count.

The original mun_srrms registration records were not modified by this experiment.

### 4.6 Concurrency Control Assessment

This experiment demonstrates the effectiveness of database-level uniqueness enforcement under concurrent access.

An application-side check alone cannot guarantee uniqueness because two users may both pass the availability check before either registration is committed.

The UNIQUE constraint provides database-level protection, ensuring that only one transaction can successfully commit the same student/offering combination.

A user-facing registration system should catch the unique-constraint violation, roll back the failed transaction and display a clear message indicating that the student is already registered for the course.

## 5. ACID Properties Assessment

### 5.1 Atomicity

Atomicity was demonstrated through ROLLBACK and SAVEPOINT operations.

The rolled-back insertion did not remain in the database, while the operations retained before and after the savepoint were committed successfully.

This demonstrates PostgreSQL's ability to treat transaction operations as a unit and selectively undo operations before final commit.

### 5.2 Consistency

Consistency was demonstrated through PostgreSQL integrity constraints.

The enrolment table enforced the UNIQUE constraint on student_id and offering_id.

The counter demonstration table also contained a CHECK constraint requiring counter_value to be non-negative.

The concurrent duplicate-registration experiment demonstrated that the database rejected an operation that would have violated an integrity constraint.

The CHECK constraint was inspected as part of the implementation but was not separately tested with an invalid negative counter value.

### 5.3 Isolation

Isolation was evaluated through two independent PostgreSQL sessions.

READ COMMITTED allowed Session A to observe another transaction's committed update on a subsequent statement.

REPEATABLE READ maintained Session A's original snapshot until its transaction completed.

The concurrent registration experiment additionally demonstrated that PostgreSQL coordinates conflicting unique-key operations across simultaneous transactions.

### 5.4 Durability

Durability was demonstrated through committed transaction results remaining visible after COMMIT.

The concurrent registration experiment provided additional evidence because Session A's committed registration was subsequently observed through another database session, even after Session B's duplicate operation failed.

A database restart or simulated crash-recovery experiment was not performed. Therefore, durability across restart or hardware failure was not independently tested.

## 6. Limitations and Recommendations

### 6.1 Experimental Environment

The experiments were conducted using PostgreSQL on a local Windows computer.

Although two independent database sessions were used, the results do not establish production-level transaction throughput, response times or performance under a large number of concurrent users.

Further tests should investigate workloads involving substantially more sessions and transactions.

### 6.2 Isolation-Level Coverage

The practical experiments covered READ COMMITTED and REPEATABLE READ.

SERIALIZABLE was not tested.

A future experiment should investigate serializable transaction execution, including the possibility of serialization failures and the need for transaction retries.

### 6.3 Registration Capacity Enforcement

The UNIQUE constraint prevents duplicate student/course-offering registrations, but it does not independently enforce course capacity.

A production registration workflow should implement capacity allocation within a properly controlled transaction.

For example, the system could lock the relevant course-offering record using SELECT FOR UPDATE or use an atomic conditional UPDATE that permits registration only while capacity remains available.

A simple application-side count followed by an INSERT may produce a race condition when several students attempt to register for the final available places simultaneously.

### 6.4 Deadlocks and Lock Management

This exercise demonstrated transaction blocking during concurrent unique-key insertion.

However, a deliberate deadlock scenario was not executed.

A more comprehensive implementation should investigate row-level locking, lock waits, deadlock detection and transaction recovery.

Applications should also implement bounded retries for appropriate deadlock and serialization-failure conditions.

### 6.5 Application Error Handling

The duplicate-registration experiment returned a PostgreSQL unique-constraint violation.

A production system should translate this technical error into a meaningful message for the student rather than expose raw database errors.

The failed transaction must be rolled back before the application continues using that database session.

### 6.6 Data Isolation and Test Safety

Dedicated demonstration tables were used for transaction and isolation tests. The duplicate-registration experiment was carried out in the separate performance database.

This approach limited the risk of changing existing academic records and allowed the demonstration data to be cleaned up independently.

## 7. Evidence Index

The following evidence should accompany this analysis.

| Evidence | Description | Claim supported |
|---|---|---|
| Transaction examples output | COMMIT, ROLLBACK and SAVEPOINT results | Transaction control behaviour |
| Isolation setup output | Counter table initialised to 100 | Test environment preparation |
| READ COMMITTED Session A output | First value 100 and second value 110 | Statement-level snapshots |
| READ COMMITTED Session B output | UPDATE 1 and COMMIT | Successful concurrent update |
| REPEATABLE READ Session A output | Repeated observation of 100 | Stable transaction snapshot |
| REPEATABLE READ Session B output | UPDATE 1 and COMMIT | Concurrent update was committed |
| Fresh counter read | Value 110 | Committed value visible to a fresh read |
| Duplicate registration Session A output | INSERT 0 1 and COMMIT | First registration committed |
| Duplicate registration Session B output | Unique-constraint violation | Duplicate insertion rejected |
| Final registration count | One matching registration | Database-level uniqueness |
| Integrity-check output | Unique constraint present and zero duplicate groups | Referential and uniqueness verification |
| Cleanup output | DELETE 1 and final count 40,004 | Removal of demonstration registration |

All results in this analysis are based on the actual PostgreSQL executions reported during the experiment. No SERIALIZABLE, deadlock or database-restart experiment is claimed.

## 8. Conclusion

Portfolio 3 provided practical experience in PostgreSQL transaction processing, rollback mechanisms, transaction isolation and concurrency control.

COMMIT, ROLLBACK and SAVEPOINT were successfully demonstrated using a dedicated transaction log table.

The READ COMMITTED experiment showed that a subsequent statement can observe another transaction's committed update. The REPEATABLE READ experiment demonstrated that a transaction retains its original snapshot even when another session commits a change.

The concurrent duplicate-registration experiment demonstrated that PostgreSQL's UNIQUE constraint protects academic registration integrity when simultaneous users attempt the same operation.

The work also highlighted the importance of application-side error handling, transaction boundaries, course-capacity enforcement and recovery strategies.

Overall, the implementation demonstrates the practical application of transaction processing and concurrency-control principles within the MUN-SRRMS university registration environment.
