create index abrpos1 on abr.rsdtdsp_pos (lg_code);
create index abrpos2 on abr.rsdtdsp_pos (machiaza_id);
create index abrpos3 on abr.rsdtdsp_pos (blk_id);
create index abrpos4 on abr.rsdtdsp_pos (rsdt_id);
create index abrpos5 on abr.rsdtdsp_pos (rsdt2_id);

create index abr1 on abr.rsdtdsp_dsp (lg_code);
create index abr2 on abr.rsdtdsp_dsp (machiaza_id);
create index abr3 on abr.rsdtdsp_dsp (blk_id);
create index abr4 on abr.rsdtdsp_dsp (rsdt_id);
create index abr5 on abr.rsdtdsp_dsp (rsdt2_id);

vacuum ANALYZE abr.rsdtdsp_pos ;
vacuum ANALYZE abr.rsdtdsp_dsp ;

delete from pggeocoder.address_g;

insert into pggeocoder.address_g (todofuken,shikuchoson,ooaza,chiban,go,lon,lat,geog)
select 
  pref as todofuken,
  city||COALESCE(ward,'') as shikuchoson,
  COALESCE(oaza_cho,'') || COALESCE(koaza,COALESCE(chome,'')) as ooza,
  blk_num as chiban,
  rsdt_num as go,
  b.rep_lon as lon,
  b.rep_lat as lat,
  st_point(b.rep_lon::float,b.rep_lat::float,4326) as geog
from abr.rsdtdsp_dsp a,abr.rsdtdsp_pos b, abr.pref c 
where a.lg_code = b.lg_code and 
    a.machiaza_id = b.machiaza_id and 
    a.blk_id = b.blk_id and 
    a.rsdt_id = b.rsdt_id and
    COALESCE(a.rsdt2_id,'') = COALESCE(b.rsdt2_id,'') and 
    substr(a.lg_code,1,2) = substr(c.lg_code,1,2);
