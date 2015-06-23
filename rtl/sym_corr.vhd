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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.ALL;

entity sym_corr is
	generic (t_symbol: integer := 16);
	port( correlator_start :in std_logic;
			correlator_clk: in std_logic;
			correlator_rst: in std_logic;
			correlator_input_q: in std_logic;
			correlator_symbol: out std_logic_vector(3 downto 0));
			
end sym_corr;

architecture Behavioral of sym_corr is
	signal count_temp: integer range 0 to 17;
	signal chip_shr: std_logic_vector(15 downto 0);
	
	type sym_t is array (15 downto 0) of std_logic_vector(15 downto 0);
	type symbol_table is array (15 downto 0) of std_logic_vector(3 downto 0);
	type corr_value_t is array (15 downto 0) of integer;
	type max_fun_output is array (1 downto 0) of integer range 0 to 16;
	
	
   constant symbol_zero_q : std_logic_vector(15 downto 0) := "1101100111000010"; 

	
													  
	constant symbol_table_q: symbol_table := ("1111",
															"1110",
															"1101",
															"1100",
															"1011",
															"1010",
															"1001",
															"1000",
															"0111",
															"0110",
															"0101",
															"0100",
															"0011",
															"0010",
															"0001",
															"0000");

															
	function bit_to_integer(input_value: std_logic) return integer is
	begin
		if (input_value = '0' ) then
			return 0;
		else
			return 1;
		end if;	
	end function bit_to_integer;
	
	function max_vector(vector: corr_value_t ) return max_fun_output is
		variable temp: integer range 0 to 8;
		variable pos: integer range 0 to 16;
		begin
			temp := 0;
		
			for i in vector'range loop
				if vector(i) > temp then
					temp := vector(i);
					pos  := i;
				end if;	
			end loop;
			
			return max_fun_output'(temp, pos);
		
	end function max_vector;
	
begin

	corr_shr: process(correlator_start, correlator_clk, correlator_rst)
		variable chip_reg: std_logic_vector(15 downto 0);
	begin
	
		if (correlator_rst = '1') then
			chip_reg := symbol_zero_q;	
		elsif (rising_edge(correlator_clk) and correlator_start = '1') then
			chip_reg := std_logic_vector(unsigned(chip_reg) rol 1);
		end if;
		
		chip_shr <= chip_reg;
	end process;	

	corr_counter: process(correlator_start, correlator_clk)
		variable count: integer range 0 to t_symbol + 1:= 0;
	begin
		if (rising_edge(correlator_clk) and correlator_start = '1') then
				count := count + 1;
				if (count = t_symbol + 1) then
					count := 1;
				end if;	
		end if;	
		
		count_temp <= count;
	end process;
	
	corr: process(correlator_start, correlator_clk, correlator_rst)
			variable reg: std_logic_vector(15 downto 0) := (others => '0');
			variable sym: sym_t; 
			variable corr_value: corr_value_t;
			variable sym_pos: max_fun_output;
		begin
			if (correlator_rst = '1') then
				for i in 0 to 15 loop
					sym(i):= (others =>'0');
					corr_value(i) := 0;
				end loop;
				
				reg := (others => '0');
			elsif (rising_edge(correlator_clk) and correlator_start = '1') then
			
					reg := reg(14 downto 0) & correlator_input_q;
					
					sym(0):= sym(0)(14 downto 0) & chip_shr(0);
					sym(1):= sym(1)(14 downto 0) & chip_shr(2);
					sym(2):= sym(2)(14 downto 0) & chip_shr(4);
					sym(3):= sym(3)(14 downto 0) & chip_shr(6);
					sym(4):= sym(4)(14 downto 0) & chip_shr(8);
					sym(5):= sym(5)(14 downto 0) & chip_shr(10);
					sym(6):= sym(6)(14 downto 0) & chip_shr(12);
					sym(7):= sym(7)(14 downto 0) & chip_shr(14);
					sym(8):= sym(8)(14 downto 0) & not chip_shr(0);
					sym(9):= sym(9)(14 downto 0) & not chip_shr(2);
					sym(10):= sym(10)(14 downto 0) & not chip_shr(4);
					sym(11):= sym(11)(14 downto 0) & not chip_shr(6);
					sym(12):= sym(12)(14 downto 0) & not chip_shr(8);
					sym(13):= sym(13)(14 downto 0) & not chip_shr(10);
					sym(14):= sym(14)(14 downto 0) & not chip_shr(12);
					sym(15):= sym(15)(14 downto 0) & not chip_shr(14);
					
					-- We've got a new symbol !
					
					if (count_temp = t_symbol) then
					
						for i in 0 to 15 loop
							for j in 0 to 15 loop
								corr_value(i) := corr_value(i) + bit_to_integer(reg(j) and sym(i)(j));
							end loop;
						end loop;
							
						sym_pos := max_vector(corr_value);
												
						correlator_symbol <= symbol_table_q(sym_pos(0));
							
						for i in 0 to 15 loop
							corr_value(i) := 0;
						end loop;
					end if;	
					
			end if;		
	end process;
	
end Behavioral;

