
#!/bin/bash

source .env

function exit_with_usage()
{
  echo "Usage: bash scripts/import_isj.sh [Year (ex. 2019)]" 1>&2
  exit 1
}

if [ $# -ne 1 ]; then
  exit_with_usage
fi

year="$1"
echo "year:${year}"

SCRIPT_DIR=$(cd $(dirname $0); pwd)
IN_ROOT_DIR=${SCRIPT_DIR}/../data/isj

IN_OAZA_DIR=${IN_ROOT_DIR}/oaza
IN_OAZA_CSV_DIR=${IN_OAZA_DIR}/${year}/csv

IN_GAIKU_DIR=${IN_ROOT_DIR}/gaiku
IN_GAIKU_CSV_DIR=${IN_GAIKU_DIR}/${year}/csv

IN_PATCHES_CSV_DIR=${IN_ROOT_DIR}/patches

if [ ! -d ${IN_OAZA_CSV_DIR} ] || [ ! -d ${IN_GAIKU_CSV_DIR} ]; then
  echo "CSV files are not downloaded yet" 1>&2
  exit 2
fi

# Drop isj tables and schema once
psql -U ${DBROLE} -d ${DBNAME} -f ./sql/isj/dropISJTables.sql

# Create isj schema and tables
psql -U ${DBROLE} -d ${DBNAME} -f ./sql/isj/createISJTables.sql


OAZA_TABLE="isj.oaza"
GAIKU_TABLE="isj.gaiku"
if ((year < 2017)); then
  GAIKU_TABLE="isj.gaiku (pref_name, city_name, oaza_name, gaiku_code, cs_number, x, y, lat, lon, residence_display_flag, representative_flag, before_update_flag, after_update_flag)"
fi

# Import oaza csv files
echo -e "\nImporting oaza csv files..."
for csv in ${IN_OAZA_CSV_DIR}/*.csv ; do
  psql -U ${DBROLE} -d ${DBNAME} -c "\copy ${OAZA_TABLE} from '${csv}' with delimiter ',' csv header;"
done

# Import gaiku csv files
echo -e "\nImporting gaiku csv files..."
for csv in ${IN_GAIKU_CSV_DIR}/*.csv ; do
  psql -U ${DBROLE} -d ${DBNAME} -c "\copy ${GAIKU_TABLE} from '${csv}' with delimiter ',' csv header;"
done

# Convert ISJ datas to pgGeocoder address tables
echo -e "\nConverting ISJ datas to address tables..."
psql -U ${DBROLE} -d ${DBNAME} -f ./sql/isj/convertISJDatas.sql

# Patch address tables
echo -e "\nPatching address tables..."
for csv in ${IN_PATCHES_CSV_DIR}/address_*.csv ; do
  table_name=`basename ${csv} .csv`
  psql -U ${DBROLE} -d ${DBNAME} -c "\copy ${table_name} from '${csv}' with delimiter ',' csv header;"
done

echo -e "\nDone!"
