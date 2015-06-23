--------------------------------------------------------------------------------
-- Numonyx™ 128 Mbit EMBEDDED FLASH MEMORY J3 Version D                       --
--------------------------------------------------------------------------------
-- See <flash.h> and <flash.c> for information on usage and bus interface.    --
--                                                                            --
-- REFERENCES                                                                 --
--                                                                            --
--  [1] Numonyx™ Embedded Flash Memory(J3 v. D) Datasheet Revision 5          --
--  [2] Mihai Plesa - StrataFlash memory operations on a Spartan-3E           --
--        <http://mihaiplesa.ro/blog/>                                        --
--                                                                            --
--------------------------------------------------------------------------------
-- Copyright (C)2011  Mathias Hörtnagl <mathias.hoertnagl@gmail.comt>         --
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

package iflash is

   component flash
      port(
         si           : in    slave_in_t;
         so           : out   slave_out_t;
      -- Non Wishbone Signals
         SF_OE        : out   std_logic;
         SF_CE        : out   std_logic;
         SF_WE        : out   std_logic;
         SF_BYTE      : out   std_logic;
         --SF_STS       : in    std_logic;
         SF_A         : out   std_logic_vector(23 downto 0);
         SF_D         : inout std_logic_vector(7 downto 0);
         PF_OE        : out   std_logic;
         LCD_RW       : out   std_logic;
         LCD_E        : out   std_logic;
         SPI_ROM_CS   : out   std_logic;
         SPI_ADC_CONV : out   std_logic;
         SPI_DAC_CS   : out   std_logic
      );
   end component;

end iflash;