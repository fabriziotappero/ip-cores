--------------------------------------------------------------------------------
-- Baud Rate Counter                                                          --
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

entity counter is
   generic(
      FREQ : positive := 50;           -- Clock frequency in MHz.
      RATE : positive := 19200         -- Baud rate (times sampling rate).
   );
   port(
      clk    : in  std_logic;
      rst    : in  std_logic;
      tick   : out std_logic
   );
end counter;

architecture rtl of counter is
   
   constant MAX : positive := (FREQ*1000000)/(RATE*16);
   
   signal c, cin : natural range 0 to MAX;
begin

   tick <= '1' when c = MAX else '0';
   cin  <=  0  when c = MAX else c + 1;

   reg : process (clk)
   begin
      if rising_edge(clk) then         
         if rst = '1' then 
            c <= 0; 
         else
            c <= cin;
         end if;
      end if;
   end process;
end rtl;