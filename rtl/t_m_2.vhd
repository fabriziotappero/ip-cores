
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

entity t_m_2 is
	port(clk : in std_logic;
		  a_0_in : in std_logic_vector(31 downto 0);
		  a_1_in : in std_logic_vector(31 downto 0);
	     a_2_in : in std_logic_vector(31 downto 0);	  
		  a_3_in : in std_logic_vector(31 downto 0);  
		  k_0_in : in std_logic_vector(31 downto 0);
		  k_1_in : in std_logic_vector(31 downto 0);
	     k_2_in : in std_logic_vector(31 downto 0);	  
		  k_3_in : in std_logic_vector(31 downto 0);  		  
		  a_0_out : out std_logic_vector(31 downto 0);
		  a_1_out : out std_logic_vector(31 downto 0);
	     a_2_out : out std_logic_vector(31 downto 0);	  
		  a_3_out : out std_logic_vector(31 downto 0));  		  
end t_m_2;

architecture Behavioral of t_m_2 is

begin

	a_0_out <= a_0_in xor k_0_in;
	a_1_out <= a_1_in xor k_1_in;
	a_2_out <= a_2_in xor k_2_in;
	a_3_out <= a_3_in xor k_3_in;
	
	-- a[0] ^= k[0]; 						tmp_4_s
	-- a[1] ^= k[1]; 						tmp_5_s
	-- a[2] ^= k[2]; 						tmp_6_s
	-- a[3] ^= k[3]; 						tmp_7_s

end Behavioral;

