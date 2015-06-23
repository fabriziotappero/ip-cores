--------------------------------------------------------------------------------
-- MIPS™ I CPU - Wishbone Master                                              --
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
use work.icpu.all;
use work.iwb.all;

package iwbm is

   component wbm is
      port(
         mi  : in  master_in_t;
         mo  : out master_out_t;
      -- Non Wishbone Signals
         ci  : out cpu_in_t;
         co  : in  cpu_out_t;
         irq : in  std_logic_vector(7 downto 0)
      );
   end component;

end iwbm;