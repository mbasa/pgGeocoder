--
-- assumes that address_t,address_s,address_o,address
-- have been created already.
--

--
-- updating the ttable field to point to address table
--
update address_t set ttable = 'address';

--
-- creating index for address_t
--
create index address_t1 on address_t(todofuken);
create index address_t2 on address_t(code);

--
-- creating index for address_s
--
create index address_s1 on address_s(todofuken);
create index address_s2 on address_s(shikuchoson);
create index address_s3 on address_s(code);

--
-- creating index for address_o
--
create index address_o1 on address_o(todofuken);
create index address_o2 on address_o(shikuchoson);
create index address_o3 on address_o(ooaza);
create index address_o4 on address_o(code);

--
-- creating index for address
--
create index address1 on address(todofuken);
create index address2 on address(shikuchoson);
create index address3 on address(ooaza);
create index address4 on address(chiban);

--
-- for Reverse Geocoding
--
create index address_o_g_idx on address_o using gist( geog );
create index address_g_idx on address using gist( geog );

create index boundary_t1 on boundary_t(todofuken);
create index boundary_t2 on boundary_t(code);
create index boundary_t_g_idx on boundary_t using gist( geom );

create index boundary_s1 on boundary_s(todofuken);
create index boundary_s2 on boundary_s(shikuchoson);
create index boundary_s3 on boundary_s(code);
create index boundary_s_g_idx on boundary_s using gist( geom );

create index boundary_o1 on boundary_o(todofuken);
create index boundary_o2 on boundary_o(shikuchoson);
create index boundary_o3 on boundary_o(ooaza);
create index boundary_o4 on boundary_o(code);
create index boundary_o_g_idx on boundary_o using gist( geom );

--
-- Vacuuming everything
--
VACUUM FULL;
