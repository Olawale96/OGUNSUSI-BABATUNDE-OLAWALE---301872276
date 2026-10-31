
# MUN-SRRMS - Portfolio 2: Query Processing and Optimisation

## 1. Project Information

**Case study:** Metropolitan University of Nigeria (MUN), a fictional Nigerian university.

**System:** Student Registration and Result Management System (SRRMS).

**DBMS:** PostgreSQL 18.6.

**Database client:** PostgreSQL command-line client (psql).

**Operating system:** Windows 64-bit.

**Implementation status:** Seven SQL queries executed successfully. A separate benchmark database was populated, indexed, and evaluated using PostgreSQL execution plans and repeated performance measurements.

## 2. Project Objectives

Portfolio 2 investigates SQL query processing and database performance optimisation.

The objectives are to:

- Develop and execute complex SQL queries.
- Apply joins, filtering, aggregation and window functions.
- Examine PostgreSQL execution plans.
- Understand sequential scans, index scans and join strategies.
- Implement and evaluate B-tree indexes.
- Compare query performance before and after optimisation.
- Analyse execution costs and indexing trade-offs using actual measurements.

## 3. Database Environment

Two databases are used.

| Database | Purpose |
|---|---|
| mun_srrms | Original Portfolio 1 database containing synthetic university records. |
| mun_srrms_perf | Separate performance-testing database containing additional benchmark records. |

The performance database was created to protect the original Portfolio 1 records from benchmark modifications.

Both databases use the same mun_srrms schema.

## 4. Project Structure

```text
Portfolio2/
│
├── sql/
│   ├── 01_queries.sql
│   ├── 02_baseline_plans.sql
│   ├── 03_benchmark_data.sql
│   ├── 04_indexes.sql
│   └── 05_optimised_plans.sql
│
├── docs/
│   ├── evidence-checklist.md
│   └── performance-analysis-template.md
│
├── evidence/
│   └── Actual SQL outputs and execution-plan screenshots
│
└── README.md
```

## 5. SQL Query Development

Seven SQL queries were developed and successfully executed against the original mun_srrms database.

| Query | Description | Main SQL technique |
|---|---|---|
| Q1 | Student directory | INNER JOIN |
| Q2 | Course class list | Multiple JOINs and filtering |
| Q3 | Results and pending results | LEFT JOIN |
| Q4 | Registration counts and average marks | GROUP BY, COUNT and AVG |
| Q5 | Student rankings | RANK() window function |
| Q6 | High-mark result count | COUNT and WHERE |
| Q7 | Individual pending course results | EXISTS / NOT EXISTS and LEFT JOIN |

The corrected Q7 query identifies individual course enrolments without results, including students who have already received results for other courses.

All seven queries executed successfully against the original sample dataset.

## 6. Performance Database Preparation

Performance experiments were conducted in mun_srrms_perf.

The following steps were performed.

### Step 1: Create the performance database

Run only if the database does not already exist:

```powershell
psql -U postgres -h localhost -p 5432 -d postgres -c "CREATE DATABASE mun_srrms_perf;"
```

### Step 2: Create the relational schema

From the main project directory:

```powershell
psql -U postgres -h localhost -p 5432 -d mun_srrms_perf -v ON_ERROR_STOP=1 -f .\Portfolio1\sql\01_schema.sql
```

### Step 3: Populate the sample university records

```powershell
psql -U postgres -h localhost -p 5432 -d mun_srrms_perf -v ON_ERROR_STOP=1 -f .\Portfolio1\sql\02_seed_data.sql
```

### Step 4: Generate benchmark records

```powershell
psql -U postgres -h localhost -p 5432 -d mun_srrms_perf -v ON_ERROR_STOP=1 -f .\Portfolio2\sql\03_benchmark_data.sql
```

The benchmark script uses PostgreSQL generate_series() to create:

- 20,000 synthetic students.
- 40,000 additional enrolments.
- 40,000 additional results.

The resulting database contains:

| Table | Final records |
|---|---:|
| Student | 20,003 |
| Enrolment | 40,004 |
| Result | 40,002 |

**Important:** The benchmark script should be executed only once against the prepared performance database. Do not run it again on the existing populated database because it will attempt to insert duplicate synthetic business identifiers.

## 7. Baseline Performance Testing

Before creating the candidate index, the baseline execution plans were captured.

Run:

```powershell
psql -U postgres -h localhost -p 5432 -d mun_srrms_perf -P pager=off -f .\Portfolio2\sql\02_baseline_plans.sql
```

The script executes EXPLAIN ANALYZE on two performance queries.

Five baseline measurements were collected for each query.

The baseline median execution times were:

| Query | Median execution time |
|---|---:|
| Q1 - High-mark result count | 2.723 ms |
| Q2 - Grouped high-mark results | 9.628 ms |

## 8. Index Implementation

A B-tree index was created on the result mark column.

```sql
CREATE INDEX IF NOT EXISTS idx_result_mark
ON mun_srrms.result (mark);
```

Execute the supplied index script:

```powershell
psql -U postgres -h localhost -p 5432 -d mun_srrms_perf -P pager=off -v ON_ERROR_STOP=1 -f .\Portfolio2\sql\04_indexes.sql
```

The script creates the candidate index, updates statistics using ANALYZE and displays the available indexes on the result table.

The candidate index is created in mun_srrms_perf only.

## 9. Optimised Performance Testing

After index creation, the same two performance queries were executed again.

Run:

```powershell
psql -U postgres -h localhost -p 5432 -d mun_srrms_perf -P pager=off -v ON_ERROR_STOP=1 -f .\Portfolio2\sql\05_optimised_plans.sql
```

Five optimised measurements were collected for each query.

The optimised median execution times were:

| Query | Median execution time |
|---|---:|
| Q1 - High-mark result count | 0.513 ms |
| Q2 - Grouped high-mark results | 7.524 ms |

## 10. Performance Results

The repeated-run median measurements produced the following comparison.

| Metric | Before indexing | After indexing | Median reduction |
|---|---:|---:|---:|
| Q1 execution time | 2.723 ms | 0.513 ms | 81.16% |
| Q2 execution time | 9.628 ms | 7.524 ms | 21.85% |

PostgreSQL selected:

- An Index Only Scan for Q1.
- A Bitmap Index Scan followed by a Bitmap Heap Scan for Q2.

The results demonstrate that index effectiveness depends on the query structure, data access requirements and PostgreSQL query planner decisions.

The measurements are specific to this local synthetic workload and should not be treated as guaranteed production performance improvements.

## 11. Technical Analysis

The accompanying performance analysis document examines:

- Query execution strategies.
- Sequential scans and index scans.
- Hash joins and aggregation.
- Actual and estimated row counts.
- Planning and execution times.
- Buffer usage.
- Index storage and maintenance overhead.
- Experimental limitations and performance trade-offs.

The repeated-run median measurements are used as the main comparison rather than relying solely on individual execution times.

## 12. Evidence and Reproducibility

The evidence directory should contain genuine screenshots or saved outputs documenting:

1. Successful execution of all seven SQL queries.
2. Benchmark data insertion and final row counts.
3. Baseline execution plans.
4. Five-run baseline measurements.
5. Candidate index creation and verification.
6. Optimised execution plans.
7. Five-run optimised measurements.
8. The completed performance analysis.

No performance figures should be invented. All reported results must originate from actual PostgreSQL executions.

## 13. Limitations

The experiments used synthetic academic data on a local Windows environment.

Performance can vary with processor activity, memory caching, storage performance, PostgreSQL statistics and concurrent workload.

Although five executions were collected per query in each condition, the baseline and indexed runs were conducted in separate groups. Consequently, possible cache and run-order effects cannot be completely eliminated.

Further experiments using larger datasets, additional query patterns and controlled alternating runs would provide stronger performance evidence.

## 14. Conclusion

Portfolio 2 successfully demonstrates SQL query development, PostgreSQL execution-plan analysis and index-based optimisation.

Seven SQL queries were implemented, and a separate performance database was populated with more than 100,000 records across students, enrolments and results.

A B-tree index on the result mark column was evaluated through repeated before-and-after execution measurements.

The observed median execution-time reductions were 81.16% for the high-mark count query and 21.85% for the grouped high-mark query.

The experiment demonstrates the importance of evidence-based indexing decisions and critical evaluation of database query performance.
