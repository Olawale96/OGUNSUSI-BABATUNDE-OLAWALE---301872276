-- OPTIONAL: run ONCE only on a disposable/test database after Portfolio 1 seed data.
-- Adds 20,000 synthetic students and two enrolments/results per generated student.
BEGIN;
INSERT INTO mun_srrms.student
(matric_number, first_name, last_name, email, date_of_birth, admission_date, programme_id)
SELECT 'MUN/LOAD/' || lpad(g::text,5,'0'), 'Test' || g, 'Student' || g,
       'load.student.' || g || '@example.edu.ng',
       DATE '2000-01-01' + (g % 2500), DATE '2026-09-01', p.programme_id
FROM generate_series(1,20000) AS gs(g)
CROSS JOIN (SELECT programme_id FROM mun_srrms.programme WHERE programme_code='MIT') p;

INSERT INTO mun_srrms.enrolment (student_id, offering_id, registration_date)
SELECT s.student_id, co.offering_id, DATE '2026-09-15'
FROM mun_srrms.student s
CROSS JOIN mun_srrms.course_offering co
JOIN mun_srrms.course c ON c.course_id=co.course_id
WHERE s.matric_number LIKE 'MUN/LOAD/%'
  AND c.course_code IN ('MIT8101','MIT8102');

INSERT INTO mun_srrms.result (enrolment_id, mark, grade)
SELECT e.enrolment_id, v.mark,
       CASE WHEN v.mark>=80 THEN 'A' WHEN v.mark>=70 THEN 'B'
            WHEN v.mark>=60 THEN 'C' WHEN v.mark>=50 THEN 'D'
            WHEN v.mark>=45 THEN 'E' ELSE 'F' END
FROM mun_srrms.enrolment e
JOIN mun_srrms.student s ON s.student_id=e.student_id
JOIN mun_srrms.course_offering co ON co.offering_id=e.offering_id
JOIN mun_srrms.course c ON c.course_id=co.course_id
CROSS JOIN LATERAL (
  SELECT ((s.student_id * 17 + c.course_id * 13) % 101)::numeric(5,2) AS mark
) v
WHERE s.matric_number LIKE 'MUN/LOAD/%'
  AND c.course_code IN ('MIT8101','MIT8102');
COMMIT;

SELECT (SELECT COUNT(*) FROM mun_srrms.student) AS students,
       (SELECT COUNT(*) FROM mun_srrms.enrolment) AS enrolments,
       (SELECT COUNT(*) FROM mun_srrms.result) AS results;
