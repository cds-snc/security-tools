#!/bin/bash

# Database connection details
DB_CONNECTION_STRING="postgresql://postgres:postgres@db:5432/postgres"

# Connect to the database and execute the query
table_count=$(psql $DB_CONNECTION_STRING -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';")

# Print the result
echo "Number of tables: $table_count"