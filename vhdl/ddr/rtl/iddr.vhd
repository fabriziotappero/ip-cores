--------------------------------------------------------------------------------
-- Mycron® DDR SDRAM - MT46V32M16 - 8 Meg x 16 x 4 banks                      --
--------------------------------------------------------------------------------
--                                                                            --
-- REFERENCES                                                                 --
--                                                                            --
--  [1] http://opencores.org/project,ddr2_sdram                               --
--  [2] http://opencores.org/project,sdram_controller                         --
--  [3] Spartan-3E Libraries Guide for HDL Designs                            --
--                                                                            --
--------------------------------------------------------------------------------
-- Copyright (C)2012  Mathias Hörtnagl <mathias.hoertnagl@gmail.comt>         --
--                                                                            --
-- This program is free software: you can redistribute it and/or modify       --
-- it under the terms of the GNU General Public License as published by       --
-- the Free Software Foundation, either version 3 of the License, or          --
-- (at your option) any later version.                                        --
--                                                                            --
-- This program is distributed in the hope that it will be useful,            --
-- but WITHOUT ANY WARRANTY; without even the implied warranty of             --
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              --
-- GNU General Public License for more details.                               --
--                                                                            --
-- You should have received a copy of the GNU General Public License          --
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.      --
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.iwb.all;

package iddr is

   component ddr is
      port (
         si       : in    slave_in_t;
         so       : out   slave_out_t;
      -- Non Wishbone Signals
         clk0     : in    std_logic;
         clk90    : in    std_logic;
         SD_CK_N  : out   std_logic;
         SD_CK_P  : out   std_logic;
         SD_CKE   : out   std_logic;         
         SD_BA    : out   std_logic_vector(1 downto 0);
         SD_A     : out   std_logic_vector(12 downto 0);   
         SD_CMD   : out   std_logic_vector(3 downto 0);
         SD_DM    : out   std_logic_vector(1 downto 0);
         SD_DQS   : inout std_logic_vector(1 downto 0);
         SD_DQ    : inout std_logic_vector(15 downto 0)
      );
   end component;
   
end iddr;