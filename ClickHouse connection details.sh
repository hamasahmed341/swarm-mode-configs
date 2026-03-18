# ClickHouse connection details
CLICKHOUSE_HOST="localhost"
CLICKHOUSE_PORT="9000"
CLICKHOUSE_USER="admin"
CLICKHOUSE_PASS="I11TestRoots"

# MySQL Connection details
MYSQL_USER="root"
MYSQL_PASSWORD="I11TestRoots"


# Create the ClickHouse Tables For Fusion Suite Features Including Secure Link And 2FA

echo "Starting ClickHouse Database Creation \n."

 clickhouse-client --host="$CLICKHOUSE_HOST" --port="$CLICKHOUSE_PORT" --user="$CLICKHOUSE_USER" --password="$CLICKHOUSE_PASS" --query="
 CREATE DATABASE IF NOT EXISTS fiv2_secure_link;"

echo "Database fiv2_secure_link Created Successfully."

 clickhouse-client --host="$CLICKHOUSE_HOST" --port="$CLICKHOUSE_PORT" --user="$CLICKHOUSE_USER" --password="$CLICKHOUSE_PASS" --query="
CREATE DATABASE IF NOT EXISTS fiv2_secure_link_2FA_configurations;"

 echo "Database fiv2_secure_link_2FA_configurations Created Successfully."

clickhouse-client --host="$CLICKHOUSE_HOST" --port="$CLICKHOUSE_PORT" --user="$CLICKHOUSE_USER" --password="$CLICKHOUSE_PASS" --query="
    CREATE DATABASE IF NOT EXISTS fusion_suite;"

    echo "Database fusion_suite Created Successfully."

clickhouse-client --host="$CLICKHOUSE_HOST" --port="$CLICKHOUSE_PORT" --user="$CLICKHOUSE_USER" --password="$CLICKHOUSE_PASS" --query="
    CREATE DATABASE IF NOT EXISTS fiv2_general;"

    echo "Database fiv2_general Created Successfully."

    clickhouse-client --host="$CLICKHOUSE_HOST" --port="$CLICKHOUSE_PORT" --user="$CLICKHOUSE_USER" --password="$CLICKHOUSE_PASS" --query="
CREATE DATABASE fiv2_issues_progress_log;"

echo "Database fiv2_issues_progress_log Created Successfully."



 clickhouse-client --host="$CLICKHOUSE_HOST" --port="$CLICKHOUSE_PORT" --user="$CLICKHOUSE_USER" --password="$CLICKHOUSE_PASS" --query="
 CREATE TABLE fiv2_secure_link.2fa_enabled_devices
(
    kuid UUID DEFAULT generateUUIDv4(),
    publicKey String,
    deviceId String,
    deviceModel String,
    deviceOS String,
    hostAppVersion String,
    isRooted UInt8,
    screenResolution String,
    userIdentifier Nullable(String),
    sdkVersion String,
    workspaceKuid String,
    projectKuid String,
    status Enum8('enabled' = 0, 'disabled' = 1),
    created_at DateTime DEFAULT now()
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(created_at)
ORDER BY (deviceId, publicKey, workspaceKuid, projectKuid, status, created_at)
SETTINGS index_granularity = 8192;
"

# Finish
echo "new 2fa_enabled_devices table IN fiv2_secure_link database Created Successfully."


 clickhouse-client --host="$CLICKHOUSE_HOST" --port="$CLICKHOUSE_PORT" --user="$CLICKHOUSE_USER" --password="$CLICKHOUSE_PASS" --query="
CREATE TABLE fiv2_secure_link.device_verification_requests
(
    kuid UUID DEFAULT generateUUIDv4(),
    fcmToken String,
    deviceId String,
    deviceModel String,
    deviceOS String,
    hostAppVersion String,
    isRooted UInt8,
    screenResolution String,
    userIdentifier Nullable(String),
    sdkVersion String,
    workspaceKuid String,
    projectKuid String,
    journey String,
    status Enum8('Passed' = 0, 'Blocked' = 1, 'TimedOut' = 2, 'Failed' = 3, 'Pending' = 4, 'Invalid App State' = 5),
    created_at DateTime DEFAULT now(),
    ipAddress Nullable(String),
    challenge String
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(created_at)
ORDER BY (deviceId, workspaceKuid, projectKuid, created_at)
SETTINGS index_granularity = 8192;
"

# Finish
echo "new device_verification_requests table IN fiv2_secure_link database Created Successfully."

 clickhouse-client --host="$CLICKHOUSE_HOST" --port="$CLICKHOUSE_PORT" --user="$CLICKHOUSE_USER" --password="$CLICKHOUSE_PASS" --query="
CREATE TABLE fiv2_secure_link_2FA_configurations.application_configurations
(
    record_kuid Nullable(String),
    workspace_kuid String,
    project_kuid String,
    application_type Enum8('app_store_play_store_app' = 1, 'non_public_app' = 2, 'smart_pos_app' = 3),
    configuration String,
    status Enum8('active' = 1, 'disabled' = 2),
    created_at DateTime DEFAULT now(),
    modified_by String
)
ENGINE = MergeTree
ORDER BY (workspace_kuid, project_kuid, status)
SETTINGS index_granularity = 8192;
"

# Finish
echo "new application_configurations table IN fiv2_secure_link_2FA_configurations database Created Successfully."


echo "ClickHouse Database and Tables For Secure Link And 2FA Created Successfully."


   clickhouse-client --host="$CLICKHOUSE_HOST" --port="$CLICKHOUSE_PORT" --user="$CLICKHOUSE_USER" --password="$CLICKHOUSE_PASS" --query="
CREATE TABLE fiv2_general.issue_resolution_statuses
(
    id UInt32,
    kuid String,
    statusName String,
    projectId Nullable(UInt32),
    projectKuid Nullable(String),
    statusType Enum8('todo' = 1, 'in_progress' = 2, 'done' = 3, 'invalid' = 4, 'recurring' = 5) DEFAULT 'todo',
    sortOrder UInt8 DEFAULT 0,
    isActive UInt8 DEFAULT 1,
    createdOn DateTime DEFAULT now()
)
ENGINE = MySQL('mariadb:3306', 'fiv2_general', 'issue_resolution_statuses', 'root',  'I11TestRoots');"

echo "Table Created In fiv2_general.issue_resolution_statuses Database."

         clickhouse-client --host="$CLICKHOUSE_HOST" --port="$CLICKHOUSE_PORT" --user="$CLICKHOUSE_USER" --password="$CLICKHOUSE_PASS" --query="
CREATE TABLE fiv2_general.users
(
    userId UInt32,
    kuid Nullable(String),
    fullName Nullable(String)
)
ENGINE = MySQL('mariadb:3306', 'fiv2_general', 'users', 'root',  'I11TestRoots');
    "

   echo "Table Created In fiv2_general.users Database."

             clickhouse-client --host="$CLICKHOUSE_HOST" --port="$CLICKHOUSE_PORT" --user="$CLICKHOUSE_USER" --password="$CLICKHOUSE_PASS" --query="
CREATE TABLE fiv2_general.Crash_progress_manager
(
    id UInt32,
    projectKuid String,
    workspaceKuid String,
    crashSignature String,
    newStatusValue Nullable(String),
    newAssigneeValue Nullable(String),
    newPriorityValue Nullable(String),
    updateOn Nullable(String)
)
ENGINE = MySQL('mariadb:3306', 'fiv2_crashes_collections', 'Crash_progress_manager', 'root',  'I11TestRoots');"

echo "Table Created In fiv2_general.Crash_progress_manager Database."

                 clickhouse-client --host="$CLICKHOUSE_HOST" --port="$CLICKHOUSE_PORT" --user="$CLICKHOUSE_USER" --password="$CLICKHOUSE_PASS" --query="
CREATE TABLE fiv2_general.releases
(
    kuid Nullable(String),
    projectKuid Nullable(String),
    releaseVersionCode Nullable(String),
    renouncedAt Nullable(String)
)
ENGINE = MySQL('mariadb:3306', 'fiv2_general', 'releases', 'root', 'I11TestRoots');
    "
echo "Table Created In fiv2_general.releases Database."



echo "ClickHouse Shell Database and Tables For fiv2_general is Created Successfully."



# Create table for fiv2_post_handshake_session_logs_raw
clickhouse-client --host="$CLICKHOUSE_HOST" --port="$CLICKHOUSE_PORT" --user="$CLICKHOUSE_USER" --password="$CLICKHOUSE_PASS" --query="
   CREATE TABLE fusion_suite.fiv2_post_handshake_session_logs_raw
(
    id UUID DEFAULT generateUUIDv4(),
    eventType Enum8('handshake' = 1, 'crash' = 2, 'ANR' = 3, 'bug' = 4, 'complaint' = 5),
    projectKuid String,
    workspaceKuid String,
    deviceId String,
    deviceOS Nullable(String) DEFAULT NULL,
    appVersion String,
    network String,
    createdOn DateTime DEFAULT now()
)
ENGINE = MergeTree
ORDER BY createdOn
TTL createdOn + toIntervalDay(28)
SETTINGS index_granularity = 8192
"

echo "Table Created In fusion_suite.fiv2_post_handshake_session_logs_raw Database."


# Create table for fiv2_post_handshake_fiv2_post_handshake_aggregatedsession_logs_raw
clickhouse-client --host="$CLICKHOUSE_HOST" --port="$CLICKHOUSE_PORT" --user="$CLICKHOUSE_USER" --password="$CLICKHOUSE_PASS" --query="
CREATE TABLE fusion_suite.fiv2_post_handshake_aggregated
(
    appVersion String,
    projectKuid String,
    workspaceKuid String,
    numberOfUniqueDevices UInt64,
    crashFreeSessionPercentage Float32,
    createdOn DateTime DEFAULT now()
)
ENGINE = AggregatingMergeTree
PARTITION BY toYYYYMM(createdOn)
ORDER BY (projectKuid, workspaceKuid, appVersion, createdOn)
SETTINGS index_granularity = 8192
"

echo "Table Created In fusion_suite.fiv2_post_handshake_aggregated Database."


# Create table for fiv2_post_handshake_mv
clickhouse-client --host="$CLICKHOUSE_HOST" --port="$CLICKHOUSE_PORT" --user="$CLICKHOUSE_USER" --password="$CLICKHOUSE_PASS" --query="
    CREATE MATERIALIZED VIEW fusion_suite.fiv2_post_handshake_mv TO fusion_suite.fiv2_post_handshake_aggregated
(
    appVersion String,
    projectKuid String,
    workspaceKuid String,
    numberOfUniqueDevices UInt64,
    crashFreeSessionPercentage Float64,
    createdOn DateTime
)
AS SELECT
    tbl.appVersion,
    tbl.projectKuid,
    tbl.workspaceKuid,
    COUNTDistinct(tbl.deviceId) AS numberOfUniqueDevices,
    round(coalesce((sum(multiIf(tbl.eventType = 'handshake', 1, 0)) - sum(multiIf(tbl.eventType = 'crash', 1, 0))) / nullIf(sum(multiIf(tbl.eventType = 'handshake', 1, 0)), 0), 0) * 100) AS crashFreeSessionPercentage,
    tbl.createdOn
FROM fusion_suite.fiv2_post_handshake_session_logs_raw AS tbl
GROUP BY
    tbl.appVersion,
    tbl.projectKuid,
    tbl.workspaceKuid,
    tbl.createdOn;
"

echo "Table Created In fusion_suite.fiv2_post_handshake_mv Materalized View."

clickhouse-client --host="$CLICKHOUSE_HOST" --port="$CLICKHOUSE_PORT" --user="$CLICKHOUSE_USER" --password="$CLICKHOUSE_PASS" --query="
CREATE VIEW fusion_suite.fiv2_post_handshake_fast_view
(
    appVersion String,
    projectKuid String,
    workspaceKuid String,
    totalUniqueUsers UInt64,
    totalCrashFreeSessions Float64,
    lastUpdated DateTime
)
AS SELECT
    appVersion,
    projectKuid,
    workspaceKuid,
    sum(numberOfUniqueDevices) AS totalUniqueUsers,
    round(sum(crashFreeSessionPercentage) / count(*), 2) AS totalCrashFreeSessions,
    max(createdOn) AS lastUpdated
FROM fusion_suite.fiv2_post_handshake_aggregated
GROUP BY
    appVersion,
    projectKuid,
    workspaceKuid;
"

echo "Table Created In fusion_suite.fiv2_post_handshake_fast_view Materalized Data Retreval View."


    clickhouse-client --host="$CLICKHOUSE_HOST" --port="$CLICKHOUSE_PORT" --user="$CLICKHOUSE_USER" --password="$CLICKHOUSE_PASS" --query="
    CREATE TABLE fusion_suite.fiv2_crashes_collections
(
    crashId UUID DEFAULT generateUUIDv4(),
    kuid String,
    projectId String DEFAULT 0,
    projectKuid String,
    workspaceKuid String,
    crashTitle Nullable(String),
    crashDescription Nullable(String),
    screenshotList Nullable(String),
    familySignature String COMMENT 'used to hash last two user screen names to group the relevancy for the developer to locate similar screen related crashes',
    signature_a Nullable(String),
    signature_b Nullable(String),
    signature_c Nullable(String),
    userActivityLogs String,
    previous_activityLogs String,
    previous_activitySnapshots Nullable(String),
    source_viewNamesVisited Nullable(String),
    source_lastViewName Nullable(String),
    familySignature_refId Nullable(UInt32) DEFAULT 0,
    env_hostAppVersion String,
    env_isSignedRelease Nullable(UInt8) COMMENT 'Reflects if the build is a debug build or a release build.',
    env_deviceOS Nullable(String),
    env_deviceModel Nullable(String),
    env_deviceId String,
    env_appPackageId Nullable(String),
    env_isEmulator Nullable(UInt8),
    env_isRooted Nullable(UInt8),
    env_sdkVersionId Nullable(String),
    env_freeMemory Nullable(String),
    env_freeDisk Nullable(String),
    env_isOnBattery Nullable(UInt8),
    env_batteryLevel Nullable(String),
    screenDensity Nullable(String),
    screenResolution Nullable(String),
    resolutionStatusId Nullable(UInt32) DEFAULT 1,
    resolutionStatusKuid String DEFAULT 'xyz1',
    sprintId Nullable(Int32),
    sprintKuid Nullable(String),
    reported_by Nullable(UInt32),
    reportee_roleType Nullable(UInt32),
    reporteeName Nullable(String) COMMENT 'Added for future usecase(s) where required.',
    reporteeEmail Nullable(String) COMMENT 'Added for future usecase(s) where required.',
    assignedTo Nullable(String),
    reproSteps_screenshots Nullable(String) COMMENT 'allowing last 5 screenshots',
    consoleLogs Nullable(String) COMMENT 'console logs containing filename',
    native_logs Nullable(String),
    stackTraceFileName Nullable(String) COMMENT 'Used by the mobile SDK to upload complete crash stack trace.',
    deobfuscatedStackTrace Nullable(String),
    week_year Nullable(Int16),
    priority Nullable(String),
    createdAt DateTime DEFAULT now(),
    crashDate Date DEFAULT toDate(createdAt),
    userEmailAddress Nullable(String),
    userPhoneNumber Nullable(String)
)
ENGINE = MergeTree
PRIMARY KEY crashId
ORDER BY (crashId, workspaceKuid, projectKuid, crashDate, env_hostAppVersion, familySignature, resolutionStatusKuid, env_deviceId)
SETTINGS index_granularity = 8192;
    "
echo "Table Created In fusion_suite.fiv2_crashes_collections Database."

       clickhouse-client --host="$CLICKHOUSE_HOST" --port="$CLICKHOUSE_PORT" --user="$CLICKHOUSE_USER" --password="$CLICKHOUSE_PASS" --query="
    CREATE TABLE fusion_suite.fiv2_crash_console_logs
(
    id UUID DEFAULT generateUUIDv4(),
    crashId UUID,
    consoleLogs Nullable(String),
    createdOn DateTime DEFAULT now()
)
ENGINE = MergeTree
ORDER BY crashId
SETTINGS index_granularity = 8192;
    "

echo "Table Created In fusion_suite.fiv2_crash_console_logs Database."

      clickhouse-client --host="$CLICKHOUSE_HOST" --port="$CLICKHOUSE_PORT" --user="$CLICKHOUSE_USER" --password="$CLICKHOUSE_PASS" --query="
    CREATE TABLE fusion_suite.fiv2_crash_native_logs
(
    id UUID DEFAULT generateUUIDv4(),
    crashId UUID,
    nativeLogs Nullable(String),
    createdOn DateTime DEFAULT now()
)
ENGINE = MergeTree
ORDER BY crashId
SETTINGS index_granularity = 8192;
    "

    echo "Table Created In fusion_suite.fiv2_crash_native_logs Database."

     clickhouse-client --host="$CLICKHOUSE_HOST" --port="$CLICKHOUSE_PORT" --user="$CLICKHOUSE_USER" --password="$CLICKHOUSE_PASS" --query="
   CREATE TABLE fusion_suite.fiv2_crash_repro_steps
(
    id UUID DEFAULT generateUUIDv4(),
    crashId UUID,
    reproStepsMedia Nullable(String),
    createdOn DateTime DEFAULT now()
)
ENGINE = MergeTree
ORDER BY crashId
SETTINGS index_granularity = 8192;
    "
 echo "Table Created In fusion_suite.fiv2_crash_repro_steps Database."

        clickhouse-client --host="$CLICKHOUSE_HOST" --port="$CLICKHOUSE_PORT" --user="$CLICKHOUSE_USER" --password="$CLICKHOUSE_PASS" --query="
  CREATE TABLE fusion_suite.fiv2_crash_recurring_monitor
(
    id UUID DEFAULT generateUUIDv4(),
    workspaceKuid String,
    projectKuid String,
    familySignature String,
    appVersion String,
    createdOn DateTime DEFAULT now()
)
ENGINE = MergeTree
ORDER BY (workspaceKuid, projectKuid, familySignature)
SETTINGS index_granularity = 8192;
    "

     echo "Table Created In fusion_suite.fiv2_crash_recurring_monitor Database."

      clickhouse-client --host="$CLICKHOUSE_HOST" --port="$CLICKHOUSE_PORT" --user="$CLICKHOUSE_USER" --password="$CLICKHOUSE_PASS" --query="
CREATE MATERIALIZED VIEW fusion_suite.mv_crash_counts_per_day_by_app_version
(
    date Date,
    appVersion String,
    projectKuid String,
    workspaceKuid String,
    total_crashes UInt64
)
ENGINE = SummingMergeTree
ORDER BY (date, appVersion, projectKuid, workspaceKuid)
SETTINGS index_granularity = 8192
AS SELECT
    toDate(createdOn) AS date,
    appVersion,
    projectKuid,
    workspaceKuid,
    count() AS total_crashes
FROM fusion_suite.fiv2_post_handshake_session_logs_raw
WHERE eventType = 'crash'
GROUP BY
    date,
    appVersion,
    projectKuid,
    workspaceKuid;
    "

     echo "Table Created In fusion_suite.mv_crash_counts_per_day_by_app_version Materalized View."
   

                     clickhouse-client --host="$CLICKHOUSE_HOST" --port="$CLICKHOUSE_PORT" --user="$CLICKHOUSE_USER" --password="$CLICKHOUSE_PASS" --query="
CREATE TABLE fusion_suite.fiv2_customerfeedback_collections
(
    feedbackId UUID,
    kuid String,
    surveyKuid String,
    workspaceKuid String,
    projectKuid String,
    deviceId String,
    deviceModel Nullable(String),
    screenResolution Nullable(String),
    deviceOS Nullable(String),
    hostAppVersion String,
    freeMemory Nullable(String),
    freeDisk Nullable(String),
    batteryLevel Nullable(String),
    isSignedRelease Nullable(Bool),
    isEmulator Nullable(Bool),
    isRooted Nullable(Bool),
    sdkVersion Nullable(String),
    customerRating UInt8 DEFAULT 0,
    responderDetail Nullable(String),
    responseType Nullable(String),
    responderCountry Nullable(String),
    questions Nullable(String),
    comments Nullable(String),
    feedback_mode Enum8('code_trigger' = 1, 'scheduled_trigger' = 2),
    createdAt DateTime DEFAULT now(),
    responseDate DateTime DEFAULT toDate(createdAt),
    surveyType Enum8('app-rating' = 1, 'nps' = 2, 'new-feature' = 3, 'custom' = 4)
)
ENGINE = MergeTree
ORDER BY (workspaceKuid, projectKuid, surveyKuid, hostAppVersion, customerRating, responseDate)
SETTINGS index_granularity = 8192;
"

echo "Table Created In fusion_suite.fiv2_customerfeedback_collections Database."

    clickhouse-client --host="$CLICKHOUSE_HOST" --port="$CLICKHOUSE_PORT" --user="$CLICKHOUSE_USER" --password="$CLICKHOUSE_PASS" --query="
    CREATE TABLE fusion_suite.fiv2_pre_post_survey_sessions
(
    sessionId UUID,
    kuid String,
    surveyKuid String,
    workspaceKuid String,
    projectKuid String,
    hostAppVersion String,
    activityType Enum8('seen' = 1, 'respond' = 2),
    created_at DateTime
)
ENGINE = MergeTree
ORDER BY created_at
SETTINGS index_granularity = 8192;
    "

    echo "Table Created In fusion_suite.fiv2_pre_post_survey_sessions Database."

        clickhouse-client --host="$CLICKHOUSE_HOST" --port="$CLICKHOUSE_PORT" --user="$CLICKHOUSE_USER" --password="$CLICKHOUSE_PASS" --query="
CREATE TABLE fusion_suite.daily_survey_stats
(
    date Date,
    surveyKuid String,
    workspaceKuid String,
    projectKuid String,
    hostAppVersion String,
    seen_count AggregateFunction(sum, UInt64),
    respond_count AggregateFunction(sum, UInt64)
)
ENGINE = AggregatingMergeTree
ORDER BY (date, workspaceKuid, projectKuid, hostAppVersion, surveyKuid)
SETTINGS index_granularity = 8192;
    "

    echo "Table Created In fusion_suite.daily_survey_stats Database."

        clickhouse-client --host="$CLICKHOUSE_HOST" --port="$CLICKHOUSE_PORT" --user="$CLICKHOUSE_USER" --password="$CLICKHOUSE_PASS" --query="
CREATE MATERIALIZED VIEW fusion_suite.raw_data_to_daily_survey_stats TO fusion_suite.daily_survey_stats
(
    date Date,
    surveyKuid String,
    workspaceKuid String,
    projectKuid String,
    hostAppVersion String,
    seen_count AggregateFunction(sum, UInt64),
    respond_count AggregateFunction(sum, UInt64)
)
AS SELECT
    toDate(created_at) AS date,
    surveyKuid,
    workspaceKuid,
    projectKuid,
    hostAppVersion,
    sumState(CAST(if(activityType = 'seen', 1, 0), 'UInt64')) AS seen_count,
    sumState(CAST(if(activityType = 'respond', 1, 0), 'UInt64')) AS respond_count
FROM fusion_suite.fiv2_pre_post_survey_sessions
GROUP BY
    date,
    workspaceKuid,
    projectKuid,
    hostAppVersion,
    surveyKuid;
    "

    echo "Table Created In fusion_suite.raw_data_to_daily_survey_stats Materalized View."

        clickhouse-client --host="$CLICKHOUSE_HOST" --port="$CLICKHOUSE_PORT" --user="$CLICKHOUSE_USER" --password="$CLICKHOUSE_PASS" --query="
CREATE VIEW fusion_suite.daily_survey_stats_view
(
    date Date,
    surveyKuid String,
    workspaceKuid String,
    projectKuid String,
    hostAppVersion String,
    seen_count UInt64,
    respond_count UInt64
)
AS SELECT
    date,
    surveyKuid,
    workspaceKuid,
    projectKuid,
    hostAppVersion,
    sumMerge(seen_count) AS seen_count,
    sumMerge(respond_count) AS respond_count
FROM fusion_suite.daily_survey_stats
GROUP BY
    date,
    workspaceKuid,
    projectKuid,
    hostAppVersion,
    surveyKuid;
    "

    echo "Table Created In fusion_suite.daily_survey_stats_view View."


            clickhouse-client --host="$CLICKHOUSE_HOST" --port="$CLICKHOUSE_PORT" --user="$CLICKHOUSE_USER" --password="$CLICKHOUSE_PASS" --query="
CREATE TABLE fusion_suite.daily_crash_counts
(
    date Date,
    projectKuid String,
    workspaceKuid String,
    appVersion String,
    crashCount UInt64
)
ENGINE = MergeTree
ORDER BY date
SETTINGS index_granularity = 8192;
    "

    echo "Table Created In fusion_suite.daily_crash_counts Database."


                clickhouse-client --host="$CLICKHOUSE_HOST" --port="$CLICKHOUSE_PORT" --user="$CLICKHOUSE_USER" --password="$CLICKHOUSE_PASS" --query="
CREATE VIEW fusion_suite.daily_crash_counts_summary
(
    date Date,
    projectKuid String,
    workspaceKuid String,
    appVersion String,
    total_crashes UInt64
)
AS SELECT
    date,
    projectKuid,
    workspaceKuid,
    appVersion,
    sum(crashCount) AS total_crashes
FROM fusion_suite.daily_crash_counts
GROUP BY
    date,
    projectKuid,
    workspaceKuid,
    appVersion
ORDER BY
    date ASC,
    projectKuid ASC,
    workspaceKuid ASC,
    appVersion ASC
    "

    echo "Table Created In fusion_suite.daily_crash_counts_summary View."


                clickhouse-client --host="$CLICKHOUSE_HOST" --port="$CLICKHOUSE_PORT" --user="$CLICKHOUSE_USER" --password="$CLICKHOUSE_PASS" --query="
CREATE MATERIALIZED VIEW fusion_suite.mv_daily_crash_counts TO fusion_suite.daily_crash_counts
(
    date Date,
    projectKuid String,
    workspaceKuid String,
    appVersion String,
    crashCount UInt64
)
AS SELECT
    toDate(createdOn) AS date,
    projectKuid,
    workspaceKuid,
    appVersion,
    countIf(eventType = 'crash') AS crashCount
FROM fusion_suite.fiv2_post_handshake_session_logs_raw
WHERE eventType = 'crash'
GROUP BY
    date,
    projectKuid,
    workspaceKuid,
    appVersion 
    "

    echo "Table Created In fusion_suite.mv_daily_crash_counts Materialized View."

# Finish

echo -e "\n${GREEN}Database creation are complete for fusion features!${NC}"






