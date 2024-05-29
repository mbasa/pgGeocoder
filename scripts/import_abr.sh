#!/bin/bash

source .env

SCRIPT_DIR=$(cd $(dirname $0); pwd)

IN_ROOT_DIR=${SCRIPT_DIR}/../data/abr

IN_PREF_DIR=${IN_ROOT_DIR}/pref

IN_RSDT_DIR=${IN_ROOT_DIR}/rsdt
IN_RSDT_CSV_DIR=${IN_RSDT_DIR}/csv
IN_RSDT_ZIP_DIR=${IN_RSDT_DIR}/zip
 
IN_RSDT_POS_DIR=${IN_ROOT_DIR}/rsdt_pos
IN_RSDT_POS_CSV_DIR=${IN_RSDT_POS_DIR}/csv
IN_RSDT_POS_ZIP_DIR=${IN_RSDT_POS_DIR}/zip

if [ ! -d ${IN_RSDT_CSV_DIR} ] || [ ! -d ${IN_RSDT_ZIP_DIR} ]; then
  echo "CSV files are not downloaded yet" 1>&2
  exit 2
fi

# Drop abr tables and schema once
psql -U ${DBROLE} -d ${DBNAME} -f ./sql/abr/dropABRTables.sql

# Create abr schema and tables
psql -U ${DBROLE} -d ${DBNAME} -f ./sql/abr/createABRTables.sql

RSDT_TABLE="abr.rsdtdsp_dsp (lg_code,machiaza_id,blk_id,rsdt_id,rsdt2_id,city,ward,oaza_cho,chome,koaza,machiaza_dist,blk_num,rsdt_num,rsdt_num2,basic_rsdt_div,rsdt_addr_flg,rsdt_addr_mtd_code,status_flg,efct_date,ablt_date,src_code,remarks)"
RSDT_POS_TABLE="abr.rsdtdsp_pos(lg_code,machiaza_id,blk_id,rsdt_id,rsdt2_id,rsdt_addr_flg,rsdt_addr_mtd_code,rep_lon,rep_lat,rep_srid,rep_scale,rep_src_code,rsdt_addr_code_rdbl,rsdt_addr_data_mnt_date,basic_rsdt_div)"
PREF_TABLE="abr.pref (lg_code,pref,pref_kana,pref_roma,efct_date,ablt_date,remarks)"


echo -e "\nImporting rsdt csv files..."

for csv in ${IN_RSDT_CSV_DIR}/*.csv ; do
  psql -U ${DBROLE} -d ${DBNAME} -c "\copy ${RSDT_TABLE} from '${csv}' with delimiter ',' csv header;"
done

for csv in ${IN_RSDT_POS_CSV_DIR}/*.csv ; do
  psql -U ${DBROLE} -d ${DBNAME} -c "\copy ${RSDT_POS_TABLE} from '${csv}' with delimiter ',' csv header;"
done

for csv in ${IN_PREF_DIR}/*.csv ; do
  psql -U ${DBROLE} -d ${DBNAME} -c "\copy ${PREF_TABLE} from '${csv}' with delimiter ',' csv header;"
done

# Comverting ABR into pgGeocoder format table
echo -e "\nConverting tables..."
psql -U ${DBROLE} -d ${DBNAME} -f ./sql/abr/convertABRTables.sql

echo -e "\nDone!"