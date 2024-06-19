--
-- Adding geometry column to temporary Gaiku/Oaza tables
--
alter table isj.gaiku add column geom geometry('POINT', 4326);
update isj.gaiku set geom = st_setsrid(st_makepoint(lon, lat), 4326);
-- create index gaiku_geom_idx on isj.gaiku using gist(geom);

alter table isj.oaza add column geom geometry('POINT', 4326);
update isj.oaza set geom = st_setsrid(st_makepoint(lon, lat), 4326);
-- create index oaza_geom_idx on isj.oaza using gist(geom);

--
-- Creating a temporary Koaza table from the Oaza/Gaiku tables
--
create table isj.koaza as 
   select a.pref_name,a.city_name,a.oaza_name||a.koaza_name as oaza_name,
     b.lat,b.lon,b.oaza_code,b.geom
     from isj.gaiku a,isj.oaza b 
     where a.pref_name = b.pref_name  and a.city_name = b.city_name 
     and a.oaza_name = b.oaza_name and length(koaza_name) > 1 
     group by a.pref_name,a.city_name,a.oaza_name,a.koaza_name,
     b.oaza_code,b.lat,b.lon,b.geom;

--
-- Creating a temporary City(Shikuchoson) table from the Oaza table
--
create table isj.city as
  select pref_code, pref_name, city_code, city_name,
    st_pointonsurface(st_union(st_makepoint(lon,lat))) as geom from isj.oaza
    group by pref_code, pref_name, city_code, city_name order by city_code;

--
-- Creating a temporary Pref(Todofuken) table from the Oaza table
--
create table isj.pref as
  select pref_code, pref_name,
    st_pointonsurface(st_union(st_makepoint(lon,lat))) as geom from isj.oaza
    group by pref_code, pref_name order by pref_code;


--
-- Inserting the Gaiku data into address table
--
insert into pggeocoder.address_c (todofuken, shikuchoson, ooaza, chiban, lat, lon, geog)
  select pref_name, city_name, oaza_name || coalesce(koaza_name, ''),
    gaiku_code, lat, lon, geom::geography from isj.gaiku;

--
-- Inserting the Oaza data into address_o Table
--
insert into pggeocoder.address_o (todofuken, shikuchoson, ooaza, lat, lon, code, geog)
  select pref_name, city_name, oaza_name, lat, lon, oaza_code,
    geom::geography from isj.oaza order by oaza_code;

--
-- Inserting the Koaza data into address_o Table
--
insert into pggeocoder.address_o (todofuken, shikuchoson, ooaza, lat, lon, code, geog)
   select pref_name,city_name,oaza_name,lat,lon,oaza_code,geom::geography 
     from isj.koaza;

--
-- Inserting the created City data into address_s table
--
insert into pggeocoder.address_s (todofuken, shikuchoson, lat, lon, code, geog)
  select pref_name, city_name, st_y(geom), st_x(geom), city_code,
    geom::geography from isj.city order by city_code;

--
-- Inserting the created Pref(Todofuken) data into address_t table
--
insert into pggeocoder.address_t (todofuken, lat, lon, code, geog)
  select pref_name, st_y(geom), st_x(geom), pref_code,
  geom::geography from isj.pref order by pref_code;

