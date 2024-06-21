#!/bin/bash

set -e # Exit script immediately on first error.
#set -x # Print commands and their arguments as they are executed.

DIR=$(cd $(dirname $0); pwd)

source "${DIR}/../.env"
source "${DIR}/.env"

if [ -z ${YEAR_ISJ} ]; then
  echo "YEAR_ISJ is not set."
  exit 1
fi

psql -U ${DBROLE} -d ${DBNAME} -c "\copy (SELECT todofuken, lat, lon, code FROM pggeocoder.address_t ORDER BY code) TO '${DIR}/fixtures/address_t.${YEAR_ISJ}.csv' WITH CSV HEADER;"
psql -U ${DBROLE} -d ${DBNAME} -c "\copy (SELECT todofuken, shikuchoson, lat, lon, code FROM pggeocoder.address_s ORDER BY code) TO '${DIR}/fixtures/address_s.${YEAR_ISJ}.csv' WITH CSV HEADER;"
psql -U ${DBROLE} -d ${DBNAME} -c "\copy (SELECT todofuken, shikuchoson, ooaza, lat, lon, code FROM pggeocoder.address_o ORDER BY code) TO '${DIR}/fixtures/address_o.${YEAR_ISJ}.csv' WITH CSV HEADER;"
