
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

entity diffPhaseDecoder is
	port(clk_18_KHz: in std_logic;
		  rst: in std_logic;
		  en: in std_logic;
		  a_k : out std_logic_vector(7 downto 0);
		  b_k : out std_logic_vector(7 downto 0);
		  i_k : in std_logic_vector(7 downto 0);  
		  q_k : in std_logic_vector(7 downto 0)); 
end diffPhaseDecoder;

architecture Behavioral of diffPhaseDecoder is

begin

	phase_decoder: process(clk_18_KHz, en, i_k, q_k)
		variable i_k_old : signed(7 downto 0) := (others=>'0');
		variable q_k_old : signed(7 downto 0) := (others=>'0');
		variable a_k_tmp : signed(15 downto 0) := (others=>'0');
		variable b_k_tmp : signed(15 downto 0) := (others=>'0');		
	begin
		if falling_edge(clk_18_KHz) and en = '1' then
			if rst = '1' then
				i_k_old := "00000001";
				q_k_old := "00000000";
			else	
				a_k_tmp := signed(i_k)*i_k_old + signed(q_k)*q_k_old;
				b_k_tmp := i_k_old*signed(q_k) - signed(i_k)*q_k_old;
				
				i_k_old := signed(i_k);
				q_k_old := signed(q_k);
			end if;
		end if;
		
		a_k <= std_logic_vector(sxt(std_logic_vector(a_k_tmp), a_k'length));
		b_k <= std_logic_vector(sxt(std_logic_vector(b_k_tmp), b_k'length));
	end process;

end Behavioral;

