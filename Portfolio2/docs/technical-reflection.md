
# Technical Reflection: Portfolio 2 - Query Processing and Optimisation

## 1. Introduction

Portfolio 2 focused on developing SQL queries, examining PostgreSQL query execution plans and evaluating indexing as a database performance optimisation technique.

The Metropolitan University of Nigeria Student Registration and Result Management System (MUN-SRRMS) provided the case-study environment.

I used PostgreSQL 18.6 and the psql command-line client on Windows 64-bit. The original database was retained for query development, while a separate database named mun_srrms_perf was created for performance experiments.

This separation was an important implementation decision because it prevented the synthetic benchmark workload from modifying the original academic records developed in Portfolio 1.

## 2. SQL Query Development

I developed and executed seven SQL queries covering different database operations.

These included multiple-table joins, filtering, result retrieval, aggregation, window functions and correlated subqueries.

One important improvement involved the query for identifying students with pending results.

The original query identified students who had no result across any of their enrolments. This could exclude a student who had received a result for one course but was still awaiting another.

I revised the query to examine individual enrolments and identify those without associated result records.

The revised query correctly identified two outstanding results in the sample dataset.

This demonstrated the importance of validating SQL queries against business requirements rather than relying exclusively on syntactically correct SQL.

## 3. Benchmark Database Design

For the performance experiments, I created a separate PostgreSQL database called mun_srrms_perf.

The Portfolio 1 relational schema and sample records were reproduced in this database.

I then generated synthetic benchmark records using PostgreSQL's generate_series() function.

The resulting dataset contained:

| Entity | Record count |
|---|---:|
| Students | 20,003 |
| Enrolments | 40,004 |
| Results | 40,002 |

Using a larger dataset provided a more meaningful environment for evaluating query execution strategies than the original database containing only two results.

I also executed ANALYZE on the relevant tables so that PostgreSQL could use updated statistical information when estimating query costs.

## 4. Baseline Query Performance

Two queries were selected for detailed performance evaluation.

The first counted result records with marks greater than or equal to 90.

The second joined result, enrolment, course offering and course records before grouping qualifying results by course.

I used EXPLAIN (ANALYZE, BUFFERS, VERBOSE, FORMAT TEXT) to examine actual execution plans, execution times, planning times, buffer activity and row estimates.

Five baseline executions were performed for each query before introducing the candidate index.

The median execution times were:

| Query | Baseline median |
|---|---:|
| High-mark result count | 2.723 ms |
| Grouped high-mark results | 9.628 ms |

PostgreSQL used sequential scans to retrieve the qualifying result records.

For the more complex query, it also used hash joins, hash aggregation and sorting.

This showed that PostgreSQL can select sequential scanning as an appropriate strategy when its cost estimates indicate that scanning the table is preferable to accessing individual records through an index.

## 5. Indexing Strategy and Implementation

I introduced a B-tree index on the mark column of the result table.

The following SQL statement was used:

```sql
CREATE INDEX IF NOT EXISTS idx_result_mark
ON mun_srrms.result (mark);
```

The index was implemented exclusively in the performance database.

After creating the index, I executed ANALYZE to update the relevant PostgreSQL statistics.

I then repeated the same two queries five times each.

The index was successfully verified through PostgreSQL's pg_indexes catalogue view.

This exercise demonstrated the importance of selecting indexes based on actual query filtering requirements and subsequently verifying whether the query planner uses them.

## 6. Optimised Performance Results

The optimised median execution times were:

| Query | Baseline median | Indexed median |
|---|---:|---:|
| High-mark result count | 2.723 ms | 0.513 ms |
| Grouped high-mark results | 9.628 ms | 7.524 ms |

The percentage reduction was calculated using:

Percentage reduction = ((Baseline median - Indexed median) / Baseline median) × 100

The observed reductions were:

- Query 1: 81.16%.
- Query 2: 21.85%.

These measurements indicate that indexing improved the observed performance of both queries under the experimental conditions.

## 7. Interpretation of Execution Plans

An important finding was that PostgreSQL selected different index-access strategies for the two queries.

### 7.1 Index Only Scan

For the high-mark count query, PostgreSQL used an Index Only Scan on idx_result_mark.

The detailed execution plan reported zero heap fetches.

This was beneficial because the query required only the indexed mark information to determine the count.

The result demonstrates how an appropriately structured index can reduce the need to access the underlying table.

### 7.2 Bitmap Index Scan and Bitmap Heap Scan

For the grouped high-mark query, PostgreSQL used a Bitmap Index Scan followed by a Bitmap Heap Scan.

The bitmap approach identified the relevant index entries and then accessed the corresponding table pages.

However, the query also required enrolment identifiers and information from additional relations.

Consequently, PostgreSQL still performed a sequential scan on the enrolment table and executed hash joins, aggregation and sorting.

This explains why the grouped query experienced a smaller performance improvement than the simpler count query.

The experiment showed that optimising one part of a query does not necessarily eliminate the cost of its other operations.

## 8. Challenges Encountered and How They Were Resolved

### 8.1 Protecting the original database

The benchmark dataset involved inserting tens of thousands of additional academic records.

Running this workload against the original Portfolio 1 database could have affected subsequent coursework activities.

I addressed this by creating mun_srrms_perf and reproducing the relational schema and sample data there.

All benchmark insertions and index experiments were performed in the separate database.

### 8.2 Understanding PostgreSQL execution plans

Initially, the execution plans contained sequential scans, nested-loop operations and hash joins.

Interpreting these operations required examining the actual execution-plan output rather than relying solely on the SQL query text.

I learned that sequential scans are not necessarily evidence of poor query performance. They can be appropriate when the query planner estimates that scanning the table is cheaper than using an index.

### 8.3 Measuring performance consistently

Single execution measurements can vary because of caching, memory activity, processor scheduling and other operating-system operations.

To improve the reliability of my comparison, I collected five execution measurements for each query before indexing and five after indexing.

I calculated median execution times and used these as the principal performance comparison.

I also retained the individual execution plans and timing outputs as supporting evidence.

The baseline and optimised measurements were collected in separate groups, however, so the experiment does not completely eliminate possible cache and run-order effects.

### 8.4 Preserving reproducible evidence

I saved the SQL query outputs, benchmark row counts, execution plans and repeated performance measurements as evidence files.

This provided a record that can be reviewed independently of the current terminal session.

## 9. Critical Evaluation and Limitations

Although the experiment demonstrated measurable improvements, several limitations should be acknowledged.

First, the benchmark data was synthetic. Its distribution may differ from that of a real university's academic records.

Second, only one candidate index was evaluated. Additional indexing strategies, including composite and covering indexes, could be investigated using more diverse query patterns.

Third, the repeated measurements were conducted in separate baseline and optimised groups. Alternating the two conditions and repeating the process under controlled cache conditions would strengthen the experimental design.

Fourth, the index introduces storage requirements and additional maintenance overhead whenever relevant records are inserted, updated or deleted.

Finally, the measured execution times are specific to the local Windows and PostgreSQL environment. They should not be interpreted as guaranteed production performance improvements.

## 10. Knowledge and Skills Acquired

This portfolio improved my practical understanding of:

- SQL joins and relational query processing.
- Aggregate functions and grouping operations.
- Window functions and ranking.
- EXISTS and NOT EXISTS subqueries.
- PostgreSQL EXPLAIN ANALYZE.
- Sequential scans, index scans and bitmap operations.
- Hash joins and hash aggregation.
- Query planning and execution costs.
- B-tree index implementation.
- Benchmark dataset generation.
- Repeated performance measurement and median calculations.
- Critical evaluation of database optimisation trade-offs.

The most important lesson was that an optimisation decision should be supported by actual execution evidence.

An index should not be created simply because a column appears in a WHERE condition. Its usefulness should be evaluated against the actual workload, data distribution and execution plans.

## 11. Proposed Improvements

Further improvements to the MUN-SRRMS database could include:

1. Evaluating composite indexes for frequently executed multi-column filters.
2. Investigating covering indexes for queries that retrieve multiple attributes.
3. Testing different join strategies under larger workloads.
4. Comparing index performance across different selectivity levels.
5. Evaluating the effect of index creation on insertion and update performance.
6. Conducting controlled alternating benchmark runs.
7. Examining query plans for more complex student registration and academic reporting workloads.

These improvements would provide a broader understanding of query optimisation in a university database environment.

## 12. Conclusion

Portfolio 2 provided practical experience in SQL query development, PostgreSQL execution-plan analysis and index-based performance optimisation.

Seven queries were successfully implemented and executed. A separate performance database was populated with 20,003 students, 40,004 enrolments and 40,002 results.

A B-tree index on the result mark attribute was introduced and evaluated using two queries.

Five-run median measurements showed an 81.16% reduction in execution time for the high-mark count query and a 21.85% reduction for the grouped high-mark query.

The exercise demonstrated the importance of analysing execution plans, understanding query planner decisions and evaluating indexing strategies through measured evidence.

It also reinforced that database performance optimisation involves balancing retrieval speed, storage requirements, data modification overhead and the characteristics of the actual workload.
