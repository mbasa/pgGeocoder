create schema if not exists abr;

CREATE TABLE if not exists abr.rsdtdsp_dsp (
  "lg_code"            TEXT DEFAULT '',
  "machiaza_id"        TEXT DEFAULT '',
  "blk_id"             TEXT DEFAULT '',
  "rsdt_id"            TEXT DEFAULT '',
  "rsdt2_id"           TEXT DEFAULT '',
  "city"               TEXT DEFAULT '',
  "ward"               TEXT DEFAULT '',
  "oaza_cho"           TEXT DEFAULT '',
  "chome"              TEXT DEFAULT '',
  "koaza"              TEXT DEFAULT '',
  "machiaza_dist"      TEXT DEFAULT '',
  "blk_num"            TEXT DEFAULT '',
  "rsdt_num"           TEXT DEFAULT '',
  "rsdt_num2"          TEXT DEFAULT '',
  "basic_rsdt_div"     TEXT DEFAULT '',
  "rsdt_addr_flg"      TEXT DEFAULT '',
  "rsdt_addr_mtd_code" TEXT DEFAULT '',
  "status_flg"         TEXT DEFAULT '',
  "efct_date"          TEXT DEFAULT '',
  "ablt_date"          TEXT DEFAULT '',
  "src_code"           TEXT DEFAULT '',
  "remarks"            TEXT DEFAULT ''
);

CREATE TABLE if not exists abr.rsdtdsp_pos (
  "lg_code"                 TEXT DEFAULT '',
  "machiaza_id"             TEXT DEFAULT '',
  "blk_id"                  TEXT DEFAULT '',
  "rsdt_id"                 TEXT DEFAULT '',
  "rsdt2_id"                TEXT DEFAULT '',
  "rsdt_addr_flg"           TEXT DEFAULT '',
  "rsdt_addr_mtd_code"      TEXT DEFAULT '',
  "rep_lon"                 FLOAT,
  "rep_lat"                 FLOAT,
  "rep_srid"                TEXT DEFAULT '',
  "rep_scale"               TEXT DEFAULT '',
  "rep_src_code"            TEXT DEFAULT '',
  "rsdt_addr_code_rdbl"     TEXT DEFAULT '',
  "rsdt_addr_data_mnt_date" TEXT DEFAULT '',
  "basic_rsdt_div"          TEXT DEFAULT ''
);

CREATE TABLE IF NOT EXISTS abr.pref (
  "lg_code"   TEXT,
  "pref"      TEXT,
  "pref_kana" TEXT,
  "pref_roma" TEXT,
  "efct_date" TEXT,
  "ablt_date" TEXT,
  "remarks"   TEXT
);





