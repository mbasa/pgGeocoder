--
-- Update geography column
--
update places set geog = geography( st_setsrid(st_makepoint(lon,lat),4326) );
