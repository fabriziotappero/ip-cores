----------------------------------------------------------------------
----                                                              ----
---- Shift register                                               ----
----                                                              ----
---- Author(s):                                                   ----
---- - Slavek Valach, s.valach@dspfpga.com                        ----
----                                                              ----
----------------------------------------------------------------------
----                                                              ----
---- Copyright (C) 2008 Authors and OPENCORES.ORG                 ----
----                                                              ----
---- This source file may be used and distributed without         ----
---- restriction provided that this copyright statement is not    ----
---- removed from the file and that any derivative work contains  ----
---- the original copyright notice and the associated disclaimer. ----
----                                                              ----
---- This source file is free software; you can redistribute it   ----
---- and/or modify it under the terms of the GNU General          ----
---- Public License as published by the Free Software Foundation; ----
---- either version 2.0 of the License, or (at your option) any   ----
---- later version.                                               ----
----                                                              ----
---- This source is distributed in the hope that it will be       ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied   ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ----
---- PURPOSE. See the GNU General Public License for more details.----
----                                                              ----
---- You should have received a copy of the GNU General           ----
---- Public License along with this source; if not, download it   ----
---- from http://www.gnu.org/licenses/gpl.txt                     ----
----                                                              ----
----------------------------------------------------------------------

library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.all; 

-------------------------------------------------------------------------------
-- Entity section
-----------------------------------------------------------------------------

entity delay is
port (
   CLK                     : in     std_logic;                    -- Input clock
   ADD_DELAY               : in     std_logic_vector(3 downto 0);
   D_IN                    : in     std_logic;
   D_OUT                   : out    std_logic);
end delay;

-----------------------------------------------------------------------------
-- Architecture section
-----------------------------------------------------------------------------
architecture implementation of delay is

constant gnd            : std_logic := '0';
constant vcc            : std_logic := '1';

BEGIN

SRL16_I : SRL16
   -- pragma translate_off
generic map (
   INIT => x"0000")
   -- pragma translate_on
port map (
   D     => D_IN,
   Clk   => Clk,
   A0    => ADD_DELAY(0),
   A1    => ADD_DELAY(1),
   A2    => ADD_DELAY(2),
   A3    => ADD_DELAY(3),
   Q     => D_OUT);

end implementation;
