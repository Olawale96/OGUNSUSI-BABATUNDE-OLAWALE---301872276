
# Database Normalisation Analysis

## 1. Introduction

Database normalisation is the systematic organisation of relational data to minimise unnecessary duplication, prevent insertion, update and deletion anomalies, and improve data integrity.

The Metropolitan University of Nigeria Student Registration and Result Management System (MUN-SRRMS) uses a relational database consisting of nine relations implemented in PostgreSQL.

This analysis evaluates the database against First Normal Form (1NF), Second Normal Form (2NF) and Third Normal Form (3NF). It considers the actual primary keys, candidate keys, functional dependencies, unique constraints and relationships implemented in the database.

An important distinction is made between the normalisation properties of the relational design and the integrity rules that PostgreSQL currently enforces.

## 2. Unnormalised Starting Point

An initial unnormalised university registration record could contain:

Student ID, student name, matriculation number, programme name, department name, course code, course title, lecturer name, semester, registration date, mark and grade.

When a student registers for several courses, student, programme and department information may be repeated across multiple registration records.

Such a design creates three common anomalies.

- **Update anomaly:** Changing a programme or department description may require updating multiple records. An incomplete update can produce inconsistent information.
- **Insertion anomaly:** A new programme or course may be difficult to record independently before a student registers for it.
- **Deletion anomaly:** Deleting the last registration for a course could unintentionally remove the only stored information about that course or its lecturer.

The MUN-SRRMS design addresses these problems by separating the principal university entities into related relations.

## 3. First Normal Form (1NF)

A relation satisfies 1NF when:

1. Each attribute contains a single atomic value.
2. Each record can be uniquely identified by a candidate key.
3. Repeating groups and multivalued attributes are eliminated.

The nine MUN-SRRMS relations use individual attributes for student names, matriculation numbers, email addresses, programme references and course information.

A student registering for several courses does not have several course codes stored in one student record. Instead, each registration is represented by an individual row in ENROLMENT.

Similarly, results are stored in RESULT and linked to the corresponding enrolment.

The design therefore avoids repeating groups and maintains atomic attributes in the implemented relations.

**Assessment:** All nine relations satisfy the implemented 1NF requirements.

## 4. Candidate Keys and Functional Dependencies

Candidate keys are important because they identify the determinants used when evaluating functional dependencies and normalisation.

The actual schema contains the following candidate keys:

| Relation | Candidate keys |
|---|---|
| DEPARTMENT | department_id; department_code; department_name |
| PROGRAMME | programme_id; programme_code; (department_id, programme_name) |
| LECTURER | lecturer_id; staff_number; email |
| STUDENT | student_id; matric_number; email |
| COURSE | course_id; course_code |
| SEMESTER | semester_id; (academic_year, term) |
| COURSE_OFFERING | offering_id; (course_id, semester_id, section_code) |
| ENROLMENT | enrolment_id; (student_id, offering_id) |
| RESULT | result_id; enrolment_id |

The candidate keys arise from the NOT NULL primary-key definitions and the implemented UNIQUE constraints.

The principal functional dependencies include:

| Relation | Functional dependency |
|---|---|
| DEPARTMENT | department_id -> department_code, department_name |
| DEPARTMENT | department_code -> department_id, department_name |
| DEPARTMENT | department_name -> department_id, department_code |
| PROGRAMME | programme_id -> department_id, programme_code, programme_name, award_level |
| PROGRAMME | programme_code -> programme_id, department_id, programme_name, award_level |
| PROGRAMME | (department_id, programme_name) -> programme_id, programme_code, award_level |
| LECTURER | lecturer_id -> staff_number, department_id, first_name, last_name, email |
| LECTURER | staff_number -> lecturer_id, department_id, first_name, last_name, email |
| LECTURER | email -> lecturer_id, staff_number, department_id, first_name, last_name |
| STUDENT | student_id -> matric_number, first_name, last_name, email, date_of_birth, admission_date, programme_id, status |
| STUDENT | matric_number -> student_id, first_name, last_name, email, date_of_birth, admission_date, programme_id, status |
| STUDENT | email -> student_id, matric_number, first_name, last_name, date_of_birth, admission_date, programme_id, status |
| COURSE | course_id -> course_code, course_title, credit_units, department_id |
| COURSE | course_code -> course_id, course_title, credit_units, department_id |
| SEMESTER | semester_id -> academic_year, term, start_date, end_date |
| SEMESTER | (academic_year, term) -> semester_id, start_date, end_date |
| COURSE_OFFERING | offering_id -> course_id, semester_id, lecturer_id, section_code, capacity |
| COURSE_OFFERING | (course_id, semester_id, section_code) -> offering_id, lecturer_id, capacity |
| ENROLMENT | enrolment_id -> student_id, offering_id, registration_date, status |
| ENROLMENT | (student_id, offering_id) -> enrolment_id, registration_date, status |
| RESULT | result_id -> enrolment_id, mark, grade, recorded_at |
| RESULT | enrolment_id -> result_id, mark, grade, recorded_at |

Each listed determinant is a candidate key for its relation and therefore determines the remaining attributes.

## 5. Second Normal Form (2NF)

A relation satisfies 2NF when it is already in 1NF and every non-prime attribute is fully functionally dependent on every candidate key.

In particular, partial dependencies on part of a composite candidate key must be eliminated.

Most MUN-SRRMS relations use single-column candidate keys. These relations cannot have partial dependencies on a composite candidate key.

Two important relations contain composite candidate keys.

### 5.1 ENROLMENT

ENROLMENT contains:

- enrolment_id
- student_id
- offering_id
- registration_date
- status

It has two candidate keys:

- enrolment_id.
- (student_id, offering_id).

The registration_date and status attributes describe a particular student's registration for a particular course offering.

Neither student_id nor offering_id independently identifies that registration or determines its registration date and status.

These attributes therefore depend on the complete student-offering combination.

The UNIQUE constraint on (student_id, offering_id) also prevents duplicate registrations for the same student and offering.

### 5.2 COURSE_OFFERING

COURSE_OFFERING contains:

- offering_id
- course_id
- semester_id
- lecturer_id
- section_code
- capacity

Its candidate keys are:

- offering_id.
- (course_id, semester_id, section_code).

The lecturer assignment and capacity describe the particular course offering, rather than independently depending on only one component of the composite key.

The composite UNIQUE constraint protects the business rule that the same course, semester and section combination cannot be duplicated.

**Assessment:** The implemented relations satisfy the 2NF requirements under the functional dependencies represented by the design.

## 6. Third Normal Form (3NF)

A relation satisfies 3NF when it is in 2NF and, for every non-trivial functional dependency X -> A, at least one of the following is true:

- X is a superkey.
- A is a prime attribute.

A prime attribute belongs to at least one candidate key.

In practical terms, non-key attributes should not depend transitively on candidate keys through other non-key attributes.

The MUN-SRRMS design reduces these dependencies by separating descriptive information into dedicated relations.

Examples include:

- STUDENT stores programme_id instead of repeating programme_name and department_name.
- PROGRAMME stores department_id instead of duplicating department descriptions.
- COURSE stores department_id rather than repeating department information.
- LECTURER stores department_id rather than duplicating department descriptions.
- COURSE_OFFERING references COURSE, SEMESTER and LECTURER through foreign keys.
- ENROLMENT references STUDENT and COURSE_OFFERING.
- RESULT references ENROLMENT instead of repeating student, course and offering information.

These arrangements reduce unnecessary duplication and the possibility of transitive dependencies between descriptive attributes.

### 6.1 Critical evaluation of RESULT and the grade dependency

The RESULT relation contains:

- result_id
- enrolment_id
- mark
- grade
- recorded_at

The implemented schema establishes:

- result_id as the primary key.
- enrolment_id as a UNIQUE foreign key.
- mark between 0 and 100.
- grade within the permitted set A, B, C, D, E and F.

However, the CHECK constraints do not enforce that a grade corresponds to its numerical mark.

Under a fixed grading policy where grade is determined exclusively by mark, the functional dependencies become:

enrolment_id -> mark

mark -> grade

Consequently:

enrolment_id -> mark -> grade

Here, mark is not a candidate key of RESULT, and grade is not a prime attribute. Under this business assumption, RESULT does not strictly satisfy 3NF because of the transitive dependency.

This issue should not be ignored or described as fully resolved.

There are two possible approaches.

**Approach 1: Derive the grade**

If the grade is always determined by the numerical mark, remove the stored grade attribute and calculate it through a database view using the approved grading scale.

This prevents inconsistent combinations of marks and grades.

**Approach 2: Record an independent awarded grade**

If the university permits moderation, resits, special assessment decisions or changes to grading policies, the awarded grade may not be determined solely by the numerical mark.

In that situation, the grading policy and assessment context must be explicitly represented, including an appropriate policy identifier or version.

The database should then enforce the relevant business rules through suitable constraints or validation logic.

**Assessment:** The other relations have a 3NF-oriented structure under the functional dependencies identified in this analysis. The RESULT relation has a documented conditional 3NF issue under a fixed grading policy. The implemented schema should therefore not be presented as unconditionally satisfying 3NF.

## 7. Integrity Constraints and Design Decisions

The database uses several integrity mechanisms:

- **Primary keys:** Uniquely identify records across all nine relations.
- **Foreign keys:** Maintain valid relationships between departments, programmes, students, courses, offerings, enrolments and results.
- **UNIQUE constraints:** Prevent duplicate business identifiers, including matriculation numbers, staff numbers, course codes and duplicate registrations.
- **CHECK constraints:** Restrict award levels, student statuses, semester terms, enrolment statuses, credit units, capacities, marks and grades.
- **NOT NULL constraints:** Ensure that mandatory attributes cannot be omitted.
- **Indexes:** Support frequently used joins and lookups.

The design uses surrogate primary keys while preserving important business candidate keys through UNIQUE constraints.

The ON UPDATE CASCADE and ON DELETE RESTRICT referential actions also provide controlled behaviour when referenced records are changed or deletion is attempted.

## 8. Limitations and Further Normalisation

The current design implements one final result per enrolment.

A more comprehensive university assessment system would require additional relations to support:

- Continuous assessment.
- Examination components.
- Resits and supplementary examinations.
- Multiple assessment attempts.
- Versioned grading policies.
- Audit records for changes to academic results.

These extensions would require a fresh analysis of functional dependencies and candidate keys to ensure that new relations maintain appropriate normalisation properties.

The current design is therefore suitable as a foundation for the academic registration and final result operations in this case study, but it is not a complete production university academic information system.

## 9. Conclusion

Normalisation has provided a structured relational foundation for MUN-SRRMS.

The design separates the major university entities, resolves the many-to-many relationship between students and course offerings, and uses primary keys, candidate keys, foreign keys and integrity constraints to protect the accuracy of stored records.

The implemented relations satisfy the core 1NF and 2NF requirements and substantially reduce unnecessary duplication and transitive dependencies.

The analysis also identifies an important conditional 3NF issue involving the relationship between numerical marks and grades in RESULT.

By acknowledging this limitation and identifying appropriate corrective approaches, the normalisation analysis evaluates the actual implementation rather than making unsupported claims of complete 3NF compliance.
