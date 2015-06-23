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
-- Entity:      ddr_ec
-- File:        ddr_ec.vhd
-- Author:      Jiri Gaisler - Gaisler Research
-- Description: Lattice DDR regs
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

-- pragma translate_off
library ec;
use ec.ODDRXB;
--pragma translate_on


entity ec_oddr_reg is
  port
    ( Q : out std_ulogic;
      C1 : in std_ulogic;
      C2 : in std_ulogic;
      CE : in std_ulogic;
      D1 : in std_ulogic;
      D2 : in std_ulogic;
      R : in std_ulogic;
      S : in std_ulogic);
end;

architecture rtl of ec_oddr_reg is

  component ODDRXB
    port(
          DA            :       in      STD_LOGIC;
          DB            :       in      STD_LOGIC;
          CLK           :       in      STD_LOGIC;
          LSR           :       in      STD_LOGIC;
          Q             :       out     STD_LOGIC
        );
  end component;

begin

  U0 : ODDRXB port map( DA => D1, DB => D2, CLK => C1, LSR => R, Q => Q);

end;
