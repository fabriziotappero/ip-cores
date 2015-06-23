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
-- Package: 	cpu_disasx
-- File:	cpu_disasx.vhd
-- Author:	Jiri Gaisler, Gaisler Research
-- Description:	SPARC disassembler according to SPARC V8 manual 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
-- pragma translate_off
library grlib;
use grlib.cpu_disas;
-- pragma translate_on

entity cpu_disasx is
port (
  clk   : in std_ulogic;
  rstn  : in std_ulogic;
  dummy : out std_ulogic;
  inst  : in std_logic_vector(31 downto 0);
  pc    : in std_logic_vector(31 downto 2);
  result: in std_logic_vector(31 downto 0);
  index : in std_logic_vector(3 downto 0);
  wreg  : in std_ulogic;
  annul : in std_ulogic;
  holdn : in std_ulogic;
  pv    : in std_ulogic;
  trap  : in std_ulogic;
  disas : in std_ulogic);
end;

architecture behav of cpu_disasx is
component cpu_disas
port (
  clk   : in std_ulogic;
  rstn  : in std_ulogic;
  dummy : out std_ulogic;
  inst  : in std_logic_vector(31 downto 0);
  pc    : in std_logic_vector(31 downto 2);
  result: in std_logic_vector(31 downto 0);
  index : in std_logic_vector(3 downto 0);
  wreg  : in std_ulogic;
  annul : in std_ulogic;
  holdn : in std_ulogic;
  pv    : in std_ulogic;
  trap  : in std_ulogic;
  disas : in std_ulogic);
end component;

begin

  u0 : cpu_disas
  port map (clk, rstn, dummy, inst, pc, result, index, wreg, annul, holdn, pv, trap, disas);

end;
