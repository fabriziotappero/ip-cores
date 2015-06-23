
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity dataConverter is
    Port (clk_36_KHz : in  STD_LOGIC;
			 rst : in std_logic;
			 bit_stream_input : in  STD_LOGIC;
          valid_input : in  STD_LOGIC;
			 dbit_output : out std_logic_vector(1 downto 0));
         
end dataConverter;

architecture Behavioral of dataConverter is
	signal s_reg_s : std_logic_vector(1 downto 0);
begin
	
	shift_reg: process(clk_36_KHz, rst, bit_stream_input)
		variable s_reg_v : std_logic_vector(1 downto 0) := (others=>'0');
	begin
		if rst = '1' then
			s_reg_v := (others=>'0');
		elsif falling_edge(clk_36_KHz) and valid_input = '1' then
			s_reg_v(1) := s_reg_v(0);
			s_reg_v(0) := bit_stream_input;
		end if;
		
		s_reg_s <= s_reg_v;
	end process;
	
	dbit_output <= s_reg_s;
	
end Behavioral;

