--------------------------------------------------------------------------------
-- Programmable Interval Timer                                                --
--------------------------------------------------------------------------------
-- Simplest implementation of a programmable interval timer. The timer is     --
-- Wishbone compliant and functions on two instructions:                      --
--                                                                            --
--  o Start the timer with a Wb write. The data to be sent contains the       --
--    inverall length.                                                        --
--                                                                            --
--  o After the set limit is reached, the timer issues an interrupt and waits --
--    for a WB write. It returns back to initial state afterwards and waits   --
--    for a new WB write.                                                     --
--                                                                            --
-- The timer supports pulse timing only.                                      --
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

package ipit is

   component pit is
      port(
         si   : in  slave_in_t;
         so   : out slave_out_t;
      -- Non-Wishbone Signals
         intr : out std_logic
      );
   end component;

end ipit;