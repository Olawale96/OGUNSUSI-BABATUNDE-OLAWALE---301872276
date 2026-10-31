-- Portfolio 1 validation queries and negative tests.
-- Run after schema and seed data. Negative tests intentionally raise errors;
-- execute each negative-test block separately, or use a savepoint as shown.

SET search_path TO mun_srrms, public;

-- Test 1: Schema inventory. Expected: 9 tables.
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'mun_srrms' AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- Test 2: Students with programme and department.
SELECT s.matric_number, s.first_name, s.last_name,
       p.programme_code, p.programme_name, d.department_name
FROM student s
JOIN programme p ON p.programme_id = s.programme_id
JOIN department d ON d.department_id = p.department_id
ORDER BY s.matric_number;

-- Test 3: Enrolments and result details.
SELECT s.matric_number, c.course_code, c.course_title,
       sem.academic_year, sem.term, e.status AS enrolment_status,
       r.mark, r.grade
FROM enrolment e
JOIN student s ON s.student_id = e.student_id
JOIN course_offering co ON co.offering_id = e.offering_id
JOIN course c ON c.course_id = co.course_id
JOIN semester sem ON sem.semester_id = co.semester_id
LEFT JOIN result r ON r.enrolment_id = e.enrolment_id
ORDER BY s.matric_number, c.course_code;

-- Test 4: Check for duplicate business identifiers (expected: zero rows).
SELECT matric_number, COUNT(*)
FROM student
GROUP BY matric_number
HAVING COUNT(*) > 1;

-- Test 5: Check for duplicate enrolments (expected: zero rows).
SELECT student_id, offering_id, COUNT(*)
FROM enrolment
GROUP BY student_id, offering_id
HAVING COUNT(*) > 1;

-- Negative test A: duplicate matriculation number must be rejected.
-- Expected: unique-constraint violation. Savepoint allows the script to continue.
BEGIN;
SAVEPOINT duplicate_student_test;
DO $$
BEGIN
    BEGIN
        INSERT INTO mun_srrms.student
            (matric_number, first_name, last_name, email, admission_date, programme_id)
        SELECT 'MUN/2026/0001', 'Test', 'Duplicate', 'duplicate-test@example.edu.ng',
               DATE '2026-09-01', programme_id
        FROM mun_srrms.programme WHERE programme_code = 'MIT';
        RAISE EXCEPTION 'TEST FAILED: duplicate matric number was accepted';
    EXCEPTION WHEN unique_violation THEN
        RAISE NOTICE 'PASS: duplicate matric number rejected';
    END;
END $$;
ROLLBACK;

-- Negative test B: mark outside 0-100 must be rejected.
BEGIN;
DO $$
DECLARE
    v_enrolment_id INTEGER;
BEGIN
    SELECT e.enrolment_id INTO v_enrolment_id
    FROM mun_srrms.enrolment e
    JOIN mun_srrms.student s ON s.student_id = e.student_id
    WHERE s.matric_number = 'MUN/2026/0001'
    ORDER BY e.enrolment_id
    LIMIT 1;

    BEGIN
        INSERT INTO mun_srrms.result (enrolment_id, mark, grade)
        VALUES (v_enrolment_id, 120, 'A');
        RAISE EXCEPTION 'TEST FAILED: invalid mark was accepted';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'PASS: mark above 100 rejected';
    END;
END $$;
ROLLBACK;

-- Negative test C: non-existent programme FK must be rejected.
BEGIN;
DO $$
BEGIN
    BEGIN
        INSERT INTO mun_srrms.student
            (matric_number, first_name, last_name, email, admission_date, programme_id)
        VALUES ('MUN/TEST/9999', 'Test', 'FK', 'fk-test@example.edu.ng', CURRENT_DATE, -999);
        RAISE EXCEPTION 'TEST FAILED: invalid programme foreign key was accepted';
    EXCEPTION WHEN foreign_key_violation THEN
        RAISE NOTICE 'PASS: invalid programme foreign key rejected';
    END;
END $$;
ROLLBACK;
-- Negative test D: duplicate enrolment must be rejected.
BEGIN;
DO $$
DECLARE
    v_student_id INTEGER;
    v_offering_id INTEGER;
BEGIN
    SELECT st.student_id, co.offering_id
    INTO v_student_id, v_offering_id
    FROM mun_srrms.student st
    JOIN mun_srrms.enrolment e
        ON e.student_id = st.student_id
    JOIN mun_srrms.course_offering co
        ON co.offering_id = e.offering_id
    JOIN mun_srrms.course c
        ON c.course_id = co.course_id
    WHERE st.matric_number = 'MUN/2026/0001'
      AND c.course_code = 'MIT8101'
    LIMIT 1;

    IF v_student_id IS NULL OR v_offering_id IS NULL THEN
        RAISE EXCEPTION 'TEST SETUP FAILED: existing enrolment not found';
    END IF;

    BEGIN
        INSERT INTO mun_srrms.enrolment
            (student_id, offering_id, registration_date)
        VALUES
            (v_student_id, v_offering_id, CURRENT_DATE);

        RAISE EXCEPTION 'TEST FAILED: duplicate enrolment was accepted';

    EXCEPTION WHEN unique_violation THEN
        RAISE NOTICE 'PASS: duplicate enrolment rejected';
    END;
END $$;
ROLLBACK;
