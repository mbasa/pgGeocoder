#!/bin/bash
# ------------------------------------------------------------------------------
# Copyright(c) 2013-2021 Georepublic
#
# Usage:
# ------
#  bash scripts/download_estat.sh [Census Year]
#
# Examples:
# ---------
#  bash scripts/download_estat.sh 2015
#
# ------------------------------------------------------------------------------

set -e # Exit script immediately on first error.
#set -x # Print commands and their arguments as they are executed.

YEAR_TCODES=(
  "2015 A002005212015"
  #"2010 A002005212010"
  #"2005 A002005212005"
  #"2000 A002005512000"
)

function exit_with_usage()
{
  echo "Usage: bash scripts/download_estat.sh [Census Year (ex. 2019)]" 1>&2
  for i in "${YEAR_TCODES[@]}"; do
    year_tcode=(`echo "${i}"`)
    year="${year_tcode[0]}"
    echo -e "\t${year}" 1>&2
  done
  exit 1
}

if [ $# -ne 1 ]; then
  exit_with_usage
fi

found=0
for i in "${YEAR_TCODES[@]}"; do
  year_tcode=(`echo "${i}"`)
  if [ "$1" == "${year_tcode[0]}" ]; then
    year="${year_tcode[0]}"
    tcode="${year_tcode[1]}"
    found=1
    break
  fi
done

if ((!found)); then
  exit_with_usage
fi

echo "year:${year}, tcode:${tcode}"

SCRIPT_DIR=$(cd $(dirname $0); pwd)
OUT_ROOT_DIR=${SCRIPT_DIR}/../data/estat/census_boundary
OUT_ZIP_DIR=${OUT_ROOT_DIR}/${year}/zip
OUT_SHP_DIR=${OUT_ROOT_DIR}/${year}/shp
OUT_SQL_DIR=${OUT_ROOT_DIR}/${year}/sql

mkdir -p ${OUT_ROOT_DIR}
mkdir -p ${OUT_ZIP_DIR}
mkdir -p ${OUT_SHP_DIR}
mkdir -p ${OUT_SQL_DIR}

BASE_URL="https://www.e-stat.go.jp/gis/statmap-search/data"

# Download 47 prefecture shapes
echo -e "Downloading zip files and extracting shp files..."
for pref_code in $(seq -w 1 47); do
  # echo "Downloading prefecture ${i} in ${tcode} ..."
  url="${BASE_URL}?dlserveyId=${tcode}&code=${pref_code}&coordSys=1&format=shape&downloadType=5"
  zip="${OUT_ZIP_DIR}/${tcode}DDSWC${pref_code}.zip"
  if [ ! -e "${zip}" ] ; then
    curl -s "${url}" > "${zip}"
    sleep 2
  fi
  unzip -qq -jo ${zip} -d ${OUT_SHP_DIR}
  echo -ne "."
done

# Generate SQL files
echo -e "\nGenerating sql files..."
counter=0
#for shp in `find ${OUT_SHP_DIR} -name '*.shp'`; do
for shp in ${OUT_SHP_DIR}/*.shp; do
  sql=${OUT_SQL_DIR}/`basename ${shp} .shp`.sql
  #echo "${shp} => ${sql}"
  if [ ${counter} -eq 0 ]; then
    create_schema="YES"
    create_table="YES"
    drop_table="IF_EXISTS"
  else
    create_schema="NO"
    create_table="NO"
    drop_table="NO"
  fi
  # ogrinfo --format PGDump
  ogr2ogr -s_srs EPSG:4612 \
          -t_srs EPSG:4326 \
          -f PGDump \
          ${sql} \
          ${shp} \
          -lco GEOM_TYPE=geometry \
          -lco GEOMETRY_NAME=geom \
          -lco FID=fid \
          -lco SCHEMA=estat \
          -lco CREATE_SCHEMA=${create_schema} \
          -lco CREATE_TABLE=${create_table} \
          -lco DROP_TABLE=${drop_table} \
          -nln estat.census_boundary \
          -oo ENCODING=CP932
  echo -ne "."
  let counter=counter+1
done

echo -e "\nDone: ${counter} sql files generated!"
