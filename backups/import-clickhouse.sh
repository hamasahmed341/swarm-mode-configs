#!/bin/bash
# import-clickhouse.sh
# clickhouse-client --user=admin --password=I11TestRoots

# ===== CONFIGURATION =====
# DB_USER="admin"
# DB_PASSWORD="I11TestRoots"
# DATABASE="fusion_suite"
# CONTAINER_ID="d24a8bdbbff2"      # Corrected variable assignment
# BACKUP_DIR="/tmp/clickhouse"     # Folder containing CSV files inside the container

# echo "Starting full database import..."
# echo "Database: $DATABASE"
# echo "Source folder: $BACKUP_DIR"

# # ===== EXECUTE COMMAND INSIDE CONTAINER =====
# docker_exec() {
#     docker exec -i "$CONTAINER_ID" bash -c "$1"
# }

# # ===== CHECK IF DIRECTORY EXISTS =====
# dir_exists=$(docker_exec "[ -d '$BACKUP_DIR' ] && echo 1 || echo 0")
# if [ "$dir_exists" -eq 0 ]; then
#     echo "✘ Backup directory does not exist inside container!"
#     exit 1
# fi

# # ===== CHECK IF DATABASE EXISTS =====
# db_exists=$(docker_exec "clickhouse-client --user='$DB_USER' --password='$DB_PASSWORD' --query='EXISTS DATABASE $DATABASE'")
# if [ "$db_exists" -eq 0 ]; then
#     echo "Database $DATABASE does not exist. Creating database..."
#     docker_exec "clickhouse-client --user='$DB_USER' --password='$DB_PASSWORD' --query='CREATE DATABASE $DATABASE'"
#     if [ $? -eq 0 ]; then
#         echo "✔ Database $DATABASE created successfully"
#     else
#         echo "✘ Error creating database $DATABASE"
#         exit 1
#     fi
# else
#     echo "Database $DATABASE already exists. Skipping creation."
# fi

# # ===== LOOP THROUGH ALL CSV FILES =====
# for file in $(docker_exec "ls $BACKUP_DIR/*.csv 2>/dev/null"); do

#     # Extract table name from filename
#     table=$(basename "$file" .csv)

#     echo "Processing table: $table"

#     # Check if table exists
#     table_exists=$(docker_exec "clickhouse-client --user='$DB_USER' --password='$DB_PASSWORD' --query='EXISTS $DATABASE.$table'")
#     if [ "$table_exists" -eq 0 ]; then
#         echo "Table $table does not exist. Creating table..."

#         # Read header line from CSV
#         header=$(docker_exec "head -n 1 $file")

#         # Generate columns with String type
#         columns=""
#         IFS=',' read -ra cols <<< "$header"
#         for col in "${cols[@]}"; do
#             col_clean=$(echo "$col" | tr -d ' ')
#             columns+="$col_clean String,"
#         done
#         columns=${columns%,}  # remove trailing comma

#         # Create table
#         docker_exec "clickhouse-client --user='$DB_USER' --password='$DB_PASSWORD' --query='CREATE TABLE $DATABASE.$table ($columns) ENGINE = MergeTree() ORDER BY tuple()'"
#         if [ $? -eq 0 ]; then
#             echo "✔ Table $table created successfully"
#         else
#             echo "✘ Error creating table $table"
#             continue
#         fi
#     else
#         echo "Table $table exists. Skipping creation."
#     fi

#     # Import data
#     echo "Importing data into $table..."
#     docker exec -i "$CONTAINER_ID" bash -c "clickhouse-client --user='$DB_USER' --password='$DB_PASSWORD' --query='INSERT INTO $DATABASE.$table FORMAT CSVWithNames'" < "$file"

#     if [ $? -eq 0 ]; then
#         echo "✔ $table imported successfully"
#     else
#         echo "✘ Error importing $table"
#     fi

# done

# echo "Full database import completed."


# ====================



#!/bin/bash

# ===== CONFIGURATION =====
CONTAINER_ID="5b50a6287a4f"
DB_USER="default"
DB_PASSWORD="I11TestRoots"
# BACKUP_ROOT="/var/www/docker-swarm-mode/backups/server-backup/clickhouse"   # Host path with exported CSVs
BACKUP_ROOT="/Users/hammasahmad/Downloads/swarm/server-backup/clickhouse"   # Host path with exported CSVs
CLICKHOUSE_DIR="/tmp/clickhouse" # Folder inside container

echo "Starting ClickHouse import into container $CONTAINER_ID..."

# Copy backup folders into container
docker cp "$BACKUP_ROOT/." "$CONTAINER_ID:$CLICKHOUSE_DIR"

# Loop over databases
for DB_DIR in "$BACKUP_ROOT"/*; do
    DATABASE=$(basename "$DB_DIR")

    # Skip non-directories
    [ -d "$DB_DIR" ] || continue

    echo "Importing database: $DATABASE"

    # Create database inside container (if not exists)
    docker exec -i "$CONTAINER_ID" \
        clickhouse-client --user="default" --password="I11TestRoots" \
        --query="CREATE DATABASE IF NOT EXISTS $DATABASE"

    # Loop over CSV files in this database folder
    for TABLE_FILE in "$DB_DIR"/*.csv; do
        TABLE_NAME=$(basename "$TABLE_FILE" .csv)
        echo "  Importing table: $TABLE_NAME"

        # Read CSV headers and generate CREATE TABLE statement with String columns
        HEADERS=$(head -n 1 "$TABLE_FILE" | sed 's/,/ String, /g')
        CREATE_TABLE_SQL="CREATE TABLE IF NOT EXISTS $DATABASE.$TABLE_NAME ($HEADERS String) ENGINE = MergeTree() ORDER BY tuple()"

        docker exec -i "$CONTAINER_ID" \
            clickhouse-client --user="$DB_USER" --password="$DB_PASSWORD" \
            --query="$CREATE_TABLE_SQL"

        # Insert CSV data
        docker exec -i "$CONTAINER_ID" \
            clickhouse-client --user="$DB_USER" --password="$DB_PASSWORD" \
            --query="INSERT INTO $DATABASE.$TABLE_NAME FORMAT CSVWithNames" \
            < "$TABLE_FILE"

        if [ $? -eq 0 ]; then
            echo "    ✔ $TABLE_NAME imported successfully"
        else
            echo "    ✘ Error importing $TABLE_NAME"
        fi
    done
done

echo "ClickHouse import completed."