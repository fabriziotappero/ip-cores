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

	--
	-- Coeficientes del filtro representados sobre 10 bits en C-2,
	-- 5 para la parte entera y 5 para la parte fraccionaria.
	--
	--
	--	h0 = 0 			-> 0000000000
	-- h1 = 0.3826 	-> 0000001100
	-- h2 = 0.7071		-> 0000010111
	-- h3 = 0.9238		-> 0000011110
	-- h4 = 1			-> 0000100000
	-- h5 = 0.9238		-> 0000011110
	-- h6 = 0.7071		-> 0000010111
	-- h7 = 0.3826		-> 0000001100
	--
	
	
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity rx_fir is

	port (mfilter_input: in std_logic_vector(9 downto 0);
			mfilter_clk:   in std_logic;
			mfilter_rst:   in std_logic;
			mfilter_output: out std_logic_vector(9 downto 0));
			
end rx_fir;

architecture Behavioral of rx_fir is
	type registers is array (6 downto 0) of signed(9 downto 0);
	type coefficients is array (7 downto 0) of signed(9 downto 0);
	
	signal reg: registers;
	signal output_temp: std_logic_vector(9 downto 0);
	
	constant coef: coefficients := ("0000001100",
											  "0000010111",
 											  "0000011110",
											  "0000100000",
											  "0000011110", 
											  "0000010111",
											  "0000001100",
											  "0000000000");										  
											  									  
	begin
		process (mfilter_clk, mfilter_rst)	
			variable acc, prod: signed(19 downto 0) := (others => '0');
		begin
				if (mfilter_rst = '1') then
					for i in 6 downto 0 loop
						reg(i) <= (others => '0');
					end loop;
	
				elsif rising_edge(mfilter_clk) then
					acc := coef(0)*signed(mfilter_input);
				
					for i in 1 to 7 loop	
						prod := coef(i)*reg(7-i);
						acc := acc + prod; 
					end loop;
				
					reg <= signed(mfilter_input) & reg(6 DOWNTO 1);
						
				end if;
			output_temp <= std_logic_vector(resize(acc, mfilter_output'length));

	end process;
	
	mfilter_output <= output_temp;
	
end Behavioral;


