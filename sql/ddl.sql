# ddl.sql pseudocode/steps
# you can assume database is already created mannually
1. switch to `host_agent`
2. create `host_info` table if not exist
3. create `host_usage` table if not exist

# Execute ddl.sql script on the host_agent database againse the psql instance
psql -h localhost -U postgres -d host_agent -f sql/ddl.sql
