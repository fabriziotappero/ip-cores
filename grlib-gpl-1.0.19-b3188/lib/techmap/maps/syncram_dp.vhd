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
-- Entity: 	syncram_dp
-- File:	syncram_dp.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	syncronous dual-port ram with tech selection
------------------------------------------------------------------------------

library ieee;
library techmap;
use ieee.std_logic_1164.all;
use techmap.gencomp.all;
use work.allmem.all;

entity syncram_dp is
  generic (tech : integer := 0; abits : integer := 6; dbits : integer := 8 );
  port (
    clk1     : in std_ulogic;
    address1 : in std_logic_vector((abits -1) downto 0);
    datain1  : in std_logic_vector((dbits -1) downto 0);
    dataout1 : out std_logic_vector((dbits -1) downto 0);
    enable1  : in std_ulogic;
    write1   : in std_ulogic;
    clk2     : in std_ulogic;
    address2 : in std_logic_vector((abits -1) downto 0);
    datain2  : in std_logic_vector((dbits -1) downto 0);
    dataout2 : out std_logic_vector((dbits -1) downto 0);
    enable2  : in std_ulogic;
    write2   : in std_ulogic; 
    testin   : in std_logic_vector(3 downto 0) := "0000");
end;

architecture rtl of syncram_dp is
begin

-- pragma translate_off
  inf : if has_dpram(tech) = 0 generate 
    x : process
    begin
      assert false report "synram_dp: technology " & tech_table(tech) &
	" not supported"
      severity failure;
      wait;
    end process;
  end generate;
-- pragma translate_on

  xcv : if tech = virtex generate 
    x0 : virtex_syncram_dp generic map (abits, dbits)
         port map (clk1, address1, datain1, dataout1, enable1, write1, 
                   clk2, address2, datain2, dataout2, enable2, write2);
  end generate;

  xc2v : if (tech = virtex2) or (tech = spartan3) or (tech = virtex4) 
	or (tech = spartan3e) or (tech = virtex5) 
  generate 
    x0 : virtex2_syncram_dp generic map (abits, dbits)
         port map (clk1, address1, datain1, dataout1, enable1, write1, 
                   clk2, address2, datain2, dataout2, enable2, write2);
  end generate;

  vir  : if tech = memvirage generate 
    x0 : virage_syncram_dp generic map (abits, dbits)
         port map (clk1, address1, datain1, dataout1, enable1, write1, 
                   clk2, address2, datain2, dataout2, enable2, write2);
  end generate;

  arti : if tech = memartisan generate 
    x0 : artisan_syncram_dp generic map (abits, dbits)
         port map (clk1, address1, datain1, dataout1, enable1, write1, 
                   clk2, address2, datain2, dataout2, enable2, write2);
  end generate;

  axc  : if tech = axcel generate 
    x0 : axcel_syncram_2p generic map (abits, dbits)
    port map (clk1, enable1, address1, dataout1, clk1, address1, datain1, write1);
    x1 : axcel_syncram_2p generic map (abits, dbits)
    port map (clk1, enable2, address2, dataout2, clk1, address1, datain1, write1);
  end generate;

  pa3  : if tech = apa3 generate 
    x0 : proasic3_syncram_dp generic map (abits, dbits)
         port map (clk1, address1, datain1, dataout1, enable1, write1, 
                   clk2, address2, datain2, dataout2, enable2, write2);
  end generate;
  
  alt : if (tech = altera) or (tech = stratix1) or (tech = stratix2) or
	(tech = stratix3) or (tech = cyclone3) generate
    x0 : altera_syncram_dp generic map (abits, dbits)
         port map (clk1, address1, datain1, dataout1, enable1, write1, 
                   clk2, address2, datain2, dataout2, enable2, write2);
  end generate;
  
  lat  : if tech = lattice generate 
    x0 : ec_syncram_dp generic map (abits, dbits)
         port map (clk1, address1, datain1, dataout1, enable1, write1, 
                   clk2, address2, datain2, dataout2, enable2, write2);
  end generate;

  vir90  : if tech = memvirage90 generate 
    x0 : virage90_syncram_dp generic map (abits, dbits)
         port map (clk1, address1, datain1, dataout1, enable1, write1, 
                   clk2, address2, datain2, dataout2, enable2, write2);
  end generate;
  
  atrh : if tech = atc18rha generate 
    x0 : atc18rha_syncram_dp generic map (abits, dbits)
         port map (clk1, address1, datain1, dataout1, enable1, write1, 
                   clk2, address2, datain2, dataout2, enable2, write2, testin);
  end generate;
end;

