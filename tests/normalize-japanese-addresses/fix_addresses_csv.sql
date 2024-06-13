BEGIN;

CREATE TEMP TABLE normalize_japanese_addresses_temp (
  id serial,
  input text,
  pref text,
  city text,
  town text,
  other text
);

\copy normalize_japanese_addresses_temp(input, pref, city, town, other) FROM 'addresses.csv' WITH CSV HEADER;

CREATE FUNCTION fix_csv_oaza_prefix_to_match_isj() RETURNS INTEGER AS $$
DECLARE
  rec_csv record;
  rec_isj record;
  input_has_prefix boolean;
  fixed_count integer;
BEGIN
  fixed_count := 0;
  FOR rec_csv IN
    SELECT * FROM normalize_japanese_addresses_temp
      WHERE town LIKE '大字%' OR town LIKE '字%'
  LOOP
    SELECT
      todofuken::text AS pref,
      shikuchoson::text AS city,
      array_agg(ooaza::text) AS towns
    INTO rec_isj
    FROM pggeocoder.address_o
    WHERE
      todofuken = rec_csv.pref AND
      shikuchoson = rec_csv.city AND
      (
        ooaza = rec_csv.town OR
        ooaza = regexp_replace(rec_csv.town, '^(大字|字)', '')
      )
    GROUP BY todofuken, shikuchoson;

    input_has_prefix := position('字' in rec_csv.input) > 0;

    RAISE NOTICE 'input_has_prefix: %, rec_isj: %', input_has_prefix, rec_isj;

    IF input_has_prefix = FALSE AND array_length(rec_isj.towns, 1) > 1 THEN
      UPDATE normalize_japanese_addresses_temp
      SET town = regexp_replace(town, '^(大字|字)', '')
      WHERE input = rec_csv.input;
      fixed_count := fixed_count + 1;
      RAISE NOTICE '  Fixed';
    END IF;
  END LOOP;
  RAISE NOTICE 'Fixed % rows', fixed_count;
  RETURN fixed_count;
END;
$$ LANGUAGE plpgsql;

SELECT fix_csv_oaza_prefix_to_match_isj();

\copy (SELECT input AS "住所", pref AS "都道府県", city AS "市区町村", town AS "町丁目", other AS "その他" FROM normalize_japanese_addresses_temp ORDER BY id) TO 'addresses.csv' WITH CSV HEADER;

ROLLBACK;