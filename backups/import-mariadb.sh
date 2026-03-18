# DROP DATABASE IF EXISTS fiv2_access_control;
# DROP DATABASE IF EXISTS fiv2_ai_agent;
# DROP DATABASE IF EXISTS fiv2_ai_agent_core;
# DROP DATABASE IF EXISTS fiv2_app_reviews;
# DROP DATABASE IF EXISTS fiv2_app_reviews_on_linked_store;
# DROP DATABASE IF EXISTS fiv2_app_reviews_report_datacollection;
# DROP DATABASE IF EXISTS fiv2_bugs_collections;
# DROP DATABASE IF EXISTS fiv2_commentspace;
# DROP DATABASE IF EXISTS fiv2_complaints_collections;
# DROP DATABASE IF EXISTS fiv2_crashes_collections;
# DROP DATABASE IF EXISTS fiv2_customerfeedback_collections;
# DROP DATABASE IF EXISTS fiv2_distribution_collections;
# DROP DATABASE IF EXISTS fiv2_general;
# DROP DATABASE IF EXISTS fiv2_iot_collections;
# DROP DATABASE IF EXISTS fiv2_notificationspace;
# DROP DATABASE IF EXISTS fiv2_qualitysuite;
# DROP DATABASE IF EXISTS fiv2_survey_collections;
# DROP DATABASE IF EXISTS fiv2_survey_reviews;
# DROP DATABASE IF EXISTS fiv2_website_collections;

# ==================================
# #!/bin/bash

# CONTAINER="af8f9efce2d6"
# DB_USER="root"
# DB_PASS="I11TestRoots"
# # BACKUP_DIR_HOST="/var/www/docker-swarm-mode/backups/server-backup/mariadb-backup"   # SQL files on your host
# BACKUP_DIR_HOST="/Users/hammasahmad/Downloads/swarm/server-backup/mariadb-backup"   # SQL files on your host
# BACKUP_DIR_CONTAINER="/tmp/mariadb-backup"    # Inside container

# # 1️⃣ Copy SQL files from host to container
# echo "Copying SQL files from host to container..."
# docker exec "$CONTAINER" mkdir -p "$BACKUP_DIR_CONTAINER"
# docker cp "$BACKUP_DIR_HOST/." "$CONTAINER:$BACKUP_DIR_CONTAINER/"
# echo "Copy complete."

# # 2️⃣ Run restore inside container
# docker exec "$CONTAINER" sh -c "

# if ! ls $BACKUP_DIR_CONTAINER/*.sql >/dev/null 2>&1; then
#   echo 'No SQL files found in $BACKUP_DIR_CONTAINER'
#   exit 1
# fi

# echo '----------------------------------------'
# echo 'Disabling foreign key checks globally...'
# # mariadb -u$DB_USER -p$DB_PASS -e 'SET GLOBAL FOREIGN_KEY_CHECKS=0;'

# for DB_NAME in \
# fiv2_general \
# fiv2_access_control \
# fiv2_ai_agent_core \
# fiv2_bugs_collections \
# fiv2_commentspace \
# fiv2_complaints_collections \
# fiv2_crashes_collections \
# fiv2_customerfeedback_collections \
# fiv2_distribution_collections \
# fiv2_app_reviews_on_linked_store \
# fiv2_app_reviews_report_datacollection \
# fiv2_iot_collections \
# fiv2_notificationspace \
# fiv2_qualitysuite \
# fiv2_survey_collections \
# fiv2_survey_reviews \
# fiv2_website_collections
# do

#     FILE=\$(ls $BACKUP_DIR_CONTAINER/\$DB_NAME*.sql 2>/dev/null | head -n1)

#     if [ -z \"\$FILE\" ]; then
#         echo \"No SQL file found for \$DB_NAME, skipping...\"
#         continue
#     fi

#     # Strip timestamp from filename to get clean DB name
#     DB_NAME=\$(basename \"\$FILE\" | sed -E 's/_[0-9]{4}-[0-9]{2}-[0-9]{2}(_[0-9]{2}-[0-9]{2}-[0-9]{2})?\.sql\$//')

#     echo '----------------------------------------'
#     echo \"Restoring \$DB_NAME from \$FILE\"

#     mariadb -u$DB_USER -p$DB_PASS -e \"CREATE DATABASE IF NOT EXISTS \\\`\$DB_NAME\\\`;\" || continue

#     mariadb -u$DB_USER -p$DB_PASS \$DB_NAME < \"\$FILE\" && \
#         echo \"Import successful for \$DB_NAME\" || \
#         echo \"Import FAILED for \$DB_NAME\"

# done

# echo '----------------------------------------'
# echo 'Re-enabling foreign key checks...'
# mariadb -u$DB_USER -p$DB_PASS -e 'SET GLOBAL FOREIGN_KEY_CHECKS=1;'

# echo 'All databases processed.'
# "
#==================================


#!/bin/bash

CONTAINER="9db6bdb75c8f"
DB_USER="root"
DB_PASS="I11TestRoots"
BACKUP_DIR_HOST="/home/ubuntu/test-docker-database-scripts/mariadb-backup"
# BACKUP_DIR_HOST="/Users/hammasahmad/Downloads/swarm/server-backup/mariadb-backup"
BACKUP_DIR_CONTAINER="/tmp/mariadb-backup"

echo "Copying SQL files from host to container..."
docker exec "$CONTAINER" mkdir -p "$BACKUP_DIR_CONTAINER"
docker cp "$BACKUP_DIR_HOST/." "$CONTAINER:$BACKUP_DIR_CONTAINER/"
echo "Copy complete."

docker exec "$CONTAINER" sh -c "

if ! ls $BACKUP_DIR_CONTAINER/*.sql >/dev/null 2>&1; then
  echo 'No SQL files found in $BACKUP_DIR_CONTAINER'
  exit 1
fi

echo '----------------------------------------'
echo 'Processing SQL backup files...'

for FILE in $BACKUP_DIR_CONTAINER/*.sql
do
    BASENAME=\$(basename \"\$FILE\")

    # Remove timestamp to get database name
    DB_NAME=\$(echo \"\$BASENAME\" | sed -E 's/_[0-9]{4}-[0-9]{2}-[0-9]{2}(_[0-9]{2}-[0-9]{2}-[0-9]{2})?\.sql\$//')

    echo '----------------------------------------'
    echo \"Restoring database: \$DB_NAME\"
    echo \"From file: \$FILE\"

    mariadb -u$DB_USER -p$DB_PASS -e \"CREATE DATABASE IF NOT EXISTS \\\`\$DB_NAME\\\`;\" || continue

    mariadb -u$DB_USER -p$DB_PASS \$DB_NAME < \"\$FILE\" && \
        echo \"Import successful for \$DB_NAME\" || \
        echo \"Import FAILED for \$DB_NAME\"

done

echo '----------------------------------------'
echo 'All databases processed.'
"