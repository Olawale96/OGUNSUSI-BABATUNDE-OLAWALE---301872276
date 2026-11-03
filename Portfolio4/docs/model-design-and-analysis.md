
# Portfolio 4 — NoSQL Database Modelling, Implementation and Evaluation

## 1. Introduction and Use Case

This portfolio implements a document-oriented data model for the Metropolitan University of Nigeria Student Registration and Result Management System (MUN-SRRMS) using MongoDB.

The purpose is to demonstrate how a NoSQL database can complement a relational database in an institutional information system.

PostgreSQL remains the authoritative database for student identities, programmes, courses, course offerings, enrolments and official academic results. MongoDB stores flexible student-facing profile information, notification preferences, accessibility settings and learning activity summaries.

This separation prevents MongoDB from becoming an independently editable source of official academic records.

The implementation uses MongoDB 9.0.4, mongosh 2.14.1 and the local MongoDB service on Windows.

## 2. Document Model Design

The implementation creates the `student_profiles` collection in the `mun_srrms_nosql` database.

A typical document contains:

```javascript
{
  _id: ObjectId("..."),
  matric_number: "MUN/2026/0001",

  profile: {
    first_name: "Ada",
    last_name: "Okafor",
    display_name: "Ada O.",
    programme: {
      programme_code: "MIT",
      programme_name: "MSc Information Technology"
    }
  },

  preferences: {
    notification_channels: ["email", "in_app"],
    language: "en",
    accessibility: []
  },

  learning_activity: [
    {
      activity_type: "resource_view",
      course_code: "MIT8101",
      occurred_at: ISODate("2026-10-01T10:00:00Z"),
      metadata: {
        resource_type: "lecture_note",
        duration_seconds: 420
      }
    }
  ],

  updated_at: ISODate("2026-10-05T00:00:00Z")
}
```

The document uses an automatically generated MongoDB ObjectId for `_id` and `matric_number` as the cross-database business identifier.

The student profile and notification preferences are embedded because they are commonly retrieved together and are relatively small.

Learning activity is represented as an embedded array of events. The implemented schema limits this array to 20 items, making it a bounded representation of recent activity rather than an unlimited lifetime event history.

For a larger production system, high-volume learning events should be moved to a separate collection indexed by matriculation number and event timestamp. This prevents individual student documents from growing indefinitely and helps avoid MongoDB's 16 MiB BSON document-size limit.

## 3. Embedding Versus Referencing

The design uses embedding for small, related information that is frequently accessed with the student profile.

Examples include:

- Student display information.
- Programme description.
- Notification preferences.
- Accessibility preferences.
- A bounded list of recent learning activities.

Embedding reduces the need for additional database queries when these attributes are required together.

Referencing is more appropriate for large, independently managed or frequently changing data.

Official enrolments, course offerings and examination results remain in PostgreSQL. Large learning-event histories should also be stored separately rather than continually expanding the profile document.

The resulting model balances document-read convenience with controlled document growth.

## 4. Schema Validation and Data Integrity

The `01_create_collection.js` script creates or updates the `student_profiles` collection using MongoDB JSON Schema validation.

The collection uses:

- `validationLevel: "strict"`.
- `validationAction: "error"`.
- Required top-level document fields.
- Explicit BSON data types.
- Nested object validation.
- Enumerated notification channels and activity types.
- A maximum of 20 embedded learning activities.
- Whitespace restrictions on important string fields.

The validator also rejects unrecognised properties in the top-level document and selected nested objects.

A unique index on `matric_number` provides business-key uniqueness independently of MongoDB's automatic `_id` index.

### 4.1 Actual validation results

Four deliberately invalid document submissions were tested.

| Validation test | Actual result | MongoDB error |
|---|---|---|
| Whitespace-only matriculation number | Rejected | 121 |
| Unexpected top-level field | Rejected | 121 |
| Unsupported notification channel | Rejected | 121 |
| Unexpected nested profile field | Rejected | 121 |

The actual test output reported:

- Invalid documents rejected: 4.
- Unexpected outcomes: 0.
- Final collection count: 2.

All four negative validation tests passed.

The experiment demonstrates that the configured validation rules are enforced during document insertion.

### 4.2 Unique Business-Key Enforcement

A separate test was performed against the unique index `uq_matric_number`.

The test first inserted a temporary document using the identifier `MUN/TEST/UNIQUE-INDEX-9001`. A second insertion using the same matriculation number was attempted.

MongoDB rejected the duplicate with error code 11000, confirming that the unique index enforced business-key uniqueness.

The temporary test document was subsequently deleted.

Actual results:

- First insertion: successful.
- Duplicate insertion: rejected with error code 11000.
- Temporary documents removed: 1.
- Final collection count: 2.

The test demonstrates that the database prevents duplicate student-profile identifiers independently of application-side checks.

The maximum activity-array length was configured in the validator but was not independently tested by inserting a document containing more than 20 activities.

## 5. Sample Data Implementation

Two synthetic student profiles were inserted into the collection.

| Matriculation number | Student | Programme | Activities |
|---|---|---|---:|
| MUN/2026/0001 | Ada Okafor | MSc Information Technology | 2 |
| MUN/2026/0002 | Chidi Bello | MSc Information Technology | 1 |

The seed script uses an upsert with `$setOnInsert`.

This means an existing sample profile is preserved instead of having its preferences or learning activities overwritten when the script is executed again.

The verification script returned:

- Total documents: 2.
- Ada's learning activities: 2.
- Chidi's learning activities: 1.
- `updated_at` BSON type: `date` for both documents.

The unique `uq_matric_number` index was also verified in the index catalogue.

## 6. CRUD Operations

The CRUD exercise was implemented through `03_crud_operations.js`.

### 6.1 Create

The script created a dedicated demonstration profile using the reserved matriculation number `MUN/DEMO/9001`.

MongoDB returned:

`acknowledged: true`

An ObjectId was automatically generated for the inserted document.

### 6.2 Read

The script retrieved Ada Okafor's existing profile using:

`matric_number: "MUN/2026/0001"`

The returned document included her profile, programme and notification preferences.

### 6.3 Update

The demonstration profile was modified using `$set` and `$push`.

`$set` changed the notification channels to email and in-app notifications.

`$push` appended a resource-view event for course MIT8101.

The actual MongoDB update response showed:

- `matchedCount: 1`
- `modifiedCount: 1`
- `upsertedCount: 0`

A subsequent read confirmed that the updated preferences and learning activity were stored.

### 6.4 Delete

The dedicated demonstration document was removed using `deleteOne()`.

MongoDB returned:

`deletedCount: 1`

The final collection count remained at two documents.

The CRUD experiment therefore demonstrated successful creation, retrieval, modification and deletion without altering the original sample profiles.

## 7. Indexing and Query Analysis

The implementation uses three indexes:

| Index | Key | Purpose |
|---|---|---|
| `_id_` | `_id` | Default document identification |
| `uq_matric_number` | `matric_number` | Unique student business identifier |
| `idx_programme_code` | `profile.programme.programme_code` | Programme-based profile retrieval |

The indexing script executes queries using both the matriculation number and programme code.

The representative matriculation-number lookup was examined using:

`explain("executionStats")`

### 7.1 Actual execution statistics

| Metric | Observed result |
|---|---:|
| Winning plan | EXPRESS_IXSCAN |
| Index used | uq_matric_number |
| Documents returned | 1 |
| Index keys examined | 1 |
| Documents examined | 1 |
| Execution time | 4 ms reported; 4,788 microseconds |

The winning execution plan explicitly identified the unique matriculation-number index.

The query therefore used an indexed lookup and examined one index key and one document to return the requested profile.

This provides practical evidence of index utilisation.

However, the collection contained only two documents. The observed execution time is not sufficient to establish a meaningful performance improvement or demonstrate scalability.

A representative performance evaluation would require a substantially larger dataset, repeated baseline and indexed measurements, controlled cache conditions and a comparison of execution statistics.

The programme index was verified in the index catalogue, and the programme query returned both student profiles. A separate execution-plan analysis for that query was not recorded.

## 8. Aggregation Pipeline

The aggregation experiment analyses embedded learning activity using four stages.

### 8.1 Pipeline operations

| Stage | Function |
|---|---|
| `$unwind` | Separates embedded learning activity events |
| `$group` | Groups events by course and activity type |
| `$project` | Produces a readable result structure |
| `$sort` | Orders the grouped output |

### 8.2 Actual aggregation results

MongoDB returned:

| Course | Activity type | Event count |
|---|---|---:|
| MIT8101 | quiz_attempt | 1 |
| MIT8101 | resource_view | 1 |
| MIT8102 | forum_post | 1 |
| **Total** | **All activity types** | **3** |

The results demonstrate that MongoDB can analyse nested document arrays without first converting them into separate relational tables.

The small dataset is suitable for demonstrating aggregation functionality, but it is not sufficient for assessing analytical performance at institutional scale.

## 9. PostgreSQL and MongoDB Architectural Comparison

| Criterion | PostgreSQL | MongoDB |
|---|---|---|
| Data structure | Relational tables | BSON documents |
| Schema | Defined relational structure | Flexible documents with validation |
| Relationships | Foreign keys and joins | Embedding and references |
| Business-key enforcement | Unique constraints | Unique indexes |
| Data validation | Types, CHECK, FK and other constraints | JSON Schema validation and indexes |
| Complex academic transactions | Strong relational fit | ACID transactions supported |
| Flexible profile attributes | Possible but requires relational design | Natural document-model fit |
| Learning activity aggregation | SQL aggregation and joins | Aggregation pipeline |
| Schema evolution | Controlled schema migrations | Document evolution with validation discipline |

PostgreSQL remains the more appropriate authoritative database for core university transactions because the system relies on structured relationships and strong relational integrity.

MongoDB is appropriate for flexible profile extensions, preferences and bounded learning activity information that may evolve independently.

The databases therefore serve complementary purposes rather than competing to store the same independently editable facts.

## 10. Cross-Database Consistency and Synchronisation

The two database systems do not automatically share foreign-key constraints or transactional consistency.

The implementation uses `matric_number` as the business identifier linking a MongoDB profile to a PostgreSQL student record.

The local coursework demonstrates the data-model association using corresponding sample identifiers. It does not implement an automatic cross-database synchronisation service.

A production integration should:

1. Verify that a matriculation number exists in PostgreSQL before creating a MongoDB profile.
2. Publish changes through a reliable application workflow, event mechanism or transactional outbox.
3. Make profile updates idempotent.
4. Detect and reconcile failed or stale synchronisation events.
5. Keep official grades and enrolment statuses authoritative in PostgreSQL.

A cached academic summary stored in MongoDB should be explicitly treated as a derived, read-only projection rather than a second source of truth.

## 11. Security and Privacy Considerations

The coursework uses synthetic student records rather than genuine student personal information.

A production deployment should implement:

- Authenticated MongoDB access with role-based permissions.
- Least-privilege database accounts.
- Network restrictions and secure connection settings.
- Encryption in transit and appropriate protection at rest.
- Regular backups and tested recovery procedures.
- Auditing and monitoring of sensitive database operations.
- Data minimisation and appropriate retention policies.

The local MongoDB environment previously displayed an access-control-disabled warning. Authentication and production security controls were not experimentally demonstrated in this portfolio.

They must therefore be enabled and tested before any production deployment.

## 12. Critical Reflection and Limitations

### 12.1 Advantages observed

The document model made it straightforward to store nested student-profile information and associated preferences.

CRUD operations could update nested objects and append activity events without requiring separate relational tables for each profile extension.

The aggregation pipeline also demonstrated convenient analysis of embedded events.

### 12.2 Limitations observed

The implementation used only two synthetic student profiles and three learning activity events.

Consequently, the exercise demonstrated functional correctness but did not establish large-scale query performance, throughput or storage efficiency.

Strict validation also introduces a responsibility to manage document-schema evolution carefully. Changes to required fields or accepted document structures must be planned so that existing documents remain compatible.

The absence of an automatic cross-database synchronisation service is another limitation. The coursework demonstrates the identifier-based association but not end-to-end consistency between the two database systems.

### 12.3 Recommendations

For a production MUN-SRRMS implementation:

- Retain PostgreSQL as the authoritative store for official academic records.
- Use MongoDB for flexible profile extensions and bounded learning-activity summaries.
- Move high-volume learning events into a separately indexed event collection.
- Establish automated profile synchronisation with monitoring and reconciliation.
- Expand validation tests to include activity-array limits, duplicate matriculation numbers and data-type violations.
- Benchmark indexed and unindexed queries using a larger representative dataset.
- Enable authentication, access control and secure backup procedures.

## 13. Conclusion

Portfolio 4 successfully demonstrated the design and implementation of a MongoDB document model that complements the MUN-SRRMS PostgreSQL database.

The practical work included collection creation, strict JSON Schema validation, synthetic document insertion, CRUD operations, unique and secondary indexing, execution-plan inspection and aggregation of embedded learning activities.

Four negative validation tests were successfully rejected by MongoDB, while the CRUD exercise completed without changing the two original sample profiles.

The indexing experiment confirmed that MongoDB used the unique matriculation-number index for the representative lookup. The aggregation exercise returned three correctly grouped learning events.

The work demonstrates that a document-oriented database can support flexible student-facing information while PostgreSQL continues to protect the integrity of official academic transactions.

The evaluation also identifies the need for larger-scale benchmarking, automated cross-database synchronisation and production security controls before the architecture could be considered deployment-ready.
