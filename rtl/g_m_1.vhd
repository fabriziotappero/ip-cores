
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

entity g_m_1 is
	port(clk : in std_logic;
		  a_1_in : in std_logic_vector(31 downto 0);
		  a_2_in : in std_logic_vector(31 downto 0);
		  a_3_in : in std_logic_vector(31 downto 0);
		  a_1_out : out std_logic_vector(31 downto 0));
end g_m_1;

architecture Behavioral of g_m_1 is

begin

	a_1_out <= a_1_in xor (not(a_3_in) and not(a_2_in));

end Behavioral;

