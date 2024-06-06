CREATE TEMP TABLE normalize_japanese_addresses_test (
  input text,
  pref text,
  city text,
  town text,
  other text
);

\copy normalize_japanese_addresses_test FROM 'addresses.csv' WITH CSV HEADER;

BEGIN;

CREATE EXTENSION IF NOT EXISTS pgtap;

SELECT plan(7104); -- SELECT count(*) FROM normalize_japanese_addresses_test

DO $$
DECLARE
  data record;
  res record;
  actual text;
  expected text;
  result text;
BEGIN
  FOR data IN SELECT * FROM normalize_japanese_addresses_test LOOP
    SELECT
      todofuken::text AS pref,
      shikuchoson::text AS city,
      ooaza::text AS town
    INTO res
    FROM geocoder(data.input);

    SELECT array_to_string(ARRAY[res.pref, res.city, res.town], ',') INTO actual;
    SELECT array_to_string(ARRAY[data.pref, data.city, data.town], ',') INTO expected;

    -- TODO: other column
    SELECT is(
      actual,
      expected,
      data.input
    ) INTO result;
    IF left(result, 3) = 'not' THEN
      RAISE NOTICE '%', result;
    END IF;
  END LOOP;
END $$;

SELECT * FROM finish();

ROLLBACK;
