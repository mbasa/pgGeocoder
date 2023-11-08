create schema if not exists isj;

--
-- 2009 ~ 2016: https://nlftp.mlit.go.jp/isj/dls/form/08.0a.html
-- 2017 ~ 2019: https://nlftp.mlit.go.jp/isj/dls/form/16.0a.html
--
create table isj.gaiku (
  pref_name text, -- 都道府県名
  city_name text, -- 市区町村名
  oaza_name text, -- 大字・丁目名
  koaza_name text, -- 小字・通称名
  gaiku_code text, -- 街区符号・地番
  cs_number smallint, -- 座標系番号
  x float, -- Ｘ座標
  y float, -- Ｙ座標
  lat float, -- 緯度
  lon float, -- 経度
  residence_display_flag boolean, -- 住居表示フラグ
  representative_flag boolean, -- 代表フラグ
  before_update_flag smallint, -- 更新前履歴フラグ (1：新規作成、2：名称変更、3：削除、0：変更なし（半角）)
  after_update_flag smallint -- 更新後履歴フラグ (1：新規作成、2：名称変更、3：削除、0：変更なし（半角）)
);

--
-- 2009 ~ 2019
-- https://nlftp.mlit.go.jp/isj/dls/form/14.0b.html
--
create table isj.oaza (
  pref_code text, -- 都道府県コード
  pref_name text, -- 都道府県名
  city_code text, -- 市区町村コード
  city_name text, -- 市区町村名
  oaza_code text, -- 大字町丁目コード
  oaza_name text, -- 大字町丁目名
  lat float, -- 緯度
  lon float, -- 経度   
  source_code smallint, -- 原典資料コード (1：自治体資料、2：街区レベル位置参照情報、3：1/25000地形図、0：その他資料)
  oaza_class_code smallint -- 大字・字・丁目区分コード (1：大字、2：字、3：丁目、0：不明（通称）)
);
