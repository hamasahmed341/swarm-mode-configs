#!/bin/bash

# ==============================
# CONFIGURATION (EDIT IF NEEDED)
# ==============================

CONTAINER_NAME="07abab2a09fa"
BACKUP_FOLDER="/Users/hammasahmad/Downloads/swarm/server-backup/mongo_backup"
CONTAINER_BACKUP_PATH="/tmp/mongo_backup"

MONGO_USER="admin"
MONGO_PASSWORD="dev"
AUTH_DB="admin"

# ==============================
# CHECK IF BACKUP EXISTS
# ==============================

if [ ! -d "$BACKUP_FOLDER" ]; then
  echo "❌ Backup folder '$BACKUP_FOLDER' not found in current directory."
  exit 1
fi

# ==============================
# COPY BACKUP INTO CONTAINER
# ==============================

echo "📦 Copying backup into container..."

docker cp "$BACKUP_FOLDER" "$CONTAINER_NAME":"$CONTAINER_BACKUP_PATH"

if [ $? -ne 0 ]; then
  echo "❌ Failed to copy backup into container."
  exit 1
fi

# ==============================
# RESTORE DATABASE
# ==============================

echo "🔄 Restoring MongoDB backup..."

docker exec "$CONTAINER_NAME" \
mongorestore \
  --username "$MONGO_USER" \
  --password "$MONGO_PASSWORD" \
  --authenticationDatabase "$AUTH_DB" \
  --drop \
  "$CONTAINER_BACKUP_PATH"

if [ $? -ne 0 ]; then
  echo "❌ Mongo restore failed."
  exit 1
fi

# ==============================
# VERIFY RESTORE
# ==============================

echo "🔍 Verifying restore..."

docker exec "$CONTAINER_NAME" \
mongosh \
  --username "$MONGO_USER" \
  --password "$MONGO_PASSWORD" \
  --authenticationDatabase "$AUTH_DB" \
  --quiet \
  --eval "db.getMongo().getDBNames().forEach(function(db){print(db)})"

echo "✅ Restore completed successfully."