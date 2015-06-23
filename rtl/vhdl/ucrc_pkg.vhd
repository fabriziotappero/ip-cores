----------------------------------------------------------------------
----                                                              ----
---- Ultimate CRC.                                                ----
----                                                              ----
---- This file is part of the ultimate CRC projectt               ----
---- http://www.opencores.org/cores/ultimate_crc/                 ----
----                                                              ----
---- Description                                                  ----
---- Ultimate CRC component declarations.                         ----
----                                                              ----
----                                                              ----
---- To Do:                                                       ----
---- -                                                            ----
----                                                              ----
---- Author(s):                                                   ----
---- - Geir Drange, gedra@opencores.org                           ----
----                                                              ----
----------------------------------------------------------------------
----                                                              ----
---- Copyright (C) 2005 Authors and OPENCORES.ORG                 ----
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
--
-- CVS Revision History
--
-- $Log: not supported by cvs2svn $
-- Revision 1.1  2005/05/09 15:56:14  gedra
-- Component declarations
--
--
--

library ieee;
use ieee.std_logic_1164.all;

package ucrc_pkg is

   component ucrc_ser
      generic (
         POLYNOMIAL : std_logic_vector;       -- 4 to 32 bits
         INIT_VALUE : std_logic_vector;
         SYNC_RESET : integer range 0 to 1);  -- use synchronous reset
      port (
         clk_i   : in  std_logic;       -- clock
         rst_i   : in  std_logic;       -- init CRC
         clken_i : in  std_logic;       -- clock enable
         data_i  : in  std_logic;       -- data input
         flush_i : in  std_logic;       -- flush crc
         match_o : out std_logic;       -- CRC match flag
         crc_o   : out std_logic_vector(POLYNOMIAL'length - 1 downto 0));  -- CRC output
   end component;

   component ucrc_par
      generic (
         POLYNOMIAL : std_logic_vector;
         INIT_VALUE : std_logic_vector;
         DATA_WIDTH : integer range 2 to 256;
         SYNC_RESET : integer range 0 to 1);  -- use synchronous reset
      port (
         clk_i   : in  std_logic;       -- clock
         rst_i   : in  std_logic;       -- init CRC
         clken_i : in  std_logic;       -- clock enable
         data_i  : in  std_logic_vector(DATA_WIDTH - 1 downto 0);  -- data input
         match_o : out std_logic;       -- CRC match flag
         crc_o   : out std_logic_vector(POLYNOMIAL'length - 1 downto 0));  -- CRC output
   end component;

end ucrc_pkg;
