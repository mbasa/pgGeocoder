
#!/bin/bash

set -e # Exit script immediately on first error.
#set -x # Print commands and their arguments as they are executed.

source .env

SCRIPT_DIR=$(cd $(dirname $0); pwd)
IN_PLACES_CSV_DIR=${SCRIPT_DIR}/../data/places

# Truncate places table once
psql -U ${DBROLE} -d ${DBNAME} -f ./sql/places/truncatePlacesTable.sql


# Import places csv files
echo -e "\nImporting places csv files..."
for csv in ${IN_PLACES_CSV_DIR}/*.csv ; do
  psql -U ${DBROLE} -d ${DBNAME} -c "\copy places (owner, category, name, lat, lon, details) from '${csv}' with delimiter ',' csv header;"
done

# Update places geog column
echo -e "\nUpdating places geog column..."
psql -U ${DBROLE} -d ${DBNAME} -f ./sql/places/updatePlacesGeogColumn.sql

echo -e "\nDone!"
