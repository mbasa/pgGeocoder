
#!/bin/bash

SCRIPT_DIR=$(cd $(dirname $0); pwd)

OUT_ROOT_DIR=${SCRIPT_DIR}/../data/abr
OUT_RSDT_DIR=${OUT_ROOT_DIR}/rsdt
OUT_RSDT_POS_DIR=${OUT_ROOT_DIR}/rsdt_pos

OUT_RSDT_CSV_DIR=${OUT_RSDT_DIR}/csv
OUT_RSDT_ZIP_DIR=${OUT_RSDT_DIR}/zip
OUT_RSDT_POS_CSV_DIR=${OUT_RSDT_POS_DIR}/csv
OUT_RSDT_POS_ZIP_DIR=${OUT_RSDT_POS_DIR}/zip

mkdir -p ${OUT_ROOT_DIR}
mkdir -p ${OUT_RSDT_DIR}
mkdir -p ${OUT_RSDT_CSV_DIR}
mkdir -p ${OUT_RSDT_ZIP_DIR}
mkdir -p ${OUT_RSDT_POS_CSV_DIR}
mkdir -p ${OUT_RSDT_POS_ZIP_DIR}

# Download zip files and extract *.csv files
echo -e "Downloading abr pinpoint zip files and extracting csv files..."
curl -s https://catalog.registries.digital.go.jp/rsc/address/address_all.csv.zip > ${OUT_ROOT_DIR}/address_all.csv.zip

unzip ${OUT_ROOT_DIR}/address_all.csv.zip -d ${OUT_ROOT_DIR}/

unzip ${OUT_ROOT_DIR}/mt_rsdtdsp_rsdt_all.csv.zip -d ${OUT_RSDT_ZIP_DIR}/
unzip "${OUT_RSDT_ZIP_DIR}/*" -d ${OUT_RSDT_CSV_DIR}/

unzip ${OUT_ROOT_DIR}/mt_rsdtdsp_rsdt_pos_all.csv.zip -d ${OUT_RSDT_POS_ZIP_DIR}/
unzip "${OUT_RSDT_POS_ZIP_DIR}/*" -d ${OUT_RSDT_POS_CSV_DIR}/

echo -e "\nDone!"
