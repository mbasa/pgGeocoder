# pgGeocoder - Japanese Geocoder on PostgreSQL

## Requirements

* PostgreSQL >= 11
* PostGIS >= 2.5
#### For Address Data Import and Creation
* GDAL >= 2.1
* curl
* unzip
* iconv

## Setup

1. Copy `.env.example` to `.env`.
   ```bash
   $ cd /path/to/pgGeocoder
   $ cp .env.example .env
   ```
2. Open `.env` file with some text editor and adjust database settings and the years of the dataset to import.
   ```
   DBROLE=postgres
   DBPASS=postgres
   DBNAME=addresses
   DBHOST=localhost
   DBPORT=5432
   YEAR_ISJ=2023
   YEAR_KSJ=2023
   YEAR_ESTAT=2020
   ```
3. Create address database (with same as `.env` values).  
   (If the database exists, drop it at first.)
   ```bash
   $ dropdb -U postgres addresses
   $ createdb -U postgres addresses
   ```
4. Run install and download/import scripts.
   ```bash
   $ bash scripts/install.sh
   $ bash scripts/import_data.sh
   ```
5. Run maintenance script.
   ```bash
   $ bash scripts/maintenance.sh
   ```
   If keeping original data source tables is preferable, add `1` as the argument.
   ```bash
   $ bash scripts/maintenance.sh 1
   ```

   Note: The maintainance script will take around 45 mins to complete depending on the specs of the computer.

## Tables/Functions

About tables structure, check the following files.
* [createTables.sql](sql/createTables.sql): Define each tables and columns, but without indexes.
* [maintTables.sql](sql/maintTables.sql): Define indexes.

About functions, check the following files.
* [pgGeocoder.sql](sql/pgGeocoder.sql): Define `geocoder` function.
* [pgReverseGeocoder.sql](sql/pgReverseGeocoder.sql): Define `reverse_geocoder` function.

## Examples

```bash
$ psql -U postgres addresses
```

* Geocode on address:
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
       1 | 139.632805 | 35.458282 | 神奈川県横浜市西区みなとみらい三丁目6番 | 神奈川県   | 横浜市西区    | みなとみらい三丁目 | 6      | 3
   (1 row)
   ```
* Reverse geocode on address:
   ```sql
   select * from reverse_geocoder(141.342094, 43.050264);
   ```  
   ```
    code |         x         |         y         |                address                | todofuken | shikuchoson  |      ooaza       | chiban | go 
   ------+-------------------+-------------------+---------------------------------------+-----------+--------------+------------------+--------+----
       1 | 141.3421173095703 | 43.05035400390625 | 北海道札幌市中央区南七条西十一丁目4-5 | 北海道    | 札幌市中央区 | 南七条西十一丁目 | 4      | 5
    (1 row)
   ```
* Reverse geocode a coordinate and specify search distance in meters (lon, lat, meters)
   ```sql
   select * from reverse_geocoder(141.342094, 43.050264, 50);
   ```
   ```
    code |         x         |         y         |                address                | todofuken | shikuchoson  |      ooaza       | chiban | go 
   ------+-------------------+-------------------+---------------------------------------+-----------+--------------+------------------+--------+----
       1 | 141.3421173095703 | 43.05035400390625 | 北海道札幌市中央区南七条西十一丁目4-5 | 北海道    | 札幌市中央区 | 南七条西十一丁目 | 4      | 5
    (1 row)
   ```

## Data Sources

1. 位置参照情報 (ISJ)  
   - Website: http://nlftp.mlit.go.jp/isj/index.html
   - Format: CSV (Zipped)
   - Geometry Type: Point
   - Remarks:
      - Point based address data for "Gaiku Level" (街区レベル) and "Oaza Level" (大字・町丁目レベル).
2. e-Stat 国勢調査町丁・字等別境界データ
   - Website: https://www.e-stat.go.jp/gis/statmap-search?page=1&type=2&aggregateUnitForBoundary=A&toukeiCode=00200521
   - Format: ESRI Shapefile (or GML)
   - Geometry Type: Polygon
   - Remarks:
      - Almost "Oaza Level" (大字・町丁目レベル) admin boundary data, but some boundaries are merged for Japanese census survey units.
      - Each prefectures' boundaries are not adjusted (snapped), so some overlaps and gaps exist.
3. 国土数値情報 (KSJ)
   - Website: https://nlftp.mlit.go.jp/ksj/index.html
   - Format: ESRI Shapefile (or GML)
   - 行政区域データ:
      - Website: https://nlftp.mlit.go.jp/ksj/gml/datalist/KsjTmplt-N03-2023.html
      - Geometry Type: Polygon
      - Remarks:
         - "City Level" (市区町村レベル) admin boundary data.
   - 市区町村役場データ:
      - Website: https://nlftp.mlit.go.jp/ksj/gml/datalist/KsjTmplt-P34.html
      - Geometry Type: Point
      - Remarks:
         - "City Office" (市区町村役場) point data.
   - 国・都道府県の機関データ:
      - Website: https://nlftp.mlit.go.jp/ksj/gml/datalist/KsjTmplt-P28-2022.html
      - Geometry Type: Point
      - Remarks:
         - Geovernment data which includes "Prefectural Office" (都道府県庁) point data.
4. デジタル庁 アドレス・ベース・レジストリ (ABR)
      - Website: https://www.digital.go.jp/policies/base_registry_address
      - Format: CSV (Zipped)
      - Geometry Type: Point
      - Remarks:
         - Pinpoint Data for selected areas.

## Notes    
    
* For `Bulk Geocoding`, wherein addresses located in a field of a table are geocoded, please see this [WIKI Entry](https://github.com/mbasa/pgGeocoder/wiki/bulk_geocoding).

* To create `TRIGGERS` that will geocode addresses automatically on an `INSERT` or `UPDATE` operation, please see this [WIKI Entry](https://github.com/mbasa/pgGeocoder/wiki/Creating-Triggers-for-the-Geocoder).


* To do `Spatial Analytics` using `pgGeocoder` with [GeoFuse](https://github.com/mbasa/geofuse), please see this [WIKI Entry](https://github.com/mbasa/pgGeocoder/wiki/Spatial-Analytics)


* To view the FOSS4G Presentation for pgGeocoder, please see this [WIKI Entry](https://github.com/mbasa/pgGeocoder/wiki/pgGeocoder-FOSS4G-Presentation)
