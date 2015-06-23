
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

entity output_trans is
	port(clk     : in std_logic;
		  enc		 : in std_logic; -- (enc, 0) / (dec, 1)
		  rc_in   : in std_logic_vector(31 downto 0);
		  a_0_in  : in std_logic_vector(31 downto 0);
		  a_1_in  : in std_logic_vector(31 downto 0);
		  a_2_in  : in std_logic_vector(31 downto 0);
		  a_3_in  : in std_logic_vector(31 downto 0);		
		  k_0_in  : in std_logic_vector(31 downto 0);
		  k_1_in  : in std_logic_vector(31 downto 0);
		  k_2_in  : in std_logic_vector(31 downto 0);
		  k_3_in  : in std_logic_vector(31 downto 0);
		  a_0_out : out std_logic_vector(31 downto 0);
		  a_1_out : out std_logic_vector(31 downto 0);
		  a_2_out : out std_logic_vector(31 downto 0);
		  a_3_out : out std_logic_vector(31 downto 0));
end output_trans;

architecture Behavioral of output_trans is

	component theta is
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

	signal a_0_s : std_logic_vector(31 downto 0);
	signal a_0_in_s : std_logic_vector(31 downto 0);
	signal a_0_out_s : std_logic_vector(31 downto 0);
	
begin

	a_0_s <= a_0_in xor rc_in;
	a_0_in_s <= a_0_s when enc = '0' else a_0_in;
	
	THETA_0 : theta port map (clk, 
									  a_0_in_s, 	     
									  a_1_in,
								     a_2_in,
									  a_3_in,
									  k_0_in,
									  k_1_in,
									  k_2_in,
									  k_3_in,
									  a_0_out_s, 	     
									  a_1_out,
								     a_2_out,
									  a_3_out);

	a_0_out <= (a_0_out_s xor rc_in) when enc = '1' else a_0_out_s;

end Behavioral;

