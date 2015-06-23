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
-- Entity: 	syncram_2p
-- File:	syncram_2p.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	syncronous 2-port ram with tech selection
------------------------------------------------------------------------------

library ieee;
library techmap;
use ieee.std_logic_1164.all;
use techmap.gencomp.all;
use work.allmem.all;

entity syncram_2p is
  generic (tech : integer := 0; abits : integer := 6; dbits : integer := 8;
	sepclk : integer := 0; wrfst : integer := 0);
  port (
    rclk     : in std_ulogic;
    renable  : in std_ulogic;
    raddress : in std_logic_vector((abits -1) downto 0);
    dataout  : out std_logic_vector((dbits -1) downto 0);
    wclk     : in std_ulogic;
    write    : in std_ulogic;
    waddress : in std_logic_vector((abits -1) downto 0);
    datain   : in std_logic_vector((dbits -1) downto 0);
    testin   : in std_logic_vector(3 downto 0) := "0000");
end;

architecture rtl of syncram_2p is
  
signal vcc, gnd : std_ulogic;
signal vgnd : std_logic_vector(dbits-1 downto 0);
signal diagin  : std_logic_vector(3 downto 0);
begin

  vcc <= '1'; gnd <= '0'; vgnd <= (others => '0');
  diagin <= (others => '0');

  inf : if tech = inferred generate 
    x0 : generic_syncram_2p generic map (abits, dbits, sepclk)
         port map (rclk, wclk, raddress, waddress, datain, write, dataout);
  end generate;

  xcv : if tech = virtex generate 
    x0 : virtex_syncram_dp generic map (abits, dbits)
         port map (wclk, waddress, datain, open, write, write, 
                   rclk, raddress, vgnd, dataout, renable, gnd);
  end generate;

  xc2v : if (tech = virtex2) or (tech = spartan3) or (tech =virtex4) 
	or (tech = spartan3e) or (tech = virtex5)
  generate
    x0 : virtex2_syncram_2p generic map (abits, dbits, sepclk, wrfst)
         port map (rclk, renable, raddress, dataout, wclk, 
		   write, waddress, datain);
  end generate;  

  vir  : if tech = memvirage generate 
   d39 : if dbits = 39 generate
    x0 : virage_syncram_2p generic map (abits, dbits, sepclk)
         port map (rclk, renable, raddress, dataout, 
		   wclk, write, waddress, datain);
   end generate;
   d32 : if dbits <= 32 generate
    x0 : virage_syncram_dp generic map (abits, dbits)
         port map (wclk, waddress, datain, open, write, write, 
                   rclk, raddress, vgnd, dataout, renable, gnd);
   end generate;
  end generate;

  atrh : if tech = atc18rha generate 
    x0 : atc18rha_syncram_2p generic map (abits, dbits, sepclk)
         port map (rclk, renable, raddress, dataout, 
		   wclk, write, waddress, datain, testin);
  end generate;

  axc  : if tech = axcel generate 
    x0 : axcel_syncram_2p generic map (abits, dbits)
         port map (rclk, renable, raddress, dataout, 
		   wclk, waddress, datain, write);
  end generate;

  proa : if tech = proasic generate 
    x0 : proasic_syncram_2p generic map (abits, dbits)
         port map (rclk, renable, raddress, dataout, 
		   wclk, waddress, datain, write);
  end generate;

  proa3 : if tech = apa3 generate 
    x0 : proasic3_syncram_2p generic map (abits, dbits)
         port map (rclk, renable, raddress, dataout, 
		   wclk, waddress, datain, write);
  end generate;

  ihp : if tech = ihp25 generate
    x0 : generic_syncram_2p generic map (abits, dbits, sepclk)
         port map (rclk, wclk, raddress, waddress, datain, write, dataout);
  end generate; 

-- NOTE: port 1 on altsyncram must be a read port due to Cyclone II M4K write issue
  alt : if (tech = altera) or (tech = stratix1) or (tech = stratix2) or
	(tech = stratix3) or (tech = cyclone3) generate
    x0 : altera_syncram_dp generic map (abits, dbits)
         port map (rclk, raddress, vgnd, dataout, renable, gnd,
                   wclk, waddress, datain, open, write, write);
  end generate;

  rh_lib18t0 : if tech = rhlib18t generate
    x0 : rh_lib18t_syncram_2p generic map (abits, dbits)
         port map (rclk, renable, raddress, dataout, write, waddress, datain, diagin);
  end generate; 

  lat : if tech = lattice generate
    x0 : ec_syncram_dp generic map (abits, dbits)
         port map (wclk, waddress, datain, open, write, write,
                   rclk, raddress, vgnd, dataout, renable, gnd);
  end generate;

  ut025 : if tech = ut25 generate 
    x0 : ut025crh_syncram_2p generic map (abits, dbits)
         port map (rclk, renable, raddress, dataout, 
		   wclk, waddress, datain, write);
  end generate;

  arti : if tech = memartisan generate 
    x0 : artisan_syncram_2p generic map (abits, dbits)
         port map (rclk, renable, raddress, dataout, 
		   wclk, write, waddress, datain);
  end generate;

  cust1 : if tech = custom1 generate 
    x0 : custom1_syncram_2p generic map (abits, dbits)
         port map (rclk, renable, raddress, dataout, 
		   wclk, write, waddress, datain);
  end generate;

  ecl : if tech = eclipse generate 
    x0 : eclipse_syncram_2p generic map (abits, dbits)
         port map (rclk, renable, raddress, dataout, 
		   wclk, waddress, datain, write);
  end generate;

  vir90  : if tech = memvirage90 generate 
    x0 : virage90_syncram_dp generic map (abits, dbits)
         port map (wclk, waddress, datain, open, write, write, 
                   rclk, raddress, vgnd, dataout, renable, gnd);
  end generate;  

  nex : if tech = easic90 generate 
    x0 : nextreme_syncram_2p generic map (abits, dbits)
         port map (rclk, renable, raddress, dataout, 
		   wclk, write, waddress, datain);
  end generate;  

-- pragma translate_off
  noram : if has_2pram(tech) = 0 generate
    x : process
    begin 
      assert false report "synram_2p: technology " & tech_table(tech) &
	" not supported"
      severity failure;
      wait;
    end process;
  end generate; 
-- pragma translate_on

end;

