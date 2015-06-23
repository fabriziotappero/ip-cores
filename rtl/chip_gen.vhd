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

entity chip_gen is

	Port( chip_gen_rst : IN STD_LOGIC;
			chip_gen_clk : IN STD_LOGIC; 
			chip_gen_symbol: IN STD_LOGIC_VECTOR(3 downto 0);
			chip_gen_iOut: OUT STD_LOGIC;
			chip_gen_qOut: OUT STD_LOGIC);

end chip_gen;

architecture Behavioral of chip_gen is
	TYPE symbol_array is ARRAY (7 downto 0) OF STD_LOGIC_VECTOR (3 downto 0);		
	
	CONSTANT symbols: symbol_array := ( "0111",
													"0110",
													"0101",
													"0100",
													"0011",
													"0010",
													"0001",
													"0000"); 
													
																																	
	CONSTANT symbol_zero_i : STD_LOGIC_VECTOR (15 downto 0) := "1010100100010111"; 
	CONSTANT symbol_zero_q : STD_LOGIC_VECTOR (15 downto 0) := "1101100111000010"; 
							 

	SIGNAL muxIout, muxQout: STD_LOGIC;
	SIGNAL sr1, sr2 : STD_LOGIC_VECTOR(15 downto 0);
	
begin

	shr: process(chip_gen_clk, chip_gen_rst)
			
	begin
	
		IF (chip_gen_rst = '1') then
			sr1 <= symbol_zero_i;
			sr2 <= symbol_zero_q;
			
		elsif rising_edge(chip_gen_clk) then

			sr1 <= std_logic_vector(unsigned(sr1) rol 1);
			sr2 <= std_logic_vector(unsigned(sr2) rol 1);

		end if;
				
	end process;

	muxI: process(chip_gen_symbol, sr1) 
	begin
			
		IF (chip_gen_symbol(2 downto 0) = symbols(0)(2 downto 0)) then
			muxIout <= sr1(0);
		elsif (chip_gen_symbol(2 downto 0) = symbols(1)(2 downto 0)) then
			muxIout <= sr1(2);
		elsif (chip_gen_symbol(2 downto 0) = symbols(2)(2 downto 0)) then
			muxIout <= sr1(4);
		elsif (chip_gen_symbol(2 downto 0) = symbols(3)(2 downto 0)) then
			muxIout <= sr1(6);
		elsif (chip_gen_symbol(2 downto 0) = symbols(4)(2 downto 0)) then
			muxIout <= sr1(8);
		elsif (chip_gen_symbol(2 downto 0) = symbols(5)(2 downto 0)) then
			muxIout <= sr1(10);
		elsif (chip_gen_symbol(2 downto 0) = symbols(6)(2 downto 0)) then
			muxIout <= sr1(12);
		elsif (chip_gen_symbol(2 downto 0) = symbols(7)(2 downto 0)) then
			muxIout <= sr1(14);
		end if;
	end process;
	
	muxQ: process(chip_gen_symbol, sr2) 
	begin
			
		IF (chip_gen_symbol(2 downto 0) = symbols(0)(2 downto 0)) then
			muxQout <= sr2(0) xor chip_gen_symbol(3);
		elsif (chip_gen_symbol(2 downto 0) = symbols(1)(2 downto 0)) then
			muxQout <= sr2(2) xor chip_gen_symbol(3);
		elsif (chip_gen_symbol(2 downto 0) = symbols(2)(2 downto 0)) then
			muxQout <= sr2(4) xor chip_gen_symbol(3);
		elsif (chip_gen_symbol(2 downto 0) = symbols(3)(2 downto 0)) then
			muxQout <= sr2(6) xor chip_gen_symbol(3);
		elsif (chip_gen_symbol(2 downto 0) = symbols(4)(2 downto 0)) then
			muxQout <= sr2(8) xor chip_gen_symbol(3);
		elsif (chip_gen_symbol(2 downto 0) = symbols(5)(2 downto 0)) then
			muxQout <= sr2(10) xor chip_gen_symbol(3);
		elsif (chip_gen_symbol(2 downto 0) = symbols(6)(2 downto 0)) then
			muxQout <= sr2(12) xor chip_gen_symbol(3);
		elsif (chip_gen_symbol(2 downto 0) = symbols(7)(2 downto 0)) then
			muxQout <= sr2(14) xor chip_gen_symbol(3);
		end if;
	end process;
			
	chip_gen_iOut <= muxIout;
	chip_gen_qOut <= muxQout;
	
end Behavioral;



