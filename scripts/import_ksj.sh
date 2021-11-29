
#!/bin/bash

source .env

function exit_with_usage()
{
  echo "Usage: bash scripts/import_ksj.sh [Year (ex. 2021)]" 1>&2
  exit 1
}

if [ $# -ne 1 ]; then
  exit_with_usage
fi

year="$1"
echo "year:${year}"

SCRIPT_DIR=$(cd $(dirname $0); pwd)
IN_ROOT_DIR=${SCRIPT_DIR}/../data/ksj

IN_ADMIN_BOUNDARY_DIR=${IN_ROOT_DIR}/admin_boundary/${year}
IN_ADMIN_BOUNDARY_SHP_DIR=${IN_ADMIN_BOUNDARY_DIR}/shp
IN_ADMIN_BOUNDARY_SQL_DIR=${IN_ADMIN_BOUNDARY_DIR}/sql

IN_GOVERNMENT_DIR=${IN_ROOT_DIR}/government
IN_GOVERNMENT_SHP_DIR=${IN_GOVERNMENT_DIR}/shp
IN_GOVERNMENT_SQL_DIR=${IN_GOVERNMENT_DIR}/sql

IN_CITY_OFFICE_DIR=${IN_ROOT_DIR}/city_office
IN_CITY_OFFICE_SHP_DIR=${IN_CITY_OFFICE_DIR}/shp
IN_CITY_OFFICE_SQL_DIR=${IN_CITY_OFFICE_DIR}/sql

# Drop ksj tables and schema once
psql -U ${DBROLE} -d ${DBNAME} -f ./sql/ksj/dropKSJTables.sql

# Import admin boundary sql file
if [ ! -d ${IN_ADMIN_BOUNDARY_SHP_DIR} ] || [ ! -d ${IN_ADMIN_BOUNDARY_SQL_DIR} ]; then
  echo "Admin boundary shp file is not downloaded yet" 1>&2
  exit 2
fi

echo -e "\nImporting admin boundary sql file..."
for sql in ${IN_ADMIN_BOUNDARY_SQL_DIR}/*.sql ; do
  psql -U ${DBROLE} -d ${DBNAME} -q -f ${sql}
done

# Import government sql file
if [ ! -d ${IN_GOVERNMENT_SHP_DIR} ] || [ ! -d ${IN_GOVERNMENT_SQL_DIR} ]; then
  echo "Government shp file is not downloaded yet" 1>&2
  exit 2
fi

echo -e "\nImporting government sql file..."
for sql in ${IN_GOVERNMENT_SQL_DIR}/*.sql ; do
  psql -U ${DBROLE} -d ${DBNAME} -q -f ${sql}
done

# Import city office sql files
if [ ! -d ${IN_CITY_OFFICE_SHP_DIR} ] || [ ! -d ${IN_CITY_OFFICE_SQL_DIR} ]; then
  echo "City office shp files are not downloaded yet" 1>&2
  exit 2
fi

echo -e "\nImporting city office sql files..."
for sql in ${IN_CITY_OFFICE_SQL_DIR}/*.sql ; do
  psql -U ${DBROLE} -d ${DBNAME} -q -f ${sql}
done

# Convert KSJ datas to pgGeocoder boundary_s|t table
echo -e "\nConverting KSJ datas to boundary/address tables..."
psql -U ${DBROLE} -d ${DBNAME} -f ./sql/ksj/convertKSJDatas.sql

echo -e "\nDone!"
