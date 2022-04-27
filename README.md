# pgGeocoder - Japanese Geocoder on PostgreSQL

1. Japanese Address Data which can be used with pgGeocoder 
   is downloadable from here:
   
   http://nlftp.mlit.go.jp/isj/index.html
2. pgGeocoder requires the following tables:
   ```
                         Table "public.address_t"
     Column   |         Type          | Collation | Nullable | Default 
   -----------+-----------------------+-----------+----------+---------
    todofuken | character varying(60) |           |          | 
    lat       | double precision      |           |          | 
    lon       | double precision      |           |          | 
    ttable    | character varying(40) |           |          | 
   
   
                          Table "public.address_s"
      Column    |         Type          | Collation | Nullable | Default 
   -------------+-----------------------+-----------+----------+---------
    todofuken   | character varying(60) |           |          | 
    shikuchoson | character varying(60) |           |          | 
    lat         | double precision      |           |          | 
    lon         | double precision      |           |          | 
   Indexes:
       "address_s1" btree (todofuken)
   
   
                          Table "public.address_o"
      Column    |         Type          | Collation | Nullable | Default 
   -------------+-----------------------+-----------+----------+---------
    todofuken   | character varying(60) |           |          | 
    shikuchoson | character varying(60) |           |          | 
    ooaza       | character varying(60) |           |          | 
    tr_ooaza    | character varying(60) |           |          | 
    lat         | double precision      |           |          | 
    lon         | double precision      |           |          | 
   Indexes:
       "address_o1" btree (todofuken)
       "address_o2" btree (shikuchoson)
       "address_o3" btree (ooaza)
   
   
                           Table "public.address"
      Column    |         Type          | Collation | Nullable | Default 
   -------------+-----------------------+-----------+----------+---------
    todofuken   | character varying(60) |           |          | 
    shikuchoson | character varying(60) |           |          | 
    ooaza       | character varying(60) |           |          | 
    chiban      | character varying(60) |           |          | 
    lat         | double precision      |           |          | 
    lon         | double precision      |           |          | 
   Indexes:
       "address1" btree (todofuken)
       "address2" btree (shikuchoson)
       "address3" btree (ooaza)
       "address4" btree (chiban)
   ```
   running `createTables.sql` will automatically build these tables,
   but without the indexes.
3. populate these tables with the Japanese address data. An import 
   script might have to be created in order to accomplish this.
4. run the `maintTables.sql` to create indexes and update the `ttable`
   field in the `address_t` table to point to the address table. 
   For performance, it is adviasable to create smaller tables out 
   of the address table (example: create table by prefecture) rather 
   than 1 big table. The `ttable` field tells pgGeocoder which table 
   holds the prefecture chiban data.
5. run `VACUUM ANALYZE;` and then `VACUUM FULL;`
6. run `pgGeocoder.sql` to install the Geocoder functions. Run the `pgReverseGeocoder.sql` to
   install the Reverse Geocoder functions.
7. normalize the Ooaza names by running:
   ```sql
   update address_o set tr_ooaza = normalizeAddr(ooaza);
   ```
8. geocode an address
   ```sql
   select * from geocoder('京都府京都市中京区河原町通四条上る米屋町３８０－１ツジクラビル１階');
   ```
   ```
    code |     x      |    y     |          address          | todofuken | shikuchoson | ooaza | chiban | go 
   ------+------------+----------+---------------------------+-----------+-------------+-------+--------+----
       2 | 135.769651 | 35.00449 | 京都府京都市中京区米屋町380番 | 京都府     | 京都市中京区  | 米屋町 | 380    | 
   (1 row)
   ```
   ```sql
   select * from geocoder('神奈川県横浜市西区みなとみらい３−６−３');
   ```
   ```
    code |     x      |     y     |             address             | todofuken | shikuchoson |     ooaza      | chiban | go 
   ------+------------+-----------+---------------------------------+-----------+-------------+----------------+--------+----
       2 | 139.632761 | 35.458281 | 神奈川県横浜市西区みなとみらい三丁目6番 | 神奈川県   | 横浜市西区    | みなとみらい三丁目 | 6      | 
   (1 row)
   ```
9. reverse geocode a coordinate (lon,lat)
   ```sql
   select * from reverse_geocoder(141.342094, 43.050264);
   ```
   ```
    code |     x      |     y     |             address              | todofuken | shikuchoson |     ooaza     | chiban | go 
   ------+------------+-----------+----------------------------------+-----------+-------------+---------------+--------+----
       1 | 141.342094 | 43.050264 | 北海道札幌市中央区南七条西十一丁目1281 | 北海道     | 札幌市中央区  | 南七条西十一丁目 | 1281   | 
   (1 row)
   ```
10. reverse geocode a coordinate and specify search distance in meters (lon,lat,meters)
    ```sql
    select * from reverse_geocoder(141.342094, 43.050264, 50);
    ```
    ```
     code |     x      |     y     |             address              | todofuken | shikuchoson |     ooaza     | chiban | go 
    ------+------------+-----------+----------------------------------+-----------+-------------+---------------+--------+----
        1 | 141.342094 | 43.050264 | 北海道札幌市中央区南七条西十一丁目1281 | 北海道     | 札幌市中央区  | 南七条西十一丁目 | 1281   | 
    (1 row)
    ```
    
    
11. For bulk geocoding, wherein addresses located in a field of a table are geocoded, please see this [WIKI Entry](https://github.com/mbasa/pgGeocoder/wiki/bulk_geocoding).


12. To create `TRIGGERS` that will geocode addresses automatically on an `INSERT` or `UPDATE` operation, please see this [WIKI Entry](https://github.com/mbasa/pgGeocoder/wiki/Creating-Triggers-for-the-Geocoder).

