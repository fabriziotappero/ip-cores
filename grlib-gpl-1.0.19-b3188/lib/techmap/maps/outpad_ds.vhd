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
-- Entity: 	outpad_ds
-- File:	outpad_ds.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	Differential output pad with technology wrapper
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library techmap;
use techmap.gencomp.all;
use techmap.allpads.all;

entity outpad_ds is
  generic (tech : integer := 0; level : integer := lvds; 
	voltage : integer := x33v; oepol : integer := 0);
  port (padp, padn : out std_ulogic; i, en : in std_ulogic);
end; 

architecture rtl of outpad_ds is
signal gnd, oen : std_ulogic;
begin
  gnd <= '0';
  oen <= not en when oepol /= padoen_polarity(tech) else en;
  gen0 : if has_ds_pads(tech) = 0 generate
    padp <= i after 1 ns;
    padn <= not i after 1 ns;
  end generate;
  xcv : if (tech = virtex) or (tech = virtex2) or (tech = spartan3) or
	(tech = virtex4) or (tech = spartan3e)
  generate
    u0 : virtex_outpad_ds generic map (level, voltage) port map (padp, padn, i);
  end generate;
  xcv5 : if (tech = virtex5) generate
    u0 : virtex5_outpad_ds generic map (level, voltage) port map (padp, padn, i);
  end generate;
  axc : if (tech = axcel) generate
    u0 : axcel_outpad_ds generic map (level, voltage) port map (padp, padn, i);
  end generate;
  rht : if (tech = rhlib18t) generate
    u0 : rh_lib18t_outpad_ds port map (padp, padn, i, oen);
  end generate;
end;

library ieee;
use ieee.std_logic_1164.all;
library techmap;
use techmap.gencomp.all;

entity outpad_dsv is
  generic (tech : integer := 0; level : integer := x33v;
	voltage : integer := lvds; width : integer := 1;
	oepol : integer := 0);
  port (
    padp : out std_logic_vector(width-1 downto 0); 
    padn : out std_logic_vector(width-1 downto 0); 
    i, en: in  std_logic_vector(width-1 downto 0));
end; 
architecture rtl of outpad_dsv is
begin
  v : for j in width-1 downto 0 generate
    u0 : outpad_ds generic map (tech, level, voltage, oepol) 
	 port map (padp(j), padn(j), i(j), en(j));
  end generate;
end;
