--
-- pgGeocoder.ja : Japanese Geocoder for PostgreSQL
-- Copyright (C) 2007  Mario Basa
--
-- This program is free software; you can redistribute it and/or
-- modify it under the terms of the GNU General Public License
-- as published by the Free Software Foundation; either version 2
-- of the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
--
-- このプログラムはフリーソフトウェアです。あなたはこれを、フリーソフトウェ
-- ア財団によって発行された GNU 一般公衆利用許諾契約書(バージョン2か、希
-- 望によってはそれ以降のバージョンのうちどれか)の定める条件の下で再頒布
-- または改変することができます。
-- 
-- このプログラムは有用であることを願って頒布されますが、*全くの無保証* 
-- です。商業可能性の保証や特定の目的への適合性は、言外に示されたものも含
-- め全く存在しません。詳しくはGNU 一般公衆利用許諾契約書をご覧ください。
--  
-- あなたはこのプログラムと共に、GNU 一般公衆利用許諾契約書の複製物を一部
-- 受け取ったはずです。もし受け取っていなければ、フリーソフトウェア財団ま
-- で請求してください(宛先は the Free Software Foundation, Inc., 59
-- Temple Place, Suite 330, Boston, MA 02111-1307 USA)。

DROP TYPE IF EXISTS geores CASCADE;

CREATE TYPE geores AS (
   code        integer,
   x           double precision,
   y           double precision,
   address     character varying,
   todofuken   character varying,
   shikuchoson character varying,
   ooaza       character varying,
   chiban      character varying,  
   go          character varying
);

--
--   Main Geocoder function.
--

CREATE OR REPLACE FUNCTION geocoder(character varying) 
  RETURNS geores AS $$
DECLARE
 address ALIAS FOR $1;
 gc      geores;
 output  geores;
 matching_nomatch     integer;
 matching_todofuken   integer;
 matching_shikuchoson integer;
 matching_ooaza       integer;
 matching_chiban      integer;
 matching_pinpnt      integer;

BEGIN

  matching_nomatch     := 0;
  matching_todofuken   := 1;
  matching_shikuchoson := 2;
  matching_ooaza       := 3;
  matching_chiban      := 4;
  matching_pinpnt      := 5;
  
  output := searchTodofuken( address );

  IF output.address <> 'なし' THEN
    output.code := matching_todofuken;
    gc := searchShikuchoson( address,output.todofuken);
  ELSE
    output.code := matching_nomatch;
    gc := searchShikuchoson( address,'');
  END IF;
   
  IF gc.address <> 'なし' THEN
    output := gc;
    output.code := matching_shikuchoson;
    gc := searchOoaza( address,output.todofuken,output.shikuchoson );
  ELSE
    RETURN output;
  END IF;

  IF gc.address <> 'なし' THEN
    output := gc;
    output.code := matching_ooaza;
    gc := searchChiban( address,output.todofuken,output.shikuchoson,
                                  output.ooaza );
  ELSE
    RETURN output;
  END IF;

  IF gc.address <> 'なし' THEN
    output := gc;
    output.code := matching_chiban;
    gc := searchPinpoint( address,output.todofuken,output.shikuchoson,
                                  output.ooaza,output.chiban );
  ELSE
    RETURN output;
  END IF;

IF gc.address <> 'なし' THEN
    output := gc;
    output.code := matching_pinpnt;
END IF;

RETURN output;

END;
$$ LANGUAGE plpgsql;

--
--  Function to normalize Address for easier matches
--

CREATE OR REPLACE FUNCTION normalizeAddr(character varying) 
  RETURNS varchar AS $$
DECLARE
  paddress ALIAS FOR $1;
  address   varchar;
  tmpstr    varchar;
  tmparr    text[];
  st        integer;
  en        integer;
  arrc      integer;
  arrl      integer;
BEGIN
  
  address := translate(paddress,
      'ヶケ?ｰ―‐−－ーのノ１２３４５６７８９０〇一二三四五六七八九十丁目',
      'がが---------12345678900123456789X-');

  IF strpos( address, 'X') <> 0 THEN
    tmparr   := string_to_array( address,'X');
    address  := '';
    arrl     := array_upper( tmparr, 1 ); 
    arrc     := 1;
    
    WHILE arrc < arrl  LOOP
            st :=  ascii(substr(tmparr[arrc],length(tmparr[arrc]),1));
            en := ascii(substr(tmparr[ arrc+1 ],1,1));

            --
            -- For cases like '十九'
            --
            IF (st < 48 OR st > 57) AND (en >= 48 AND en <= 57) THEN
               IF arrc = 1 THEN
                 address :=  address || tmparr[arrc] || '1' ||  tmparr[arrc+1];
              ELSE
                 address :=  address ||  '1' ||  tmparr[arrc+1];
              END IF;
            END IF;
            
            --
            -- For cases like '二十九'
            --
            IF (st >= 48 AND  st <= 57) AND (en >= 48 AND en <= 57) THEN
                IF arrc = 1 THEN              
                   address :=  address || tmparr[arrc] ||  tmparr[arrc+1];
                ELSE
                   address :=  address || tmparr[arrc+1];
                END IF;
            END IF;
            
            --
            -- For cases like '二十'
            --
            IF (st >= 48 AND  st <= 57) AND (en < 48 OR en > 57) THEN
               IF arrc = 1 THEN
                  address :=  address || tmparr[arrc] ||  '0' || tmparr[arrc+1];
               ELSE
                  address :=  address ||  '0' || tmparr[arrc+1];
               END IF;
            END IF;
        
            --
            -- For cases like '十'
            --
            IF (st < 48 OR  st > 57) AND (en < 48 OR en > 57) THEN
               IF arrc = 1 THEN
                  address :=  address || tmparr[arrc] ||  '10' || tmparr[arrc+1];
               ELSE
                  address :=  address ||  '10' || tmparr[arrc+1];
               END IF;
            END IF;
        
           arrc := arrc + 1;
     END LOOP;
     
  END IF;
  
  --
  -- Removing 大字 OR 字 since addresses sometimes omit this
  --
  IF address ~ '^大字' OR address ~ '^字' THEN
    address := regexp_replace(address, '^(大字|字)', '');
  END IF;

  --
  -- Adding Kobayashi-san's rule set
  --
  address := translate( address,
    '榮之ノ治ヰヱ淵渕輿曽藪薮籠篭劔峯峰岡丘富冨祓桧檜莱洲冶治壇檀舘館斉斎竈竃朗鷆膳録嶋崎埼碕庄荘横橫鄕神塚塚都都德福朗郞嶽區溪縣廣斎眞槇槙莊藏龍瀧澤當邊舖萬豫禮茅礪砺',
    '栄-の冶いえ渕淵興曾薮藪篭籠剱峰峯丘岡冨富秡檜桧来州治冶檀壇館舘斎斉釜釜郎鷏善禄島埼崎崎荘庄橫横郷神塚塚都都徳福朗郎岳区渓県広斉真槙槇荘蔵竜滝沢当辺舗万予礼芽砺礪'
  );

 --
 -- For addresses like 清水一丁目−３番−１４号
 --  
  address := replace(address,'--','-');

  --
  -- Replacing 通り with 通. Common address mistake.
  --
  address := replace(address,'通り','通');

  --
  -- Replacing floor num in address ie 清水1-3-14 3F
  --
  address := regexp_replace(address,' \d*F' ,' nF');
  address := regexp_replace(address,'　\d*F' ,' nF');
  address := regexp_replace(address,' \W*Ｆ' ,' nF');
  address := regexp_replace(address,'　\W*Ｆ',' nF');
  address := regexp_replace(address,' \W*階' ,' nF');
  address := regexp_replace(address,'　\W*階',' nF');
  address := regexp_replace(address,' \d*階' ,' nF');
  address := regexp_replace(address,'　\d*階',' nF');

  --
  -- For addresses like 北海道札幌市白石区本通１北３
  --
  tmpstr := ( regexp_matches(address,'\d[東西南北]\d'))[1];
  
  IF tmpstr IS NOT NULL THEN
    tmparr  := string_to_array( tmpstr,NULL );
    address := regexp_replace(address,tmpstr,tmparr[1]||'-'||tmparr[2]||tmparr[3]);
  END IF;
  
  --
  -- For addresses like  北海道札幌市白石区南郷通６北－４
  --
  tmpstr := ( regexp_matches(address,'\d[東西南北]-\d'))[1];
  
  IF tmpstr IS NOT NULL THEN
    tmparr  := string_to_array( tmpstr,NULL );
    address := regexp_replace(address,tmpstr,tmparr[1]||'-'||tmparr[2]||tmparr[4]);
  END IF;
  
  RETURN address;

END;
$$ LANGUAGE plpgsql;


--
--  Function to search Todofuken level of an address
--  parameters: address
--

CREATE OR REPLACE FUNCTION searchTodofuken(character varying) 
  RETURNS geores AS $$
DECLARE
  paddress ALIAS FOR $1;
  address  varchar;
  rec      RECORD;
  output   geores;
BEGIN

--  RAISE NOTICE 'Todofuken Parameter passed is : %',paddress;

  output.x         := -999;
  output.y         := -999;
  output.address   := 'なし';
  output.todofuken := '';

  address := replace(paddress,' ','');
  address := replace(address,'　','');

  SELECT INTO rec * FROM pggeocoder.address_t WHERE address
     LIKE todofuken||'%';

  IF FOUND THEN
     output.x         := rec.lon;
     output.y         := rec.lat;
     output.code      := 4;
     output.address   := rec.todofuken;
     output.todofuken := rec.todofuken;
  ELSE
     output.code    := 5;
  END IF;

  RETURN output;
END;
$$ LANGUAGE plpgsql;

--
--  Function to search Shikuchoson level of an address
--  parameters: address,todofuken (may be blank)
--

CREATE OR REPLACE FUNCTION searchShikuchoson( character varying,
                                               character varying ) 
  RETURNS geores AS $$
DECLARE
  paddress    ALIAS FOR $1;
  r_todofuken ALIAS FOR $2;
  address     varchar;
  tmpstr      varchar;
  rec         RECORD;
  output      geores;
BEGIN

--  RAISE NOTICE 'Shikuchoson Parameters passed are : % and %',
--         paddress,r_todofuken;

  output.x         := -999;
  output.y         := -999;
  output.address   := 'なし';  

  address := replace(paddress,' ','');
  address := replace(address,'　','');

  IF r_todofuken <> '' THEN
    tmpstr := split_part(address,r_todofuken,2);
    SELECT INTO rec * FROM pggeocoder.address_s WHERE 
     todofuken = r_todofuken AND
     normalizeAddr(tmpstr) LIKE tr_shikuchoson||'%'
     ORDER BY length(tr_shikuchoson) DESC;
  ELSE
    tmpstr := normalizeAddr(address);
    SELECT INTO rec * FROM pggeocoder.address_s WHERE 
     tmpstr LIKE tr_shikuchoson||'%'
     ORDER BY length(tr_shikuchoson) DESC;
  END IF;

  --
  -- Removing District ('郡') since it is not
  -- normally written in the address
  --
  IF NOT FOUND THEN
    tmpstr := normalizeAddr(address);

    IF r_todofuken <> '' THEN      
      SELECT INTO rec * FROM pggeocoder.address_s WHERE 
      todofuken = r_todofuken AND
      tmpstr LIKE '%'||substr(tr_shikuchoson,strpos(tr_shikuchoson,'郡')+1)||'%'
      ORDER BY length(tr_shikuchoson) DESC;
    ELSE
      SELECT INTO rec * FROM pggeocoder.address_s WHERE 
      tmpstr LIKE substr(tr_shikuchoson,strpos(tr_shikuchoson,'郡')+1)||'%'
      ORDER BY length(tr_shikuchoson) DESC;
    END IF;
  END IF;

  IF FOUND THEN
     output.x          := rec.lon;
     output.y          := rec.lat;
     output.code       := 3;
     output.address    := rec.todofuken || rec.shikuchoson;
     output.todofuken  := rec.todofuken;
     output.shikuchoson:= rec.shikuchoson;
  END IF;

  RETURN output;

END;
$$ LANGUAGE plpgsql;

--
--  Function to search Ooaza level of an address
--  parameters: address, shikuchoson
--

CREATE OR REPLACE FUNCTION searchOoaza( character varying, character varying,
                                         character varying ) 
  RETURNS geores AS $$
DECLARE
  paddress      ALIAS FOR $1;
  r_todofuken   ALIAS FOR $2;
  r_shikuchoson ALIAS FOR $3;
  address       varchar;
  t_shikuchoson varchar;
  tmpstr        varchar;
  tmpaddr       varchar;
  rec           RECORD;
  output        geores;
BEGIN

--  RAISE NOTICE 'Ooaza Parameters passed are : % and %',
--         paddress,r_shikuchoson;

  output.x         := -999;
  output.y         := -999;
  output.address   := 'なし';

  address := replace(paddress,' ','');
  address := replace(address,'　','');
  
  t_shikuchoson := normalizeAddr( r_shikuchoson );

  tmpstr  := split_part(normalizeAddr(address),t_shikuchoson,2);

  IF tmpstr = '' THEN    
    tmpstr  := split_part(normalizeAddr(address),
      substr(t_shikuchoson,strpos(t_shikuchoson,'郡')+1),2);
  END IF;
  
  --tmpstr  := tmpstr || '-'; 
  --tmpaddr := normalizeAddr( tmpstr );

  tmpaddr := tmpstr || '-'; -- to match addresses like 杉並区清水１

  --
  -- Removing 大字 OR 字 since addresses sometimes omit this
  --
  IF tmpaddr ~ '^大字' OR tmpaddr ~ '^字' THEN
    tmpaddr := regexp_replace(tmpaddr, '^(大字|字)', '');
  END IF;

  --
  -- Trying to parse Kyoto Addresses which contains Directions
  --
  IF r_todofuken = '京都府' THEN
    
    SELECT INTO rec *,
    strpos(address,ooaza) AS pos,
    length(tr_ooaza) AS length 
    FROM pggeocoder.address_o WHERE 
    todofuken = r_todofuken AND
    tr_shikuchoson = t_shikuchoson AND
    strpos(tmpaddr,tr_ooaza) >= 1 
    ORDER BY length DESC,pos DESC,year DESC LIMIT 1; 
  ELSE      
    --
    -- the 'Order By length' slows down the operation a bit
    -- but produces more accurate matches.
    --
    SELECT INTO rec *,length(tr_ooaza) AS length FROM pggeocoder.address_o WHERE 
     todofuken = r_todofuken AND
     tr_shikuchoson = t_shikuchoson AND
     strpos(tmpaddr,tr_ooaza) = 1 
     ORDER BY length DESC,year DESC LIMIT 1; 
  END IF;

  IF FOUND THEN
     output.x          := rec.lon;
     output.y          := rec.lat;
     output.code       := 2;
     output.address    := rec.todofuken||rec.shikuchoson||rec.ooaza;
     output.todofuken  := rec.todofuken;
     output.shikuchoson:= rec.shikuchoson;
     output.ooaza      := rec.ooaza;          
  END IF;
  
  RETURN output;

END;
$$ LANGUAGE plpgsql;

--
--  Function to search Chiban level of an address
--  parameters: address, todofuken, shikuchoson, ooza
--

CREATE OR REPLACE FUNCTION searchChiban( character varying,character varying, 
                                          character varying,character varying ) 
  RETURNS geores AS $$
DECLARE
  paddress      ALIAS FOR $1;
  r_todofuken   ALIAS FOR $2;
  r_shikuchoson ALIAS FOR $3;
  r_ooaza       ALIAS FOR $4;
  address       varchar;
  ooaza         varchar;
  shikuchoson   varchar;
  preftab       varchar;
  tmpstr1       varchar;
  tmpstr2       varchar;
  tmpstr3       varchar;
  tmpcnt        integer;
  tmpflag       integer;
  rec           RECORD;
  output        geores;
BEGIN

  output.x         := -999;
  output.y         := -999;
  output.address   := 'なし';

  preftab := '';

  IF r_todofuken <> '' THEN
    SELECT INTO rec * FROM pggeocoder.address_t where todofuken = r_todofuken;
    preftab := rec.ttable;
  END IF;

  IF preftab = '' THEN
    RETURN  output;
  END IF;

  address := normalizeAddr( paddress );
  address := replace(address,' ','');
  address := replace(address,'　','');  

  ooaza := replace(r_ooaza,' ','');
  ooaza := replace(ooaza,'　','');
  ooaza := normalizeAddr( ooaza );

  shikuchoson := replace(r_shikuchoson,' ','');
  shikuchoson := replace(shikuchoson,'　','');
  shikuchoson := normalizeAddr( shikuchoson );

--  RAISE NOTICE 'Chiban Parameters passed are : % and %',
--         address,ooaza;

  -- Test if ooaza string is contained in shikuchoson
  -- i.e. address='和気郡和気町和気681'' ooaza='和気'

  -- FOR counter IN reverse 5..2 LOOP
  --   tmpstr1 := split_part( address,ooaza,counter);
  --   EXIT WHEN tmpstr1 <> '';
  -- END LOOP;
  
  
  tmpstr1 := split_part(address,ooaza,2);
  tmpstr1 := replace(tmpstr1,'X','10');

  tmpcnt  := 1;
  tmpflag := length( tmpstr1 );
  tmpstr2 := '';
  tmpstr3 := '';
  
  WHILE tmpcnt <= tmpflag LOOP
   tmpstr2 := substr(tmpstr1,tmpcnt,1);
   
   IF ascii( tmpstr2 ) >= 48 AND ascii( tmpstr2 ) <= 57 THEN
     tmpstr3 := tmpstr3 || tmpstr2;
   ELSE
      EXIT;
   END IF;
   
   tmpcnt := tmpcnt + 1;
  END LOOP;

  tmpstr1 := 'SELECT * FROM '|| preftab ||' WHERE '  ||
   'tr_shikuchoson = ' || quote_literal(shikuchoson) || ' AND ' ||
   'tr_ooaza       = ' || quote_literal(ooaza)       || ' AND ' ||
   'chiban         = ' || quote_literal(tmpstr3) || 
   ' ORDER BY year DESC';

   EXECUTE tmpstr1 into rec;
      
  IF rec.lon IS NOT NULL AND rec.lat IS NOT NULL THEN
    output.code       := 1;
    output.x          := rec.lon;
    output.y          := rec.lat;
    output.address    := rec.todofuken||rec.shikuchoson||
                         rec.ooaza||rec.chiban;
    output.todofuken  := rec.todofuken;
    output.shikuchoson:= rec.shikuchoson;
    output.ooaza      := rec.ooaza;
    output.chiban     := rec.chiban;
  END IF;
  
  RETURN output;

END;
$$ LANGUAGE plpgsql;


--
--  Function to search Pinpoint level of an address
--  parameters: address, todofuken, shikuchoson, ooza, chiban
--

CREATE OR REPLACE FUNCTION searchPinpoint( character varying,character varying, 
                            character varying,character varying,character varying ) 
  RETURNS geores AS $$
DECLARE
  paddress      ALIAS FOR $1;
  r_todofuken   ALIAS FOR $2;
  r_shikuchoson ALIAS FOR $3;
  r_ooaza       ALIAS FOR $4;
  r_chiban      ALIAS FOR $5;
  address       varchar;
  ooaza         varchar;
  tmpstr1       varchar;
  tmpstr2       varchar;
  tmpstr3       varchar;
  rec           RECORD;
  output        geores;
BEGIN

  output.x         := -999;
  output.y         := -999;
  output.address   := 'なし';

  address := replace(paddress,'番地','-');
  address := replace(address,'番','-');
  address := normalizeAddr( address );

  address := replace(address,' ','');
  address := replace(address,'　','');

  ooaza := replace(r_ooaza,'番','-');
  ooaza := normalizeAddr(ooaza);

  tmpstr2 := substring( split_part(address,ooaza,2) from '\d*\-\d*');

  IF tmpstr2 IS NOT NULL THEN
    tmpstr3 := split_part(tmpstr2,'-',2);
  ELSE
    RETURN output;
  END IF;

  tmpstr1 := 'SELECT * FROM pggeocoder.address_g WHERE '  ||
   'tr_shikuchoson = ' || quote_literal(normalizeAddr(r_shikuchoson)) || ' AND ' ||
   'tr_ooaza       = ' || quote_literal(normalizeAddr(r_ooaza))       || ' AND ' ||
   'chiban         = ' || quote_literal(r_chiban) || ' AND ' ||
   'go             = ' || quote_literal(tmpstr3);

  --RAISE NOTICE 'tmpstr1 %',tmpstr1;
  
  EXECUTE tmpstr1 into rec;
      
  IF rec.lon IS NOT NULL AND rec.lat IS NOT NULL THEN
    output.code       := 1;
    output.x          := rec.lon;
    output.y          := rec.lat;
    output.address    := rec.todofuken||r_shikuchoson||
                         r_ooaza||rec.chiban||'-'||tmpstr3;
    output.todofuken  := rec.todofuken;
    output.shikuchoson:= r_shikuchoson;
    output.ooaza      := r_ooaza;
    output.chiban     := rec.chiban;
    output.go         := tmpstr3;
  END IF;
  
  RETURN output;

END;
$$ LANGUAGE plpgsql;


