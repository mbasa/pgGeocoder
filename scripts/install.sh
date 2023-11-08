
#!/bin/bash

source .env

## Adding PostGIS extension support
#psql -U ${DBROLE} -d ${DBNAME} -c "create extension postgis;"

# Creating the necessary pgGeocoder Tables
psql -U ${DBROLE} -d ${DBNAME} -f ./sql/createTables.sql

# Load geocoder function
psql -U ${DBROLE} -d ${DBNAME} -f ./sql/pgGeocoder.sql

# Load reverse_geocoder function
psql -U ${DBROLE} -d ${DBNAME} -f ./sql/pgReverseGeocoder.sql

echo -e "\nDone!"
