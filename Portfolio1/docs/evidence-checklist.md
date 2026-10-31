
# Portfolio 1 Evidence Checklist

## 1. Environment and Database Setup

- [x] Screenshot of PostgreSQL version showing PostgreSQL 18.6.
- [x] Screenshot of successful execution of 01_schema.sql.
- [x] Screenshot of all nine tables listed in PostgreSQL.
- [x] Screenshot of table definitions, primary keys and foreign keys.

## 2. Data Population and Query Execution

- [x] Screenshot of successful execution of 02_seed_data.sql.
- [x] Screenshot showing record counts for all nine tables.
- [x] Screenshot showing students with their programme and department.
- [x] Screenshot showing enrolments and result details.

## 3. Database Integrity and Validation

- [x] Duplicate matriculation number rejected.
- [x] Mark outside the permitted 0–100 range rejected.
- [x] Invalid programme foreign key rejected.
- [x] Duplicate student-course enrolment rejected.
- [x] Updated screenshot showing all four successful negative tests.

## 4. Database Design Documentation

- [x] ERD source file: docs/erd.mmd.
- [x] Rendered ERD showing all nine entities and relationships.
- [x] Relational schema documentation.
- [x] Normalisation analysis covering 1NF, 2NF and 3NF.
- [x] Case-study documentation.

## 5. Project Management and Reflection

- [ ] Git commit history showing incremental development.
- [ ] Technical reflection explaining:
  - One important database design decision.
  - One implementation or testing challenge.
  - How the challenge was resolved.
  - One proposed improvement to the database.
- [ ] Final review of README.md and project documentation.

## 6. Evidence Environment Details

Operating System: Windows

Database Management System: PostgreSQL 18.6

Database Client: PostgreSQL command-line client (psql)

Project Database: mun_srrms

Project Schema: mun_srrms

Test Date: 31 October 2026

All sample records are synthetic and created for academic demonstration.

## 7. Evidence Storage

Store screenshots in the Portfolio1/evidence/ directory.

Recommended filenames:

1. 01_schema_creation.png
2. 02_table_inventory.png
3. 03_seed_data.png
4. 04_record_counts.png
5. 05_validation_tests.png
6. 06_entity_relationship_diagram.png
7. 07_postgresql_version.png
8. 08_table_constraints.png

All screenshots must represent genuine execution evidence. Remove passwords and other sensitive information before submission.
