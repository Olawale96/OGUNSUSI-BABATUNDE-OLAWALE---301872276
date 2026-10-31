
# Technical Reflection: Portfolio 1 - Database Design and Modelling

## 1. Introduction

This portfolio activity involved the design, implementation and testing of a relational database for the Metropolitan University of Nigeria Student Registration and Result Management System (MUN-SRRMS).

The main objective was to develop a structured database capable of supporting university academic operations, including student registration, programme administration, course scheduling, lecturer allocation and result management.

I implemented the database using PostgreSQL 18.6 on a Windows 64-bit environment, using the PostgreSQL command-line client (psql). The exercise provided practical experience in translating organisational requirements into a relational database structure, applying integrity constraints, populating tables and testing database behaviour.

## 2. Database Design Decisions

One important design decision was to use a relational database rather than storing all academic information in a single table.

The university system contains several related entities, including departments, programmes, students, lecturers, courses, semesters, course offerings, enrolments and results. Separating these entities into nine tables reduced unnecessary duplication and established clear relationships between academic records.

I used integer identity columns as surrogate primary keys. This provides stable internal identifiers while unique constraints protect natural business identifiers such as matriculation numbers, staff numbers and course codes.

Another important decision was to resolve the many-to-many relationship between students and course offerings through the ENROLMENT table. This allows a student to register for several course offerings while allowing each offering to contain multiple students.

The composite unique constraint on (student_id, offering_id) was particularly important because it prevents the same student from registering more than once for the same offering.

I also implemented foreign keys, CHECK constraints, NOT NULL constraints and indexes. These mechanisms help enforce data integrity and support common database operations.

## 3. Implementation Experience

The implementation was completed in stages.

First, I installed and verified PostgreSQL 18.6. I created a dedicated database named `mun_srrms` and implemented the relational schema using the `01_schema.sql` script.

The schema successfully created nine tables and nine explicitly defined indexes. Primary keys, foreign keys, uniqueness rules and validation constraints were also established.

Second, I executed `02_seed_data.sql` to populate the database with synthetic university records.

The resulting database contained:

| Data category | Records |
|---|---:|
| Departments | 2 |
| Programmes | 2 |
| Lecturers | 2 |
| Students | 3 |
| Courses | 2 |
| Semesters | 1 |
| Course offerings | 2 |
| Enrolments | 4 |
| Results | 2 |

Third, I executed the validation script and used additional SQL queries to verify the database structure, record counts and relationships.

This staged approach made it easier to identify implementation problems and confirm that each part of the database was working before proceeding.

## 4. Challenges Encountered and How They Were Resolved

Several practical challenges arose during implementation.

### 4.1 Working directory and file paths

At one point, I executed a PowerShell command from the wrong directory. PostgreSQL project files could not be located because the terminal was no longer positioned in the project folder.

I resolved this by navigating back to the correct project directory using the `cd` command and confirming the location with `Get-Location`.

This demonstrated the importance of understanding the command-line working directory when executing database scripts.

### 4.2 Entity Relationship Diagram parsing

While rendering the Mermaid ERD, I encountered a parsing error caused by the way a composite unique constraint had been represented as an entity attribute.

I corrected the Mermaid notation by removing the unsupported attribute representation and documenting the uniqueness rule in comments and supporting documentation instead.

The diagram subsequently rendered, displaying the nine database entities and their relationships.

This experience highlighted the difference between logical database constraints and the syntax supported by a particular diagramming tool.

### 4.3 Incomplete duplicate-enrolment testing

The original validation script checked whether duplicate enrolment records already existed, but it did not directly attempt to insert a duplicate registration.

I identified this gap and added a negative test that attempted to register an already-enrolled student for the same course offering.

PostgreSQL rejected the operation because of the composite unique constraint.

The test displayed the expected PASS notification, demonstrating that the database enforced the intended business rule.

This was an important lesson: checking that invalid records do not currently exist is different from testing whether the database actively prevents their insertion.

### 4.4 Database evidence and verification

Another challenge was ensuring that the portfolio contained evidence of actual implementation rather than screenshots of SQL code alone.

I used PostgreSQL queries to verify the database version, table inventory, record counts and constraint definitions. I also captured execution output for schema creation, data insertion and validation.

This improved my understanding of reproducibility and the importance of supporting technical claims with genuine execution evidence.

## 5. Testing and Validation Outcomes

The database underwent both positive and negative testing.

Positive tests confirmed that the nine tables existed, student records were correctly associated with their programmes and departments, and enrolment records could be joined to course offerings and results.

The record-count verification also confirmed that all nine tables contained the expected sample records.

Negative testing demonstrated that PostgreSQL rejected:

1. A duplicate matriculation number.
2. A mark greater than 100.
3. A student referencing a non-existent programme.
4. A duplicate registration for the same course offering.

All four negative tests produced their expected PASS notifications.

The tests demonstrated that primary keys, unique constraints, foreign keys and CHECK constraints were functioning as intended.

## 6. Critical Evaluation and Design Limitations

Although the implementation is functional, several limitations remain.

First, course capacity is stored in the COURSE_OFFERING table, but the database does not yet prevent registrations from exceeding that capacity. A suitable transactional or database-level mechanism would be required to enforce this rule safely when several students register concurrently.

Second, the RESULT table stores both numerical marks and grades. Although PostgreSQL validates the permitted range of each value, it does not guarantee that the grade corresponds to the numerical mark. Where grade is entirely determined by mark under a fixed policy, this also introduces a potential transitive dependency that requires consideration in the normalisation design.

A database view or a properly versioned grading policy could provide a stronger solution.

Third, application authentication, role-based access control and detailed auditing have not yet been implemented. These would be essential considerations before deploying the system in a real university environment.

Finally, the current model supports one final result per enrolment. A more comprehensive academic system would require additional relations for continuous assessment, examination components, resits and multiple assessment attempts.

These limitations demonstrate that a functioning relational schema is only one component of a complete academic information system.

## 7. Knowledge and Skills Acquired

This implementation improved my practical understanding of relational database design and administration.

I gained experience in:

- Translating organisational requirements into relational entities and relationships.
- Implementing primary keys, foreign keys and candidate keys.
- Applying normalisation principles to reduce data duplication.
- Using SQL scripts to create and populate relational tables.
- Applying CHECK, UNIQUE and NOT NULL constraints.
- Testing referential integrity and duplicate prevention.
- Using transactions and rollbacks during negative testing.
- Inspecting PostgreSQL system metadata to verify database structures.
- Producing an Entity Relationship Diagram and technical documentation.
- Maintaining implementation evidence for reproducibility.

An important lesson was that database correctness should not be assumed merely because SQL scripts execute successfully. The actual records, relationships and constraints must also be tested.

## 8. Proposed Improvements

The following improvements would strengthen the database in subsequent development:

1. Introduce transactional enforcement of course offering capacity.
2. Improve grade processing through a defined and versioned grading policy.
3. Introduce user authentication and role-based access control.
4. Add assessment-level records to support multiple assessment components.
5. Introduce comprehensive audit logging for changes to important academic records.
6. Evaluate the effectiveness of existing indexes using query execution plans.
7. Implement appropriate backup, recovery and replication procedures.

These improvements will help connect the initial relational design exercise with the later portfolio activities.

## 9. Conclusion

Portfolio 1 provided practical experience in designing, implementing and validating a relational database using PostgreSQL.

The MUN-SRRMS database successfully established nine related tables, populated them with synthetic academic records and enforced important integrity rules.

The validation exercises demonstrated that PostgreSQL could prevent duplicate student registrations, reject invalid marks and maintain referential integrity.

Beyond implementation, the exercise reinforced the importance of normalisation, appropriate key selection, systematic testing, technical documentation and critical evaluation of design limitations.

The completed relational model provides a foundation for the subsequent portfolio activities involving SQL query optimisation, transaction processing, concurrency control, MongoDB data modelling and distributed database technologies.
