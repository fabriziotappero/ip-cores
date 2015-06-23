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
-- Entity: 	inpad_ds
-- File:	inpad_ds.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	input pad with technology wrapper
------------------------------------------------------------------------------

library techmap;
library ieee;
use ieee.std_logic_1164.all;
use techmap.gencomp.all;
use techmap.allpads.all;

entity inpad_ds is
  generic (tech : integer := 0; level : integer := lvds; voltage : integer := x33v);
  port (padp, padn : in std_ulogic; o : out std_ulogic);
end; 

architecture rtl of inpad_ds is
signal gnd : std_ulogic;
begin
  gnd <= '0';
  gen0 : if has_ds_pads(tech) = 0 generate
    o <= to_X01(padp) after 1 ns;
  end generate;
  xcv : if (tech = virtex) or (tech = virtex2) or (tech = spartan3) generate
    u0 : virtex_inpad_ds generic map (level, voltage) port map (padp, padn, o);
  end generate;
  xc4v : if (tech = virtex4) or (tech = spartan3e) or (tech = virtex5) generate
    u0 : virtex4_inpad_ds generic map (level, voltage) port map (padp, padn, o);
  end generate;
  axc : if (tech = axcel) generate
    u0 : axcel_inpad_ds generic map (level, voltage) port map (padp, padn, o);
  end generate;
  rht : if (tech = rhlib18t) generate
    u0 : rh_lib18t_inpad_ds port map (padp, padn, o, gnd);
  end generate;
end;

library techmap;
library ieee;
use ieee.std_logic_1164.all;
use techmap.gencomp.all;

entity inpad_dsv is
  generic (tech : integer := 0; level : integer := lvds; 
	   voltage : integer := x33v; width : integer := 1);
  port (
    padp : in  std_logic_vector(width-1 downto 0); 
    padn : in  std_logic_vector(width-1 downto 0); 
    o   : out std_logic_vector(width-1 downto 0));
end; 
architecture rtl of inpad_dsv is
begin
  v : for i in width-1 downto 0 generate
    u0 : inpad_ds generic map (tech, level, voltage) port map (padp(i), padn(i), o(i));
  end generate;
end;
