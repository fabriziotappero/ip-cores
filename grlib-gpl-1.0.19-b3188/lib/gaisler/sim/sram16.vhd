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
-- Entity: 	sram16
-- File:	sram16.vhd
-- Author:	Jiri Gaisler Gaisler Research
-- Description:	Simulation model of generic 16-bit async SRAM
------------------------------------------------------------------------------

-- pragma translate_off

library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;

library gaisler;
use gaisler.sim.all;
library grlib;
use grlib.stdlib.all;

entity sram16 is
  generic (
    index : integer := 0;		-- Byte lane (0 - 3)
    abits: Positive := 10;		-- Default 10 address bits (1 Kbyte)
    echk : integer := 0;		-- Generate EDAC checksum
    tacc : integer := 10;		-- access time (ns)
    fname : string := "ram.dat");	-- File to read from
  port (  
    a : in std_logic_vector(abits-1 downto 0);
    d : inout std_logic_vector(15 downto 0);
    lb : in std_logic;
    ub : in std_logic;
    ce : in std_logic;
    we : in std_ulogic;
    oe : in std_ulogic);
end;     


architecture sim of sram16 is

signal cex : std_logic_vector(0 to 1);

begin

  cex(0) <= ce or lb; cex(1) <= ce or ub;

  sr0 : sram generic map (index+1, abits, tacc, fname)
	port map (a, d(7 downto 0), cex(0), we, oe);

  sr1 : sram generic map (index, abits, tacc, fname)
	port map (a, d(15 downto 8), cex(1), we, oe);

end sim;
-- pragma translate_on
