-- Capture baseline plan before running this file.
CREATE INDEX IF NOT EXISTS idx_result_mark ON mun_srrms.result (mark);
ANALYZE mun_srrms.result;
SELECT indexname, indexdef FROM pg_indexes
WHERE schemaname='mun_srrms' AND tablename='result'
ORDER BY indexname;
