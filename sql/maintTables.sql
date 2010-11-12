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
