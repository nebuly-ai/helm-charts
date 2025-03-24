# Convert comma-separated services to space-separated list
CLICKHOUSE_SERVICES=$(echo "$CLICKHOUSE_SERVICES" | tr "," " ")
BACKUP_DATE=$(date +%Y-%m-%d-%H-%M-%S)

declare -A BACKUP_NAMES
declare -A DIFF_FROM

# Handle backup password if provided
if [[ -n "$BACKUP_PASSWORD" ]]; then
    BACKUP_PASSWORD="--password=$BACKUP_PASSWORD"
fi

# Determine backup type for each server
for SERVER in $CLICKHOUSE_SERVICES; do
    if [[ "$MAKE_INCREMENT_BACKUP" == "1" ]]; then
        LAST_FULL_BACKUP=$(clickhouse-client -q "SELECT name FROM system.backup_list \
            WHERE location='remote' AND name LIKE '%${SERVER}%' AND name LIKE '%full%' \
            AND desc NOT LIKE 'broken%' ORDER BY created DESC LIMIT 1 FORMAT TabSeparatedRaw" \
            --host="$SERVER" --port="$CLICKHOUSE_PORT" --user="$BACKUP_USER" $BACKUP_PASSWORD)

        TODAY_FULL_BACKUP=$(clickhouse-client -q "SELECT name FROM system.backup_list \
            WHERE location='remote' AND name LIKE '%${SERVER}%' AND name LIKE '%full%' \
            AND desc NOT LIKE 'broken%' AND toDate(created) = today() \
            ORDER BY created DESC LIMIT 1 FORMAT TabSeparatedRaw" \
            --host="$SERVER" --port="$CLICKHOUSE_PORT" --user="$BACKUP_USER" $BACKUP_PASSWORD)

        PREV_BACKUP_NAME=$(clickhouse-client -q "SELECT name FROM system.backup_list \
            WHERE location='remote' AND desc NOT LIKE 'broken%' ORDER BY created DESC \
            LIMIT 1 FORMAT TabSeparatedRaw" \
            --host="$SERVER" --port="$CLICKHOUSE_PORT" --user="$BACKUP_USER" $BACKUP_PASSWORD)

        DIFF_FROM[$SERVER]=""

        if [[ ("$FULL_BACKUP_WEEKDAY" == "$(date +%u)" && -z "$TODAY_FULL_BACKUP") || -z "$PREV_BACKUP_NAME" || -z "$LAST_FULL_BACKUP" ]]; then
            BACKUP_NAMES[$SERVER]="full-$BACKUP_DATE"
        else
            BACKUP_NAMES[$SERVER]="increment-$BACKUP_DATE"
            DIFF_FROM[$SERVER]="--diff-from-remote=$PREV_BACKUP_NAME"
        fi
    else
        BACKUP_NAMES[$SERVER]="full-$BACKUP_DATE"
    fi
    echo "Set backup name on $SERVER = ${BACKUP_NAMES[$SERVER]}"
done

# Initiate backup creation
for SERVER in $CLICKHOUSE_SERVICES; do
    echo "Creating ${BACKUP_NAMES[$SERVER]} on $SERVER"
    clickhouse-client --echo -mn -q "INSERT INTO system.backup_actions(command) \
        VALUES('create ${SERVER}-${BACKUP_NAMES[$SERVER]}')" \
        --host="$SERVER" --port="$CLICKHOUSE_PORT" --user="$BACKUP_USER" $BACKUP_PASSWORD
done

# Monitor backup process
for SERVER in $CLICKHOUSE_SERVICES; do
    while [[ "in progress" == $(clickhouse-client -mn -q "SELECT status FROM system.backup_actions \
        WHERE command='create ${SERVER}-${BACKUP_NAMES[$SERVER]}' FORMAT TabSeparatedRaw" \
        --host="$SERVER" --port="$CLICKHOUSE_PORT" --user="$BACKUP_USER" $BACKUP_PASSWORD) ]]; do
        echo "Still in progress ${BACKUP_NAMES[$SERVER]} on $SERVER"
        sleep 1
    done

    if [[ "success" != $(clickhouse-client -mn -q "SELECT status FROM system.backup_actions \
        WHERE command='create ${SERVER}-${BACKUP_NAMES[$SERVER]}' FORMAT TabSeparatedRaw" \
        --host="$SERVER" --port="$CLICKHOUSE_PORT" --user="$BACKUP_USER" $BACKUP_PASSWORD) ]]; then
        echo "Error creating ${BACKUP_NAMES[$SERVER]} on $SERVER"
        clickhouse-client -mn --echo -q "SELECT status,error FROM system.backup_actions \
            WHERE command='create ${SERVER}-${BACKUP_NAMES[$SERVER]}'" \
            --host="$SERVER" --port="$CLICKHOUSE_PORT" --user="$BACKUP_USER" $BACKUP_PASSWORD
        exit 1
    fi
done

# Upload backups
for SERVER in $CLICKHOUSE_SERVICES; do
    echo "Uploading ${DIFF_FROM[$SERVER]} ${BACKUP_NAMES[$SERVER]} on $SERVER"
    clickhouse-client --echo -mn -q "INSERT INTO system.backup_actions(command) \
        VALUES('upload ${DIFF_FROM[$SERVER]} ${SERVER}-${BACKUP_NAMES[$SERVER]}')" \
        --host="$SERVER" --port="$CLICKHOUSE_PORT" --user="$BACKUP_USER" $BACKUP_PASSWORD
done

# Monitor upload process
for SERVER in $CLICKHOUSE_SERVICES; do
    while [[ "in progress" == $(clickhouse-client -mn -q "SELECT status FROM system.backup_actions \
        WHERE command='upload ${DIFF_FROM[$SERVER]} ${SERVER}-${BACKUP_NAMES[$SERVER]}'" \
        --host="$SERVER" --port="$CLICKHOUSE_PORT" --user="$BACKUP_USER" $BACKUP_PASSWORD) ]]; do
        echo "Upload still in progress ${BACKUP_NAMES[$SERVER]} on $SERVER"
        sleep 5
    done

    if [[ "success" != $(clickhouse-client -mn -q "SELECT status FROM system.backup_actions \
        WHERE command='upload ${DIFF_FROM[$SERVER]} ${SERVER}-${BACKUP_NAMES[$SERVER]}'" \
        --host="$SERVER" --port="$CLICKHOUSE_PORT" --user="$BACKUP_USER" $BACKUP_PASSWORD) ]]; then
        echo "Error uploading ${BACKUP_NAMES[$SERVER]} on $SERVER"
        clickhouse-client -mn --echo -q "SELECT status,error FROM system.backup_actions \
            WHERE command='upload ${DIFF_FROM[$SERVER]} ${SERVER}-${BACKUP_NAMES[$SERVER]}'" \
            --host="$SERVER" --port="$CLICKHOUSE_PORT" --user="$BACKUP_USER" $BACKUP_PASSWORD
        exit 1
    fi

    clickhouse-client --echo -mn -q "INSERT INTO system.backup_actions(command) \
        VALUES('delete local ${SERVER}-${BACKUP_NAMES[$SERVER]}')" \
        --host="$SERVER" --port="$CLICKHOUSE_PORT" --user="$BACKUP_USER" $BACKUP_PASSWORD
done

echo "BACKUP CREATED"

