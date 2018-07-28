--
-- assumes that address_t,address_s,address_o,address
-- have been created already.
--

--
-- updating the ttable field to point to address table
--
update address_t set ttable = 'address';

--
-- creating index for address_s
--
create index address_s1 on address_s(todofuken);

--
-- creating index for address_o
--
create index address_o1 on address_o(todofuken);
create index address_o2 on address_o(shikuchoson);
create index address_o3 on address_o(ooaza);

--
-- creating index for address
--
create index address1 on address(todofuken);
create index address2 on address(shikuchoson);
create index address3 on address(ooaza);
create index address4 on address(chiban);

--
-- creating index on places
--
create index places1 on places(owner);
create index places2 on places(category);
create index places3 on places(name);

--
-- for Reverse Geocoding
--
create extension postgis;
--
alter table address add column geog geography('POINT');
update address set geog = geography( st_setsrid(st_makepoint(lon,lat),4326) );
create index address_g_ndx on address using gist( geog );

--
-- for Reverse Geocoding in Places 
--
alter table places add column geog geography('POINT');
update places set geog = geography( st_setsrid(st_makepoint(lon,lat),4326) );
create index places_g_ndx on places using gist( geog );

--
-- adding a JSONB column to Places
--
alter table places add column extra_data jsonb;

--
-- Vacuuming everything
--
VACUUM FULL;
