#!/bin/bash
set -e

# Create jumpserver database if it doesn't exist
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    SELECT 'CREATE DATABASE jumpserver'
    WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'jumpserver')\gexec
EOSQL

echo "Database jumpserver created successfully"
