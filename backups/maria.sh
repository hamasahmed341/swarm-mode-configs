#!/bin/bash

DB_USER="root"
DB_PASS="I11TestRoots"
BACKUP_DIR="/home/ubuntu/test-docker-database-scripts/mariadb-backup"
# BACKUP_DIR="/home/dev/mariadb-backup"
DATE=$(date +"%Y-%m-%d_%H-%M-%S")

mkdir -p $BACKUP_DIR

DATABASES=$(mysql -u $DB_USER -p$DB_PASS -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema|mysql|sys)")

for DB in $DATABASES; do
    mysqldump -u $DB_USER -p$DB_PASS $DB > "$BACKUP_DIR/${DB}_$DATE.sql"
    echo "Dumped $DB"
done

echo "All databases dumped successfully."

# chmod +x mariadb_backup_script_11_march_2026.sh
# ./mariadb_backup_script_11_march_2026.sh














