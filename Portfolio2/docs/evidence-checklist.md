
# Portfolio 2 Evidence Checklist
## Query Processing and Performance Optimisation

## 1. Environment and Database Setup

- [x] PostgreSQL version verified: 18.6.
- [x] Original database mun_srrms preserved.
- [x] Separate performance database mun_srrms_perf created.
- [x] Portfolio 1 schema implemented in performance database.
- [x] Sample university data inserted.
- [x] Benchmark dataset generated successfully.

## 2. SQL Query Development and Execution

- [x] Q1: Student directory with programme and department.
- [x] Q2: Course class list with semester filtering.
- [x] Q3: Results and pending results using LEFT JOIN.
- [x] Q4: Registration counts and average marks.
- [x] Q5: Student ranking using RANK().
- [x] Q6: High-mark result counting.
- [x] Q7: Pending results using EXISTS / NOT EXISTS.
- [x] Corrected Q7 to identify individual pending course results.

## 3. Benchmark Dataset

- [x] 20,000 synthetic students inserted.
- [x] 40,000 synthetic enrolments inserted.
- [x] 40,000 synthetic results inserted.
- [x] Final student count verified: 20,003.
- [x] Final enrolment count verified: 40,004.
- [x] Final result count verified: 40,002.
- [x] ANALYZE executed on relevant database tables.

## 4. Baseline Performance Testing

- [x] Baseline execution plans captured before indexing.
- [x] Query 1 executed five times without candidate index.
- [x] Query 2 executed five times without candidate index.
- [x] Baseline scan methods identified.
- [x] Baseline planning and execution times recorded.
- [x] Median baseline execution times calculated.

## 5. Index Implementation

- [x] B-tree index idx_result_mark created.
- [x] Index definition verified through pg_indexes.
- [x] ANALYZE executed after index creation.
- [x] Existing primary-key and unique indexes preserved.

## 6. Optimised Performance Testing

- [x] Query 1 executed five times after indexing.
- [x] Query 2 executed five times after indexing.
- [x] Index Only Scan identified for Query 1.
- [x] Bitmap Index Scan identified for Query 2.
- [x] Sequential scans on remaining tables analysed.
- [x] Optimised planning and execution times recorded.
- [x] Median indexed execution times calculated.

## 7. Performance Comparison

- [x] Baseline and indexed execution plans compared.
- [x] Query 1 median reduction calculated: 81.16%.
- [x] Query 2 median reduction calculated: 21.85%.
- [x] Planning-time differences evaluated.
- [x] Buffer usage and scan methods discussed.
- [x] Index maintenance trade-offs discussed.
- [x] Experimental limitations documented.
- [x] Performance analysis document updated using actual measurements.


## 8. Screenshots and Supporting Evidence

### Saved execution evidence

- [x] Seven SQL query results: evidence/01_sql_query_results.txt
- [x] Benchmark row counts: evidence/02_benchmark_row_counts.txt
- [x] Baseline execution plans: evidence/03_baseline_execution_plans.txt
- [x] Optimised execution plans: evidence/04_optimised_execution_plans.txt
- [x] Five-run performance measurements: evidence/05_repeated_performance_measurements.txt

### Screenshots requiring content verification

- [ ] PostgreSQL version.
- [ ] Seven SQL query execution results.
- [ ] Benchmark data insertion and final record counts.
- [ ] Baseline execution plans.
- [ ] Index creation and verification.
- [ ] Optimised execution plans.
- [ ] Repeated performance measurements.

Screenshots must be reviewed individually and given descriptive filenames before submission.

## 9. Version Control and Final Review

- [x] Root Git repository initialised.
- [ ] Portfolio 2 development commits created progressively.
- [ ] Portfolio 2 evidence committed.
- [ ] Final technical and academic review completed.

## 10. Evidence Environment Details

Operating System: Windows 64-bit

DBMS: PostgreSQL 18.6

Database Client: PostgreSQL command-line client (psql)

Original Database: mun_srrms

Performance Database: mun_srrms_perf

Students: 20,003

Enrolments: 40,004

Results: 40,002

Benchmark Date: 31 October 2026

All benchmark records are synthetic and generated for academic performance testing.

## 11. Evidence Storage

Store all genuine screenshots and supporting outputs inside:

Portfolio2/evidence/

Use descriptive filenames and ensure execution plans, timing measurements and query results are readable.

Do not invent performance measurements or present single-run measurements as repeated-run averages.
