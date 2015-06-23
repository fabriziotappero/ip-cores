
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

entity diffPhaseEncoder is
	port(clk_18_KHz: in std_logic;
		  rst: in std_logic;
		  en: in std_logic;
		  a_k : in std_logic;
		  b_k : in std_logic;
		  i_k : out std_logic_vector(7 downto 0);  
		  q_k : out std_logic_vector(7 downto 0)); 
end diffPhaseEncoder;

architecture Behavioral of diffPhaseEncoder is
	
		-- constellation values arranged as fixed point 8-bit, 6-bit fractional.

	constant c_minus_0_7 : std_logic_vector(7 downto 0) := "10100101";
	constant c_plus_0_7  : std_logic_vector(7 downto 0) := "01011011"; 
	constant c_plus_1    : std_logic_vector(7 downto 0) := "01111111";
	constant c_minus_1   : std_logic_vector(7 downto 0) := "10000000";
	constant c_plus_0      : std_logic_vector(7 downto 0) := "00000000";
	
	type state is (plus_0_plus_1,
				   plus_0_7_plus_0_7,
					plus_1_plus_0,
					plus_0_7_minus_0_7,
					plus_0_minus_1,
					minus_0_7_minus_0_7,
					minus_1_plus_0,
					minus_0_7_plus_0_7);
					
	signal pr_state : state;
	signal nx_state : state;	
	
begin

	fsm_seq: process(clk_18_KHz, rst) 
	begin
	
		if falling_edge(clk_18_KHz)  then
			if  rst = '1' then
				pr_state <= plus_1_plus_0;		
			else	
				pr_state <= nx_state;
			end if;
		end if;	
	end process;
	

	fsm_comb: process(pr_state, a_k, b_k, en)
	begin
		case pr_state is
			when plus_0_plus_1 =>
				i_k <= c_plus_0;
				q_k <= c_plus_1;

				if en = '1' then
					if (a_k = '0' and b_k = '0') then
						nx_state <= minus_0_7_plus_0_7;
					elsif (a_k = '0' and b_k = '1') then
						nx_state <= minus_0_7_minus_0_7;
					elsif (a_k = '1' and b_k = '0') then 
						nx_state <= plus_0_7_plus_0_7;
					else -- 1, 1
						nx_state <= plus_0_7_minus_0_7;
					end if;
				else
					nx_state <= plus_0_plus_1;
				end if;	
			
		   when plus_0_7_plus_0_7 =>
				i_k <= c_plus_0_7;
				q_k <= c_plus_0_7;
				
				if en = '1' then	
					if (a_k = '0' and b_k = '0') then
						nx_state <= plus_0_plus_1;
					elsif (a_k = '0' and b_k = '1') then
						nx_state <= minus_1_plus_0;
					elsif (a_k = '1' and b_k = '0') then 
						nx_state <= plus_1_plus_0;
					else -- 1, 1
						nx_state <= plus_0_minus_1;
					end if;
				else
					nx_state <= plus_0_7_plus_0_7;
				end if;
				
		   when plus_1_plus_0 =>
				i_k <= c_plus_1;
				q_k <= c_plus_0;		 
				
				if en = '1' then	
					if (a_k = '0' and b_k = '0') then
						nx_state <= plus_0_7_plus_0_7; 
					elsif (a_k = '0' and b_k = '1') then
						nx_state <= minus_0_7_plus_0_7;		
					elsif (a_k = '1' and b_k = '0') then 
						nx_state <= plus_0_7_minus_0_7;
					else -- 1, 1
						nx_state <= minus_0_7_minus_0_7;
					end if;
				else
					nx_state <= plus_1_plus_0;
				end if;
				
		   when plus_0_7_minus_0_7 =>
				i_k <= c_plus_0_7;
				q_k <= c_minus_0_7;
				
				if en = '1' then
					if (a_k = '0' and b_k = '0') then
						nx_state <= plus_1_plus_0;
					elsif (a_k = '0' and b_k = '1') then
						nx_state <= plus_0_plus_1;
					elsif (a_k = '1' and b_k = '0') then 
						nx_state <= plus_0_minus_1;
					else -- 1, 1
						nx_state <= minus_1_plus_0;
					end if;
				else
					nx_state <= plus_0_7_minus_0_7;
				end if;
				
			when plus_0_minus_1 =>
				i_k <= c_plus_0;
				q_k <= c_minus_1;			 	
			
				if en = '1' then
					if (a_k = '0' and b_k = '0') then
						nx_state <= plus_0_7_minus_0_7;
					elsif (a_k = '0' and b_k = '1') then
						nx_state <= plus_0_7_plus_0_7;
					elsif (a_k = '1' and b_k = '0') then 
						nx_state <= minus_0_7_minus_0_7;
					else -- 1, 1
						nx_state <= minus_0_7_plus_0_7;
					end if;
				else
					nx_state <= plus_0_minus_1;
				end if;
				
			when minus_0_7_minus_0_7 =>
				i_k <= c_minus_0_7;
				q_k <= c_minus_0_7;
				
				if en = '1' then
					if (a_k = '0' and b_k = '0') then
						nx_state <= plus_0_minus_1;
					elsif (a_k = '0' and b_k = '1') then
						nx_state <= plus_1_plus_0;		
					elsif (a_k = '1' and b_k = '0') then 
						nx_state <= minus_1_plus_0;
					else -- 1, 1
						nx_state <= plus_0_plus_1;
					end if;
				else
					nx_state <= minus_0_7_minus_0_7;
				end if;	
				
			when minus_1_plus_0 =>
				i_k <= c_minus_1;
				q_k <= c_plus_0;		
				
				if en = '1' then
					if (a_k = '0' and b_k = '0') then
						nx_state <= minus_0_7_minus_0_7;
					elsif (a_k = '0' and b_k = '1') then
						nx_state <= plus_0_7_minus_0_7;		
					elsif (a_k = '1' and b_k = '0') then 
						nx_state <= minus_0_7_plus_0_7;
					else -- 1, 1
						nx_state <= plus_0_7_plus_0_7;
					end if;
				else
					nx_state <= minus_1_plus_0;
				end if;	
				
			when minus_0_7_plus_0_7 =>
				i_k <= c_minus_0_7;
				q_k <= c_plus_0_7;	
				
				if en = '1' then
					if (a_k = '0' and b_k = '0') then
						nx_state <= minus_1_plus_0;
					elsif (a_k = '0' and b_k = '1') then
						nx_state <= plus_0_minus_1;			
					elsif (a_k = '1' and b_k = '0') then 
						nx_state <= plus_0_plus_1;
					else -- 1, 1
						nx_state <= plus_1_plus_0;
					end if;
				else
					nx_state <= minus_0_7_plus_0_7;
				end if;	
				
		end case;
	end process;


end Behavioral;

