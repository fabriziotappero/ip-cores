--------------------------------------------------------------------------------
-- PS2 Keyboard Controller                                                    --
--------------------------------------------------------------------------------
-- The controller does not distinguish extended and normal keys. Most of the  --
-- practically relevant keys are without ambiguity. The controller ignores    --
-- all unmapped keys (see ascii.vhd).                                         --
--                                                                            --
-- REFERENCES                                                                 --
--                                                                            --
--  [1] Chu Pong P., FPGA Prototyping By VHDL Examples,                       --
--      John Wiley & Sons Inc., Hoboken, New Jersy, 2008,                     --
--      ISBN: 978-0470185315                                                  --
--                                                                            --
--  [2] Z80 System On A Chip                                                  --
--      <http://www.opencores.org/?do=project&who=z80soc>                     --
--  [3] Keyboard Scancode Table                                               --
--      <http://www.computer-engineering.org/ps2keyboard/scancodes2.html>     --
--  [4] PS2 Protocol                                                          --
--      <http://pcbheaven.com/wikipages/The_PS2_protocol/>                    --
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

package ikeyb is

   component keyb is
      port(
         si        : in  slave_in_t;
         so        : out slave_out_t;
      -- Non-Wishbone Signals
         PS2_CLK   : in  std_logic;
         PS2_DATA  : in  std_logic;
         intr      : out std_logic
      );
   end component;

end ikeyb;