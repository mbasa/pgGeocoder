
#!/bin/bash

# Inspired by https://github.com/IMI-Tool-Project/imi-enrichment-address/blob/master/tools/download.sh

# 2023(令和5年) ~ 2015(平成27年)
# Don't support <= H20, because oaza level data is not completed
# "[year] [era_year] [oaza_ver] [gaiku_ver]"
YEAR_VERSIONS=(
  "2023 R5  17.0b 22.0a"
  "2022 R4  16.0b 21.0a"
  "2021 R3  15.0b 20.0a"
  "2020 R2  14.0b 19.0a"
  "2019 R1  13.0b 18.0a"
  "2018 H30 12.0b 17.0a"
  "2017 H29 11.0b 16.0a"
  "2016 H28 10.0b 15.0a"
  "2015 H27 09.0b 14.0a"
  #"2014 H26 08.0b 13.0a"
  #"2013 H25 07.0b 12.0a"
  #"2012 H24 06.0b 11.0a"
  #"2011 H23 05.0b 10.0a"
  #"2010 H22 04.0b 09.0a"
  #"2009 H21 03.0b 08.0a"
)

function exit_with_usage()
{
  echo "Usage: bash scripts/download_isj.sh [Year (ex. 2020)]" 1>&2
  for i in "${YEAR_VERSIONS[@]}"; do
    year_ver=(`echo "${i}"`)
    year="${year_ver[0]}"
    era_year="${year_ver[1]}"
    echo -e "\t${era_year}: ${year}" 1>&2
  done
  exit 1
}

if [ $# -ne 1 ]; then
  exit_with_usage
fi

found=0
for i in "${YEAR_VERSIONS[@]}"; do
  year_ver=(`echo "${i}"`)
  if [ "$1" == "${year_ver[0]}" ]; then
    year="${year_ver[0]}"
    era_year="${year_ver[1]}"
    oaza_ver="${year_ver[2]}"
    gaiku_ver="${year_ver[3]}"
    found=1
    break
  fi
done

if ((!found)); then
  exit_with_usage
fi

echo "year:${year}, era_year:${era_year}, oaza_ver:${oaza_ver}, gaiku_ver:${gaiku_ver}"

SCRIPT_DIR=$(cd $(dirname $0); pwd)
OUT_ROOT_DIR=${SCRIPT_DIR}/../data/isj

OUT_OAZA_DIR=${OUT_ROOT_DIR}/oaza
OUT_OAZA_ZIP_DIR=${OUT_OAZA_DIR}/${year}/zip
OUT_OAZA_CSV_DIR=${OUT_OAZA_DIR}/${year}/csv

OUT_GAIKU_DIR=${OUT_ROOT_DIR}/gaiku
OUT_GAIKU_ZIP_DIR=${OUT_GAIKU_DIR}/${year}/zip
OUT_GAIKU_CSV_DIR=${OUT_GAIKU_DIR}/${year}/csv

mkdir -p ${OUT_ROOT_DIR}

mkdir -p ${OUT_OAZA_DIR}
mkdir -p ${OUT_OAZA_ZIP_DIR}
mkdir -p ${OUT_OAZA_CSV_DIR}

mkdir -p ${OUT_GAIKU_DIR}
mkdir -p ${OUT_GAIKU_ZIP_DIR}
mkdir -p ${OUT_GAIKU_CSV_DIR}

# Download zip files and extract *.csv files
echo -e "Downloading oaza/gaiku zip files and extracting csv files..."
for pref_code in `seq -w 1 47` ; do
  oaza_url="https://nlftp.mlit.go.jp/isj/dls/data/${oaza_ver}/${pref_code}000-${oaza_ver}.zip"
  oaza_zip="${OUT_OAZA_ZIP_DIR}/${pref_code}000-${oaza_ver}.zip"
  if [ ! -e "${oaza_zip}" ] ; then
    curl -s ${oaza_url} > ${oaza_zip}
  fi
  unzip -p ${oaza_zip} '*.[cC][sS][vV]' | iconv -c -f cp932 -t utf8 > ${OUT_OAZA_CSV_DIR}/${pref_code}_${year}.csv

  gaiku_url="https://nlftp.mlit.go.jp/isj/dls/data/${gaiku_ver}/${pref_code}000-${gaiku_ver}.zip"
  gaiku_zip="${OUT_GAIKU_ZIP_DIR}/${pref_code}000-${gaiku_ver}.zip"
  if [ ! -e "${gaiku_zip}" ] ; then
    curl -s ${gaiku_url} > ${gaiku_zip}
  fi
  unzip -p ${gaiku_zip} '*.[cC][sS][vV]' | iconv -c -f cp932 -t utf8 > ${OUT_GAIKU_CSV_DIR}/${pref_code}_${year}.csv

  echo -ne "."
done

echo -e "\nDone!"
