
#!/bin/bash

source .env

function exit_with_usage()
{
  echo "Usage: bash scripts/maintenance.sh [keep_flag (ex. 1, default:0)]" 1>&2
  exit 1
}

if [ -z "$1" ]; then
  keep=0
else
  keep="$1"
fi

if ((!keep)); then
  psql -U ${DBROLE} -d ${DBNAME} -f ./sql/isj/dropISJTables.sql
  psql -U ${DBROLE} -d ${DBNAME} -f ./sql/estat/dropEStatTables.sql
  psql -U ${DBROLE} -d ${DBNAME} -f ./sql/ksj/dropKSJTables.sql
fi

# Adding indexes on the pgGeocoder Tables
psql -U ${DBROLE} -d ${DBNAME} -f ./sql/maintTables.sql

echo -e "\nDone!"
