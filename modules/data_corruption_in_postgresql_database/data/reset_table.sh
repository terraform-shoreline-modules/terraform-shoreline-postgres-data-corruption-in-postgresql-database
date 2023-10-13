

#!/bin/bash



# Set variables

DB_NAME=${DB_NAME}

TABLE_NAME=${TABLE_NAME}



# Stop the PostgreSQL service

sudo systemctl stop postgresql



# Run the pg_resetxlog or pg_resetwal command to repair the corrupted table

sudo -u postgres pg_resetxlog -f /var/lib/postgresql/${VERSION}/main/pg_xlog

sudo -u postgres pg_resetwal -f /var/lib/postgresql/${VERSION}/main/pg_wal



# Start the PostgreSQL service

sudo systemctl start postgresql



# Verify that the table is repaired

sudo -u postgres psql -d $DB_NAME -c "SELECT * FROM $TABLE_NAME LIMIT 1;"