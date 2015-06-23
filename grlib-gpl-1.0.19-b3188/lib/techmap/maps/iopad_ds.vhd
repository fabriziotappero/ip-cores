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
-- Entity: 	iopad
-- File:	iopad.vhd
-- Author:	Nils Johan Wessman - Gaisler Research
-- Description:	differential io pad with technology wrapper
------------------------------------------------------------------------------

library techmap;
library ieee;
use ieee.std_logic_1164.all;
use techmap.gencomp.all;
use techmap.allpads.all;

entity iopad_ds is
  generic (tech : integer := 0; level : integer := 0; slew : integer := 0;
	   voltage : integer := x33v; strength : integer := 12;
	   oepol : integer := 0);
  port (padp, padn : inout std_ulogic; i, en : in std_ulogic; o : out std_ulogic);
end; 

architecture rtl of iopad_ds is
signal oen : std_ulogic;
begin
  oen <= not en when oepol /= padoen_polarity(tech) else en;
  gen0 : if has_pads(tech) = 0 generate
    padp <= i after 2 ns when oen = '0' 
-- pragma translate_off
           else 'X' after 2 ns when is_x(oen) 
-- pragma translate_on
           else 'Z' after 2 ns;
    padn <= not i after 2 ns when oen = '0' 
-- pragma translate_off
           else 'X' after 2 ns when is_x(oen) 
-- pragma translate_on
           else 'Z' after 2 ns;
    o <= to_X01(padp) after 1 ns;
  end generate;
  xcv : if (tech = virtex5) generate
    x0 : virtex5_iopad_ds generic map (level, slew, voltage, strength) 
	 port map (padp, padn, i, oen, o);
  end generate;
end;

library techmap;
library ieee;
use ieee.std_logic_1164.all;
use techmap.gencomp.all;

entity iopad_dsv is
  generic (tech : integer := 0; level : integer := 0; slew : integer := 0;
	voltage : integer := x33v; strength : integer := 12; width : integer := 1;
	oepol : integer := 0);
  port (
    padp, padn : inout std_logic_vector(width-1 downto 0); 
    i   : in  std_logic_vector(width-1 downto 0);
    en  : in  std_ulogic;
    o   : out std_logic_vector(width-1 downto 0));
end; 
architecture rtl of iopad_dsv is
begin
  v : for j in width-1 downto 0 generate
    x0 : iopad_ds generic map (tech, level, slew, voltage, strength, oepol) 
	 port map (padp(j), padn(j), i(j), en, o(j));
  end generate;
end;

library techmap;
library ieee;
use ieee.std_logic_1164.all;
use techmap.gencomp.all;

entity iopad_dsvv is
  generic (tech : integer := 0; level : integer := 0; slew : integer := 0;
	voltage : integer := x33v; strength : integer := 12; width : integer := 1;
	oepol : integer := 0);
  port (
    padp, padn : inout std_logic_vector(width-1 downto 0); 
    i   : in  std_logic_vector(width-1 downto 0);
    en  : in  std_logic_vector(width-1 downto 0);
    o   : out std_logic_vector(width-1 downto 0));
end; 
architecture rtl of iopad_dsvv is
begin
  v : for j in width-1 downto 0 generate
    x0 : iopad_ds generic map (tech, level, slew, voltage, strength, oepol) 
	 port map (padp(j), padn(j), i(j), en(j), o(j));
  end generate;
end;
