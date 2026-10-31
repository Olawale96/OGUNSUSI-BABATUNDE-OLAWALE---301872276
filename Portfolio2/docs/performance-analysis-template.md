
# Portfolio 2: Query Processing and Performance Optimisation

## 1. Experimental Environment

| Configuration | Actual value |
|---|---|
| Operating system | Windows 64-bit |
| DBMS | PostgreSQL 18.6 |
| Database client | psql |
| Original database | mun_srrms |
| Performance database | mun_srrms_perf |
| Students | 20,003 |
| Enrolments | 40,004 |
| Results | 40,002 |
| Test date | 31 October 2026 |

A separate performance database was created to protect the original Portfolio 1 database from benchmark data modifications.

## 2. SQL Query Development

Seven queries were implemented and executed successfully.

The queries demonstrated:

1. Multiple-table INNER JOIN operations.
2. Multi-table filtering and class-list retrieval.
3. LEFT JOIN operations for identifying pending results.
4. Aggregate functions, including COUNT and AVG.
5. Window functions using RANK().
6. Conditional filtering and counting.
7. EXISTS and NOT EXISTS subqueries.

The queries were initially executed against the original database containing three students, four enrolments and two results.

The seventh query was improved to identify individual enrolments without corresponding results, rather than excluding students who already had another result.

## 3. Benchmark Data Generation

The performance database was populated with synthetic benchmark records.

| Data category | Initial records | Added | Final records |
|---|---:|---:|---:|
| Students | 3 | 20,000 | 20,003 |
| Enrolments | 4 | 40,000 | 40,004 |
| Results | 2 | 40,000 | 40,002 |

PostgreSQL's generate_series() function was used to generate synthetic student records.

Each generated student received two course enrolments and two associated result records.

The transaction completed successfully. ANALYZE was subsequently executed to update PostgreSQL planner statistics.

## 4. Performance Queries

Two queries were selected for the indexing experiment.

### 4.1 Query 1: High-mark result count

```sql
SELECT COUNT(*)
FROM mun_srrms.result
WHERE mark >= 90;
```

This query filters results using the numerical mark attribute. It provides a straightforward test of whether a B-tree index on the mark column can improve filtering performance.

### 4.2 Query 2: High-mark results grouped by course

```sql
SELECT c.course_code, COUNT(*) AS high_mark_results
FROM mun_srrms.result r
JOIN mun_srrms.enrolment e
    ON e.enrolment_id = r.enrolment_id
JOIN mun_srrms.course_offering co
    ON co.offering_id = e.offering_id
JOIN mun_srrms.course c
    ON c.course_id = co.course_id
WHERE r.mark >= 90
GROUP BY c.course_code
ORDER BY c.course_code;
```

This query evaluates a more complex workload involving filtering, joins, aggregation and sorting.

Both queries were evaluated using:

EXPLAIN (ANALYZE, BUFFERS, VERBOSE, FORMAT TEXT)

## 5. Index Design and Implementation

A B-tree index was introduced on the result mark attribute.

```sql
CREATE INDEX IF NOT EXISTS idx_result_mark
ON mun_srrms.result (mark);
```

The index was created in the performance database only.

ANALYZE was subsequently executed to update the database statistics.

PostgreSQL confirmed the existence of:

- idx_result_mark on mark.
- result_enrolment_id_key on enrolment_id.
- result_pkey on result_id.

## 6. Baseline Performance Results

Five baseline executions were performed without the candidate index.

### 6.1 Query 1: Baseline measurements

| Run | Execution time |
|---|---:|
| 1 | 2.723 ms |
| 2 | 2.680 ms |
| 3 | 2.966 ms |
| 4 | 3.137 ms |
| 5 | 2.689 ms |
| Median | 2.723 ms |

The execution plans consistently used a sequential scan on the result table.

The five executions returned 4,358 matching records.

In the initial detailed execution plan, PostgreSQL estimated 4,364 matching rows, compared with the actual 4,358.

The representative detailed baseline plan recorded 255 shared buffer hits and zero shared buffer reads.

### 6.2 Query 2: Baseline measurements

| Run | Execution time |
|---|---:|
| 1 | 9.314 ms |
| 2 | 9.738 ms |
| 3 | 10.209 ms |
| 4 | 9.603 ms |
| 5 | 9.628 ms |
| Median | 9.628 ms |

The baseline plan used sequential scans on the result, enrolment, course offering and course tables.

PostgreSQL used hash joins to associate the qualifying results with enrolments and course offerings. Hash aggregation and QuickSort were used to produce the grouped output.

The representative detailed baseline plan recorded 552 shared buffer hits and zero shared buffer reads.

## 7. Optimised Performance Results

After creating idx_result_mark, the same queries were executed five additional times.

### 7.1 Query 1: Optimised measurements

| Run | Execution time |
|---|---:|
| 1 | 0.878 ms |
| 2 | 0.504 ms |
| 3 | 0.507 ms |
| 4 | 0.513 ms |
| 5 | 0.560 ms |
| Median | 0.513 ms |

PostgreSQL selected an Index Only Scan using idx_result_mark.

The representative detailed optimised plan reported:
- 4,358 actual matching rows.
- Zero heap fetches.
- 15 shared buffer hits.
- 0.601 ms execution time.

The five-run median is 0.513 ms and is used for the primary performance comparison.

### 7.2 Query 2: Optimised measurements

| Run | Execution time |
|---|---:|
| 1 | 7.465 ms |
| 2 | 7.308 ms |
| 3 | 8.625 ms |
| 4 | 7.620 ms |
| 5 | 7.524 ms |
| Median | 7.524 ms |

The execution plan used:
- Bitmap Index Scan on idx_result_mark.
- Bitmap Heap Scan on result.
- Sequential Scan on enrolment.
- Hash Join operations.
- HashAggregate.
- QuickSort.

The representative detailed optimised plan recorded:
- 4,358 actual matching rows.
- 255 exact heap blocks accessed.
- 566 shared buffer hits.
- Zero shared buffer reads.
- 7.647 ms execution time.

The five-run median is 7.524 ms and is used for the primary performance comparison.

## 8. Comparative Performance Analysis

### 8.1 Summary of five-run median measurements

| Metric | Query 1 baseline | Query 1 indexed | Query 2 baseline | Query 2 indexed |
|---|---:|---:|---:|---:|
| Median execution time | 2.723 ms | 0.513 ms | 9.628 ms | 7.524 ms |
| Median planning time | 0.335 ms | 0.425 ms | 3.122 ms | 3.059 ms |

### 8.2 Percentage execution-time reduction

Formula:

Percentage reduction = ((Baseline median - Indexed median) / Baseline median) × 100

Query 1:

((2.723 - 0.513) / 2.723) × 100

= 81.16% reduction.

Query 2:

((9.628 - 7.524) / 9.628) × 100

= 21.85% reduction.

The measurements indicate that the candidate index improved the observed median execution time of both queries.

Query 1 benefited more because PostgreSQL could perform an Index Only Scan without heap fetches.

Query 2 required additional information from the enrolment and course-offering relations. Consequently, the index improved result filtering but did not eliminate the remaining joins, sequential scan or aggregation operations.

### 8.3 Planning-time observations

The median planning time for Query 1 increased slightly from 0.335 ms to 0.425 ms after indexing.

Query 2's median planning time decreased from 3.122 ms to 3.059 ms.

This demonstrates that an index can affect planning decisions as well as execution. A reduction in execution time does not necessarily imply that every stage of query processing becomes faster.

## 9. Discussion and Critical Evaluation

### 9.1 Index effectiveness

The experiment demonstrates that a B-tree index can improve filtering operations on a numerical attribute.

The strongest improvement occurred in Query 1, where the index supported an Index Only Scan.

Query 2 benefited through a Bitmap Index Scan and Bitmap Heap Scan, but other query operations continued to contribute to overall execution time.

### 9.2 Query planner behaviour

PostgreSQL's query planner evaluates alternative execution strategies using statistical information and estimated costs.

The database does not automatically use every available index. Sequential scans can be more efficient when a large proportion of a table must be accessed or when the table is relatively small.

The experiment demonstrates why execution plans must be examined instead of assuming that creating an index guarantees better performance.

### 9.3 Estimated versus actual rows

The baseline and optimised execution plans showed differences between estimated and actual qualifying rows.

For example, the representative baseline estimate was 4,364 rows, while the actual result was 4,358.

The optimised plan estimated 4,582 rows, while the actual result remained 4,358.

These differences demonstrate that planner estimates are predictions based on statistical information rather than guaranteed actual counts.

### 9.4 Index maintenance and storage

Indexes introduce additional storage requirements and maintenance overhead.

When records are inserted, updated or deleted, PostgreSQL may also need to maintain associated index entries.

Consequently, indexes should be selected based on measured workload requirements rather than created indiscriminately.

### 9.5 Experimental limitations

The measurements were collected on a local Windows environment using synthetic data.

Five executions were performed for each query before and after indexing. Median execution times were used to reduce the influence of unusually fast or slow individual runs.

However, the experiment was not a controlled production benchmark. Cache warming, operating-system activity, CPU scheduling and other environmental conditions may influence results.

The baseline runs were performed consecutively before the indexed runs, rather than alternating between conditions. Therefore, caching and run-order effects cannot be completely excluded.

The results should be interpreted as observed improvements in this particular experiment, not guaranteed improvements under all workloads.

A larger dataset, additional workload patterns and controlled alternating benchmark runs could provide further evidence.

## 10. Conclusion

Portfolio 2 demonstrated practical SQL query development, query-plan inspection and index-based performance optimisation.

Seven SQL queries were successfully implemented and executed. A separate performance database was populated with 20,003 students, 40,004 enrolments and 40,002 results.

A B-tree index was introduced on the result mark attribute and evaluated using two queries.

Five-run median execution times showed an 81.16% reduction for Query 1 and a 21.85% reduction for Query 2.

The exercise demonstrated that the effectiveness of an index depends on the query structure, data distribution, table size and query planner decisions.

It also reinforced the importance of comparing actual execution plans, considering storage and write overhead, and reporting measured evidence rather than assuming that an optimisation will always improve performance.

## 11. Evidence Requirements

The following evidence should accompany this analysis:

1. Seven SQL query execution results.
2. Benchmark data insertion and final record counts.
3. Five-run baseline measurement output.
4. Representative detailed baseline execution plans.
5. Candidate index creation and verification.
6. Five-run optimised measurement output.
7. Representative detailed optimised execution plans.
8. This completed performance analysis.
