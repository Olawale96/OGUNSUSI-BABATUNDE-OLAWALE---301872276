-- Portfolio 3: isolated test data for transaction-isolation experiments.
-- Safe to re-run. This table is deliberately separate from operational tables.

CREATE TABLE IF NOT EXISTS mun_srrms.transaction_demo_counter (
    counter_id INTEGER PRIMARY KEY,
    counter_value INTEGER NOT NULL CHECK (counter_value >= 0)
);

INSERT INTO mun_srrms.transaction_demo_counter(counter_id, counter_value)
VALUES (1, 100)
ON CONFLICT (counter_id) DO UPDATE
SET counter_value = EXCLUDED.counter_value;

SELECT * FROM mun_srrms.transaction_demo_counter WHERE counter_id = 1;
-- Reset to 100 before each experiment by running this setup script again.
