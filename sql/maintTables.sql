--
-- assumes that address_t,address_s,address_o,address
-- have been created already.
--

--
-- updating the ttable field to point to address table
--
update pggeocoder.address_t set ttable = 'pggeocoder.address_c';

--
-- creating index for address_t
--
create index address_t1 on pggeocoder.address_t(todofuken);
create index address_t2 on pggeocoder.address_t(code);

--
-- creating index for address_s
--
create index address_s1 on pggeocoder.address_s(todofuken);
create index address_s2 on pggeocoder.address_s(shikuchoson);
create index address_s3 on pggeocoder.address_s(code);

--
-- creating index for address_o
--
create index address_o1 on pggeocoder.address_o(todofuken);
create index address_o2 on pggeocoder.address_o(shikuchoson);
create index address_o3 on pggeocoder.address_o(ooaza);
create index address_o4 on pggeocoder.address_o(code);

--
-- creating index for address
--
create index address_c1 on pggeocoder.address_c(todofuken);
create index address_c2 on pggeocoder.address_c(shikuchoson);
create index address_c3 on pggeocoder.address_c(ooaza);
create index address_c4 on pggeocoder.address_c(chiban);

--
-- creating index for address_g
--
create index address_g1 on pggeocoder.address_g(shikuchoson);
create index address_g2 on pggeocoder.address_g(ooaza);
create index address_g3 on pggeocoder.address_g(chiban);
create index address_g4 on pggeocoder.address_g(go);

--
-- for Reverse Geocoding
--
create index address_o_g_idx on pggeocoder.address_o using gist( geog );
create index address_g_idx on pggeocoder.address_c using gist( geog );

create index boundary_t1 on pggeocoder.boundary_t(todofuken);
create index boundary_t2 on pggeocoder.boundary_t(code);
create index boundary_t_g_idx on pggeocoder.boundary_t using gist( geom );

create index boundary_s1 on pggeocoder.boundary_s(todofuken);
create index boundary_s2 on pggeocoder.boundary_s(shikuchoson);
create index boundary_s3 on pggeocoder.boundary_s(code);
create index boundary_s_g_idx on pggeocoder.boundary_s using gist( geom );

create index boundary_o1 on pggeocoder.boundary_o(todofuken);
create index boundary_o2 on pggeocoder.boundary_o(shikuchoson);
create index boundary_o3 on pggeocoder.boundary_o(ooaza);
create index boundary_o4 on pggeocoder.boundary_o(code);
create index boundary_o_g_idx on pggeocoder.boundary_o using gist( geom );

--
-- Vacuuming everything
--
VACUUM FULL;
