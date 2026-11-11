# Portfolio 3 – Transaction Management and Concurrency

## 1. Overview

Portfolio 3 examines transaction management, isolation behaviour, concurrent database operations and integrity enforcement within the Metropolitan University of Nigeria Student Registration and Result Management System (MUN-SRRMS).

The practical experiments were conducted using PostgreSQL 18.6. They demonstrate how transaction boundaries, isolation levels and database constraints help preserve data consistency when multiple users access the system concurrently.

## 2. Evidence Register

The `evidence` directory contains six structured text transcripts documenting the PostgreSQL practical experiments.

| Evidence file | Experiment and observed outcome |
|---|---|
| `01_transaction_control.txt` | Demonstrates COMMIT, ROLLBACK and SAVEPOINT. Committed changes were retained, rolled-back changes were discarded, and partial rollback preserved the appropriate records. |
| `02_read_committed.txt` | Demonstrates READ COMMITTED behaviour. Session A observed 100 initially and 110 after Session B committed an update. |
| `03_repeatable_read.txt` | Demonstrates REPEATABLE READ snapshot behaviour. Session A continued to observe 100, while a fresh read after the transaction returned 110. |
| `04_concurrent_registration.txt` | Demonstrates concurrent registration attempts. PostgreSQL rejected the second insert through the `enrolment_student_offering_unique` constraint, leaving exactly one matching registration. |
| `05_integrity_checks.txt` | Records verification of the unique constraint, zero duplicate student/offering combinations and enrolment counts before cleanup. |
| `06_cleanup_verification.txt` | Records deletion of the demonstration registration and verification that the performance database returned to 40,004 enrolment records. |

## 3. Important Experimental Observations

### Transaction control

The COMMIT, ROLLBACK and SAVEPOINT experiments demonstrated the ability to retain, discard and partially reverse changes within a transaction.

The experiment also recorded gaps in identity values after rollback. This is expected PostgreSQL behaviour because identity sequences are not rolled back with ordinary transaction operations.

### Transaction isolation

The READ COMMITTED experiment demonstrated that successive statements within a transaction can observe newly committed changes.

The REPEATABLE READ experiment demonstrated that a transaction retains its consistent snapshot, preventing a later SELECT from observing the concurrent committed update during that transaction.

### Concurrent registration and integrity

The concurrent registration experiment demonstrated how a UNIQUE constraint prevents two transactions from creating the same student/course-offering registration.

The integrity checks subsequently identified zero duplicate student/offering combinations.

### Cleanup

The demonstration registration was removed after testing. The performance database returned to its original 40,004 enrolment records. The cleanup transcript confirms that the original academic database was not modified by this operation.

## 4. Evidence and Reproducibility Notes

- The evidence directory contains structured text transcripts, not PNG screenshots.
- The transcripts record the commands, outputs and observations documented during the practical experiments.
- Concurrent operations were performed using independent database sessions.
- The experiments distinguish observed PostgreSQL behaviour from theoretical explanations.
- Demonstration data was cleaned up and the final record count was verified.
- The transcripts should be read alongside the SQL scripts and technical analysis in this portfolio.

## 5. Evidence Limitations

The text transcripts provide a readable record of the practical results but are not substitutes for original graphical or terminal screenshots. They should therefore be described accurately as structured execution transcripts rather than screenshot evidence.
