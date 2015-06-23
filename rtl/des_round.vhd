
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

entity des_round is
	port(clk : in std_logic;
		  l_0 : in std_logic_vector(31 downto 0);
		  r_0 : in std_logic_vector(31 downto 0);
		  k_i : in std_logic_vector(47 downto 0);
		  l_1 : out std_logic_vector(31 downto 0);
		  r_1 : out std_logic_vector(31 downto 0));
end des_round;

architecture Behavioral of des_round is

	component f_fun is
		port(clk : in std_logic;
			  r_in : in std_logic_vector(31 downto 0);
			  k_in : in std_logic_vector(47 downto 0);
			  r_out : out std_logic_vector(31 downto 0));
	end component;

	component dsp_xor is
		port (clk     : in std_logic;
				op_1	  : in std_logic_vector(31 downto 0);
				op_2	  : in std_logic_vector(31 downto 0);
				op_3	  : out std_logic_vector(31 downto 0));
	end component;

	signal f_out_s : std_logic_vector(31 downto 0);

begin

	F_FUN_0 : f_fun port map (clk, r_0, k_i, f_out_s);

	l_1 <= r_0;
	r_1 <= l_0 xor f_out_s;

end Behavioral;

