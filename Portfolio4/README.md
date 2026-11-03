# MUN-SRRMS Portfolio 4 — NoSQL and Advanced Data Models

**Technology:** MongoDB Community Server + `mongosh`

**Database:** `mun_srrms_nosql`

**Relational counterpart:** PostgreSQL database `mun_srrms` from Portfolio 1

## Design decision
PostgreSQL remains the authoritative database for students, programmes, courses, course offerings, enrolments and official results. MongoDB stores flexible student-facing profile documents and learning activity summaries. The MongoDB document uses `matric_number` as a cross-database business identifier; it does not pretend PostgreSQL's integer `student_id` is MongoDB's `_id`.

## Requirements
- MongoDB Community Server 6.0+ (or compatible managed MongoDB deployment)
- `mongosh`
- A local MongoDB instance reachable at `mongodb://localhost:27017` or your configured connection string

## Run order
1. Start MongoDB and verify the service.
2. Run `mongodb/01_create_collection.js` to create or update the collection validator and unique matriculation-number index.
3. Run `mongodb/02_seed_documents.js` to insert the synthetic sample profiles.
4. Run `mongodb/06_verify_documents.js` to inspect document counts, BSON date types and index definitions.
5. Run `mongodb/03_crud_operations.js` to demonstrate CREATE, READ, UPDATE and DELETE.
6. Run `mongodb/04_indexes_and_queries.js` to create the programme index and inspect query execution statistics.
7. Run `mongodb/05_aggregation.js` to analyse embedded learning activities.
8. Run `mongodb/07_validation_tests.js` to test rejection of invalid documents.
9. Run `mongodb/08_unique_index_test.js` to verify unique matriculation-number enforcement.
10. Complete `docs/model-design-and-analysis.md` using actual results.
11. Preserve genuine screenshots and exported outputs under `evidence/`.

Run a script from a terminal with:
```bash
mongosh "mongodb://localhost:27017/mun_srrms_nosql" mongodb/01_create_collection.js
```
Repeat for the other scripts. In Windows PowerShell, use the same command on one line. If authentication is enabled, use your own secure connection string; never commit credentials.

## Evidence and honesty
The scripts are implementation material, not proof that your local MongoDB has run them. Capture your own output, MongoDB version, document counts and query results. Do not invent execution times or screenshots.

## Git suggestions
- `Add MongoDB student profile model and validation`
- `Add MongoDB CRUD and aggregation exercises`
- `Document relational versus document model evaluation`

## Important boundary
Do not duplicate official grades or enrolment status as independently editable facts in MongoDB. If a profile needs a read-only academic summary, treat it as a cached projection and document its refresh/consistency strategy. The SQL database remains authoritative.