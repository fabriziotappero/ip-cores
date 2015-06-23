

-- Copyright (c) 2013 Antonio de la Piedra
 
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
 
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
 
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ff_bank is
        port(clk : in std_logic;
				 d   : in std_logic_vector(31 downto 0);
             q   : out std_logic_vector(31 downto 0));
end ff_bank;

architecture rtl of ff_bank is
begin
        process(clk)
        begin
			if rising_edge(clk) then
				q <= d;
         end if;
        end process;
end rtl;

