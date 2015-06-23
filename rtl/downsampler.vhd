-- Copyright (c) 2010 Antonio de la Piedra
 
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

-- A VHDL model of the IEEE 802.15.4 physical layer.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity downsampler is
	port (downsampler_clk: in std_logic;
			downsampler_start: in std_logic;
			downsampler_input: in std_logic_vector(9 downto 0);
			downsampler_output: out std_logic_vector(9 downto 0));
end downsampler;

architecture Behavioral of downsampler is
begin
	process(downsampler_clk, downsampler_start, downsampler_input)
	begin
		if rising_edge(downsampler_clk) and downsampler_start = '1' then
			downsampler_output <= downsampler_input;
		end if;
			
	end process;
	
	
end Behavioral;

