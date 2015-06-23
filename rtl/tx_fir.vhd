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

-- Half-cosine pulse shapping filter [1] implemented as FIR structure.
-- FIR implementation based on [2].

-- [1] IEEE, 802.15.4. Part 15.4: Wireless Medium Access Control (MAC) and Physical Layer (PHY)
--     Specifications for Low-Rate Wireless Personal Area Networks (LR-WPANs).

-- [2] Volnei A. Pedroni. Circuit Design with VHDL.


-- Filter coefficientes represented over 10 bits in 2's complement.
	
	-- h0 = 0 	-> 0000000000
	-- h1 = 0.3826 	-> 0000001100
	-- h2 = 0.7071	-> 0000010111
	-- h3 = 0.9238	-> 0000011110
	-- h4 = 1	-> 0000100000
	-- h5 = 0.9238	-> 0000011110
	-- h6 = 0.7071	-> 0000010111
	-- h7 = 0.3826	-> 0000001100
	
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity tx_fir is

	port (mfilter_input: in std_logic_vector(1 downto 0);
			mfilter_clk:   in std_logic;
			mfilter_rst:   in std_logic;
			mfilter_output: out std_logic_vector(9 downto 0));
			
end tx_fir;

architecture Behavioral of tx_fir is
	type registers is array (6 downto 0) of signed(1 downto 0);
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
			variable acc: signed(9 downto 0) := (others => '0');
		begin
			
			if (mfilter_rst = '1') then
				for i in 6 downto 0 loop
						reg(i) <= (others => '0');
				end loop;
	
			elsif rising_edge(mfilter_clk) then

				if (mfilter_input = "01") then
					acc := resize(coef(0), acc'length);
				elsif (mfilter_input = "11") then
					acc := resize(-coef(0), acc'length);
				else
					acc := (others => '0');
				end if;
				
				for i in 1 to 7 loop	
					if (reg(7-i) = "01") then
						acc := resize(acc + coef(i), acc'length);
					elsif (reg(7-i)= "11") then
						acc := resize(acc - coef(i), acc'length);
					end if;	
				end loop;
				
				reg <= signed(mfilter_input) & reg(6 DOWNTO 1);
						

			end if;
		output_temp <= std_logic_vector(acc);
	
	end process;
	
	mfilter_output <= output_temp;
	
end Behavioral;

