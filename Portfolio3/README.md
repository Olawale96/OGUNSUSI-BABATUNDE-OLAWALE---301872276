
# Portfolio 3 Evidence Register

All evidence must be genuine PostgreSQL execution output or screenshots captured during the practical experiments.

## 1. Transaction Control

| Filename | Evidence |
|---|---|
| 01_commit_result.png | BEGIN, INSERT and COMMIT with committed record |
| 02_rollback_result.png | INSERT followed by ROLLBACK and zero matching rows |
| 03_savepoint_result.png | SAVEPOINT, partial rollback and retained records |

## 2. Transaction Isolation

| Filename | Evidence |
|---|---|
| 04_read_committed_session_a.png | Session A first and second readings: 100 and 110 |
| 05_read_committed_session_b.png | Session B concurrent update and COMMIT |
| 06_repeatable_read_session_a.png | Session A repeated readings of 100 |
| 07_repeatable_read_session_b.png | Session B concurrent update and COMMIT |
| 08_repeatable_read_fresh_read.png | Fresh read after both transactions: 110 |

## 3. Concurrent Registration

| Filename | Evidence |
|---|---|
| 09_duplicate_registration_session_a.png | Session A successful INSERT and COMMIT |
| 10_duplicate_registration_session_b.png | Session B blocking attempt, unique-constraint error and ROLLBACK |
| 11_registration_count_verification.png | Final count of exactly one registration |

## 4. Integrity and Cleanup

| Filename | Evidence |
|---|---|
| 12_integrity_check.png | Unique constraint verification and zero duplicate registrations |
| 13_cleanup_verification.png | DELETE 1 and final enrolment count of 40,004 |

## 5. Evidence Requirements

- Screenshots must show the actual PostgreSQL commands and their results.
- Capture both Session A and Session B wherever concurrent operations are involved.
- Do not expose passwords or credentials.
- Do not invent or recreate screenshots that purport to show historical executions.
- Preserve original terminal results wherever possible.
- Clearly distinguish experimentally observed outcomes from theoretical expectations.

All evidence supports the technical analysis in portfolio-analysis-template.md.
