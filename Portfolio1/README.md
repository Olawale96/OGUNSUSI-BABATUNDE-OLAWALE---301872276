
# MUN-SRRMS - Portfolio 1: Database Design and Modelling

## Project Information

**Case study:** Metropolitan University of Nigeria (MUN), a fictional Nigerian university.

**System:** Student Registration and Result Management System (SRRMS).

**Database:** PostgreSQL.

**Tested DBMS version:** PostgreSQL 18.6.

**Database name:** `mun_srrms`.

**Schema name:** `mun_srrms`.

**Implementation environment:** Windows 64-bit using the PostgreSQL command-line client (`psql`).

**Implementation status:** Relational schema implemented, sample data populated, and database integrity validation executed successfully.

## 1. Project Description

The MUN Student Registration and Result Management System is a relational database project designed to support the management of university academic information.

The database supports:

- Department and programme management.
- Lecturer and student records.
- Course and semester management.
- Course offering allocation.
- Student course registration.
- Final result recording and retrieval.

The project demonstrates relational database modelling, SQL implementation, normalisation, integrity constraints and database validation.

## 2. Project Structure

```text
Portfolio1/
│
├── sql/
│   ├── 01_schema.sql
│   ├── 02_seed_data.sql
│   └── 03_validation_tests.sql
│
├── docs/
│   ├── case-study.md
│   ├── relational-schema.md
│   ├── normalisation.md
│   ├── erd.mmd
│   ├── erd.md
│   └── evidence-checklist.md
│
├── evidence/
│   └── Screenshots of actual implementation and testing
│
└── README.md
```

## 3. Database Architecture

The relational database contains nine tables:

1. DEPARTMENT
2. PROGRAMME
3. LECTURER
4. STUDENT
5. COURSE
6. SEMESTER
7. COURSE_OFFERING
8. ENROLMENT
9. RESULT

The implementation includes:

- Primary keys and foreign keys.
- Unique constraints and composite unique constraints.
- Check constraints and NOT NULL constraints.
- Identity columns.
- Nine explicitly created indexes on foreign-key columns.
- Referential integrity using ON UPDATE CASCADE and ON DELETE RESTRICT.

## 4. Software Requirements

- PostgreSQL 14 or later.
- PostgreSQL command-line client (`psql`) or pgAdmin.
- Windows, Linux or macOS.
- Permission to create a database and schema.

The implementation was executed and verified using PostgreSQL 18.6 on Windows 64-bit.

## 5. Database Installation and Execution

The following instructions reproduce the implementation on a fresh PostgreSQL installation.

### Step 1: Create the database

From PowerShell, run:

```powershell
psql -U postgres -h localhost -p 5432 -d postgres -c "CREATE DATABASE mun_srrms;"
```

This command creates the project database. Run it only once; skip it if the database already exists.

### Step 2: Navigate to the Portfolio 1 folder

From the parent project directory, run:

```powershell
cd .\Portfolio1
```

### Step 3: Execute the schema script

```powershell
psql -U postgres -h localhost -p 5432 -d mun_srrms -v ON_ERROR_STOP=1 -f .\sql\01_schema.sql
```

This creates the schema, nine tables, constraints and indexes.

### Step 4: Insert the sample data

```powershell
psql -U postgres -h localhost -p 5432 -d mun_srrms -v ON_ERROR_STOP=1 -f .\sql\02_seed_data.sql
```

The sample data consists entirely of synthetic university records.

Run this script only once on a freshly created schema.

### Step 5: Execute the validation tests

```powershell
psql -U postgres -h localhost -p 5432 -d mun_srrms -v ON_ERROR_STOP=1 -f .\sql\03_validation_tests.sql
```

The validation script tests:

- Database table inventory.
- Student, programme and department relationships.
- Enrolment and result relationships.
- Duplicate matriculation prevention.
- Duplicate enrolment prevention.
- Invalid mark rejection.
- Invalid foreign-key rejection.

Negative tests use transaction rollbacks so that unsuccessful test operations do not remain in the database.

## 6. Implementation and Testing Results

The following results were obtained during local implementation:

| Item | Verified result |
|---|---:|
| Database schema | Created |
| Relational tables | 9 |
| Explicit indexes | 9 |
| Departments | 2 |
| Programmes | 2 |
| Lecturers | 2 |
| Students | 3 |
| Courses | 2 |
| Semesters | 1 |
| Course offerings | 2 |
| Enrolments | 4 |
| Results | 2 |

All four negative integrity tests passed:

1. Duplicate matriculation number rejected.
2. Mark above 100 rejected.
3. Invalid programme foreign key rejected.
4. Duplicate student-course enrolment rejected.

The implementation and validation were executed locally on 31 October 2026.

## 7. Documentation

The `docs` directory contains:

- `case-study.md`: Organisation background, system requirements, database users and operational scope.
- `relational-schema.md`: Table definitions, attributes, keys, relationships and constraints.
- `normalisation.md`: Analysis of 1NF, 2NF and 3NF, functional dependencies and design limitations.
- `erd.mmd`: Mermaid Entity Relationship Diagram source.
- `erd.md`: Markdown version used to render the ER diagram.
- `evidence-checklist.md`: Practical implementation and assessment evidence requirements.

## 8. Evidence and Reproducibility

The `evidence` directory contains screenshots documenting the actual database implementation and testing.

Evidence includes:

- PostgreSQL version.
- Successful schema creation.
- Database table inventory.
- Successful sample-data insertion.
- Record-count verification.
- Validation results.
- Rendered Entity Relationship Diagram.
- Database constraint definitions.

Screenshots must represent genuine execution results. Passwords and other sensitive information must not be included.

## 9. Known Design Limitations

The current implementation has several documented limitations:

- Course capacity is stored but not yet enforced during registration.
- Mark and grade values are individually validated, but their correspondence is not enforced.
- Application-level authentication and role-based permissions are not implemented.
- Multiple assessment components are outside the current design.
- A comprehensive academic audit trail has not yet been implemented.

These limitations provide opportunities for further development and critical evaluation.

## 10. Academic Integrity and Data Protection

All sample records are synthetic and created solely for academic demonstration.

No real student records or personal university information should be inserted into the demonstration database.

The project must be evaluated using actual implementation evidence, test results and the student's own technical analysis.
