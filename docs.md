# System Documentation

## 1. Docker Swarm Configuration (v3)

The following `docker-compose.yml` (version 3.8) is used for the Swarm deployment. It defines services for MariaDB, ClickHouse, MongoDB, Redis, and application services.

### `v3/docker-compose.yml`

```yaml
version: "3.8"

services:
  mariadb:
    image: mariadb:11
    volumes:
      - /var/www/docker-swarm-mode/saas-prod/data/mariadb:/var/lib/mysql # need to add the paths when prod server moved
      - /var/www/docker-swarm-mode/saas-prod/db-init/mariadb:/docker-entrypoint-initdb.d:ro # need to add the paths when prod server moved
    environment:
      MYSQL_ROOT_PASSWORD: I11TestRoots
    networks:
      - backend_net
    deploy:
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 10

    command:
      - --innodb-buffer-pool-size=4G
      - --innodb-log-file-size=512M
      - --max-connections=200
      - --innodb-log-buffer-size=16M
      - --innodb-flush-log-at-trx-commit=2

  clickhouse:
    image: clickhouse/clickhouse-server:latest
    user: "101:101"
    volumes:
      - /var/www/docker-swarm-mode/saas-prod/data/clickhouse:/var/lib/clickhouse # need to add the paths when prod server moved
    networks:
      - backend_net
    environment:
      CLICKHOUSE_USER: admin
      CLICKHOUSE_PASSWORD: I11TestRoots
    ulimits:
      nofile:
        soft: 262144
        hard: 262144
    healthcheck:
      test: ["CMD", "wget", "--spider", "-q", "http://localhost:8123/ping"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 60s

  mongodb:
    image: mongo:7.0
    environment:
      - MONGO_INITDB_ROOT_USERNAME=admin
      - MONGO_INITDB_ROOT_PASSWORD=dev
    command:
      - mongod
      - --wiredTigerCacheSizeGB=2
      - --bind_ip_all
    volumes:
      - /var/www/docker-swarm-mode/saas-prod/data/mongo:/data/db # need to add the paths when prod server moved
    networks:
      - backend_net
    deploy:
      restart_policy:
        condition: on-failure
    healthcheck:
      test: ["CMD", "mongosh", "--eval", "db.adminCommand('ping')"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  redis_cache:
    image: redis:7-alpine
    networks:
      - backend_net
    ports:
      - "6379:6379" # optional if you want host access
    deploy:
      resources:
        limits:
          memory: 2G
        reservations:
          memory: 512M
    command:
      - redis-server
      - --maxmemory
      - 1536mb
      - --maxmemory-policy
      - allkeys-lru
      - --save
      - ""
      - --appendonly
      - yes

  identity-management:
    image: o3webmaster/app-service-identity:swarm-mode
    environment:
      - NODE_ENV=development
      - APP_SRC_PATH=/api/v1
      - DB_HOST=mariadb
      - DB_PORT=3306
      - DB_USER=root
      - DB_PASSWORD=I11TestRoots
      - DB_NAME=fiv2_general
      - REDIS_HOST=redis_cache
      - CLICKHOUSE_HOST=http://clickhouse:8123
      - CLICKHOUSE_USER=admin
      - CLICKHOUSE_PASSWORD=I11TestRoots
      - MONGO_URI=mongodb://mongodb:27017/fusion_suite?authSource=admin
    command: ["node", "server.js"]
    ports:
      - "8005:8005"
    networks:
      - backend_net
    deploy:
      replicas: 2
      restart_policy:
        condition: on-failure
        delay: 7s
        max_attempts: 20

  app-services:
    image: o3webmaster/app-services:swarm-mode
    environment:
      - NODE_ENV=development
      - APP_SRC_PATH=/api/v1
      - DB_HOST=mariadb
      - DB_PORT=3306
      - DB_USER=root
      - DB_PASSWORD=I11TestRoots
      - DB_NAME=fiv2_general
      - REDIS_HOST=redis_cache
      - CLICKHOUSE_HOST=http://clickhouse:8123
      - CLICKHOUSE_USER=admin
      - CLICKHOUSE_PASSWORD=I11TestRoots
      - MONGO_URI=mongodb://admin:dev@mongodb:27017/fusion_suite?authSource=admin
    command: ["node", "server.js"]
    ports:
      - "8006:8006"
    networks:
      - backend_net
    deploy:
      replicas: 2
      restart_policy:
        condition: on-failure
        delay: 7s
        max_attempts: 20

  stripe-webhook:
    image: o3webmaster/stripe-webhook
    environment:
      - NODE_ENV=development
      - APP_SRC_PATH=/api/v1
      - DB_HOST=mariadb
      - DB_PORT=3306
      - DB_USER=root
      - DB_PASSWORD=I11TestRoots
      - DB_NAME=fiv2_general
      - REDIS_HOST=redis_cache
      - CLICKHOUSE_HOST=http://clickhouse:8123
      - CLICKHOUSE_USER=admin
      - CLICKHOUSE_PASSWORD=I11TestRoots
      - MONGO_URI=mongodb://admin:dev@mongodb:27017/fusion_suite?authSource=admin
    command: ["node", "server.js"]
    ports:
      - "8011:8011"
    networks:
      - backend_net
    deploy:
      replicas: 2
      restart_policy:
        condition: on-failure
        delay: 7s
        max_attempts: 20

networks:
  frontend_net:
    driver: overlay
    external: true
  backend_net:
    driver: overlay
    external: true
```

## 2. Database Backup & Restore Procedures

### MariaDB

**Backup:**
Run the following commands to dump the databases:

```bash
sudo mysqldump -u root -p fiv2_crashes_collections > fiv2_crashes_collections_11_feb_2026.sql
sudo mysqldump -u root -p fiv2_general > fiv2_general_11_feb_2026.sql
sudo mysqldump -u root -p fiv2_access_control > fiv2_access_control_11_feb_2026.sql
```

**Restore:**
Run the following commands to restore the databases:

```bash
mariadb -u root -p fiv2_crashes_collections < fiv2_crashes_collections_11_feb_2026.sql
mariadb -u root -p fiv2_general < fiv2_general_11_feb_2026.sql
mariadb -u root -p fiv2_access_control < fiv2_access_control_11_feb_2026.sql
```

### MongoDB

**Import:**
To import a collection from a backup file (e.g., `/tmp/backup.json`):

```bash
mongoimport \
  --username admin \
  --password dev \
  --authenticationDatabase admin \
  --db fusion_suite \
  --collection packagelimits \
  --file /tmp/backup.json
```

**Verify:**
Connect via `mongosh` to verify data:

```bash
mongosh -u admin -p dev
db.packagelimits.find().limit(10).pretty()
```

## 3. ClickHouse Backup & Restore Scripts

### Backup Script (`backup-script`) for ClickHouse DB Data

This script exports all tables from a specified database into CSV files.

**Script Logic:**

1.  Connects to ClickHouse using credentials (`admin`, `I11TestRoots`).
2.  Creates a backup directory with a timestamp.
3.  Fetches all tables using `SHOW TABLES`.
4.  Loops through each table and exports data using:
    ```sql
    SELECT * FROM <database>.<table> FORMAT CSVWithNames
    ```

**Usage:**
Ensure the script is executable (`chmod +x backup-script`) and run it. It defaults to backing up the `fusion_suite` database (configurable).

### Restore Script (`restore-script`)

This script imports data from the CSV files generated by the backup script.

**Script Logic:**

1.  Points to a source directory containing the CSV files.
2.  Checks if the target database exists; if not, creates it.
3.  Loops through all `.csv` files in the backup directory.
4.  For each file:
    - Checks if the table exists.
    - **If missing**: Reads the CSV header to infer columns (defaults to `String` type for simplicity) and creates the table with `ENGINE = MergeTree()`.
    - **If exists**: Skips creation.
    - Imports data using:
      ```sql
      INSERT INTO <database>.<table> FORMAT CSVWithNames
      ```

**Usage:**
Update the `BACKUP_DIR` variable in the script to point to your backup folder, then run the script.
