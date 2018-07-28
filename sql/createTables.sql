create table address_t (todofuken varchar,lat float,lon float,
    ttable varchar);

create table address_s (todofuken varchar,shikuchoson varchar,
    lat float,lon float );

create table address_o (todofuken varchar,shikuchoson varchar,
    ooaza varchar, tr_ooaza varchar,
    lat float, lon float );

create table address   (todofuken varchar,shikuchoson varchar,
    ooaza varchar, chiban varchar,
    lat float, lon float );

create table places (id serial,owner varchar,category varchar, 
    name varchar,lat float, lon float);