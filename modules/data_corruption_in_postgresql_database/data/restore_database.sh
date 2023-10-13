

#!/bin/bash



# Define the parameters

DB_USERNAME=${DB_USERNAME}

DB_PASSWORD=${DB_PASSWORD}

DB_NAME=${DB_NAME}

BACKUP_FILE=${BACKUP_FILE}



# Stop the PostgreSQL service

sudo systemctl stop postgresql



# Drop the existing database

psql -U $DB_USERNAME -c "DROP DATABASE $DB_NAME"



# Create a new empty database

psql -U $DB_USERNAME -c "CREATE DATABASE $DB_NAME"



# Restore data from backup

pg_restore -U $DB_USERNAME -d $DB_NAME $BACKUP_FILE



# Start the PostgreSQL service

sudo systemctl start postgresql