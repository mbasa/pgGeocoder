# pgGeocoder - Japanese Geocoder on PostgreSQL

## Requirements

- PostgreSQL >= 11
- PostGIS >= 2.5
- GDAL >= 2.1
- curl
- unzip
- iconv

## Setup

1. Copy `.env.example` to `.env`.
   ```bash
   $ cd /path/to/pgGeocoder
   $ cp .env.example .env
   ```
2. Open `.env` file with some text editor and adjust database settings.
   ```
   DBROLE=postgres
   DBPASS=postgres
   DBNAME=addresses
   DBHOST=localhost
   DBPORT=5432
   ```
3. Create address database (with same as `.env` values).  
   (If the database exists, drop it at first.)
   ```bash
   # dropdb -U postgres addresses
   $ createdb -U postgres addresses
   ```
4. Run install and download/import scripts.
   ```bash
   $ bash scripts/install.sh
   $ bash scripts/download_isj.sh 2020
   $ bash scripts/import_isj.sh 2020
   ```
5. Run maintenance script.
   ```bash
   $ bash scripts/maintenance.sh
   ```
   If keeping original data source tables is preferable, add `1` as the argument.
   ```bash
   $ bash scripts/maintenance.sh 1
   ```

The above steps take about 30 mins on MacBook Pro (2.6 GHz 16GB RAM) environment.

## Tables/Functions

About tables structure, check the following files.
- [createTables.sql](sql/createTables.sql): Define each tables and columns, but without indexes.
- [maintTables.sql](sql/maintTables.sql): Define indexes.

About functions, check the following files.
- [pgGeocoder.sql](sql/pgGeocoder.sql): Define `geocoder` function.
- [pgReverseGeocoder.sql](sql/pgReverseGeocoder.sql): Define `reverse_geocoder` function.

## Examples

```bash
$ psql -U postgres addresses
```

- Geocode on address:
   ```sql
   select * from geocoder('京都府京都市中京区河原町通四条上る米屋町３８０－１ツジクラビル１階');
   ```
   ```
    code |     x      |     y     |          address          | todofuken | shikuchoson | ooaza | chiban | go 
   ------+------------+-----------+---------------------------+-----------+-------------+-------+--------+----
       2 | 135.769661 | 35.004476 | 京都府京都市中京区米屋町380番 | 京都府     | 京都市中京区  | 米屋町 | 380    | 
   (1 row)
   ```
   ```sql
   select * from geocoder('神奈川県横浜市西区みなとみらい３−６−３');
   ```
   ```
    code |     x      |     y     |             address             | todofuken | shikuchoson |     ooaza      | chiban | go 
   ------+------------+-----------+---------------------------------+-----------+-------------+----------------+--------+----
       2 | 139.632805 | 35.458282 | 神奈川県横浜市西区みなとみらい三丁目6番 | 神奈川県   | 横浜市西区    | みなとみらい三丁目 | 6      | 
   (1 row)
   ```
- Reverse geocode on address:
   ```sql
   select * from reverse_geocoder(141.342094, 43.050264);
   ```
   ```
    code |     x      |     y     |            address            | todofuken | shikuchoson |     ooaza     | chiban | go 
   ------+------------+-----------+-------------------------------+-----------+-------------+---------------+--------+----
       1 | 141.341681 | 43.050529 | 北海道札幌市中央区南七条西十一丁目3 | 北海道     | 札幌市中央区  | 南七条西十一丁目 | 3      | 
   (1 row)
   ```
- Reverse geocode a coordinate and specify search distance in meters (lon, lat, meters)
   ```sql
   select * from reverse_geocoder(141.342094, 43.050264, 50);
   ```
   ```
    code |     x      |     y     |            address            | todofuken | shikuchoson |     ooaza     | chiban | go 
   ------+------------+-----------+-------------------------------+-----------+-------------+---------------+--------+----
       1 | 141.341681 | 43.050529 | 北海道札幌市中央区南七条西十一丁目3 | 北海道     | 札幌市中央区  | 南七条西十一丁目 | 3      | 
   (1 row)
   ```

## Data Sources

1. 位置参照情報 (ISJ)  
   - Website: http://nlftp.mlit.go.jp/isj/index.html
   - Format: CSV (Zipped)
   - Geometry Type: Point
   - Remarks:
      - Point based address data for "Gaiku Level" (街区レベル) and "Oaza Level" (大字・町丁目レベル).
