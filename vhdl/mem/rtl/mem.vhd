--------------------------------------------------------------------------------
-- WB Memory Controller                                                       --
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
use work.imem.all;
use work.data.all;

entity mem is
   port(
      si : in  slave_in_t;
      so : out slave_out_t
   );
end mem;

architecture rtl of mem is

   signal mem : mem_block_t := data;

   attribute RAM_STYLE : string;
   attribute RAM_STYLE of mem: signal is "BLOCK";

   signal a : integer range 0 to 4095;
begin
   a <= to_integer( unsigned(si.adr(13 downto 2)) );
   mem0 : process(si.clk)
   begin
      for i in 0 to 3 loop
         if rising_edge(si.clk) then
            if si.stb = '1' then
               if (si.sel(i) = '1') and (si.we = '1') then
                  mem(i)( a ) <= si.dat(8*(i+1)-1 downto 8*i);
               end if;
               so.dat(8*(i+1)-1 downto 8*i) <= mem(i)( a );
            end if;
         end if;
      end loop;
   end process;
   
   -- process(si.clk)
   -- begin
      -- if rising_edge(si.clk) then
         so.ack <= si.stb;
      -- end if;
   -- end process;
end architecture;