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
-- Entity: 	iodpad
-- File:	iodpad.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	Open-drain I/O pad with technology wrapper
------------------------------------------------------------------------------

library ieee;
library techmap;
use ieee.std_logic_1164.all;
use techmap.gencomp.all;
use techmap.allpads.all;

entity iodpad is
  generic (tech : integer := 0; level : integer := 0; slew : integer := 0;
	   voltage : integer := x33v; strength : integer := 12;
	   oepol : integer := 0);
  port (pad : inout std_ulogic; i : in std_ulogic; o : out std_ulogic);
end; 

architecture rtl of iodpad is
signal gnd, oen : std_ulogic;
begin
  oen <= not i when oepol /= padoen_polarity(tech) else i;
  gnd <= '0';
  gen0 : if has_pads(tech) = 0 generate
    pad <= '0' after 2 ns when oen = '0' 
-- pragma translate_off
           else 'X' after 2 ns when is_x(i) 
-- pragma translate_on
           else 'Z' after 2 ns;
    o <= to_X01(pad) after 1 ns;
  end generate;
  xcv : if (tech = virtex) or (tech = virtex2) or (tech = spartan3) 
	or (tech = spartan3e) or (tech = virtex4) or (tech = virtex5) 
  generate
    x0 : virtex_iopad generic map (level, slew, voltage, strength) 
	 port map (pad, gnd, oen, o);
  end generate;
  axc : if (tech = axcel) or (tech = proasic) or (tech = apa3) generate
    x0 : axcel_iopad generic map (level, slew, voltage, strength) 
	 port map (pad, gnd, oen, o);
  end generate;
  atc : if (tech = atc18s) generate
    x0 : atc18_iopad generic map (level, slew, voltage, strength) 
	 port map (pad, gnd, oen, o);
  end generate;
  atcrh : if (tech = atc18rha) generate
    x0 : atc18rha_iopad generic map (level, slew, voltage, strength) 
	 port map (pad, gnd, oen, o);
  end generate;
  um : if (tech = umc) generate
    x0 : umc_iopad generic map (level, slew, voltage, strength) 
	 port map (pad, gnd, oen, o);
  end generate;
  rhu : if (tech = rhumc) generate
    x0 : rhumc_iopad generic map (level, slew, voltage, strength) 
	 port map (pad, gnd, oen, o);
  end generate;
  ihp : if (tech = ihp25) generate
    x0 : ihp25_iopad generic map (level, slew, voltage, strength)
         port map (pad, gnd, oen, o);
    end generate;
  rh18t : if (tech = rhlib18t) generate
    x0 : rh_lib18t_iopad generic map (strength)
         port map (pad, gnd, oen, o);
    end generate;
  ut025 : if (tech = ut25) generate
    x0 : ut025crh_iopad generic map (strength)
         port map (pad, gnd, oen, o);
    end generate;
  pere  : if (tech = peregrine) generate
    x0 : peregrine_iopad generic map (level, slew, voltage, strength)
         port map(pad, gnd, oen, o);
  end generate; 
end;

library ieee;
library techmap;
use ieee.std_logic_1164.all;
use techmap.gencomp.all;

entity iodpadv is
  generic (tech : integer := 0; level : integer := 0; slew : integer := 0;
	voltage : integer := 0; strength : integer := 0; width : integer := 1;
	oepol : integer := 0);
  port (
    pad : inout std_logic_vector(width-1 downto 0); 
    i   : in  std_logic_vector(width-1 downto 0);
    o   : out std_logic_vector(width-1 downto 0));
end; 
architecture rtl of iodpadv is
begin
  v : for j in width-1 downto 0 generate
    x0 : iodpad generic map (tech, level, slew, voltage, strength, oepol) 
	 port map (pad(j), i(j), o(j));
  end generate;
end;
