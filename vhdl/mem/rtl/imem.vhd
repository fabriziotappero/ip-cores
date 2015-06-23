--------------------------------------------------------------------------------
-- WB Memory Controller                                                       --
--------------------------------------------------------------------------------
-- Memory with a bus width of 32bit and a granularity of 8bit.                --
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

package imem is

   type mem_t is array ( 0 to 4095 )
      of std_logic_vector(7 downto 0);

   type mem_block_t is array ( 0 to 3 ) of mem_t;

   component mem is
      port(
         si : in  slave_in_t;
         so : out slave_out_t
      );
   end component;
   
end imem;