# Benchmark Data

A 120,000+ sample Address Data is provided to test the Matching Rate of this geocoder as well as its speed performance. These are non-normalized, non-generated, live addresses gathered from different Japanese Agencies through their OpenData Portal pages. The addresses can be found in the `pgg_benchmark.txt` file.

### Installation 

To install, run the included file `pgg_benchmark.sql` using `pgsql` on a database with pg_geocoder fully installed. 

```shell
pgsql -f pgg_benchmark.sql addresses2020
```

This will create a `pgg_benchmark` table and populate it with the addresses, then add a `gc` column of type `geores` to contain the geocoder reult information. Finally, the entire addresses will be geocoded. 

From here, it is possible to see the results of the pg_geocoder geocding process on the addresses. Below is an example query to list all the `Pinpoint` and `Banchi` level matches with the corresponding Lng/Lat coordinates on Tokyo addresses:

```sql 
select (gc).code,address,(gc).x,(gc).y from pgg_benchmark where (gc).code <= 2 and (gc).todofuken = '東京都';
```

### Benchmarkong Geocoding Rate

To get the time it takes to geocode the entire table, set the `\timing` pgsql timing feature to on amd then geocode the table using SQL's `update` command.

```sql 
\timing on
update pgg_benchmark set gc = geocoder( address );

UPDATE 124729
Time: 163124.479 ms (02:43.124)
```

Note: The time result is from a MacBook Pro M1 with 16gb of memory. The results will vary depending on the database machine specifications. 
