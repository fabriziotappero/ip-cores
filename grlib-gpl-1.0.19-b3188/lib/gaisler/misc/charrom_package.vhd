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
-- Package:     charrom_package
-- File:        charrom_package.vhd
-- Author:      Marcus Hellqvist
-- Description: Charrom types and component
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.stdlib.all;

package charrom_package is

type rom_type is record
 addr           : std_logic_vector(11 downto 0);
 data           : std_logic_vector(7 downto 0);
end record;

component charrom
  port(
    clk         : in std_ulogic;
    addr        : in std_logic_vector(11 downto 0);
    data        : out std_logic_vector(7 downto 0)
    );
end component;

end package;
