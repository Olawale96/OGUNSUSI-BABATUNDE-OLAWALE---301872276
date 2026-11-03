CREATE SCHEMA distributed_demo;

CREATE TABLE distributed_demo.registration_events (
    event_id BIGINT PRIMARY KEY,
    matric_number TEXT NOT NULL,
    event_type TEXT NOT NULL CHECK (
        event_type IN ('course_registered', 'course_dropped', 'result_published')
    ),
    event_time TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);
