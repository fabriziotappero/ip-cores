--------------------------------------------------------------------------------
-- 8-Color 100x37 Textmode Video Controller                                   --
--------------------------------------------------------------------------------
-- This controller features a 800x600@72Hz resolution Textmode VGA  with 100  --
-- characters per line and 37 lines. One out of 8 different colors can be     --
-- assigned to every single character and the character's background          --
-- respectivly.                                                               --
-- You can replace the character set with your own with <chars.py>. It takes  --
-- a <*.bdf> file and translates the character map into a <rom.vhd>           --
-- (Replaces the original!).                                                  --
--                                                                            --
-- For information about colors and usage consult <stdio.h> and <stdio.c>.    --
--                                                                            --
-- REFERENCES                                                                 --
--                                                                            --
--  [1] VGA Display Adapter                                                   --
--      <http://javiervalcarce.es/wiki/VHDL_Macro:_VGA80x40>                  --
--      Copyright 2007 by Javier Valcarce García                              --
--  [2] BDF Console Font File                                                 --
--      <http://www.ibiblio.org/pub/Linux/X11/fonts/>                         --
--  [3] Z80 System On A Chip                                                  --
--      <http://www.opencores.org/?do=project&who=z80soc>                     --
--  [4] Yet Another VGA                                                       --
--      <http://www.opencores.org/?do=project&who=yavga>                      --
--  [5] Xilinx Spartan 3E Starter Kit Board User Guide                        --
--      <http://www.xilinx.com/support/documentation/                         --
--      spartan-3e_board_and_kit_documentation.htm>                           --
--  [6] Display resolution calculator                                         --
--      <http://www.epanorama.net/faq/vga2rgb/calc.html>                      --
--                                                                            --
--  [7] Chu Pong P., FPGA Prototyping By VHDL Examples,                       --
--      John Wiley & Sons Inc., Hoboken, New Jersy, 2008,                     --
--      ISBN: 978-0470185315                                                  --
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

package ivga is

   component vga is
      port(
         si        : in  slave_in_t;
         so        : out slave_out_t;
         VGA_RED   : out std_logic;
         VGA_GREEN : out std_logic;
         VGA_BLUE  : out std_logic;
         VGA_HSYNC : out std_logic;
         VGA_VSYNC : out std_logic
      );
   end component;
end ivga;