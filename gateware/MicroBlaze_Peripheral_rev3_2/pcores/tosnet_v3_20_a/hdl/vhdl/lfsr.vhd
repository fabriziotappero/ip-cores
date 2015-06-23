----------------------------------------------------------------------------------
-- Company: 		University of Southern Denmark
-- Engineer: 		Simon Falsig
-- 
-- Create Date:    	9/6/2008 
-- Design Name: 	Linear Feedback Shift Register
-- Module Name:    	lfsr - Behavioral 
-- File Name:		lfsr.vhd
-- Project Name:	TosNet
-- Target Devices:	Spartan3/6
-- Tool versions:	Xilinx ISE 12.2
-- Description: 	The LFSR is used to create pseudo-random sequences that are
--					used for scrambling outgoing data. With a similarly seeded
--					LFSR on the receiving side, the data can be de-scrambled.
--
-- Revision: 
-- Revision 3.2 - 	Initial release
--
-- Copyright 2010
--
-- This module is free software: you can redistribute it and/or modify
-- it under the terms of the GNU Lesser General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This module is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU Lesser General Public License for more details.
--
-- You should have received a copy of the GNU Lesser General Public License
-- along with this module.  If not, see <http://www.gnu.org/licenses/>.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;


entity lfsr is
	generic (
		lfsr_length 		: STD_LOGIC_VECTOR(7 downto 0);
		lfsr_out_length		: STD_LOGIC_VECTOR(7 downto 0);
		lfsr_allow_zero		: STD_LOGIC);
	port (
		lfsr_out			: out	STD_LOGIC_VECTOR((conv_integer(lfsr_out_length) - 1) downto 0);
		lfsr_seed			: in	STD_LOGIC_VECTOR((conv_integer(lfsr_length) - 1) downto 0);
		lfsr_reset			: in	STD_LOGIC;
		lfsr_clk 			: in	STD_LOGIC;
		lfsr_clk_en			: in	STD_LOGIC);
end lfsr;

architecture Behavioral of lfsr is

	signal	value			: STD_LOGIC_VECTOR((conv_integer(lfsr_length) - 1) downto 0);

begin

	process(lfsr_clk)
	begin
		if(lfsr_clk = '1' and lfsr_clk'EVENT) then
			if(lfsr_reset = '1') then
				value <= lfsr_seed;
				lfsr_out <= (others => '0');
			elsif(lfsr_clk_en = '1') then
				value((conv_integer(lfsr_length) - 2) downto 0) <= value((conv_integer(lfsr_length) - 1) downto 1);
				value((conv_integer(lfsr_length) - 1)) <= value(1) xor value(0);
				if(lfsr_allow_zero = '0' and value((conv_integer(lfsr_length) - 1) downto (conv_integer(lfsr_length) - conv_integer(lfsr_out_length))) = 0) then
					lfsr_out <= (others => '1');
				else
					lfsr_out <= value((conv_integer(lfsr_length) - 1) downto (conv_integer(lfsr_length) - conv_integer(lfsr_out_length)));
				end if;
			end if;
		end if;
	end process;

end Behavioral;

