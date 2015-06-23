
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

entity t_m_3 is
	port(clk : in std_logic;
		  a_0_in : in std_logic_vector(31 downto 0);
		  a_1_in : in std_logic_vector(31 downto 0);
		  a_2_in : in std_logic_vector(31 downto 0);
		  a_3_in : in std_logic_vector(31 downto 0);
		  a_0_out : out std_logic_vector(31 downto 0);
		  a_2_out : out std_logic_vector(31 downto 0));
end t_m_3;

architecture Behavioral of t_m_3 is

	signal tmp_0_s : std_logic_vector(31 downto 0);
	signal tmp_1_s : std_logic_vector(31 downto 0);
	signal tmp_2_s : std_logic_vector(31 downto 0);
	signal tmp_3_s : std_logic_vector(31 downto 0);

begin

	-- temp = a[1]^a[3]; 
	-- temp ^= temp>>>8 ^ temp<<<8;

	-- a[0] ^= temp;
	-- a[2] ^= temp;

	tmp_0_s <= a_1_in xor a_3_in;
	tmp_1_s <= tmp_0_s(23 downto 0) & tmp_0_s(31 downto 24); 
	tmp_2_s <= tmp_0_s(7 downto 0) & tmp_0_s(31 downto 8); 
	tmp_3_s <= tmp_0_s xor tmp_1_s xor tmp_2_s;

	a_0_out <= a_0_in xor tmp_3_s;
	a_2_out <= a_2_in xor tmp_3_s;
		
end Behavioral;


