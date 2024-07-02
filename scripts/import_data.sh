#!/bin/bash

source .env

T_YEAR_ISJ=2020
T_YEAR_KSJ=2021
T_YEAR_ESTAT=2015

if [ ! -z "${YEAR_ISJ}" ] 
then
    T_YEAR_ISJ=${YEAR_ISJ}
fi

echo "YEAR ISJ:${T_YEAR_ISJ}"

if [ ! -z "${YEAR_KSJ}" ] 
then
    T_YEAR_KSJ=${YEAR_KSJ}
fi

echo "YEAR KSJ:${T_YEAR_KSJ}"

if [ ! -z "${YEAR_ESTAT}" ] 
then
    T_YEAR_ESTAT=${YEAR_ESTAT}
fi

echo "YEAR ESTAT:${T_YEAR_ESTAT}"

##--
##-- Importing Multiple Years for ISJ
##--
array=(`echo $T_YEAR_ISJ | sed 's/,/\n/g'`)
array_len=${#array[@]}

for((i=0;i<$array_len-1;i++)) 
 do
  /bin/bash scripts/download_isj.sh ${array[$i]}
  /bin/bash scripts/import_isj.sh ${array[$i]} nopatch
 done

/bin/bash scripts/download_isj.sh ${array[($array_len-1)]}
/bin/bash scripts/import_isj.sh ${array[($array_len-1)]}

##--

/bin/bash scripts/download_estat.sh ${T_YEAR_ESTAT}
/bin/bash scripts/import_estat.sh ${T_YEAR_ESTAT}
/bin/bash scripts/download_ksj.sh ${T_YEAR_KSJ}
/bin/bash scripts/import_ksj.sh ${T_YEAR_KSJ}
/bin/bash scripts/download_abr.sh
/bin/bash scripts/import_abr.sh
