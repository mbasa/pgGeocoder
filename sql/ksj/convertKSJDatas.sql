--
-- Inserting the City(Shikuchoson) data into boundary_s Table
--
insert into boundary_s (todofuken, shikuchoson, code, geom)
  select n03_001 as pref_name, coalesce(n03_003, '') || coalesce(n03_004, '') as city_name,
    n03_007 as city_code, st_multi(st_union(geom)) as geom from ksj.admin_boundary
    where n03_007 is not null group by n03_001, n03_003, n03_004, n03_007
  order by n03_007;

--
-- Inserting the Pref(Todofuken) data into boundary_t Table
--
insert into boundary_t (todofuken, code, geom)
  select n03_001 as pref_name, max(left(n03_007, 2)) as pref_code,
    st_multi(st_union(geom)) from ksj.admin_boundary
    group by n03_001 order by pref_code;

--
-- Fillng the Pref(Todofuken) boundary polygon holes
--
update boundary_t as a set geom = b.geom
  from (
    select code, st_collect(st_makepolygon(geom)) as geom
      from (
        select code, st_exteriorring((st_dump(geom)).geom) as geom
          from boundary_t
      ) as s
      group by code
  ) as b where a.code = b.code;

--
-- Fixing city changes after 2015
--
update ksj.city_office set p34_001 = '04216', p34_003 = '富谷市役所' where p34_001 = '04423' and p34_002 = '1' and p34_003 = '富谷町役場';
update ksj.city_office set p34_001 = '40231', p34_003 = '那珂川市役所' where p34_001 = '40305' and p34_002 = '1' and p34_003 = '那珂川町役場';

--
-- Adjusting the City(Shikuchoson) location in address_s Table
--
update address_s as a set lat = st_y(b.geom), lon = st_x(b.geom), geog = b.geom::geography
  from (
    select p34_001 as code, p34_003 as name, geom from ksj.city_office where p34_002 = '1'
  ) as b where a.code = b.code and
    not ((b.code = '46303' and b.name = '三島村役場')
      OR (b.code = '46304' and b.name = '十島村役場')
      OR (b.code = '47381' and b.name = '竹富町役場'));

--
-- Filling the City(Shikuchoson) location in address_s Table
--
insert into address_s (todofuken, shikuchoson, lat, lon, code, geog)
  select b.todofuken, b.shikuchoson, st_y(point) as lat, st_x(point) AS lon, b.code, b.point::geography as geog
    from (select *, st_pointonsurface(geom) as point from boundary_s) as b
      left join (select *, geog::geometry as geom from address_s) as a on st_contains(b.geom, a.geom)
    where a.code is null;

--
-- Adjusting the Pref(Todofuken) location in address_t Table
--
update address_t as a set lat = st_y(b.geom), lon = st_x(b.geom), geog = b.geom::geography
  from (
    select left(p28_001, 2) as code, p28_005 as name, geom from ksj.government
      where p28_003 = '12001' and p28_004 = '12001'
  ) as b where a.code = b.code;
