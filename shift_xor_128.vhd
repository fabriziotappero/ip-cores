
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

entity shift_xor_128 is
	port(clk : in std_logic;
	     a : in std_logic_vector(162 downto 0);
	     m : in std_logic_vector(162 downto 0);
		  c : out std_logic_vector(162 downto 0));
end shift_xor_128;

architecture Behavioral of shift_xor_128 is

	component dsp_xor is
		port (clk     : in std_logic;
				op_1	  : in std_logic_vector(47 downto 0);
				op_2	  : in std_logic_vector(47 downto 0);
				op_3	  : out std_logic_vector(47 downto 0));
	end component;

	signal op_1_s : std_logic_vector(162 downto 0);

	signal r_0_s : std_logic_vector(47 downto 0);
	signal r_1_s : std_logic_vector(47 downto 0);
	signal r_2_s : std_logic_vector(47 downto 0);
	signal r_3_s : std_logic_vector(47 downto 0);

	signal xor_in_aux_0_s : std_logic_vector(47 downto 0);
	signal xor_in_aux_1_s : std_logic_vector(47 downto 0);
	signal xor_out_aux_s : std_logic_vector(47 downto 0);

begin

	process(a, m, op_1_s, r_3_s, r_2_s, r_1_s, r_0_s)
	begin
		if a(162) = '1' then
			c <= r_3_s(47 downto 29) & r_2_s & r_1_s & r_0_s; 
		else
			c <= op_1_s; 
		end if;
	end process;

	op_1_s <= a(161 downto 0) & '0';

	DSP_XOR_0 : dsp_xor port map (clk, op_1_s(47 downto 0),       m(47 downto 0),   r_0_s);
	DSP_XOR_1 : dsp_xor port map (clk, op_1_s(95 downto 48),      m(95 downto 48),  r_1_s);
	DSP_XOR_2 : dsp_xor port map (clk, op_1_s(143 downto 96),     m(143 downto 96),  r_2_s);

	xor_in_aux_0_s <= op_1_s(162 downto 134) & "0000000000000000000";
	xor_in_aux_1_s <=    m(162 downto 134) & "0000000000000000000";

	DSP_XOR_3 : dsp_xor port map (clk, xor_in_aux_0_s,  xor_in_aux_1_s, r_3_s);

end Behavioral;

