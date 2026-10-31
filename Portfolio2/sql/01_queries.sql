-- Q1: Student directory with programme and department
SELECT s.matric_number, s.first_name, s.last_name, p.programme_code,
       p.programme_name, d.department_name
FROM mun_srrms.student s
JOIN mun_srrms.programme p ON p.programme_id=s.programme_id
JOIN mun_srrms.department d ON d.department_id=p.department_id
ORDER BY s.matric_number;

-- Q2: Class list for MIT8101, First semester 2026/2027
SELECT c.course_code, c.course_title, s.matric_number, s.first_name,
       s.last_name, e.registration_date
FROM mun_srrms.course c
JOIN mun_srrms.course_offering co ON co.course_id=c.course_id
JOIN mun_srrms.semester sem ON sem.semester_id=co.semester_id
JOIN mun_srrms.enrolment e ON e.offering_id=co.offering_id
JOIN mun_srrms.student s ON s.student_id=e.student_id
WHERE c.course_code='MIT8101'
  AND sem.academic_year='2026/2027'
  AND sem.term='First'
  AND e.status='registered'
ORDER BY s.matric_number;

-- Q3: Results and pending results
SELECT s.matric_number, c.course_code, c.course_title, r.mark, r.grade
FROM mun_srrms.student s
JOIN mun_srrms.enrolment e ON e.student_id=s.student_id
JOIN mun_srrms.course_offering co ON co.offering_id=e.offering_id
JOIN mun_srrms.course c ON c.course_id=co.course_id
LEFT JOIN mun_srrms.result r ON r.enrolment_id=e.enrolment_id
ORDER BY s.matric_number, c.course_code;

-- Q4: Registration counts and average mark by course
SELECT c.course_code, c.course_title, COUNT(e.enrolment_id) AS registrations,
       COUNT(r.result_id) AS results_recorded, ROUND(AVG(r.mark),2) AS average_mark
FROM mun_srrms.course c
JOIN mun_srrms.course_offering co ON co.course_id=c.course_id
LEFT JOIN mun_srrms.enrolment e ON e.offering_id=co.offering_id
LEFT JOIN mun_srrms.result r ON r.enrolment_id=e.enrolment_id
GROUP BY c.course_code, c.course_title
ORDER BY c.course_code;

-- Q5: Rank students by mark within each offering
SELECT c.course_code, s.matric_number, r.mark, r.grade,
       RANK() OVER (PARTITION BY co.offering_id ORDER BY r.mark DESC) AS course_rank
FROM mun_srrms.result r
JOIN mun_srrms.enrolment e ON e.enrolment_id=r.enrolment_id
JOIN mun_srrms.student s ON s.student_id=e.student_id
JOIN mun_srrms.course_offering co ON co.offering_id=e.offering_id
JOIN mun_srrms.course c ON c.course_id=co.course_id
ORDER BY c.course_code, course_rank;

-- Q6: High-mark results for performance testing
SELECT COUNT(*) FROM mun_srrms.result WHERE mark >= 90;

-- Q7: Individual course enrolments with pending results
SELECT s.matric_number,
       s.first_name,
       s.last_name,
       c.course_code,
       c.course_title,
       e.registration_date
FROM mun_srrms.student s
JOIN mun_srrms.enrolment e
    ON e.student_id = s.student_id
JOIN mun_srrms.course_offering co
    ON co.offering_id = e.offering_id
JOIN mun_srrms.course c
    ON c.course_id = co.course_id
LEFT JOIN mun_srrms.result r
    ON r.enrolment_id = e.enrolment_id
WHERE r.result_id IS NULL
ORDER BY s.matric_number, c.course_code;