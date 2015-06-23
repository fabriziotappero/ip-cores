--
-- 65xx compatible microprocessor core
--
-- Version : 0246
--
-- Copyright (c) 2002 Daniel Wallner (jesus@opencores.org)
--
-- All rights reserved
--
-- Redistribution and use in source and synthezised forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
-- Redistributions of source code must retain the above copyright notice,
-- this list of conditions and the following disclaimer.
--
-- Redistributions in synthesized form must reproduce the above copyright
-- notice, this list of conditions and the following disclaimer in the
-- documentation and/or other materials provided with the distribution.
--
-- Neither the name of the author nor the names of other contributors may
-- be used to endorse or promote products derived from this software without
-- specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
--
-- Please report bugs to the author, but before you do so, please
-- make sure that this is not a derivative work and that
-- you have the latest version of this file.
--
-- The latest version of this file can be found at:
--	http://www.opencores.org/cvsweb.shtml/t65/
--
-- Limitations :
--
-- 65C02
-- supported : inc, dec, phx, plx, phy, ply
-- missing : bra, ora, lda, cmp, sbc, tsb*2, trb*2, stz*2, bit*2, wai, stp, jmp, bbr*8, bbs*8
--
-- File history :
--
--	0246 : First release
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.T65_Pack.all;

entity T65_MCode is
	port(
		Mode			: in std_logic_vector(1 downto 0);	-- "00" => 6502, "01" => 65C02, "10" => 65816
		IR				: in std_logic_vector(7 downto 0);
		MCycle			: in std_logic_vector(2 downto 0);
		P				: in std_logic_vector(7 downto 0);
		LCycle			: out std_logic_vector(2 downto 0);
		ALU_Op			: out std_logic_vector(3 downto 0);
		Set_BusA_To		: out std_logic_vector(2 downto 0); -- DI,A,X,Y,S,P
		Set_Addr_To		: out std_logic_vector(1 downto 0); -- PC Adder,S,AD,BA
		Write_Data		: out std_logic_vector(2 downto 0); -- DL,A,X,Y,S,P,PCL,PCH
		Jump			: out std_logic_vector(1 downto 0); -- PC,++,DIDL,Rel
		BAAdd			: out std_logic_vector(1 downto 0);	-- None,DB Inc,BA Add,BA Adj
		BreakAtNA		: out std_logic;
		ADAdd			: out std_logic;
		PCAdd			: out std_logic;
		Inc_S			: out std_logic;
		Dec_S			: out std_logic;
		LDA				: out std_logic;
		LDP				: out std_logic;
		LDX				: out std_logic;
		LDY				: out std_logic;
		LDS				: out std_logic;
		LDDI			: out std_logic;
		LDALU			: out std_logic;
		LDAD			: out std_logic;
		LDBAL			: out std_logic;
		LDBAH			: out std_logic;
		SaveP			: out std_logic;
		Write			: out std_logic
	);
end T65_MCode;

architecture rtl of T65_MCode is

	signal Branch : std_logic;

begin

	with IR(7 downto 5) select
		Branch <= not P(Flag_N) when "000",
			P(Flag_N) when "001",
			not P(Flag_V) when "010",
			P(Flag_V) when "011",
			not P(Flag_C) when "100",
			P(Flag_C) when "101",
			not P(Flag_Z) when "110",
			P(Flag_Z) when others;

	process (IR, MCycle, P, Branch, Mode)
	begin
		LCycle <= "001";
		Set_BusA_To <= "001"; -- A
		Set_Addr_To <= (others => '0');
		Write_Data <= (others => '0');
		Jump <= (others => '0');
		BAAdd <= "00";
		BreakAtNA <= '0';
		ADAdd <= '0';
		PCAdd <= '0';
		Inc_S <= '0';
		Dec_S <= '0';
		LDA <= '0';
		LDP <= '0';
		LDX <= '0';
		LDY <= '0';
		LDS <= '0';
		LDDI <= '0';
		LDALU <= '0';
		LDAD <= '0';
		LDBAL <= '0';
		LDBAH <= '0';
		SaveP <= '0';
		Write <= '0';

		case IR(7 downto 5) is
		when "100" =>
			case IR(1 downto 0) is
			when "00" =>
				Set_BusA_To <= "011"; -- Y
				Write_Data <= "011"; -- Y
			when "10" =>
				Set_BusA_To <= "010"; -- X
				Write_Data <= "010"; -- X
			when others =>
				Write_Data <= "001"; -- A
			end case;
		when "101" =>
			case IR(1 downto 0) is
			when "00" =>
				if IR(4) /= '1' or IR(2) /= '0' then
					LDY <= '1';
				end if;
			when "10" =>
				LDX <= '1';
			when others =>
				LDA <= '1';
			end case;
			Set_BusA_To <= "000"; -- DI
		when "110" =>
			case IR(1 downto 0) is
			when "00" =>
				if IR(4) = '0' then
					LDY <= '1';
				end if;
				Set_BusA_To <= "011"; -- Y
			when others =>
				Set_BusA_To <= "001"; -- A
			end case;
		when "111" =>
			case IR(1 downto 0) is
			when "00" =>
				if IR(4) = '0' then
					LDX <= '1';
				end if;
				Set_BusA_To <= "010"; -- X
			when others =>
				Set_BusA_To <= "001"; -- A
			end case;
		when others =>
		end case;

		if IR(7 downto 6) /= "10" and IR(1 downto 0) = "10" then
			Set_BusA_To <= "000"; -- DI
		end if;

		case IR(4 downto 0) is
		when "00000" | "01000" | "01010" | "11000" | "11010" =>
			-- Implied
			case IR is
			when "00000000" =>
				-- BRK
				LCycle <= "110";
				case to_integer(unsigned(MCycle)) is
				when 1 =>
					Set_Addr_To <= "01"; -- S
					Write_Data <= "111"; -- PCH
					Write <= '1';
				when 2 =>
					Dec_S <= '1';
					Set_Addr_To <= "01"; -- S
					Write_Data <= "110"; -- PCL
					Write <= '1';
				when 3 =>
					Dec_S <= '1';
					Set_Addr_To <= "01"; -- S
					Write_Data <= "101"; -- P
					Write <= '1';
				when 4 =>
					Dec_S <= '1';
					Set_Addr_To <= "11"; -- BA
				when 5 =>
					LDDI <= '1';
					Set_Addr_To <= "11"; -- BA
				when 6 =>
					Jump <= "10"; -- DIDL
				when others =>
				end case;
			when "00100000" =>
				-- JSR
				LCycle <= "101";
				case to_integer(unsigned(MCycle)) is
				when 1 =>
					Jump <= "01";
					LDDI <= '1';
					Set_Addr_To <= "01"; -- S
				when 2 =>
					Set_Addr_To <= "01"; -- S
					Write_Data <= "111"; -- PCH
					Write <= '1';
				when 3 =>
					Dec_S <= '1';
					Set_Addr_To <= "01"; -- S
					Write_Data <= "110"; -- PCL
					Write <= '1';
				when 4 =>
					Dec_S <= '1';
				when 5 =>
					Jump <= "10"; -- DIDL
				when others =>
				end case;
			when "01000000" =>
				-- RTI
				LCycle <= "101";
				case to_integer(unsigned(MCycle)) is
				when 1 =>
					Set_Addr_To <= "01"; -- S
				when 2 =>
					Inc_S <= '1';
					Set_Addr_To <= "01"; -- S
				when 3 =>
					Inc_S <= '1';
					Set_Addr_To <= "01"; -- S
					Set_BusA_To <= "000"; -- DI
				when 4 =>
					LDP <= '1';
					Inc_S <= '1';
					LDDI <= '1';
					Set_Addr_To <= "01"; -- S
				when 5 =>
					Jump <= "10"; -- DIDL
				when others =>
				end case;
			when "01100000" =>
				-- RTS
				LCycle <= "101";
				case to_integer(unsigned(MCycle)) is
				when 1 =>
					Set_Addr_To <= "01"; -- S
				when 2 =>
					Inc_S <= '1';
					Set_Addr_To <= "01"; -- S
				when 3 =>
					Inc_S <= '1';
					LDDI <= '1';
					Set_Addr_To <= "01"; -- S
				when 4 =>
					Jump <= "10"; -- DIDL
				when 5 =>
					Jump <= "01";
				when others =>
				end case;
			when "00001000" | "01001000" | "01011010" | "11011010" =>
				-- PHP, PHA, PHY*, PHX*
				LCycle <= "010";
				if Mode = "00" and IR(1) = '1' then
					LCycle <= "001";
				end if;
				case to_integer(unsigned(MCycle)) is
				when 1 =>
					case IR(7 downto 4) is
					when "0000" =>
						Write_Data <= "101"; -- P
					when "0100" =>
						Write_Data <= "001"; -- A
					when "0101" =>
						Write_Data <= "011"; -- Y
					when "1101" =>
						Write_Data <= "010"; -- X
					when others =>
					end case;
					Write <= '1';
					Set_Addr_To <= "01"; -- S
				when 2 =>
					Dec_S <= '1';
				when others =>
				end case;
			when "00101000" | "01101000" | "01111010" | "11111010" =>
				-- PLP, PLA, PLY*, PLX*
				LCycle <= "011";
				if Mode = "00" and IR(1) = '1' then
					LCycle <= "001";
				end if;
				case IR(7 downto 4) is
				when "0010" =>
					LDP <= '1';
				when "0110" =>
					LDA <= '1';
				when "0111" =>
					if Mode /= "00" then
						LDY <= '1';
					end if;
				when "1111" =>
					if Mode /= "00" then
						LDX <= '1';
					end if;
				when others =>
				end case;
				case to_integer(unsigned(MCycle)) is
				when 0 =>
					SaveP <= '1';
				when 1 =>
					Set_Addr_To <= "01"; -- S
				when 2 =>
					Inc_S <= '1';
					Set_Addr_To <= "01"; -- S
				when 3 =>
					Set_BusA_To <= "000"; -- DI
				when others =>
				end case;
			when "10100000" | "11000000" | "11100000" =>
				-- LDY, CPY, CPX
				-- Immediate
				case to_integer(unsigned(MCycle)) is
				when 0 =>
				when 1 =>
					Jump <= "01";
				when others =>
				end case;
			when "10001000" =>
				-- DEY
				LDY <= '1';
				case to_integer(unsigned(MCycle)) is
				when 0 =>
				when 1 =>
					Set_BusA_To <= "011"; -- Y
				when others =>
				end case;
			when "11001010" =>
				-- DEX
				LDX <= '1';
				case to_integer(unsigned(MCycle)) is
				when 0 =>
				when 1 =>
					Set_BusA_To <= "010"; -- X
				when others =>
				end case;
			when "00011010" | "00111010" =>
				-- INC*, DEC*
				if Mode /= "00" then
					LDA <= '1'; -- A
				end if;
				case to_integer(unsigned(MCycle)) is
				when 0 =>
				when 1 =>
					Set_BusA_To <= "100"; -- S
				when others =>
				end case;
			when "00001010" | "00101010" | "01001010" | "01101010" =>
				-- ASL, ROL, LSR, ROR
				LDA <= '1'; -- A
				Set_BusA_To <= "001"; -- A
				case to_integer(unsigned(MCycle)) is
				when 0 =>
				when 1 =>
				when others =>
				end case;
			when "10001010" | "10011000" =>
				-- TYA, TXA
				LDA <= '1'; -- A
				case to_integer(unsigned(MCycle)) is
				when 0 =>
				when 1 =>
				when others =>
				end case;
			when "10101010" | "10101000" =>
				-- TAX, TAY
				case to_integer(unsigned(MCycle)) is
				when 0 =>
				when 1 =>
					Set_BusA_To <= "001"; -- A
				when others =>
				end case;
			when "10011010" =>
				-- TXS
				case to_integer(unsigned(MCycle)) is
				when 0 =>
					LDS <= '1';
				when 1 =>
				when others =>
				end case;
			when "10111010" =>
				-- TSX
				LDX <= '1';
				case to_integer(unsigned(MCycle)) is
				when 0 =>
				when 1 =>
					Set_BusA_To <= "100"; -- S
				when others =>
				end case;

--			when "00011000" | "00111000" | "01011000" | "01111000" | "10111000" | "11011000" | "11111000" | "11001000" | "11101000" =>
--				-- CLC, SEC, CLI, SEI, CLV, CLD, SED, INY, INX
--				case to_integer(unsigned(MCycle)) is
--				when 1 =>
--				when others =>
--				end case;
			when others =>
				case to_integer(unsigned(MCycle)) is
				when 0 =>
				when others =>
				end case;
			end case;

		when "00001" | "00011" =>
			-- Zero Page Indexed Indirect (d,x)
			LCycle <= "101";
			if IR(7 downto 6) /= "10" then
				LDA <= '1';
			end if;
			case to_integer(unsigned(MCycle)) is
			when 0 =>
			when 1 =>
				Jump <= "01";
				LDAD <= '1';
				Set_Addr_To <= "10"; -- AD
			when 2 =>
				ADAdd <= '1';
				Set_Addr_To <= "10"; -- AD
			when 3 =>
				BAAdd <= "01";	-- DB Inc
				LDBAL <= '1';
				Set_Addr_To <= "10"; -- AD
			when 4 =>
				LDBAH <= '1';
				if IR(7 downto 5) = "100" then
					Write <= '1';
				end if;
				Set_Addr_To <= "11"; -- BA
			when 5 =>
			when others =>
			end case;

		when "01001" | "01011" =>
			-- Immediate
			LDA <= '1';
			case to_integer(unsigned(MCycle)) is
			when 0 =>
			when 1 =>
				Jump <= "01";
			when others =>
			end case;

		when "00010" | "10010" =>
			-- Immediate, KIL
			LDX <= '1';
			case to_integer(unsigned(MCycle)) is
			when 0 =>
			when 1 =>
				if IR = "10100010" then
					-- LDX
					Jump <= "01";
				else
					-- KIL !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				end if;
			when others =>
			end case;

		when "00100" =>
			-- Zero Page
			LCycle <= "010";
			case to_integer(unsigned(MCycle)) is
			when 0 =>
				if IR(7 downto 5) = "001" then
					SaveP <= '1';
				end if;
			when 1 =>
				Jump <= "01";
				LDAD <= '1';
				if IR(7 downto 5) = "100" then
					Write <= '1';
				end if;
				Set_Addr_To <= "10"; -- AD
			when 2 =>
			when others =>
			end case;

		when "00101" | "00110" | "00111" =>
			-- Zero Page
			if IR(7 downto 6) /= "10" and IR(1 downto 0) = "10" then
				-- Read-Modify-Write
				LCycle <= "100";
				case to_integer(unsigned(MCycle)) is
				when 1 =>
					Jump <= "01";
					LDAD <= '1';
					Set_Addr_To <= "10"; -- AD
				when 2 =>
					LDDI <= '1';
					Write <= '1';
					Set_Addr_To <= "10"; -- AD
				when 3 =>
					LDALU <= '1';
					SaveP <= '1';
					Write <= '1';
					Set_Addr_To <= "10"; -- AD
				when 4 =>
				when others =>
				end case;
			else
				LCycle <= "010";
				if IR(7 downto 6) /= "10" then
					LDA <= '1';
				end if;
				case to_integer(unsigned(MCycle)) is
				when 0 =>
				when 1 =>
					Jump <= "01";
					LDAD <= '1';
					if IR(7 downto 5) = "100" then
						Write <= '1';
					end if;
					Set_Addr_To <= "10"; -- AD
				when 2 =>
				when others =>
				end case;
			end if;

		when "01100" =>
			-- Absolute
			if IR(7 downto 6) = "01" and IR(4 downto 0) = "01100" then
				-- JMP
				if IR(5) = '0' then
					LCycle <= "011";
					case to_integer(unsigned(MCycle)) is
					when 2 =>
						Jump <= "01";
						LDDI <= '1';
					when 3 =>
						Jump <= "10"; -- DIDL
					when others =>
					end case;
				else
					LCycle <= "101";
					case to_integer(unsigned(MCycle)) is
					when 2 =>
						Jump <= "01";
						LDDI <= '1';
						LDBAL <= '1';
					when 3 =>
						LDBAH <= '1';
						if Mode /= "00" then
							Jump <= "10"; -- DIDL
						end if;
						if Mode = "00" then
							Set_Addr_To <= "11"; -- BA
						end if;
					when 4 =>
						LDDI <= '1';
						if Mode = "00" then
							Set_Addr_To <= "11"; -- BA
							BAAdd <= "01";	-- DB Inc
						else
							Jump <= "01";
						end if;
					when 5 =>
						Jump <= "10"; -- DIDL
					when others =>
					end case;
				end if;
			else
				LCycle <= "011";
				case to_integer(unsigned(MCycle)) is
				when 0 =>
					if IR(7 downto 5) = "001" then
						SaveP <= '1';
					end if;
				when 1 =>
					Jump <= "01";
					LDBAL <= '1';
				when 2 =>
					Jump <= "01";
					LDBAH <= '1';
					if IR(7 downto 5) = "100" then
						Write <= '1';
					end if;
					Set_Addr_To <= "11"; -- BA
				when 3 =>
				when others =>
				end case;
			end if;

		when "01101" | "01110" | "01111" =>
			-- Absolute
			if IR(7 downto 6) /= "10" and IR(1 downto 0) = "10" then
				-- Read-Modify-Write
				LCycle <= "101";
				case to_integer(unsigned(MCycle)) is
				when 1 =>
					Jump <= "01";
					LDBAL <= '1';
				when 2 =>
					Jump <= "01";
					LDBAH <= '1';
					Set_Addr_To <= "11"; -- BA
				when 3 =>
					LDDI <= '1';
					Write <= '1';
					Set_Addr_To <= "11"; -- BA
				when 4 =>
					Write <= '1';
					LDALU <= '1';
					SaveP <= '1';
					Set_Addr_To <= "11"; -- BA
				when 5 =>
					SaveP <= '1';
				when others =>
				end case;
			else
				LCycle <= "011";
				if IR(7 downto 6) /= "10" then
					LDA <= '1';
				end if;
				case to_integer(unsigned(MCycle)) is
				when 0 =>
				when 1 =>
					Jump <= "01";
					LDBAL <= '1';
				when 2 =>
					Jump <= "01";
					LDBAH <= '1';
					if IR(7 downto 5) = "100" then
						Write <= '1';
					end if;
					Set_Addr_To <= "11"; -- BA
				when 3 =>
				when others =>
				end case;
			end if;

		when "10000" =>
			-- Relative
			if Branch = '1' then
				LCycle <= "100";
			else
				LCycle <= "010";
			end if;
			case to_integer(unsigned(MCycle)) is
			when 2 =>
				Jump <= "01";
				LDDI <= '1';
			when 3 =>
				Jump <= "11"; -- Rel
				PCAdd <= '1';
			when 4 =>
			when others =>
			end case;

		when "10001" | "10011" =>
			-- Zero Page Indirect Indexed (d),y
			LCycle <= "101";
			if IR(7 downto 6) /= "10" then
				LDA <= '1';
			end if;
			case to_integer(unsigned(MCycle)) is
			when 0 =>
			when 1 =>
				Jump <= "01";
				LDAD <= '1';
				Set_Addr_To <= "10"; -- AD
			when 2 =>
				LDBAL <= '1';
				BAAdd <= "01";	-- DB Inc
				Set_Addr_To <= "10"; -- AD
			when 3 =>
				Set_BusA_To <= "011"; -- Y
				BAAdd <= "10";	-- BA Add
				LDBAH <= '1';
				Set_Addr_To <= "11"; -- BA
			when 4 =>
				BAAdd <= "11";	-- BA Adj
				if IR(7 downto 5) = "100" then
					Write <= '1';
				else
					BreakAtNA <= '1';
				end if;
				Set_Addr_To <= "11"; -- BA
			when 5 =>
			when others =>
			end case;

		when "10100" | "10101" | "10110" | "10111" =>
			-- Zero Page, X
			if IR(7 downto 6) /= "10" and IR(1 downto 0) = "10" then
				-- Read-Modify-Write
				LCycle <= "101";
				case to_integer(unsigned(MCycle)) is
				when 1 =>
					Jump <= "01";
					LDAD <= '1';
					Set_Addr_To <= "10"; -- AD
				when 2 =>
					ADAdd <= '1';
					Set_Addr_To <= "10"; -- AD
				when 3 =>
					LDDI <= '1';
					Write <= '1';
					Set_Addr_To <= "10"; -- AD
				when 4 =>
					LDALU <= '1';
					SaveP <= '1';
					Write <= '1';
					Set_Addr_To <= "10"; -- AD
				when 5 =>
				when others =>
				end case;
			else
				LCycle <= "011";
				if IR(7 downto 6) /= "10" then
					LDA <= '1';
				end if;
				case to_integer(unsigned(MCycle)) is
				when 0 =>
				when 1 =>
					Jump <= "01";
					LDAD <= '1';
					Set_Addr_To <= "10"; -- AD
				when 2 =>
					ADAdd <= '1';
					if IR(7 downto 5) = "100" then
						Write <= '1';
					end if;
					Set_Addr_To <= "10"; -- AD
				when 3 =>
				when others =>
				end case;
			end if;

		when "11001" | "11011" =>
			-- Absolute Y
			LCycle <= "100";
			if IR(7 downto 6) /= "10" then
				LDA <= '1';
			end if;
			case to_integer(unsigned(MCycle)) is
			when 0 =>
			when 1 =>
				Jump <= "01";
				LDBAL <= '1';
			when 2 =>
				Jump <= "01";
				Set_BusA_To <= "011"; -- Y
				BAAdd <= "10";	-- BA Add
				LDBAH <= '1';
				Set_Addr_To <= "11"; -- BA
			when 3 =>
				BAAdd <= "11";	-- BA adj
				if IR(7 downto 5) = "100" then
					Write <= '1';
				else
					BreakAtNA <= '1';
				end if;
				Set_Addr_To <= "11"; -- BA
			when 4 =>
			when others =>
			end case;

		when "11100" | "11101" | "11110" | "11111" =>
			-- Absolute X
			if IR(7 downto 6) /= "10" and IR(1 downto 0) = "10" then
				-- Read-Modify-Write
				LCycle <= "110";
				case to_integer(unsigned(MCycle)) is
				when 1 =>
					Jump <= "01";
					LDBAL <= '1';
				when 2 =>
					Jump <= "01";
					Set_BusA_To <= "010"; -- X
					BAAdd <= "10";	-- BA Add
					LDBAH <= '1';
					Set_Addr_To <= "11"; -- BA
				when 3 =>
					BAAdd <= "11";	-- BA adj
					Set_Addr_To <= "11"; -- BA
				when 4 =>
					LDDI <= '1';
					Write <= '1';
					Set_Addr_To <= "11"; -- BA
				when 5 =>
					LDALU <= '1';
					SaveP <= '1';
					Write <= '1';
					Set_Addr_To <= "11"; -- BA
				when 6 =>
				when others =>
				end case;
			else
				LCycle <= "100";
				if IR(7 downto 6) /= "10" then
					LDA <= '1';
				end if;
				case to_integer(unsigned(MCycle)) is
				when 0 =>
				when 1 =>
					Jump <= "01";
					LDBAL <= '1';
				when 2 =>
					Jump <= "01";
					Set_BusA_To <= "010"; -- X
					BAAdd <= "10";	-- BA Add
					LDBAH <= '1';
					Set_Addr_To <= "11"; -- BA
				when 3 =>
					BAAdd <= "11";	-- BA adj
					if IR(7 downto 5) = "100" then
						Write <= '1';
					else
						BreakAtNA <= '1';
					end if;
					Set_Addr_To <= "11"; -- BA
				when 4 =>
				when others =>
				end case;
			end if;
		when others =>
		end case;
	end process;

	process (IR, MCycle)
	begin
		-- ORA, AND, EOR, ADC, NOP, LD, CMP, SBC
		-- ASL, ROL, LSR, ROR, BIT, LD, DEC, INC
		case IR(1 downto 0) is
		when "00" =>
			case IR(4 downto 2) is
			when "000" | "001" | "011" =>
				case IR(7 downto 5) is
				when "110" | "111" =>
					-- CP
					ALU_Op <= "0110";
				when "101" =>
					-- LD
					ALU_Op <= "0101";
				when "001" =>
					-- BIT
					ALU_Op <= "1100";
				when others =>
					-- NOP/ST
					ALU_Op <= "0100";
				end case;
			when "010" =>
				case IR(7 downto 5) is
				when "111" | "110" =>
					-- IN
					ALU_Op <= "1111";
				when "100" =>
					-- DEY
					ALU_Op <= "1110";
				when others =>
					-- LD
					ALU_Op <= "1101";
				end case;
			when "110" =>
				case IR(7 downto 5) is
				when "100" =>
					-- TYA
					ALU_Op <= "1101";
				when others =>
					ALU_Op <= "----";
				end case;
			when others =>
				case IR(7 downto 5) is
				when "101" =>
					-- LD
					ALU_Op <= "1101";
				when others =>
					ALU_Op <= "0100";
				end case;
			end case;
		when "01" =>
			ALU_Op(3) <= '0';
			ALU_Op(2 downto 0) <= IR(7 downto 5);
		when "10" =>
			ALU_Op(3) <= '1';
			ALU_Op(2 downto 0) <= IR(7 downto 5);
			case IR(7 downto 5) is
			when "000" =>
				if IR(4 downto 2) = "110" then
					-- INC
					ALU_Op <= "1111";
				end if;
			when "001" =>
				if IR(4 downto 2) = "110" then
					-- DEC
					ALU_Op <= "1110";
				end if;
			when "100" =>
				if IR(4 downto 2) = "010" then
					-- TXA
					ALU_Op <= "0101";
				else
					ALU_Op <= "0100";
				end if;
			when others =>
			end case;
		when others =>
			case IR(7 downto 5) is
			when "100" =>
				ALU_Op <= "0100";
			when others =>
				if MCycle = "000" then
					ALU_Op(3) <= '0';
					ALU_Op(2 downto 0) <= IR(7 downto 5);
				else
					ALU_Op(3) <= '1';
					ALU_Op(2 downto 0) <= IR(7 downto 5);
				end if;
			end case;
		end case;
	end process;

end;
