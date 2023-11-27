create index abrpos1 on abr.rsdtdsp_pos (lg_code);
create index abrpos2 on abr.rsdtdsp_pos (town_id);
create index abrpos3 on abr.rsdtdsp_pos (blk_id);
create index abrpos4 on abr.rsdtdsp_pos (addr_id);
create index abrpos5 on abr.rsdtdsp_pos (addr2_id);

create index abr1 on abr.rsdtdsp_dsp (lg_code);
create index abr2 on abr.rsdtdsp_dsp (town_id);
create index abr3 on abr.rsdtdsp_dsp (blk_id);
create index abr4 on abr.rsdtdsp_dsp (addr_id);
create index abr5 on abr.rsdtdsp_dsp (addr2_id);

vacuum ANALYZE abr.rsdtdsp_pos ;
vacuum ANALYZE abr.rsdtdsp_dsp ;

delete from pggeocoder.address_g;

insert into pggeocoder.address_g (todofuken,shikuchoson,ooaza,chiban,go,lon,lat)
select 
  pref_name as todofuken,
  city_name||COALESCE(od_city_name,'') as shikuchoson,
  oaza_town_name || COALESCE(koaza_name,chome_name) as ooza,
  blk_num as chiban,
  rsdt_num as go,
  b.rep_pnt_lon as lon,
  b.rep_pnt_lat as lat 
  from abr.rsdtdsp_dsp a,abr.rsdtdsp_pos b, abr.pref c 
  where a.lg_code = b.lg_code and 
    a.town_id = b.town_id and 
    a.blk_id = b.blk_id and 
    a.addr_id = b.addr_id and
    COALESCE(a.addr2_id,'') = COALESCE(b.addr2_id,'') and 
    substr(a.lg_code,1,2) = substr(c.lg_code,1,2);
