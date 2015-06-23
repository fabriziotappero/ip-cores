----------------------------------------------------------------------------------
-- Company: 		University of Southern Denmark
-- Engineer: 		Simon Falsig
-- 
-- Create Date:    	11/5/2010 
-- Design Name		8b/10b decoder
-- Module Name:    	dec_8b10b - Behavioral 
-- File Name:		dec_8b10b.vhd
-- Project Name:	TosNet
-- Target Devices:	Spartan3/6
-- Tool versions:	Xilinx ISE 12.2
-- Description: 	An 8b/10b decoder. Like the encoder module, only the
--					functionality that is actually used in the TosNet physical
--					layer is implemented. That means that there is no support for
--					disparity checking, and the code error detection will not
--					detect all code errors (in particular in the case of the 
--					primary/alternate encoding of HGF symbol "111"). The datalink
--					layer does CRC checking though, so any errors are very likely
--					to be picked up there instead.
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

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity dec_8b10b is
port (	clk					: in	STD_LOGIC;
		ce					: in	STD_LOGIC;
		din					: in	STD_LOGIC_VECTOR(9 downto 0);
		dout				: out	STD_LOGIC_VECTOR(7 downto 0);
		kout				: out	STD_LOGIC;
		code_err			: out	STD_LOGIC);
end dec_8b10b;

architecture Behavioral of dec_8b10b is

	signal EDCBA			: STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
	signal HGF				: STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
	signal iedcba			: STD_LOGIC_VECTOR(5 downto 0) := (others => '0');
	signal jhgf				: STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
	signal jhgfiedcba		: STD_LOGIC_VECTOR(9 downto 0) := (others => '0');
	signal code_err_s1		: STD_LOGIC;
	signal code_err_s2		: STD_LOGIC;

begin

	process(jhgfiedcba, EDCBA, HGF, code_err_s1, code_err_s2)
	begin
		case jhgfiedcba is
			when "1001111100" =>
				dout <= "00111100";
				kout <= '1';
				code_err <= '0';
			when "0110000011" =>
				dout <= "00111100";
				kout <= '1';
				code_err <= '0';
			when "0101111100" =>
				dout <= "10111100";
				kout <= '1';
				code_err <= '0';
			when "1010000011" =>
				dout <= "10111100";
				kout <= '1';
				code_err <= '0';
			when others =>
				dout <= HGF & EDCBA;
				kout <= '0';
				code_err <= code_err_s1 or code_err_s2;
		end case;
	end process;

	jhgfiedcba <= jhgf & iedcba;

	process(clk)
	begin
		if(clk = '1' and clk'event) then
			if(ce = '1') then
				iedcba <= din(5 downto 0);
				jhgf <= din(9 downto 6);
			end if;
		end if;
	end process;

	process(iedcba)
	begin
		code_err_s1 <= '0';
		case iedcba is
--			when "000000" =>
--			when "000001" =>
--			when "000010" =>
--			when "000011" =>
--			when "000100" =>
			when "000101" =>
				EDCBA <= "01111";
			when "000110" =>
				EDCBA <= "00000";
			when "000111" =>
				EDCBA <= "00111";
--			when "001000" =>
			when "001001" =>
				EDCBA <= "10000";
			when "001010" =>
				EDCBA <= "11111";
			when "001011" =>
				EDCBA <= "01011";
			when "001100" =>
				EDCBA <= "11000";
			when "001101" =>
				EDCBA <= "01101";
			when "001110" =>
				EDCBA <= "01110";
--			when "001111" =>
--			when "010000" =>
			when "010001" =>
				EDCBA <= "00001";
			when "010010" =>
				EDCBA <= "00010";
			when "010011" =>
				EDCBA <= "10011";
			when "010100" =>
				EDCBA <= "00100";
			when "010101" =>
				EDCBA <= "10101";
			when "010110" =>
				EDCBA <= "10110";
			when "010111" =>
				EDCBA <= "10111";
			when "011000" =>
				EDCBA <= "01000";
			when "011001" =>
				EDCBA <= "11001";
			when "011010" =>
				EDCBA <= "11010";
			when "011011" =>
				EDCBA <= "11011";
			when "011100" =>
				EDCBA <= "11100";
			when "011101" =>
				EDCBA <= "11101";
			when "011110" =>
				EDCBA <= "11110";
--			when "011111" =>
--			when "100000" =>
			when "100001" =>
				EDCBA <= "11110";
			when "100010" =>
				EDCBA <= "11101";
			when "100011" =>
				EDCBA <= "00011";
			when "100100" =>
				EDCBA <= "11011";
			when "100101" =>
				EDCBA <= "00101";
			when "100110" =>
				EDCBA <= "00110";
			when "100111" =>
				EDCBA <= "01000";
			when "101000" =>
				EDCBA <= "10111";
			when "101001" =>
				EDCBA <= "01001";
			when "101010" =>
				EDCBA <= "01010";
			when "101011" =>
				EDCBA <= "00100";
			when "101100" =>
				EDCBA <= "01100";
			when "101101" =>
				EDCBA <= "00010";
			when "101110" =>
				EDCBA <= "00001";
--			when "101111" =>
--			when "110000" =>
			when "110001" =>
				EDCBA <= "10001";
			when "110010" =>
				EDCBA <= "10010";
			when "110011" =>
				EDCBA <= "11000";
			when "110100" =>
				EDCBA <= "10100";
			when "110101" =>
				EDCBA <= "11111";
			when "110110" =>
				EDCBA <= "10000";
--			when "110111" =>
			when "111000" =>
				EDCBA <= "00111";
			when "111001" =>
				EDCBA <= "00000";
			when "111010" =>
				EDCBA <= "01111";
--			when "111011" =>
--			when "111100" =>
--			when "111101" =>
--			when "111110" =>
--			when "111111" =>
			when others =>
				code_err_s1 <= '1';
				EDCBA <= "00000";
		end case;
	end process;

	process(jhgf)
	begin
		code_err_s2 <= '0';
		case jhgf is
--			when "0000" =>
			when "0001" =>
				HGF <= "111";
			when "0010" =>
				HGF <= "000";
			when "0011" =>
				HGF <= "011";
			when "0100" =>
				HGF <= "100";
			when "0101" =>
				HGF <= "101";
			when "0110" =>
				HGF <= "110";
			when "0111" =>
				HGF <= "111";
			when "1000" =>
				HGF <= "111";
			when "1001" =>
				HGF <= "001";
			when "1010" =>
				HGF <= "010";
			when "1011" =>
				HGF <= "100";
			when "1100" =>
				HGF <= "011";
			when "1101" =>
				HGF <= "000";
			when "1110" =>
				HGF <= "111";
--			when "1111" =>
			when others =>
				code_err_s2 <= '1';
				HGF <= "000";
		end case;
	end process;
	
	
end Behavioral;

