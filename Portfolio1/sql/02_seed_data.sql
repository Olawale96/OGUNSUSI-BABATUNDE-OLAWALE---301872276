-- Synthetic data only. Safe to run once on a freshly created schema.
BEGIN;
SET search_path TO mun_srrms, public;

INSERT INTO department (department_code, department_name) VALUES
('SCI', 'School of Computing and Informatics'),
('BUS', 'School of Business');

INSERT INTO programme (department_id, programme_code, programme_name, award_level)
SELECT department_id, 'MIT', 'Master of Information Technology', 'MSc'
FROM department WHERE department_code = 'SCI';

INSERT INTO programme (department_id, programme_code, programme_name, award_level)
SELECT department_id, 'BSC-CS', 'BSc Computer Science', 'BSc'
FROM department WHERE department_code = 'SCI';

INSERT INTO lecturer (staff_number, department_id, first_name, last_name, email)
SELECT 'MUN-L001', department_id, 'Ada', 'Okafor', 'ada.okafor@example.edu.ng'
FROM department WHERE department_code = 'SCI';

INSERT INTO lecturer (staff_number, department_id, first_name, last_name, email)
SELECT 'MUN-L002', department_id, 'Tunde', 'Bello', 'tunde.bello@example.edu.ng'
FROM department WHERE department_code = 'SCI';

INSERT INTO student
(matric_number, first_name, last_name, email, date_of_birth, admission_date, programme_id)
SELECT 'MUN/2026/0001', 'Amara', 'Eze', 'amara.eze@example.edu.ng', DATE '2000-03-12', DATE '2026-09-01', programme_id
FROM programme WHERE programme_code = 'MIT';

INSERT INTO student
(matric_number, first_name, last_name, email, date_of_birth, admission_date, programme_id)
SELECT 'MUN/2026/0002', 'Chidi', 'Adebayo', 'chidi.adebayo@example.edu.ng', DATE '1999-11-08', DATE '2026-09-01', programme_id
FROM programme WHERE programme_code = 'MIT';

INSERT INTO student
(matric_number, first_name, last_name, email, date_of_birth, admission_date, programme_id)
SELECT 'MUN/2026/0003', 'Zainab', 'Yusuf', 'zainab.yusuf@example.edu.ng', DATE '2001-06-21', DATE '2026-09-01', programme_id
FROM programme WHERE programme_code = 'BSC-CS';

INSERT INTO course (course_code, course_title, credit_units, department_id)
SELECT 'MIT8101', 'Advanced Database Systems', 3, department_id
FROM department WHERE department_code = 'SCI';

INSERT INTO course (course_code, course_title, credit_units, department_id)
SELECT 'MIT8102', 'Research Methods in IT', 2, department_id
FROM department WHERE department_code = 'SCI';

INSERT INTO semester (academic_year, term, start_date, end_date)
VALUES ('2026/2027', 'First', DATE '2026-09-14', DATE '2027-01-15');

INSERT INTO course_offering (course_id, semester_id, lecturer_id, section_code, capacity)
SELECT c.course_id, s.semester_id, l.lecturer_id, 'A', 60
FROM course c
JOIN semester s ON s.academic_year = '2026/2027' AND s.term = 'First'
JOIN lecturer l ON l.staff_number = 'MUN-L001'
WHERE c.course_code = 'MIT8101';

INSERT INTO course_offering (course_id, semester_id, lecturer_id, section_code, capacity)
SELECT c.course_id, s.semester_id, l.lecturer_id, 'A', 60
FROM course c
JOIN semester s ON s.academic_year = '2026/2027' AND s.term = 'First'
JOIN lecturer l ON l.staff_number = 'MUN-L002'
WHERE c.course_code = 'MIT8102';

INSERT INTO enrolment (student_id, offering_id, registration_date)
SELECT st.student_id, co.offering_id, DATE '2026-09-15'
FROM student st
CROSS JOIN course_offering co
JOIN course c ON c.course_id = co.course_id
WHERE st.matric_number IN ('MUN/2026/0001', 'MUN/2026/0002')
  AND c.course_code = 'MIT8101';

INSERT INTO enrolment (student_id, offering_id, registration_date)
SELECT st.student_id, co.offering_id, DATE '2026-09-15'
FROM student st
CROSS JOIN course_offering co
JOIN course c ON c.course_id = co.course_id
WHERE st.matric_number IN ('MUN/2026/0001', 'MUN/2026/0003')
  AND c.course_code = 'MIT8102';

-- Illustrative marks and grades. In production, derive grade from a grading policy.
INSERT INTO result (enrolment_id, mark, grade)
SELECT e.enrolment_id, 86.50, 'A'
FROM enrolment e
JOIN student st ON st.student_id = e.student_id
JOIN course_offering co ON co.offering_id = e.offering_id
JOIN course c ON c.course_id = co.course_id
WHERE st.matric_number = 'MUN/2026/0001' AND c.course_code = 'MIT8101';

INSERT INTO result (enrolment_id, mark, grade)
SELECT e.enrolment_id, 72.00, 'B'
FROM enrolment e
JOIN student st ON st.student_id = e.student_id
JOIN course_offering co ON co.offering_id = e.offering_id
JOIN course c ON c.course_id = co.course_id
WHERE st.matric_number = 'MUN/2026/0002' AND c.course_code = 'MIT8101';

COMMIT;
