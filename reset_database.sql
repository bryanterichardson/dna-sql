REVOKE CONNECT ON DATABASE dna_production FROM public;

SELECT pid, pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = 'dna_production' AND pid <> pg_backend_pid();

DROP DATABASE dna_production;
CREATE DATABASE dna_production;

GRANT CONNECT ON DATABASE dna_production TO public;