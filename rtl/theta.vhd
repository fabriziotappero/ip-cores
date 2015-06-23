
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

entity theta is
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
end theta;

architecture Behavioral of theta is

	component t_m_1 is
	port(clk : in std_logic;
		  a_0_in : in std_logic_vector(31 downto 0);
		  a_1_in : in std_logic_vector(31 downto 0);
		  a_2_in : in std_logic_vector(31 downto 0);
		  a_3_in : in std_logic_vector(31 downto 0);
		  a_1_out : out std_logic_vector(31 downto 0);
		  a_3_out : out std_logic_vector(31 downto 0));
	end component;

	component t_m_2 is
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
	end component;

	component t_m_3 is
	port(clk : in std_logic;
		  a_0_in : in std_logic_vector(31 downto 0);
		  a_1_in : in std_logic_vector(31 downto 0);
		  a_2_in : in std_logic_vector(31 downto 0);
		  a_3_in : in std_logic_vector(31 downto 0);
		  a_0_out : out std_logic_vector(31 downto 0);
		  a_2_out : out std_logic_vector(31 downto 0));
	end component;

	signal a_1_0_s : std_logic_vector(31 downto 0);
	signal a_3_0_s : std_logic_vector(31 downto 0);

	signal tmp_0_s : std_logic_vector(31 downto 0);
	signal tmp_1_s : std_logic_vector(31 downto 0);
	signal tmp_2_s : std_logic_vector(31 downto 0);
	signal tmp_3_s : std_logic_vector(31 downto 0);
	
begin

	T_M_1_0 : t_m_1 port map (clk, a_0_in, a_1_in, a_2_in, a_3_in, a_1_0_s, a_3_0_s);
	T_M_2_0 : t_m_2 port map (clk, a_0_in, a_1_0_s, a_2_in, a_3_0_s, k_0_in, k_1_in, k_2_in, k_3_in, tmp_0_s, tmp_1_s, tmp_2_s, tmp_3_s);
	T_M_1_1 : t_m_3 port map (clk, tmp_0_s, tmp_1_s, tmp_2_s, tmp_3_s, a_0_out, a_2_out);

	a_1_out <= tmp_1_s;
	a_3_out <= tmp_3_s;

--Theta(k,a){
	-- temp = a[0]^a[2]; 				tmp_0_s
	-- temp ^= temp>>>8 ^ temp<<<8; 	tmp_1_s
	-- a[1] ^= temp; 						tmp_2_s
	-- a[3] ^= temp; 						tmp_3_s

	-- a[0] ^= k[0]; 						tmp_4_s
	-- a[1] ^= k[1]; 						tmp_5_s
	-- a[2] ^= k[2]; 						tmp_6_s
	-- a[3] ^= k[3]; 						tmp_7_s

	-- temp = a[1]^a[3]; 
	-- temp ^= temp>>>8 ^ temp<<<8;

	-- a[0] ^= temp;
	-- a[2] ^= temp;
--}

end Behavioral;

