----------------------------------------------------------------------
----                                                              ----
---- Vertical V4 clock generator                                  ----
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

entity video_clk_gen_v4 is
Generic (
   POLARITY                : natural := 1);                       -- Define polarity of the output clock signal
port (
   CLK                     : in     std_logic;                    -- Input clock
   RST                     : in     std_logic;                    -- System reset
   CLK_OUT                 : out    std_logic);
end video_clk_gen_v4;

-----------------------------------------------------------------------------
-- Architecture section
-----------------------------------------------------------------------------
architecture implementation of video_clk_gen_v4 is

constant gnd            : std_logic := '0';
constant vcc            : std_logic := '1';

component ODDR
port (
   Q                    : out    std_logic;
   D1                   : in     std_logic;
   D2                   : in     std_logic;      	
   C                    : in     std_logic;
   CE                   : in     std_logic;
   R                    : in     std_logic;
   S                    : in     std_logic);
end component;

signal clk_n               : std_logic;
signal d0_i                : std_logic;
signal d1_i                : std_logic;

BEGIN

clk_n <= Not clk;
d0_i <= '1' When POLARITY = 1 Else '0';
d1_i <= '0' When POLARITY = 1 Else '1';

GEN_PIXEL_CLK : ODDR
port map (
   Q        => CLK_OUT,
   D1       => d0_i,
   D2       => d1_i,
   C        => clk,      	
   CE       => vcc,
   R        => gnd,
   S        => gnd);

end implementation;
