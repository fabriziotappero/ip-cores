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

entity upsampler is

	generic (factor : integer := 7);
	
	Port( upsampler_output: OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
              upsampler_input: IN  STD_LOGIC;
              upsampler_clk: IN STD_LOGIC;
              upsampler_start: IN STD_LOGIC);

end upsampler;

architecture Behavioral of upsampler is
	signal count_temp: integer range 0 to factor + 1;
begin

	counter: process(upsampler_clk, upsampler_start)
		variable count: integer range 0 to factor + 1;
	begin
		if (upsampler_start = '1' and rising_edge(upsampler_clk)) then
			if (count = factor) then
				count := 0;
			else
				count := count + 1;
			end if;	
		end if;
		
		count_temp <= count;
		
	end process;
	
	upsampler_output <= (not upsampler_input) & '1' when (upsampler_start = '1' and count_temp = 1)
							   else "00";
end Behavioral;


