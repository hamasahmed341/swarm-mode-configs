#!/bin/bash

# ===== CONFIGURATION =====
DB_HOST="localhost"
DB_USER="default"
DB_PASSWORD="I11TestRoots"
BACKUP_ROOT="/var/www/clickhouse_backup_$(date +%F_%H-%M-%S)"

# ===== CREATE ROOT BACKUP DIRECTORY =====
mkdir -p "$BACKUP_ROOT"

echo "Starting full ClickHouse export..."
echo "Backup root folder: $BACKUP_ROOT"

# ===== GET ALL DATABASES =====
DATABASES=$(clickhouse-client \
    --host="$DB_HOST" \
    --user="$DB_USER" \
    --password="$DB_PASSWORD" \
    --query="SHOW DATABASES")

# ===== LOOP OVER DATABASES =====
for DATABASE in $DATABASES; do
    # Skip system databases
    if [[ "$DATABASE" == "system" || "$DATABASE" == "information_schema" ]]; then
        continue
    fi

    echo "Exporting database: $DATABASE"

    # Create a directory for this database
    DB_BACKUP_DIR="$BACKUP_ROOT/$DATABASE"
    mkdir -p "$DB_BACKUP_DIR"

    # ===== GET TABLES IN DATABASE =====
    TABLES=$(clickhouse-client \
        --host="$DB_HOST" \
        --user="$DB_USER" \
        --password="$DB_PASSWORD" \
        --query="SHOW TABLES FROM $DATABASE")

    # ===== EXPORT EACH TABLE =====
    for table in $TABLES; do
        echo "  Exporting table: $table"

        clickhouse-client \
            --host="$DB_HOST" \
            --user="$DB_USER" \
            --password="$DB_PASSWORD" \
            --query="SELECT * FROM $DATABASE.$table FORMAT CSVWithNames" \
            > "$DB_BACKUP_DIR/$table.csv"

        if [ $? -eq 0 ]; then
            echo "    ✔ $table exported successfully"
        else
            echo "    ✘ Error exporting $table"
        fi
    done
done

echo "Full ClickHouse export completed."