# pgGeocoder Tests

## Requirements

* [pgTAP](https://pgtap.org/)
* [pg_prove](https://pgtap.org/pg_prove.html)
* Perl

### Install pgTAP

```bash
git clone git@github.com:theory/pgtap.git
cd pgtap
make
make install
```

### Install pg_prove

macOS:
```bash
brew install perl
cpan TAP::Parser::SourceHandler::pgTAP
ln -s $(find `brew --prefix` -name pg_prove) symlink it into $(brew --prefix)/bin
```

Linux: (TODO: check actual environment)
```bash
cpan TAP::Parser::SourceHandler::pgTAP
```

## Setup test data

Setup smaller test data which can be used in GitHub Actions.

### Load test data from `fixtures/address_*.csv.gz`

```bash
cp tests/.env.test tests/.env
bash tests/create_test_db_from_fixtures.sh
```
Default test database name is `addresses_test`, but it can be changed in `tests/.env`.

### Update fixtures csv from production database tables

```bash
bash tests/dump_prod_tables_to_fixtures.sh
```
`address_t`, `address_s` and `address_o` tables basic columns are dumped to `fixtures/address_*.csv.gz` files.

## Run tests

Go to the test directory.
```bash
cd tests
```

Run pgTAP tests directly.
```bash
psql -U postgres -d addresses_test -f addresses.test.sql
```

Or run pg_prove tests.
```bash
pg_prove -U postgres -d addresses_test addresses.test.sql
```

To detect error, using pg_prove is recommended.
