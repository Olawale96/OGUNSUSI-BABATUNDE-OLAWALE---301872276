# Portfolio 3 Evidence Register

## 1. Saved experimental evidence

| File | Description | Status |
|---|---|---|
| 01_transaction_control.txt | COMMIT, ROLLBACK and SAVEPOINT | Saved |
| 02_read_committed.txt | Two-session READ COMMITTED observations | Saved |
| 03_repeatable_read.txt | Two-session REPEATABLE READ observations | Saved |
| 04_concurrent_registration.txt | Concurrent duplicate registration and unique violation | Saved |
| 05_integrity_checks.txt | UNIQUE constraint and duplicate checks | Saved |
| 06_cleanup_verification.txt | Demonstration registration removal and row-count restoration | Saved |

These files are structured transcriptions of actual PostgreSQL
observations supplied during the practical experiments. They are
not raw terminal exports or screenshots.

## 2. Screenshots still required

- [ ] COMMIT demonstration.
- [ ] ROLLBACK demonstration.
- [ ] SAVEPOINT demonstration.
- [ ] READ COMMITTED Session A and Session B.
- [ ] REPEATABLE READ Session A and Session B.
- [ ] Fresh counter read after REPEATABLE READ.
- [ ] Concurrent registration Session A.
- [ ] Concurrent registration Session B and unique-constraint error.
- [ ] Final registration count.
- [ ] Integrity-check output.
- [ ] Cleanup verification.

## 3. Evidence requirements

- Capture genuine PostgreSQL execution screenshots.
- Show the SQL statements and corresponding results.
- Capture both sessions for concurrent operations.
- Hide passwords and credentials.
- Do not recreate screenshots or present expected results as actual evidence.
- Keep all screenshots and text evidence in this folder.

## 4. Academic evidence standard

Every reported result must be supported by an actual observation.
The technical analysis must distinguish completed experiments from
proposed future tests.
