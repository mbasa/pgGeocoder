
#!/bin/bash

source .env

function exit_with_usage()
{
  echo "Usage: bash scripts/import_estat.sh [Year (ex. 2019)]" 1>&2
  exit 1
}

if [ $# -ne 1 ]; then
  exit_with_usage
fi

year="$1"
echo "year:${year}"

SCRIPT_DIR=$(cd $(dirname $0); pwd)
IN_ROOT_DIR=${SCRIPT_DIR}/../data/estat/census_boundary

IN_SHP_DIR=${IN_ROOT_DIR}/${year}/shp
IN_SQL_DIR=${IN_ROOT_DIR}/${year}/sql

if [ ! -d ${IN_SHP_DIR} ] || [ ! -d ${IN_SQL_DIR} ]; then
  echo "SHP files are not downloaded yet" 1>&2
  exit 2
fi

# Drop estat tables and schema once
psql -U ${DBROLE} -d ${DBNAME} -f ./sql/estat/dropEStatTables.sql

# Import sql files
echo -e "\nImporting sql files..."
for sql in ${IN_SQL_DIR}/*.sql ; do
  psql -U ${DBROLE} -d ${DBNAME} -q -f ${sql}
done

# Convert EStat datas to pgGeocoder boundary_o table
echo -e "\nConverting EStat datas to boundary_o table..."
psql -U ${DBROLE} -d ${DBNAME} -f ./sql/estat/convertEStatDatas.sql

echo -e "\nDone!"
