-- Repeat the exact baseline queries after index creation.
ANALYZE mun_srrms.result;
EXPLAIN (ANALYZE, BUFFERS, VERBOSE, FORMAT TEXT)
SELECT COUNT(*) FROM mun_srrms.result WHERE mark >= 90;

EXPLAIN (ANALYZE, BUFFERS, VERBOSE, FORMAT TEXT)
SELECT c.course_code, COUNT(*) AS high_mark_results
FROM mun_srrms.result r
JOIN mun_srrms.enrolment e ON e.enrolment_id=r.enrolment_id
JOIN mun_srrms.course_offering co ON co.offering_id=e.offering_id
JOIN mun_srrms.course c ON c.course_id=co.course_id
WHERE r.mark >= 90
GROUP BY c.course_code
ORDER BY c.course_code;
