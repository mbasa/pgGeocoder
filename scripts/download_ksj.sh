#!/bin/bash
# ------------------------------------------------------------------------------
# Copyright(c) 2021 Georepublic
#
# Usage:
# ------
#  bash scripts/download_ksj.sh [Year of admin boundary]
#
# Examples:
# ---------
#  bash scripts/download_ksj.sh 2021
#
# ------------------------------------------------------------------------------

#set -e # Exit script immediately on first error.
#set -x # Print commands and their arguments as they are executed.

YEAR_FNAMES=(
  "2021 N03-20210101"
  "2020 N03-20200101"
  "2019 N03-190101"
  "2018 N03-180101"
  "2017 N03-170101"
  "2016 N03-160101"
  "2015 N03-150101"
)

function exit_with_usage()
{
  echo "Usage: bash scripts/download_ksj.sh [Year (ex. 2021)]" 1>&2
  for i in "${YEAR_FNAMES[@]}"; do
    year_fname=(`echo "${i}"`)
    year="${year_fname[0]}"
    echo -e "\t${year}" 1>&2
  done
  exit 1
}

if [ $# -ne 1 ]; then
  exit_with_usage
fi

found=0
for i in "${YEAR_FNAMES[@]}"; do
  year_fname=(`echo "${i}"`)
  if [ "$1" == "${year_fname[0]}" ]; then
    year="${year_fname[0]}"
    fname="${year_fname[1]}"
    found=1
    break
  fi
done

if ((!found)); then
  exit_with_usage
fi

echo "year:${year}, fname:${fname}"

SCRIPT_DIR=$(cd $(dirname $0); pwd)
OUT_ROOT_DIR=${SCRIPT_DIR}/../data/ksj
OUT_ADMIN_BOUNDARY_DIR=${OUT_ROOT_DIR}/admin_boundary/${year}
OUT_ADMIN_BOUNDARY_ZIP_DIR=${OUT_ADMIN_BOUNDARY_DIR}/zip
OUT_ADMIN_BOUNDARY_SHP_DIR=${OUT_ADMIN_BOUNDARY_DIR}/shp
OUT_ADMIN_BOUNDARY_SQL_DIR=${OUT_ADMIN_BOUNDARY_DIR}/sql
OUT_GOVERNMENT_DIR=${OUT_ROOT_DIR}/government
OUT_GOVERNMENT_ZIP_DIR=${OUT_GOVERNMENT_DIR}/zip
OUT_GOVERNMENT_SHP_DIR=${OUT_GOVERNMENT_DIR}/shp
OUT_GOVERNMENT_SQL_DIR=${OUT_GOVERNMENT_DIR}/sql
OUT_CITY_OFFICE_DIR=${OUT_ROOT_DIR}/city_office
OUT_CITY_OFFICE_ZIP_DIR=${OUT_CITY_OFFICE_DIR}/zip
OUT_CITY_OFFICE_SHP_DIR=${OUT_CITY_OFFICE_DIR}/shp
OUT_CITY_OFFICE_SQL_DIR=${OUT_CITY_OFFICE_DIR}/sql

mkdir -p ${OUT_ADMIN_BOUNDARY_DIR}
mkdir -p ${OUT_ADMIN_BOUNDARY_ZIP_DIR}
mkdir -p ${OUT_ADMIN_BOUNDARY_SHP_DIR}
mkdir -p ${OUT_ADMIN_BOUNDARY_SQL_DIR}
mkdir -p ${OUT_GOVERNMENT_DIR}
mkdir -p ${OUT_GOVERNMENT_ZIP_DIR}
mkdir -p ${OUT_GOVERNMENT_SHP_DIR}
mkdir -p ${OUT_GOVERNMENT_SQL_DIR}
mkdir -p ${OUT_CITY_OFFICE_DIR}
mkdir -p ${OUT_CITY_OFFICE_ZIP_DIR}
mkdir -p ${OUT_CITY_OFFICE_SHP_DIR}
mkdir -p ${OUT_CITY_OFFICE_SQL_DIR}

# Download admin boundary zip
echo "Downloading admin boundary zip file at ${year} and extracting shp file..."
url="https://nlftp.mlit.go.jp/ksj/gml/data/N03/N03-${year}/${fname}_GML.zip"
zip="${OUT_ADMIN_BOUNDARY_ZIP_DIR}/${fname}_GML.zip"
if [ ! -e "${zip}" ] ; then
  curl -s "${url}" > "${zip}"
fi
unzip -qq -jo ${zip} -d ${OUT_ADMIN_BOUNDARY_SHP_DIR}

# Generate admin boundary SQL file
for shp in ${OUT_ADMIN_BOUNDARY_SHP_DIR}/*.shp; do
  sql=${OUT_ADMIN_BOUNDARY_SQL_DIR}/`basename ${shp} .shp`.sql
  #echo "${shp} => ${sql}"
  # ogrinfo --format PGDump
  ogr2ogr -s_srs EPSG:4612 \
          -t_srs EPSG:4326 \
          -f PGDump \
          ${sql} \
          ${shp} \
          -lco GEOM_TYPE=geometry \
          -lco GEOMETRY_NAME=geom \
          -lco FID=fid \
          -lco SCHEMA=ksj \
          -lco CREATE_SCHEMA=YES \
          -lco CREATE_TABLE=YES \
          -lco DROP_TABLE=IF_EXISTS \
          -nln ksj.admin_boundary \
          -oo ENCODING=CP932
done

# Download government zip
echo "Downloading government zip file and extracting shp file..."
url="https://nlftp.mlit.go.jp/ksj/gml/data/P28/P28-13/P28-13.zip"
zip="${OUT_GOVERNMENT_ZIP_DIR}/P28-13.zip"
if [ ! -e "${zip}" ] ; then
  curl -s "${url}" > "${zip}"
fi
unzip -qq -jo ${zip} -d ${OUT_GOVERNMENT_SHP_DIR}

# Generate admin boundary SQL file
for shp in ${OUT_GOVERNMENT_SHP_DIR}/*.shp; do
  sql=${OUT_GOVERNMENT_SQL_DIR}/`basename ${shp} .shp`.sql
  #echo "${shp} => ${sql}"
  # ogrinfo --format PGDump
  ogr2ogr -s_srs EPSG:4612 \
          -t_srs EPSG:4326 \
          -f PGDump \
          ${sql} \
          ${shp} \
          -lco GEOM_TYPE=geometry \
          -lco GEOMETRY_NAME=geom \
          -lco FID=fid \
          -lco SCHEMA=ksj \
          -lco CREATE_SCHEMA=YES \
          -lco CREATE_TABLE=YES \
          -lco DROP_TABLE=IF_EXISTS \
          -nln ksj.government \
          -oo ENCODING=CP932
done

# Download 47 prefecture shapes
echo -e "Downloading city office zip files and extracting shp files..."
for pref_code in $(seq -w 1 47); do
  # echo "Downloading prefecture ${i} in ${tcode} ..."
  url="https://nlftp.mlit.go.jp/ksj/gml/data/P34/P34-14/P34-14_${pref_code}_GML.zip"
  zip="${OUT_CITY_OFFICE_ZIP_DIR}/P34-14_${pref_code}_GML.zip"
  if [ ! -e "${zip}" ] ; then
    curl -s "${url}" > "${zip}"
  fi
  unzip -qq -jo ${zip} -d ${OUT_CITY_OFFICE_SHP_DIR}
done

# Generate SQL files
echo -e "Generating sql files..."
counter=0
#for shp in `find ${OUT_SHP_DIR} -name '*.shp'`; do
for shp in ${OUT_CITY_OFFICE_SHP_DIR}/*.shp; do
  sql=${OUT_CITY_OFFICE_SQL_DIR}/`basename ${shp} .shp`.sql
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
          -lco SCHEMA=ksj \
          -lco CREATE_SCHEMA=${create_schema} \
          -lco CREATE_TABLE=${create_table} \
          -lco DROP_TABLE=${drop_table} \
          -nln ksj.city_office \
          -oo ENCODING=CP932
  echo -ne "."
  let counter=counter+1
done

echo -e "\nDone: sql files generated!"
