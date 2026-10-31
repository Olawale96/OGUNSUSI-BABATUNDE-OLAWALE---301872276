
# Case Study: Metropolitan University of Nigeria (MUN)

## 1. Organisation Background

Metropolitan University of Nigeria (MUN) is a fictional Nigerian higher education institution developed as the case-study organisation for this Advanced Database Systems portfolio.

The university offers undergraduate and postgraduate programmes across several academic departments. Its academic activities involve student admissions, programme administration, course scheduling, semester registration, lecturer allocation, assessment and result management.

As student numbers, academic programmes and course offerings increase, maintaining these records through disconnected spreadsheets and manual processes becomes difficult. Such an approach can introduce data duplication, inconsistent student records, registration errors, poor reporting and difficulties maintaining academic information.

To address these challenges, the university requires a Student Registration and Result Management System (SRRMS).

## 2. System Description

The SRRMS is an academic information management system designed to maintain structured university records and support student registration and result processing.

For Portfolio 1, PostgreSQL 18.6 is used as the primary relational database management system. It stores the university's authoritative academic reference records, student information, course offerings, enrolments and final results.

The wider portfolio will extend the same scenario through MongoDB for selected flexible data, transaction and concurrency experiments, and distributed database exercises involving replication, backup and recovery.

## 3. Database Users and Their Responsibilities

| User category | Responsibilities |
|---|---|
| Students | Review personal academic information, registered courses and published results. |
| Lecturers | View assigned course offerings and submit or verify student results. |
| Department administrators | Maintain departmental programmes, courses and lecturer information. |
| Registry staff | Manage student academic records, registration activities and official reports. |
| Heads of Department | Review departmental course and academic performance information. |
| Database administrators | Maintain database availability, access controls, backups, integrity and performance. |

These are the intended system user categories. The Portfolio 1 relational schema establishes the data structures but does not yet implement application authentication, user-specific permissions or role-based access control.

## 4. Major Data Stored

The relational database contains nine principal entities:

1. **Department:** Department identifiers, codes and names.
2. **Programme:** Academic programmes, award levels and departmental ownership.
3. **Lecturer:** Staff identifiers, names, email addresses and departmental membership.
4. **Student:** Matriculation numbers, personal details, admission dates, programme assignments and academic status.
5. **Course:** Course codes, titles, credit units and departmental ownership.
6. **Semester:** Academic years, terms and semester dates.
7. **Course Offering:** Courses scheduled for a particular semester, assigned lecturers, sections and registration capacity.
8. **Enrolment:** Student registrations for specific course offerings, including registration dates and status.
9. **Result:** Final numerical marks, grades and result recording timestamps.

The database uses primary keys, foreign keys, unique constraints and validation rules to maintain the integrity of these records.

## 5. Major Operations Supported

The SRRMS is designed to support the following operations:

### 5.1 Academic Structure Management
- Create and maintain academic departments.
- Register programmes under departments.
- Maintain course information and credit units.
- Maintain lecturer records and departmental assignments.

### 5.2 Student Record Management
- Register student records.
- Assign students to academic programmes.
- Maintain matriculation numbers and student status.
- Retrieve student records using matriculation numbers and programme information.

### 5.3 Semester and Course Management
- Create academic semesters.
- Schedule courses for different semesters.
- Assign lecturers to course offerings.
- Define course sections and registration capacities.

### 5.4 Course Registration
- Register students for available course offerings.
- Retrieve students registered for a particular offering.
- Track registration dates and enrolment status.
- Prevent duplicate registration by the same student for the same offering.

### 5.5 Result Management
- Record final numerical marks and grades.
- Associate results with valid student enrolments.
- Retrieve student results by course, semester and academic year.
- Prevent more than one result record from being attached to a single enrolment.

## 6. Business and Data Integrity Requirements

The database design is based on the following requirements:

1. Every department must have a unique department code and department name.
2. Every programme must belong to an existing department.
3. Every student must have a unique matriculation number and be assigned to an existing programme.
4. Every lecturer must have a unique staff number.
5. Every course must have a unique course code.
6. A course can be offered in multiple semesters.
7. Every course offering must reference an existing course, semester and lecturer.
8. A student may register for multiple course offerings.
9. A course offering may contain multiple students.
10. A student must not register more than once for the same course offering.
11. Every result must reference an existing enrolment.
12. Every result must have a numerical mark between 0 and 100.
13. An enrolment may have no result or one final result.
14. Academic records must not be deleted where doing so would violate existing foreign-key relationships.

The implemented PostgreSQL constraints enforce these requirements where applicable.

## 7. Implementation Assumptions and Limitations

The following assumptions apply to the current implementation:

- MUN is a fictional institution, and all sample records are synthetic.
- Each student is assigned to one programme in the current model.
- Each course offering is assigned to one lecturer.
- Each enrolment represents one student's registration for one course offering.
- Each enrolment can have at most one final result.
- The permitted grades are A, B, C, D, E and F.
- The grading boundaries are illustrative and must be confirmed against an official university grading policy.

Several limitations are acknowledged:

1. **Course capacity:** The database stores a capacity value for each offering, but it does not yet prevent enrolments from exceeding that capacity. This requires additional transactional or database-level enforcement.
2. **Grade consistency:** The database validates the permitted mark and grade ranges independently but does not enforce the correspondence between a mark and its grade.
3. **Access control:** Application authentication, role-based permissions and student-specific access restrictions are outside the current schema implementation.
4. **Assessment management:** Continuous assessment, examination components, resits and multiple assessment records require additional tables.
5. **Auditability:** A comprehensive academic change-audit mechanism has not yet been implemented.
6. **Privacy:** Personal student information must be protected through appropriate access controls, secure backups and responsible handling procedures.

These limitations provide opportunities for further database development and critical evaluation in subsequent portfolio activities.

## 8. Suitability for Advanced Database Exercises

The MUN-SRRMS scenario provides a consistent foundation for all portfolio activities.

| Portfolio activity | Application to MUN-SRRMS |
|---|---|
| Database design and modelling | Relational modelling of students, programmes, departments, courses and results. |
| SQL and query optimisation | Student registration queries, course reports, result retrieval and index analysis. |
| Transactions and concurrency | Simultaneous course registration, duplicate prevention and result updates. |
| NoSQL data modelling | Flexible student preferences, profile extensions and learning activity records using MongoDB. |
| Distributed databases | PostgreSQL replication, backup, recovery, availability and distributed architecture experiments. |

PostgreSQL remains the authoritative source for structured academic records. MongoDB is intended to complement it with selected flexible data rather than create competing versions of official enrolment and result records.

## 9. Conclusion

The Metropolitan University of Nigeria Student Registration and Result Management System provides a realistic academic information-management scenario for investigating advanced database concepts.

Its relational foundation supports the modelling and management of university academic records while providing opportunities to examine query optimisation, transaction processing, concurrency, NoSQL data modelling and distributed database technologies.

The case study therefore provides a consistent practical context for implementing, testing, analysing and critically evaluating advanced database systems throughout the portfolio.
