--
-- pgReverseGeocoder.ja : Japanese Reverse Geocoder for PostgreSQL
-- Copyright (C) 2018  Mario Basa
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

-- DROP TYPE geores CASCADE;

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


CREATE OR REPLACE FUNCTION mk_geores( record RECORD) RETURNS geores AS $$
DECLARE 
    output geores;
BEGIN
     output.x          := record.lon;
     output.y          := record.lat;
     output.code       := 1;
     output.address    := record.address;
     output.todofuken  := record.todofuken;
     output.shikuchoson:= record.shikuchoson;
     output.ooaza      := record.ooaza;
     output.chiban     := record.chiban;
     
     RETURN output;
END;
$$ LANGUAGE plpgsql;

--
--   NOTE: The Address Table must have a column named "geog" of type Geography
--

CREATE OR REPLACE FUNCTION reverse_geocoder(
    mLon  numeric default 0.0, 
    mLat  numeric default 0.0, 
    mDist numeric default 50,
    mAddr boolean default true,
    mCat  varchar default NULL,
    mOwnr varchar default NULL,
    mLimit numeric default 1  ) 
  RETURNS setof geores AS $$
DECLARE  
  mAddress  varchar;
  record    RECORD;
  temp_rec  RECORD;
  output    geores;
BEGIN

	IF mAddr = TRUE THEN
	   --
	   -- Address Table Search
	   --
        SELECT INTO record todofuken::text, shikuchoson::text, 
            ooaza::text, chiban::text,
            lon, lat,
            todofuken||shikuchoson||ooaza||chiban::text AS address,
            st_distance(st_setsrid(st_makepoint( mLon,mLat),4326)::geography,geog) AS dist 
        FROM address  
        WHERE st_dwithin(st_setsrid(st_makepoint(mLon,mLat),4326)::geography,geog,mDist) 
        ORDER BY dist LIMIT 1;
        
        RETURN NEXT mk_geores( record );        
        RETURN;
    ELSE
        --
        -- Places Table Search
        --
        IF mCat IS NOT NULL AND mOwnr IS NOT NULL THEN
            FOR record IN 
            SELECT '' AS todofuken, '' AS shikuchoson, 
                '' AS ooaza, '' AS chiban,
                lon, lat,
                name::text AS address,
                st_distance(st_setsrid(st_makepoint( mLon,mLat),4326)::geography,geog) AS dist 
            FROM places  
            WHERE owner = mOwnr AND category = mCat AND 
                st_dwithin(st_setsrid(st_makepoint(mLon,mLat),4326)::geography,geog,mDist) 
            ORDER BY dist LIMIT mLimit LOOP
            
            RETURN NEXT mk_geores( record ); 
            
            END LOOP;
        ELSIF mCat IS NOT NULL AND mOwnr IS NULL THEN
            FOR record IN
            SELECT '' AS todofuken, '' AS shikuchoson, 
                '' AS ooaza, '' AS chiban,
                lon, lat,
                name::text AS address,
                st_distance(st_setsrid(st_makepoint( mLon,mLat),4326)::geography,geog) AS dist 
            FROM places  
            WHERE category = mCat AND 
                st_dwithin(st_setsrid(st_makepoint(mLon,mLat),4326)::geography,geog,mDist) 
            ORDER BY dist LIMIT mLimit LOOP
            
            RETURN NEXT mk_geores( record ); 
            
            END LOOP;        
        
        ELSIF mCat IS NULL AND mOwnr IS NOT NULL THEN
            FOR record IN 
            SELECT '' AS todofuken, '' AS shikuchoson, 
                '' AS ooaza, '' AS chiban,
                lon, lat,
                name::text AS address,
                st_distance(st_setsrid(st_makepoint( mLon,mLat),4326)::geography,geog) AS dist 
            FROM places  
            WHERE owner = mOwnr AND  
                st_dwithin(st_setsrid(st_makepoint(mLon,mLat),4326)::geography,geog,mDist) 
            ORDER BY dist LIMIT mLimit LOOP
            
            RETURN NEXT mk_geores( record ); 
            
            END LOOP;                
        
        ELSE
            FOR record IN
            SELECT '' AS todofuken, '' AS shikuchoson, 
                '' AS ooaza, '' AS chiban,
                lon, lat,
                name::text AS address,
                st_distance(st_setsrid(st_makepoint( mLon,mLat),4326)::geography,geog) AS dist 
            FROM places  
            WHERE st_dwithin(st_setsrid(st_makepoint(mLon,mLat),4326)::geography,geog,mDist) 
            ORDER BY dist LIMIT mLimit LOOP
            
            RETURN NEXT mk_geores( record ); 
            
            END LOOP;        
        END IF;
        
    END IF;
    
END;
$$ LANGUAGE plpgsql;
  
