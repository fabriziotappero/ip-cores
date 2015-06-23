------------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2003, Gaisler Research
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 
-----------------------------------------------------------------------------   
-- Entity:      tap
-- File:        tap.vhd
-- Author:      Edvin Catovic - Gaisler Research
-- Description: TAP controller technology wrapper
------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
library techmap;
use techmap.gencomp.all;
use techmap.alltap.all;
library grlib;
use grlib.stdlib.all;

entity tap is
  generic (
    tech   : integer := 0;    
    irlen  : integer range 2 to 8 := 4;
    idcode : integer range 0 to 255 := 9;
    manf   : integer range 0 to 2047 := 804;
    part   : integer range 0 to 65535 := 0;
    ver    : integer range 0 to 15 := 0;
    trsten : integer range 0 to 1 := 1;
    scantest : integer := 0);
  port (
    trst        : in std_ulogic;
    tck         : in std_ulogic;
    tms         : in std_ulogic;
    tdi         : in std_ulogic;
    tdo         : out std_ulogic;
    tapo_tck    : out std_ulogic;
    tapo_tdi    : out std_ulogic;
    tapo_inst   : out std_logic_vector(7 downto 0);
    tapo_rst    : out std_ulogic;
    tapo_capt   : out std_ulogic;
    tapo_shft   : out std_ulogic;
    tapo_upd    : out std_ulogic;
    tapo_xsel1  : out std_ulogic;
    tapo_xsel2  : out std_ulogic;
    tapi_en1    : in std_ulogic;
    tapi_tdo1   : in std_ulogic;
    tapi_tdo2   : in std_ulogic;
    testen      : in std_ulogic := '0';
    testrst     : in std_ulogic := '1';
    tdoen       : out std_ulogic    
    );
end;


architecture rtl of tap is
signal tckn, ltck, ltckn : std_ulogic;
begin
  
   xcv : if tech = virtex generate
     u0 : virtex_tap port map (tapi_tdo1, tapi_tdo1, tapo_tck, tapo_tdi, tapo_rst,   
                                tapo_capt, tapo_shft, tapo_upd, tapo_xsel1, tapo_xsel2);
   end generate;

   xc2v : if tech = virtex2 generate
     u0 : virtex2_tap port map (tapi_tdo1, tapi_tdo1, tapo_tck, tapo_tdi, tapo_rst,   
                                tapo_capt, tapo_shft, tapo_upd, tapo_xsel1, tapo_xsel2);
   end generate;

   xc4v : if tech = virtex4 generate
     u0 : virtex4_tap port map (tapi_tdo1, tapi_tdo1, tapo_tck, tapo_tdi, tapo_rst,   
                                tapo_capt, tapo_shft, tapo_upd, tapo_xsel1, tapo_xsel2);
   end generate;   

   xc5v : if tech = virtex5 generate
     u0 : virtex5_tap port map (tapi_tdo1, tapi_tdo1, tapo_tck, tapo_tdi, tapo_rst,   
                                tapo_capt, tapo_shft, tapo_upd, tapo_xsel1, tapo_xsel2);
   end generate;   

   xc3s : if (tech = spartan3) or (tech = spartan3e) generate  
     u0 : spartan3_tap port map (tapi_tdo1, tapi_tdo1, tapo_tck, tapo_tdi, tapo_rst,   
                                tapo_capt, tapo_shft, tapo_upd, tapo_xsel1, tapo_xsel2);
   end generate;

  alt : if (tech = altera) or (tech = stratix1) or (tech = stratix2) or
	(tech = stratix3) or (tech = cyclone3) generate
     u0 : altera_tap port map (tapi_tdo1, tapi_tdo1, tapo_tck, tapo_tdi, tapo_inst, tapo_rst,   
                                tapo_capt, tapo_shft, tapo_upd, tapo_xsel1, tapo_xsel2);
   end generate;

   actpa3 : if (tech = apa3) generate
     u0 : proasic3_tap port map (tck, tms, tdi, trst, tdo,
       tapi_tdo1, tapi_tdo2, tapi_en1, tapo_tck, tapo_tdi, tapo_rst,
                                 tapo_capt, tapo_shft, tapo_upd, tapo_inst);
   end generate;
   
   inf : if (tech /= virtex2) and (tech /= spartan3) and (tech /= spartan3e) 
	and (tech /= virtex) and (tech /= virtex4) and (tech /= virtex5) and
            (tech /= altera) and (tech /= stratix1)  and (tech /= stratix2) and
            (tech /= stratix3)  and (tech /= cyclone3) and (tech /= apa3)
   generate
   asic : if is_fpga(tech) = 0 generate
     tckn <= tck when (scantest = 1) and (testen = '1') else not tck;
     pclk : techbuf generic map (tech => tech) port map (tck, ltck);
     nclk : techbuf generic map (tech => tech) port map (tckn, ltckn);
   end generate;
   fpga : if is_fpga(tech) = 1 generate
     ltck <= tck; ltckn <= not tck;
   end generate;
      u0 : tap_gen generic map (irlen => irlen,  manf => manf, part => part, ver => ver,
		idcode => idcode, scantest => scantest)
        port map (trst, ltck, ltckn, tms, tdi, tdo, tapi_en1, tapi_tdo1, tapi_tdo2, tapo_tck,
                  tapo_tdi, tapo_inst, tapo_rst, tapo_capt, tapo_shft, tapo_upd, tapo_xsel1,
                  tapo_xsel2, testen, testrst, tdoen);
   end generate;
  
end;  
