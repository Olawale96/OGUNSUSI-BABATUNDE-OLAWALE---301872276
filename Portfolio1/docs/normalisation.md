
# Database Normalisation Analysis

## 1. Introduction

Database normalisation is the systematic organisation of relational data to minimise unnecessary duplication, prevent data anomalies, and improve data integrity. The Metropolitan University of Nigeria Student Registration and Result Management System (MUN-SRRMS) uses a relational design consisting of nine tables.

The database design was evaluated against First Normal Form (1NF), Second Normal Form (2NF), and Third Normal Form (3NF). The analysis considers the candidate keys, functional dependencies, relationships, and constraints implemented in PostgreSQL.

## 2. Unnormalised Starting Point

An initial unnormalised student registration record could contain:

Student ID, student name, matriculation number, programme name, department name, course code, course title, lecturer name, semester, registration date, mark, and grade.

If a student registers for five courses, the student, programme, and department information may be repeated across five records.

This arrangement creates three common data anomalies:

- **Update anomaly:** Changing a student's programme or department information may require updating several records. Inconsistent updates can produce conflicting data.
- **Insertion anomaly:** A department or programme may not be recorded independently until a student registers for a course.
- **Deletion anomaly:** Removing the last registration for a particular course could unintentionally remove the only stored record of related course or lecturer information.

The MUN-SRRMS design addresses these problems by separating entities into related tables.

## 3. First Normal Form (1NF)

A relation satisfies 1NF when:

1. Each attribute contains a single, atomic value.
2. Each row can be uniquely identified by a key.
3. Repeating groups and multivalued attributes are eliminated.

The MUN-SRRMS database satisfies these requirements. For example, student names, matriculation numbers, email addresses, and programme references are stored in separate columns.

A student registering for multiple courses does not have a list of course codes stored in one student record. Instead, each registration is represented by a separate row in the ENROLMENT table.

Similarly, results are recorded in the RESULT table and linked to the corresponding enrolment.

**Assessment:** The nine relations satisfy the implemented 1NF design requirements.

## 4. Second Normal Form (2NF)

A relation satisfies 2NF when it is already in 1NF and every non-prime attribute is fully functionally dependent on every candidate key. This means partial dependencies on part of a composite candidate key must be eliminated.

The MUN-SRRMS design separates student, course, lecturer, programme, and semester information into their respective relations.

The relationship between STUDENT and COURSE_OFFERING is many-to-many. It is resolved through the ENROLMENT table.

The ENROLMENT relation has two candidate keys:

- enrolment_id, the primary key.
- (student_id, offering_id), the composite candidate key enforced by a UNIQUE constraint.

The registration date and enrolment status describe the particular student registration for a particular course offering. They are therefore dependent on the complete student-offering combination, rather than on student_id or offering_id independently.

The use of a single-column surrogate primary key does not remove the need to enforce the business candidate key. The composite UNIQUE constraint prevents duplicate registrations.

The other tables use single-column primary keys or additional unique candidate keys. Their non-key attributes are associated with their respective entity identifiers.

**Assessment:** The relations satisfy the 2NF requirements under the functional dependencies represented by the implemented design.

## 5. Third Normal Form (3NF)

A relation satisfies 3NF when it is in 2NF and every non-trivial functional dependency X → A satisfies at least one of these conditions:

- X is a superkey; or
- A is a prime attribute.

In practical terms, non-key attributes should not depend transitively on candidate keys through other non-key attributes.

The MUN-SRRMS design separates programme and department information from student records. For example, STUDENT stores programme_id instead of repeating programme_name and department_name.

PROGRAMME stores its department reference, while DEPARTMENT maintains the department's descriptive information.

Similarly:

- COURSE stores department_id instead of repeating department details.
- LECTURER stores department_id rather than duplicating department information.
- COURSE_OFFERING references COURSE, SEMESTER, and LECTURER using foreign keys.
- ENROLMENT references STUDENT and COURSE_OFFERING instead of repeating their descriptive attributes.

These arrangements reduce transitive dependencies and unnecessary duplication.

### 5.1 Result and Grade Design Consideration

The RESULT table currently stores enrolment_id, mark, grade, and recorded_at.

The enrolment_id identifies the result, while mark records the student's numerical performance and grade stores the corresponding classification.

There is an important design consideration: when grade is determined entirely by mark under a fixed grading policy, mark determines grade. Consequently, the dependency chain becomes:

enrolment_id → mark → grade

This introduces a potential transitive dependency and means the RESULT relation may not strictly satisfy 3NF under that grading assumption.

The current database checks that marks are between 0 and 100 and that grades belong to the permitted grade set. However, these constraints do not ensure that the grade corresponds to the mark.

Two possible improvements are:

1. Remove the stored grade and calculate it using a database view based on the mark and an established grading policy.
2. Retain grade as an officially awarded result, but record the applicable grading-policy version and enforce consistency through application or database validation.

For a production university system, the grading policy should be explicitly defined and versioned to preserve the interpretation of historical results.

This limitation is acknowledged rather than presenting the existing implementation as having an integrity guarantee that it does not currently provide.

## 6. Key Functional Dependencies

The principal functional dependencies include:

| Relation | Functional dependency |
|---|---|
| DEPARTMENT | department_id → department_code, department_name |
| PROGRAMME | programme_id → department_id, programme_code, programme_name, award_level |
| LECTURER | lecturer_id → staff_number, department_id, first_name, last_name, email |
| STUDENT | student_id → matric_number, names, email, programme_id, status |
| COURSE | course_id → course_code, course_title, credit_units, department_id |
| SEMESTER | semester_id → academic_year, term, start_date, end_date |
| COURSE_OFFERING | offering_id → course_id, semester_id, lecturer_id, section_code, capacity |
| ENROLMENT | enrolment_id → student_id, offering_id, registration_date, status |
| RESULT | result_id → enrolment_id, mark, grade, recorded_at |

Additional candidate keys are enforced using UNIQUE constraints. Examples include department_code, matric_number, programme_code, course_code, academic_year with term, and the composite student_id with offering_id in ENROLMENT.

## 7. Integrity Constraints and Design Decisions

The database uses several integrity mechanisms:

- **Primary keys:** Uniquely identify records in all nine relations.
- **Foreign keys:** Maintain valid relationships between departments, programmes, students, courses, offerings, enrolments, and results.
- **UNIQUE constraints:** Prevent duplicate matriculation numbers, staff numbers, course codes, registrations, and other duplicate business identifiers.
- **CHECK constraints:** Restrict award levels, student statuses, enrolment statuses, semester terms, credit units, capacities, dates, marks, and grades.
- **NOT NULL constraints:** Ensure that required attributes cannot be omitted.
- **Indexes:** Support commonly used joins and lookup operations. Their performance impact will be examined in Portfolio 2.

The database uses a surrogate primary key for each main entity while preserving important business uniqueness rules through additional constraints.

The model intentionally represents one final result per enrolment. A more extensive assessment system would introduce separate ASSESSMENT and ASSESSMENT_SCORE relations to support continuous assessment, examinations, resits, and multiple assessment components.

## 8. Conclusion

Normalisation has provided a structured relational foundation for the MUN-SRRMS database. The design separates university entities, resolves the student-to-course-offering many-to-many relationship, and uses keys and integrity constraints to protect the accuracy of stored records.

The implemented structure satisfies the core 1NF and 2NF design requirements and substantially reduces transitive dependencies through its 3NF-oriented structure. The stored grade attribute remains a documented design consideration requiring a grading-policy decision before claiming strict 3NF compliance for the RESULT relation.
