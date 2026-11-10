# Metropolitan University of Nigeria
## Student Registration and Result Management System

```mermaid
erDiagram
    DEPARTMENT ||--o{ PROGRAMME : contains
    DEPARTMENT ||--o{ LECTURER : employs
    DEPARTMENT ||--o{ COURSE : owns
    PROGRAMME ||--o{ STUDENT : admits
    COURSE ||--o{ COURSE_OFFERING : scheduled_as
    SEMESTER ||--o{ COURSE_OFFERING : includes
    LECTURER ||--o{ COURSE_OFFERING : teaches
    STUDENT ||--o{ ENROLMENT : registers
    COURSE_OFFERING ||--o{ ENROLMENT : receives
    ENROLMENT ||--o| RESULT : produces

    DEPARTMENT {
        int department_id PK
        varchar department_code UK
        varchar department_name UK
    }

    PROGRAMME {
        int programme_id PK
        int department_id FK
        varchar programme_code UK
        varchar programme_name
        varchar award_level
    }

    LECTURER {
        int lecturer_id PK
        varchar staff_number UK
        int department_id FK
        varchar first_name
        varchar last_name
        varchar email UK
    }

    STUDENT {
        int student_id PK
        varchar matric_number UK
        varchar first_name
        varchar last_name
        varchar email UK
        date date_of_birth
        date admission_date
        int programme_id FK
        varchar status
    }

    COURSE {
        int course_id PK
        varchar course_code UK
        varchar course_title
        smallint credit_units
        int department_id FK
    }

    SEMESTER {
        int semester_id PK
        varchar academic_year
        varchar term
        date start_date
        date end_date
    }

    COURSE_OFFERING {
        int offering_id PK
        int course_id FK
        int semester_id FK
        int lecturer_id FK
        varchar section_code
        int capacity
    }

    ENROLMENT {
        int enrolment_id PK
        int student_id FK
        int offering_id FK
        date registration_date
        varchar status
    }

    RESULT {
        int result_id PK
        int enrolment_id FK
        numeric mark
        varchar grade
        timestamptz recorded_at
    }

%% Additional UNIQUE constraints enforced by PostgreSQL:
%% PROGRAMME: (department_id, programme_name)
%% SEMESTER: (academic_year, term)
%% COURSE_OFFERING: (course_id, semester_id, section_code)
%% ENROLMENT: (student_id, offering_id)
%% RESULT: enrolment_id
```

### Database Integrity Constraints

1. ENROLMENT has a composite UNIQUE constraint on (student_id, offering_id), preventing a student from registering for the same course offering more than once.

2. RESULT.enrolment_id is UNIQUE and NOT NULL, ensuring that each enrolment can have at most one result record.

3. Every RESULT must reference an existing ENROLMENT.

4. PROGRAMME enforces uniqueness of (department_id, programme_name).

5. SEMESTER enforces uniqueness of (academic_year, term).

6. COURSE_OFFERING enforces uniqueness of (course_id, semester_id, section_code).
