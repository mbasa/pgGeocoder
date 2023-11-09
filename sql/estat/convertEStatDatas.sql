--
-- Inserting the Oaza data into boundary_o Table
--
insert into boundary_o (todofuken, shikuchoson, ooaza, code, geom)
  select pref_name, city_name, s_name, key_code, geom from
    (
      select pref_name, city_name, s_name, min(key_code) as key_code, st_multi(st_union(geom)) as geom from estat.census_boundary
        where hcode = 8101 and s_name is not null group by pref_name, city_name, s_name
      union
      select pref_name, city_name, null as s_name, key_code, st_multi(st_union(geom)) as geom from estat.census_boundary
        where hcode = 8101 and s_name is null and length(key_code) > 2 group by pref_name, city_name, key_code
    ) as cb order by key_code;
