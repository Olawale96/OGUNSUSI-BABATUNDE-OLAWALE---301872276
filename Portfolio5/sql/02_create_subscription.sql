-- Run this on the subscriber after both containers are healthy.
-- Credentials are coursework-only defaults from docker-compose.yml.
CREATE SUBSCRIPTION mun_srrms_events_sub
CONNECTION 'host=publisher port=5432 dbname=mun_srrms_dist user=repl_user password=LocalLab_Replication_ChangeMe'
PUBLICATION mun_srrms_events_pub
WITH (copy_data = true, create_slot = true, enabled = true);
