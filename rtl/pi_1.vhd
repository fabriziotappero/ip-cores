
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

entity pi_1 is
	port(a_1_in 	: in std_logic_vector(31 downto 0);
		  a_2_in 	: in std_logic_vector(31 downto 0);
		  a_3_in 	: in std_logic_vector(31 downto 0);
		  a_1_out 	: out std_logic_vector(31 downto 0);
		  a_2_out	: out std_logic_vector(31 downto 0);
		  a_3_out 	: out std_logic_vector(31 downto 0));
end pi_1;

architecture Behavioral of pi_1 is

begin

	a_1_out <= a_1_in(30 downto 0) & a_1_in(31); 
	a_2_out <= a_2_in(26 downto 0) & a_2_in(31 downto 27);
	a_3_out <= a_3_in(29 downto 0) & a_3_in(31 downto 30);

end Behavioral;

