BEGIN;

CREATE EXTENSION IF NOT EXISTS pgtap;

CREATE TEMP TABLE normalize_japanese_addresses_test (
  input text,
  pref text,
  city text,
  town text,
  other text
);

\copy normalize_japanese_addresses_test FROM 'addresses.csv' WITH CSV HEADER;
\copy normalize_japanese_addresses_test FROM 'addresses2023.csv' WITH CSV HEADER;

SELECT COUNT(*) FROM normalize_japanese_addresses_test;
\gset
SELECT plan(:count);

CREATE FUNCTION test_addresses() RETURNS SETOF TEXT AS $$
DECLARE
  data record;
  res record;
BEGIN
  FOR data IN SELECT * FROM normalize_japanese_addresses_test LOOP
    -- TODO: How and when check last other column ?
    SELECT
      todofuken::text AS pref,
      shikuchoson::text AS city,
      ooaza::text AS town
    INTO res
    FROM geocoder(data.input);

    RETURN NEXT is(
      ARRAY[res.pref, res.city, res.town],
      ARRAY[data.pref, data.city, data.town],
      data.input
    );
  END LOOP;
  RETURN;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM test_addresses();

SELECT * FROM finish();

ROLLBACK;
