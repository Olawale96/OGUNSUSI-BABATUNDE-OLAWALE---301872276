-- Optional checks after restoring the custom-format backup into
-- mun_srrms_restore_test on the publisher.
SELECT current_database();
SELECT COUNT(*) AS restored_event_rows
FROM distributed_demo.registration_events;
