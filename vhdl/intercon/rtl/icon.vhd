--------------------------------------------------------------------------------
-- Wishbone Shared Bus Intercon                                               --
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

package icon is

   component intercon is
      port(
         CLK50_I  : in  std_logic;
         CLK25_I  : in  std_logic;
         RST_I    : in  std_logic;
         mi       : out master_in_t;
         mo       : in  master_out_t;
         brami    : out slave_in_t;
         bramo    : in  slave_out_t;
         flasi    : out slave_in_t;
         flaso    : in  slave_out_t;
         ddri     : out slave_in_t;
         ddro     : in  slave_out_t;
         dispi    : out slave_in_t;
         dispo    : in  slave_out_t;
         keybi    : out slave_in_t;
         keybo    : in  slave_out_t;
         piti     : out slave_in_t;
         pito     : in  slave_out_t;
         uartri   : out slave_in_t;
         uartro   : in  slave_out_t;
         uartti   : out slave_in_t;
         uartto   : in  slave_out_t
      );
   end component;

end icon;