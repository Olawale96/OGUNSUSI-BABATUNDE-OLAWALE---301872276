
# Relational Database Schema

## 1. Database Overview

**System:** Metropolitan University of Nigeria Student Registration and Result Management System (MUN-SRRMS)

**DBMS:** PostgreSQL 18.6

**Database:** `mun_srrms`

**Schema:** `mun_srrms`

The database contains nine relational tables. Surrogate integer primary keys provide stable internal identifiers, while unique constraints preserve the uniqueness of important business identifiers.

Notation:
- PK = Primary Key
- FK = Foreign Key
- UQ = Unique Constraint
- NN = NOT NULL
- ID = Identity column
- CK = CHECK Constraint

## 2. Relational Schema Definitions

### 2.1 DEPARTMENT

`department`

| Attribute | Data type | Constraint |
|---|---|---|
| department_id | INTEGER | PK, ID |
| department_code | VARCHAR(12) | NN, UQ |
| department_name | VARCHAR(120) | NN, UQ |

Additional constraints:
- department_code must not be blank.
- department_name must not be blank.

### 2.2 PROGRAMME

`programme`

| Attribute | Data type | Constraint |
|---|---|---|
| programme_id | INTEGER | PK, ID |
| department_id | INTEGER | NN, FK |
| programme_code | VARCHAR(20) | NN, UQ |
| programme_name | VARCHAR(160) | NN |
| award_level | VARCHAR(20) | NN |

Additional constraints:
- Foreign key: department_id references department(department_id).
- Unique combination: (department_id, programme_name).
- award_level must be one of ND, HND, BSc, BEng, MSc, MTech or PhD.
- programme_name must not be blank.

### 2.3 LECTURER

`lecturer`

| Attribute | Data type | Constraint |
|---|---|---|
| lecturer_id | INTEGER | PK, ID |
| staff_number | VARCHAR(20) | NN, UQ |
| department_id | INTEGER | NN, FK |
| first_name | VARCHAR(80) | NN |
| last_name | VARCHAR(80) | NN |
| email | VARCHAR(254) | NN, UQ |

Additional constraints:
- Foreign key: department_id references department(department_id).
- staff_number must not be blank.
- email must not be blank.

### 2.4 STUDENT

`student`

| Attribute | Data type | Constraint |
|---|---|---|
| student_id | INTEGER | PK, ID |
| matric_number | VARCHAR(24) | NN, UQ |
| first_name | VARCHAR(80) | NN |
| last_name | VARCHAR(80) | NN |
| email | VARCHAR(254) | NN, UQ |
| date_of_birth | DATE | Nullable |
| admission_date | DATE | NN |
| programme_id | INTEGER | NN, FK |
| status | VARCHAR(20) | NN, Default: active |

Additional constraints:
- Foreign key: programme_id references programme(programme_id).
- status must be active, suspended, withdrawn or graduated.
- matric_number and email must not be blank.
- date_of_birth, when supplied, must be earlier than admission_date.

### 2.5 COURSE

`course`

| Attribute | Data type | Constraint |
|---|---|---|
| course_id | INTEGER | PK, ID |
| course_code | VARCHAR(16) | NN, UQ |
| course_title | VARCHAR(160) | NN |
| credit_units | SMALLINT | NN |
| department_id | INTEGER | NN, FK |

Additional constraints:
- Foreign key: department_id references department(department_id).
- credit_units must be between 1 and 6.
- course_code and course_title must not be blank.

### 2.6 SEMESTER

`semester`

| Attribute | Data type | Constraint |
|---|---|---|
| semester_id | INTEGER | PK, ID |
| academic_year | VARCHAR(9) | NN |
| term | VARCHAR(16) | NN |
| start_date | DATE | NN |
| end_date | DATE | NN |

Additional constraints:
- Unique combination: (academic_year, term).
- term must be First, Second or Summer.
- end_date must be on or after start_date.

### 2.7 COURSE_OFFERING

`course_offering`

| Attribute | Data type | Constraint |
|---|---|---|
| offering_id | INTEGER | PK, ID |
| course_id | INTEGER | NN, FK |
| semester_id | INTEGER | NN, FK |
| lecturer_id | INTEGER | NN, FK |
| section_code | VARCHAR(10) | NN, Default: A |
| capacity | INTEGER | NN, Default: 100 |

Additional constraints:
- course_id references course(course_id).
- semester_id references semester(semester_id).
- lecturer_id references lecturer(lecturer_id).
- Unique combination: (course_id, semester_id, section_code).
- capacity must be between 1 and 1000.
- section_code must not be blank.

### 2.8 ENROLMENT

`enrolment`

| Attribute | Data type | Constraint |
|---|---|---|
| enrolment_id | INTEGER | PK, ID |
| student_id | INTEGER | NN, FK |
| offering_id | INTEGER | NN, FK |
| registration_date | DATE | NN, Default: CURRENT_DATE |
| status | VARCHAR(20) | NN, Default: registered |

Additional constraints:
- student_id references student(student_id).
- offering_id references course_offering(offering_id).
- Unique combination: (student_id, offering_id).
- status must be registered, dropped or completed.

The composite unique constraint prevents a student from registering for the same course offering more than once.

### 2.9 RESULT

`result`

| Attribute | Data type | Constraint |
|---|---|---|
| result_id | INTEGER | PK, ID |
| enrolment_id | INTEGER | NN, FK, UQ |
| mark | NUMERIC(5,2) | NN |
| grade | VARCHAR(2) | NN |
| recorded_at | TIMESTAMPTZ | NN, Default: CURRENT_TIMESTAMP |

Additional constraints:
- enrolment_id references enrolment(enrolment_id).
- enrolment_id is unique, allowing at most one result per enrolment.
- mark must be between 0 and 100.
- grade must be A, B, C, D, E or F.

The grade is stored alongside the numerical mark. The current constraints validate their individual permitted values but do not enforce the correspondence between them. This design consideration is discussed in the normalisation analysis.

## 3. Relationship Cardinalities

| Parent entity | Child entity | Relationship |
|---|---|---|
| Department | Programme | One-to-many |
| Department | Lecturer | One-to-many |
| Department | Course | One-to-many |
| Programme | Student | One-to-many |
| Course | Course Offering | One-to-many |
| Semester | Course Offering | One-to-many |
| Lecturer | Course Offering | One-to-many |
| Student | Enrolment | One-to-many |
| Course Offering | Enrolment | One-to-many |
| Enrolment | Result | One-to-zero-or-one |

The STUDENT and COURSE_OFFERING entities have a many-to-many relationship resolved through the ENROLMENT associative entity.

## 4. Candidate Keys and Uniqueness

The database enforces the following candidate keys through primary keys and unique constraints:

| Relation | Candidate key or unique identifier |
|---|---|
| DEPARTMENT | department_id, department_code, department_name |
| PROGRAMME | programme_id, programme_code, (department_id, programme_name) |
| LECTURER | lecturer_id, staff_number, email |
| STUDENT | student_id, matric_number, email |
| COURSE | course_id, course_code |
| SEMESTER | semester_id, (academic_year, term) |
| COURSE_OFFERING | offering_id, (course_id, semester_id, section_code) |
| ENROLMENT | enrolment_id, (student_id, offering_id) |
| RESULT | result_id, enrolment_id |

The identity-generated primary keys are surrogate identifiers. The other unique keys protect business-level uniqueness.

## 5. Referential Integrity

All foreign-key constraints use:

- ON UPDATE CASCADE
- ON DELETE RESTRICT

This ensures that referenced key updates propagate to related records while preventing deletion of parent records that are still referenced by dependent records.

For example:
- A department cannot be deleted while programmes, lecturers or courses reference it.
- A student cannot be deleted while enrolment records reference that student.
- An enrolment cannot be deleted while a result references it.

This protects the consistency of related academic records.

## 6. Indexing Strategy

PostgreSQL automatically creates indexes for primary keys and unique constraints.

The schema also creates nine explicit indexes on foreign-key columns:

| Index | Table and column |
|---|---|
| idx_programme_department | programme(department_id) |
| idx_lecturer_department | lecturer(department_id) |
| idx_student_programme | student(programme_id) |
| idx_course_department | course(department_id) |
| idx_offering_course | course_offering(course_id) |
| idx_offering_semester | course_offering(semester_id) |
| idx_offering_lecturer | course_offering(lecturer_id) |
| idx_enrolment_student | enrolment(student_id) |
| idx_enrolment_offering | enrolment(offering_id) |

These indexes are intended to support common join and lookup operations. Their actual performance benefits, storage costs and maintenance overhead will be evaluated in Portfolio 2 using query execution plans and performance measurements.

## 7. Design Summary

The relational model uses nine tables to represent the principal entities and operations of a university registration and result management system.

The design applies:
- Primary keys for entity identification.
- Foreign keys for referential integrity.
- Unique constraints for candidate keys and business identifiers.
- Check constraints for domain and value validation.
- Identity columns for automatically generated surrogate identifiers.
- Indexes to support relational queries.

The model provides a structured foundation for student registration, course allocation, semester management, lecturer assignment, enrolment tracking and result recording.
