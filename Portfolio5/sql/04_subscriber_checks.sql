-- Run on subscriber.
SELECT *
FROM distributed_demo.registration_events
ORDER BY event_id;

SELECT subname, subenabled
FROM pg_subscription;

SELECT *
FROM pg_stat_subscription;
