--
-- creating the pgg_benchmark table
--
drop table if exists  pgg_benchmark;
create table pgg_benchmark (address text);

--
-- copying the addresses from the text file into the table
--
\copy pgg_benchmark(address) from pgg_benchmark.txt CSV;

--
-- adding a geores column to contain geocoder data
--
alter table pgg_benchmark add column gc geores;

--
-- geocoding the addresses
--
update pgg_benchmark set gc = geocoder( address );
