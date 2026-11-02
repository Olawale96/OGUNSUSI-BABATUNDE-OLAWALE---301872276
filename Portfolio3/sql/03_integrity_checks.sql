-- Portfolio 3: inspect constraints and check for duplicate registrations.
SET search_path TO mun_srrms, public;

-- Confirm the unique constraint exists on enrolment(student_id, offering_id).
SELECT
    conname,
    pg_get_constraintdef(oid) AS constraint_definition
FROM pg_constraint
WHERE conrelid = 'mun_srrms.enrolment'::regclass
  AND contype = 'u'
ORDER BY conname;

-- This query should return no rows if the unique constraint is functioning.
SELECT student_id, offering_id, COUNT(*) AS duplicate_count
FROM mun_srrms.enrolment
GROUP BY student_id, offering_id
HAVING COUNT(*) > 1;

-- Review current registration counts by offering.
SELECT offering_id, status, COUNT(*) AS enrolment_count
FROM mun_srrms.enrolment
GROUP BY offering_id, status
ORDER BY offering_id, status;

-- Inspect the relevant table definition in psql:
-- \d+ mun_srrms.enrolment
