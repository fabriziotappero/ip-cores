--
-- AT90Sxxxx compatible microcontroller core
--
-- Version : 0221
--
-- Copyright (c) 2001-2002 Daniel Wallner (jesus@opencores.org)
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
--	http://www.opencores.org/cvsweb.shtml/t51/
--
-- Limitations :
--
-- File history :
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.AX_Pack.all;

entity AX_ALU is
	generic(
		TriState	: boolean := false
	);
	port(
		Clk			: in std_logic;
		ROM_Data	: in std_logic_vector(15 downto 0);
		A			: in std_logic_vector(7 downto 0);
		B			: in std_logic_vector(7 downto 0);
		Q			: out std_logic_vector(7 downto 0);
		SREG		: in std_logic_vector(7 downto 0);
		PassB		: in std_logic;
		Skip		: in std_logic;
		Do_Other	: out std_logic;
		Z_Skip		: out std_logic;
		Status_D	: out std_logic_vector(6 downto 0);
		Status_Wr	: out std_logic_vector(6 downto 0)	-- T,H,S,V,N,Z,C
	);
end AX_ALU;

architecture rtl of AX_ALU is

	signal	Do_NEG			: std_logic;
	signal	Do_ADD			: std_logic;
	signal	Do_SUB			: std_logic;
	signal	Do_DEC			: std_logic;
	signal	Do_INC			: std_logic;
	signal	Do_AND			: std_logic;
	signal	Do_OR			: std_logic;
	signal	Do_XOR			: std_logic;
	signal	Do_COM			: std_logic;
	signal	Do_SWAP			: std_logic;
	signal	Do_BLD			: std_logic;
	signal	Do_BST			: std_logic;
	signal	Do_ROR			: std_logic;
	signal	Do_ASR			: std_logic;
	signal	Do_LSR			: std_logic;
	signal	Do_PASSB		: std_logic;
	signal	Do_SBRC			: std_logic;
	signal	Do_SBRS			: std_logic;
	signal	Use_Carry		: std_logic;

	signal	Bit_Pattern		: std_logic_vector(7 downto 0);
	signal	Bit_Test		: std_logic_vector(7 downto 0);

	signal	Q_i				: std_logic_vector(7 downto 0);
	signal	Q_L				: std_logic_vector(7 downto 0);
	signal	Q_C				: std_logic_vector(7 downto 0);
	signal	Q_S				: std_logic_vector(7 downto 0);
	signal	Q_R				: std_logic_vector(7 downto 0);
	signal	Q_B				: std_logic_vector(7 downto 0);

	-- AddSub intermediate signals
	signal	Carry7_v		: std_logic;
	signal	Overflow_v		: std_logic;
	signal	Overflow_t		: std_logic;
	signal	HalfCarry_v		: std_logic;
	signal	Carry_v			: std_logic;
	signal	Q_v				: std_logic_vector(7 downto 0);
	signal	AAS				: std_logic_vector(7 downto 0);
	signal	BAS				: std_logic_vector(7 downto 0);

begin

	Q <= Q_i;

	Do_Other <= Do_PASSB;

	gNoTri : if not TriState generate
		Q_i <= Q_v when Do_ADD = '1' or Do_SUB = '1' else
			Q_L when Do_AND = '1' or Do_OR = '1' or Do_XOR = '1' else
			Q_C when Do_COM = '1' else
			Q_S when Do_SWAP = '1' else
			Q_R when Do_ASR = '1' or Do_LSR = '1' or Do_ROR = '1' else
			Q_B;
	end generate;

	gTri : if TriState generate
		Q_i <= Q_v when Do_ADD = '1' or Do_SUB = '1' else "ZZZZZZZZ";
		Q_i <= Q_L when Do_AND = '1' or Do_OR = '1' or Do_XOR = '1' else "ZZZZZZZZ";
		Q_i <= Q_C when Do_COM = '1' else "ZZZZZZZZ";
		Q_i <= Q_S when Do_SWAP = '1' else "ZZZZZZZZ";
		Q_i <= Q_R when Do_ASR = '1' or Do_LSR = '1' or Do_ROR = '1' else "ZZZZZZZZ";
		Q_i <= Q_B when Do_BLD = '1' else "ZZZZZZZZ";
	end generate;

	process (Clk)
	begin
		if Clk'event and Clk = '1' then
			Do_SUB <= '0';
			Do_ADD <= '0';
			Use_Carry <= '0';
			Do_AND <= '0';
			Do_XOR <= '0';
			Do_OR <= '0';
			Do_SWAP <= '0';
			Do_ASR <= '0';
			Do_LSR <= '0';
			Do_ROR <= '0';
			Do_INC <= '0';
			Do_DEC <= '0';
			Do_COM <= '0';
			Do_NEG <= '0';
			Do_BLD <= '0';
			Do_BST <= '0';
			Do_PASSB <= '0';
			Do_SBRC <= '0';
			Do_SBRS <= '0';
			if PassB = '0' then
			if Skip = '0' then
			if ROM_Data(15 downto 10) = "000101" or ROM_Data(15 downto 12) = "0011" or
				ROM_Data(15 downto 10) = "000110" or ROM_Data(15 downto 12) = "0101" or
				ROM_Data(15 downto 12) = "0100" or ROM_Data(15 downto 10) = "000001" or
				ROM_Data(15 downto 10) = "000010" or
				(ROM_Data(15 downto 9) = "1001010" and ROM_Data(3 downto 0) = "0001") or
				(ROM_Data(15 downto 9) = "1001010" and ROM_Data(3 downto 0) = "1010") then
				-- CP, CPI, SUB, SUBI, SBCI, CPC, SBC, NEG, DEC
				Do_SUB <= '1';
			end if;
			if ROM_Data(15 downto 10) = "000011" or ROM_Data(15 downto 10) = "000111" or
				(ROM_Data(15 downto 9) = "1001010" and ROM_Data(3 downto 0) = "0011") then
				-- ADD, ADC, INC
				Do_ADD <= '1';
			end if;
			if ROM_Data(15 downto 12) = "0100" or ROM_Data(15 downto 10) = "000001" or
				ROM_Data(15 downto 10) = "000010" or ROM_Data(15 downto 10) = "000111" then
				-- SBCI, CPC, SBC, ADC
				Use_Carry <= '1';
			end if;
			if ROM_Data(15 downto 10) = "001000" or ROM_Data(15 downto 12) = "0111" then
				-- AND, ANDI
				Do_AND <= '1';
			end if;
			if ROM_Data(15 downto 10) = "001001" then
				-- EOR
				Do_XOR <= '1';
			end if;
			if ROM_Data(15 downto 10) = "001010" or ROM_Data(15 downto 12) = "0110" then
				-- OR, ORI
				Do_OR <= '1';
			end if;
			if ROM_Data(15 downto 9) = "1001010" and ROM_Data(3 downto 0) = "0010" then
				-- SWAP
				Do_SWAP <= '1';
			end if;
			if ROM_Data(15 downto 9) = "1001010" and ROM_Data(3 downto 0) = "0101" then
				-- ASR
				Do_ASR <= '1';
			end if;
			if ROM_Data(15 downto 9) = "1001010" and ROM_Data(3 downto 0) = "0110" then
				-- LSR
				Do_LSR <= '1';
			end if;
			if ROM_Data(15 downto 9) = "1001010" and ROM_Data(3 downto 0) = "0111" then
				-- ROR
				Do_ROR <= '1';
			end if;
			if ROM_Data(15 downto 9) = "1001010" and ROM_Data(3 downto 0) = "0011" then
				-- INC
				Do_INC <= '1';
			end if;
			if ROM_Data(15 downto 9) = "1001010" and ROM_Data(3 downto 0) = "1010" then
				-- DEC
				Do_DEC <= '1';
			end if;
			if ROM_Data(15 downto 9) = "1001010" and ROM_Data(3 downto 0) = "0000" then
				-- COM
				Do_COM <= '1';
			end if;
			if ROM_Data(15 downto 9) = "1001010" and ROM_Data(3 downto 0) = "0001" then
				-- NEG
				Do_NEG <= '1';
			end if;
			if ROM_Data(15 downto 9) = "1111100" then
				-- BLD
				Do_BLD <= '1';
			end if;
			if ROM_Data(15 downto 9) = "1111101" then
				-- BST
				Do_BST <= '1';
			end if;
			if ROM_Data(15 downto 10) = "001011" or
				ROM_Data(15 downto 12) = "1011" or
				ROM_Data(15 downto 12) = "1110" then
				-- MOV, DidPause, IN, OUT, LDI
				Do_PASSB <= '1';
			end if;
			if ROM_Data(15 downto 9) = "1111110" then
				-- SBRC
				Do_SBRC <= '1';
			else
				Do_SBRC <= '0';
			end if;
			if ROM_Data(15 downto 9) = "1111111" then
				-- SBRS
				Do_SBRS <= '1';
			else
				Do_SBRS <= '0';
			end if;
			end if;
			else
				Do_PASSB <= '1';
			end if;

			case ROM_Data(2 downto 0) is
			when "000" =>
				Bit_Pattern <= "00000001";
			when "001" =>
				Bit_Pattern <= "00000010";
			when "010" =>
				Bit_Pattern <= "00000100";
			when "011" =>
				Bit_Pattern <= "00001000";
			when "100" =>
				Bit_Pattern <= "00010000";
			when "101" =>
				Bit_Pattern <= "00100000";
			when "110" =>
				Bit_Pattern <= "01000000";
			when others =>
				Bit_Pattern <= "10000000";
			end case;
		end if;
	end process;

	Bit_Test <= Bit_Pattern and A;

	Z_Skip <= '1' when ((Bit_Test /= "00000000") and (Do_SBRS = '1')) or
					((Bit_Test = "00000000") and (Do_SBRC = '1')) else '0';

	AAS <= "00000000" when Do_NEG = '1' else A;
	BAS <= A when Do_NEG = '1' else "00000001" when Do_DEC = '1' or Do_INC = '1' else B;
	AddSub(AAS(3 downto 0), BAS(3 downto 0), Do_SUB, Do_SUB xor (Use_Carry and SREG(0)), Q_v(3 downto 0), HalfCarry_v);
	AddSub(AAS(6 downto 4), BAS(6 downto 4), Do_SUB, HalfCarry_v, Q_v(6 downto 4), Carry7_v);
	AddSub(AAS(7 downto 7), BAS(7 downto 7), Do_SUB, Carry7_v, Q_v(7 downto 7), Carry_v);
	OverFlow_v <= Carry_v xor Carry7_v;
	Status_D(5) <= HalfCarry_v xor Do_SUB;	-- H

	Q_L <= (A and B) when Do_AND = '1' else
		(A or B) when Do_OR = '1' else
		(A xor B);

	Q_C <= (not A);

	Q_S <= A(3 downto 0) & A(7 downto 4);

	Q_R(6 downto 0) <=  A(7 downto 1);
	Q_R(7) <= (A(7) and Do_ASR) or (SREG(0) and Do_ROR);

	Q_B <= ((not Bit_Pattern) and A) when SREG(6) = '0' else
			(Bit_Pattern or A);

	Status_D(6) <= '1' when (Bit_Pattern and A) /= "00000000" else '0';

	Overflow_t <= Overflow_v when Do_SUB = '1' or Do_ADD = '1' else
		Q_i(7) xor A(0) when (Do_ASR or Do_LSR or Do_ROR) = '1' else '0';	-- V
	Status_D(3) <= Overflow_t;
	Status_D(2) <= Q_i(7);	-- N
	Status_D(4) <= Overflow_t xor Q_i(7);	-- SREG(3) xor SREG(2);		-- S
	Status_D(1) <= '1' when Q_i(7 downto 0) = "00000000" and (Do_SUB = '0' or Use_Carry = '0') else
		SREG(1) when Q_i(7 downto 0) = "00000000" and Do_SUB = '1' and Use_Carry = '1' else '0';	-- Z
	Status_D(0) <= ((Carry_v xor Do_SUB) and (Do_ADD or Do_SUB)) or
					(A(0) and (Do_ASR or Do_LSR or Do_ROR)) or Do_COM;

	process (Do_SUB, Do_ADD, Do_COM, Do_ASR, Do_LSR, Do_ROR, Do_AND, Do_XOR, Do_OR, Do_INC, Do_DEC, Do_BST)
	begin
		Status_Wr <= "0000000";
		if (Do_COM or Do_ASR or Do_LSR or Do_ROR) = '1' then
			Status_Wr <= "0011111"; -- Z,C,N,V	,S
		end if;
		if (Do_AND or Do_XOR or Do_OR or Do_INC or Do_DEC) = '1' then
			Status_Wr <= "0011110"; -- Z,N,V	,S
		elsif (Do_SUB or Do_ADD) = '1' then
			Status_Wr <= "0111111"; -- Z,C,N,V,H	,S
		end if;
		if Do_BST = '1' then
			Status_Wr <= "1000000"; -- T
		end if;
	end process;

end;
