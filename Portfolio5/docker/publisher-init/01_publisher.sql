CREATE SCHEMA distributed_demo;

CREATE TABLE distributed_demo.registration_events (
    event_id BIGINT PRIMARY KEY,
    matric_number TEXT NOT NULL,
    event_type TEXT NOT NULL CHECK (
        event_type IN ('course_registered', 'course_dropped', 'result_published')
    ),
    event_time TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE ROLE repl_user WITH LOGIN REPLICATION PASSWORD 'LocalLab_Replication_ChangeMe';
GRANT CONNECT ON DATABASE mun_srrms_dist TO repl_user;
GRANT USAGE ON SCHEMA distributed_demo TO repl_user;
GRANT SELECT ON distributed_demo.registration_events TO repl_user;

CREATE PUBLICATION mun_srrms_events_pub
FOR TABLE distributed_demo.registration_events;
