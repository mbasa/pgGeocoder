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

SELECT plan(7104); -- SELECT count(*) FROM normalize_japanese_addresses_test

CREATE FUNCTION test_addresses() RETURNS SETOF TEXT AS $$
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

    -- TODO: How and when check last other column ?
    SELECT array_to_string(ARRAY[res.pref, res.city, res.town], ',') INTO actual;
    SELECT array_to_string(ARRAY[data.pref, data.city, data.town], ',') INTO expected;

    RETURN NEXT is(
      actual,
      expected,
      data.input
    );
  END LOOP;
  RETURN;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM test_addresses();

SELECT * FROM finish();

ROLLBACK;
