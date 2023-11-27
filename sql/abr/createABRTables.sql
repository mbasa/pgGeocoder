create schema if not exists abr;

CREATE TABLE if not exists abr.rsdtdsp_dsp (
  "lg_code" TEXT DEFAULT '',
  "town_id" TEXT DEFAULT '',
  "blk_id" TEXT DEFAULT '',
  "addr_id" TEXT DEFAULT '',
  "addr2_id" TEXT DEFAULT '',
  "city_name" TEXT,
  "od_city_name" TEXT,
  "oaza_town_name" TEXT,
  "chome_name" TEXT,
  "koaza_name" TEXT,
  "blk_num" TEXT,
  "rsdt_num" TEXT,
  "rsdt_num2" TEXT,
  "basic_rsdt_div" TEXT,
  "rsdt_addr_flg" TEXT,
  "rsdt_addr_mtd_code" TEXT,
  "oaza_frn_ltrs_flg" TEXT,
  "koaza_frn_ltrs_flg" TEXT,
  "status_flg" TEXT,
  "efct_date" TEXT,
  "ablt_date" TEXT,
  "src_code" TEXT,
  "remarks" TEXT
);

CREATE TABLE if not exists abr.rsdtdsp_pos (
  "lg_code" TEXT DEFAULT '',
  "town_id" TEXT DEFAULT '',
  "blk_id" TEXT DEFAULT '',
  "addr_id" TEXT DEFAULT '',
  "addr2_id" TEXT DEFAULT '',
  "disp_flag" TEXT,
  "disp_method_flag" TEXT,
  "basic_rsdt_div" TEXT,
  "rep_pnt_lon" REAL,
  "rep_pnt_lat" REAL,
  "epsg" TEXT,
  "scale" TEXT,
  "source_url" TEXT,
  "effective_date" TEXT
);

CREATE TABLE IF NOT EXISTS abr.pref (
  "lg_code" TEXT,
  "pref_name" TEXT,
  "pref_name_kana" TEXT,
  "pref_name_roma" TEXT,
  "efct_date" TEXT,
  "ablt_date" TEXT,
  "remarks" TEXT
);





