----------------------------------------------------------------------------------
-- Company: 		University of Southern Denmark
-- Engineer: 		Simon Falsig
-- 
-- Create Date:    	11/5/2010 
-- Design Name: 	8b/10b encoder
-- Module Name:    	enc_8b10b - Behavioral 
-- File Name:		enc_8b10b.vhd
-- Project Name:	TosNet
-- Target Devices:	Spartan3/6
-- Tool versions:	Xilinx ISE 12.2
-- Description: 	An 8b/10b encoder. The complete 8b/10b encoding is not
--					implemented though (only the control symbols K.28.1 and 
--					K.28.5 are available, all others will just encode as K.28.1).
--					This is done to simplify and minimize the code, and as the
--					other control codes aren't used by the TosNet physical layer
--					anyways.
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

entity enc_8b10b is
port (	clk					: in	STD_LOGIC;
		ce					: in	STD_LOGIC;
		din					: in	STD_LOGIC_VECTOR(7 downto 0);
		dout				: out	STD_LOGIC_VECTOR(9 downto 0);
		kin					: in	STD_LOGIC);
end enc_8b10b;

architecture Behavioral of enc_8b10b is

	signal rd				: STD_LOGIC := '0';
	signal next_rd			: STD_LOGIC;
	signal temp_rd_s0		: STD_LOGIC; --Stage 0
	signal temp_rd_k0		: STD_LOGIC; --Stage 1, k=0
	signal dxA				: STD_LOGIC;
	signal EDCBA			: STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
	signal HGF				: STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
	signal iedcba			: STD_LOGIC_VECTOR(5 downto 0) := (others => '0');
	signal jhgf				: STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
begin

	process(jhgf, iedcba, kin, rd, temp_rd_k0, EDCBA, HGF)
	begin
		if(kin = '0') then
			dout <= jhgf & iedcba;
			next_rd <= temp_rd_k0;
		else
			next_rd <= not rd;
			if(HGF = "101" and EDCBA = "11100") then
				if(rd = '0') then
					dout <= "0101111100";
				else
					dout <= "1010000011";
				end if;
			else		--Transmit K.28.1 => QUIET
				if(rd = '0') then
					dout <= "1001111100";
				else
					dout <= "0110000011";
				end if;
			end if;
		end if;
	end process;
	

	process(clk)
	begin
		if(clk = '1' and clk'event) then
			if(ce = '1') then
				EDCBA <= din(4 downto 0);
				HGF <= din(7 downto 5);
				rd <= next_rd;
			end if;
		end if;
	end process;
	
	process(EDCBA, rd)
	begin
		case EDCBA is
			when "00000" =>
				temp_rd_s0 <= not rd;
				if(rd = '0') then
					iedcba <= "111001";
				else
					iedcba <= "000110";
				end if;
			when "00001" =>
				temp_rd_s0 <= not rd;
				if(rd = '0') then
					iedcba <= "101110";
				else
					iedcba <= "010001";
				end if;
			when "00010" =>
				temp_rd_s0 <= not rd;
				if(rd = '0') then
					iedcba <= "101101";
				else
					iedcba <= "010010";
				end if;
			when "00011" =>
				temp_rd_s0 <= rd;
				iedcba <= "100011";
			when "00100" =>
				temp_rd_s0 <= not rd;
				if(rd = '0') then
					iedcba <= "101011";
				else
					iedcba <= "010100";
				end if;
			when "00101" =>
				temp_rd_s0 <= rd;
				iedcba <= "100101";
			when "00110" =>
				temp_rd_s0 <= rd;
				iedcba <= "100110";
			when "00111" =>
				temp_rd_s0 <= rd;
				if(rd = '0') then
					iedcba <= "000111";
				else
					iedcba <= "111000";
				end if;
			when "01000" =>
				temp_rd_s0 <= not rd;
				if(rd = '0') then
					iedcba <= "100111";
				else
					iedcba <= "011000";
				end if;
			when "01001" =>
				temp_rd_s0 <= rd;
				iedcba <= "101001";
			when "01010" =>
				temp_rd_s0 <= rd;
				iedcba <= "101010";
			when "01011" =>
				temp_rd_s0 <= rd;
				iedcba <= "001011";
			when "01100" =>
				temp_rd_s0 <= rd;
				iedcba <= "101100";
			when "01101" =>
				temp_rd_s0 <= rd;
				iedcba <= "001101";
			when "01110" =>
				temp_rd_s0 <= rd;
				iedcba <= "001110";
			when "01111" =>
				temp_rd_s0 <= not rd;
				if(rd = '0') then
					iedcba <= "111010";
				else
					iedcba <= "000101";
				end if;
			when "10000" =>
				temp_rd_s0 <= not rd;
				if(rd = '0') then
					iedcba <= "110110";
				else
					iedcba <= "001001";
				end if;
			when "10001" =>
				temp_rd_s0 <= rd;
				iedcba <= "110001";
			when "10010" =>
				temp_rd_s0 <= rd;
				iedcba <= "110010";
			when "10011" =>
				temp_rd_s0 <= rd;
				iedcba <= "010011";
			when "10100" =>
				temp_rd_s0 <= rd;
				iedcba <= "110100";
			when "10101" =>
				temp_rd_s0 <= rd;
				iedcba <= "010101";
			when "10110" =>
				temp_rd_s0 <= rd;
				iedcba <= "010110";
			when "10111" =>
				temp_rd_s0 <= not rd;
				if(rd = '0') then
					iedcba <= "010111";
				else
					iedcba <= "101000";
				end if;
			when "11000" =>
				temp_rd_s0 <= not rd;
				if(rd = '0') then
					iedcba <= "110011";
				else
					iedcba <= "001100";
				end if;
			when "11001" =>
				temp_rd_s0 <= rd;
				iedcba <= "011001";
			when "11010" =>
				temp_rd_s0 <= rd;
				iedcba <= "011010";
			when "11011" =>
				temp_rd_s0 <= not rd;
				if(rd = '0') then
					iedcba <= "011011";
				else
					iedcba <= "100100";
				end if;
			when "11100" =>
				temp_rd_s0 <= rd;
				iedcba <= "011100";
			when "11101" =>
				temp_rd_s0 <= not rd;
				if(rd = '0') then
					iedcba <= "011101";
				else
					iedcba <= "100010";
				end if;
			when "11110" =>
				temp_rd_s0 <= not rd;
				if(rd = '0') then
					iedcba <= "011110";
				else
					iedcba <= "100001";
				end if;
			when "11111" =>
				temp_rd_s0 <= not rd;
				if(rd = '0') then
					iedcba <= "110101";
				else
					iedcba <= "001010";
				end if;
			when others =>
		end case;
	end process;
	
	dxA <= '1' when (((EDCBA = 17 or EDCBA = 18 or EDCBA = 20) and temp_rd_s0 = '0') or
					 ((EDCBA = 11 or EDCBA = 13 or EDCBA = 14) and temp_rd_s0 = '1'))
					 else '0';

	process(HGF, EDCBA, dxA, temp_rd_s0)
	begin
		case HGF is
			when "000" =>
				temp_rd_k0 <= not temp_rd_s0;
				if(temp_rd_s0 = '0') then
					jhgf <= "1101";
				else
					jhgf <= "0010";
				end if;
			when "001" =>
				temp_rd_k0 <= temp_rd_s0;
				jhgf <= "1001";
			when "010" =>
				temp_rd_k0 <= temp_rd_s0;
				jhgf <= "1010";
			when "011" =>
				temp_rd_k0 <= not temp_rd_s0;
				if(temp_rd_s0 = '0') then
					jhgf <= "0011";
				else
					jhgf <= "1100";
				end if;
			when "100" =>
				temp_rd_k0 <= not temp_rd_s0;
				if(temp_rd_s0 = '0') then
					jhgf <= "1011";
				else
					jhgf <= "0100";
				end if;
			when "101" =>
				temp_rd_k0 <= temp_rd_s0;
				jhgf <= "0101";
			when "110" =>
				temp_rd_k0 <= temp_rd_s0;
				jhgf <= "0110";
			when "111" =>
				temp_rd_k0 <= not temp_rd_s0;
				if(dxA = '0') then
					if(temp_rd_s0 = '0') then
						jhgf <= "0111";
					else
						jhgf <= "1000";
					end if;
				else
					if(temp_rd_s0 = '0') then
						jhgf <= "1110";
					else
						jhgf <= "0001";
					end if;
				end if;
			when others =>
		end case;
	end process;
					
		
	

end Behavioral;

