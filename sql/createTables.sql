create extension postgis;


--
-- Creating pggeocoder Schema
--
drop schema if exists pggeocoder cascade;
create schema pggeocoder;

--
-- for Geocoding
--
create table pggeocoder.address_t (
  todofuken varchar(60),
  lat float,
  lon float,
  ttable varchar(40),
  code varchar(2),
  geog geography('POINT'),
  year text
);

create unique index address_t_u on pggeocoder.address_t (todofuken);

create table pggeocoder.address_s (
  todofuken varchar(60),
  shikuchoson varchar(60),
  tr_shikuchoson varchar(60),
  lat float,
  lon float,
  code varchar(5),
  geog geography('POINT'),
  year text
);

create unique index address_s_u on pggeocoder.address_s (todofuken,shikuchoson);

create table pggeocoder.address_o (
  todofuken varchar(60),
  shikuchoson varchar(60),
  tr_shikuchoson varchar(60),
  ooaza varchar(60),
  tr_ooaza varchar(60),
  lat float,
  lon float,
  code varchar(12),
  geog geography('POINT'),
  year text
);

create unique index address_o_u on pggeocoder.address_o (todofuken,shikuchoson,ooaza);

create table pggeocoder.address_c (
  todofuken varchar(60),
  shikuchoson varchar(60),
  tr_shikuchoson varchar(60),
  ooaza varchar(60),
  tr_ooaza varchar(60),
  chiban varchar(60),
  lat float,
  lon float,
  geog geography('POINT'),
  year text
);

create unique index address_c_u on pggeocoder.address_c (todofuken,shikuchoson,ooaza,chiban);

create table pggeocoder.address_g (
  todofuken varchar(60),
  shikuchoson varchar(60),
  tr_shikuchoson varchar(60),
  ooaza varchar(60),
  tr_ooaza varchar(60),
  chiban varchar(60),
  go varchar(60),
  lat float,
  lon float,
  geog geography('POINT')
);

--
-- for Reverse Geocoding
--
create table pggeocoder.boundary_t (
  todofuken varchar(60),
  code varchar(2),
  geom geometry('MULTIPOLYGON', 4326)
);

create table pggeocoder.boundary_s (
  todofuken varchar(60),
  shikuchoson varchar(60),
  code varchar(5),
  geom geometry('MULTIPOLYGON', 4326)
);

create table pggeocoder.boundary_o (
  todofuken varchar(60),
  shikuchoson varchar(60),
  ooaza varchar(60),
  code varchar(12),
  geom geometry('MULTIPOLYGON', 4326)
);
