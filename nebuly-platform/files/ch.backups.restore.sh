if [[ "" != "$BACKUP_PASSWORD" ]]; then
  BACKUP_PASSWORD="--password=$BACKUP_PASSWORD";
fi;

declare -A BACKUP_NAMES;
CLICKHOUSE_SCHEMA_RESTORE_SERVICES=$(echo $CLICKHOUSE_SCHEMA_RESTORE_SERVICES | tr "," " ");
CLICKHOUSE_DATA_RESTORE_SERVICES=$(echo $CLICKHOUSE_DATA_RESTORE_SERVICES | tr "," " ");

for SERVER in $CLICKHOUSE_SCHEMA_RESTORE_SERVICES; do
  SHARDED_PREFIX=${SERVER%-*}

  if [[ -n "$BACKUP_NAME" ]]; then
    LATEST_BACKUP_NAME="$BACKUP_NAME"
  else
    LATEST_BACKUP_NAME=$(clickhouse-client -q "SELECT name FROM system.backup_list WHERE location='remote' AND desc NOT LIKE 'broken%' AND name LIKE '%${SHARDED_PREFIX}%' ORDER BY created DESC LIMIT 1 FORMAT TabSeparatedRaw" --host="$SERVER" --port="$CLICKHOUSE_PORT" --user="$BACKUP_USER" $BACKUP_PASSWORD);
  fi;

  if [[ "" == "$LATEST_BACKUP_NAME" ]]; then
    echo "Remote backup not found for $SERVER";
    exit 1;
  fi;

  BACKUP_NAMES[$SERVER]="$LATEST_BACKUP_NAME";
  clickhouse-client -mn --echo -q "INSERT INTO system.backup_actions(command) VALUES('restore_remote --schema --rm ${BACKUP_NAMES[$SERVER]}')" --host="$SERVER" --port="$CLICKHOUSE_PORT" --user="$BACKUP_USER" $BACKUP_PASSWORD;

  while [[ "in progress" == $(clickhouse-client -mn -q "SELECT status FROM system.backup_actions WHERE command='restore_remote --schema --rm ${BACKUP_NAMES[$SERVER]}' ORDER BY start DESC LIMIT 1 FORMAT TabSeparatedRaw" --host="$SERVER" --port="$CLICKHOUSE_PORT" --user="$BACKUP_USER" $BACKUP_PASSWORD) ]]; do
    echo "still in progress ${BACKUP_NAMES[$SERVER]} on $SERVER";
    sleep 1;
  done;

  RESTORE_STATUS=$(clickhouse-client -mn -q "SELECT status FROM system.backup_actions WHERE command='restore_remote --schema --rm ${BACKUP_NAMES[$SERVER]}' ORDER BY start DESC LIMIT 1 FORMAT TabSeparatedRaw" --host="$SERVER" --port="$CLICKHOUSE_PORT" --user="$BACKUP_USER" $BACKUP_PASSWORD);

  if [[ "success" != "${RESTORE_STATUS}" ]]; then
    echo "error restore_remote --schema --rm ${BACKUP_NAMES[$SERVER]} on $SERVER";
    clickhouse-client -mn --echo -q "SELECT start,finish,status,error FROM system.backup_actions WHERE command='restore_remote --schema --rm ${BACKUP_NAMES[$SERVER]}'" --host="$SERVER" --port="$CLICKHOUSE_PORT" --user="$BACKUP_USER" $BACKUP_PASSWORD;
    exit 1;
  fi;

  echo "schema ${BACKUP_NAMES[$SERVER]} on $SERVER RESTORED";
  clickhouse-client -q "INSERT INTO system.backup_actions(command) VALUES('delete local ${BACKUP_NAMES[$SERVER]}')" --host="$SERVER" --port="$CLICKHOUSE_PORT" --user="$BACKUP_USER" $BACKUP_PASSWORD;

done;

for SERVER in $CLICKHOUSE_DATA_RESTORE_SERVICES; do
  clickhouse-client -mn --echo -q "INSERT INTO system.backup_actions(command) VALUES('restore_remote --data ${BACKUP_NAMES[$SERVER]}')" --host="$SERVER" --port="$CLICKHOUSE_PORT" --user="$BACKUP_USER" $BACKUP_PASSWORD;
done;

for SERVER in $CLICKHOUSE_DATA_RESTORE_SERVICES; do
  while [[ "in progress" == $(clickhouse-client -mn -q "SELECT status FROM system.backup_actions WHERE command='restore_remote --data ${BACKUP_NAMES[$SERVER]}' ORDER BY start DESC LIMIT 1 FORMAT TabSeparatedRaw" --host="$SERVER" --port="$CLICKHOUSE_PORT" --user="$BACKUP_USER" $BACKUP_PASSWORD) ]]; do
    echo "still in progress ${BACKUP_NAMES[$SERVER]} on $SERVER";
    sleep 1;
  done;

  RESTORE_STATUS=$(clickhouse-client -mn -q "SELECT status FROM system.backup_actions WHERE command='restore_remote --data ${BACKUP_NAMES[$SERVER]}' ORDER BY start DESC LIMIT 1 FORMAT TabSeparatedRaw" --host="$SERVER" --port="$CLICKHOUSE_PORT" --user="$BACKUP_USER" $BACKUP_PASSWORD);

  if [[ "success" != "${RESTORE_STATUS}" ]]; then
    echo "error restore_remote --data ${BACKUP_NAMES[$SERVER]} on $SERVER";
    clickhouse-client -mn --echo -q "SELECT start,finish,status,error FROM system.backup_actions WHERE command='restore_remote --data ${BACKUP_NAMES[$SERVER]}'" --host="$SERVER" --port="$CLICKHOUSE_PORT" --user="$BACKUP_USER" $BACKUP_PASSWORD;
    exit 1;
  fi;

  echo "data ${BACKUP_NAMES[$SERVER]} on $SERVER RESTORED";
  clickhouse-client -q "INSERT INTO system.backup_actions(command) VALUES('delete local ${BACKUP_NAMES[$SERVER]}')" --host="$SERVER" --port="$CLICKHOUSE_PORT" --user="$BACKUP_USER" $BACKUP_PASSWORD;
done;
