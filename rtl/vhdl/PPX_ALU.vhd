--
-- PIC16xx compatible microcontroller core
--
-- Version : 0222
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

entity PPX_ALU is
	generic(
		InstructionLength : integer;
		TriState	: boolean := false
	);
	port (
		Clk			: in std_logic;
		ROM_Data	: in std_logic_vector(InstructionLength - 1 downto 0);
		A			: in std_logic_vector(7 downto 0);
		B			: in std_logic_vector(7 downto 0);
		Q			: out std_logic_vector(7 downto 0);
		Skip		: in std_logic;
		Carry		: in std_logic;
		Z_Skip		: out std_logic;
		STATUS_d	: out std_logic_vector(2 downto 0);
		STATUS_Wr	: out std_logic_vector(2 downto 0)
	);
end PPX_ALU;

architecture rtl of PPX_ALU is

	procedure AddSub(A : std_logic_vector(3 downto 0);
					B : std_logic_vector(3 downto 0);
					Sub : std_logic;
					Carry_In : std_logic;
					signal Res : out std_logic_vector(3 downto 0);
					signal Carry : out std_logic) is
		variable B_i		: unsigned(4 downto 0);
		variable Full_Carry	: unsigned(4 downto 0);
		variable Res_i		: unsigned(4 downto 0);
	begin
		if Sub = '1' then
			B_i := "0" & not unsigned(B);
		else
			B_i := "0" & unsigned(B);
		end if;
		if (Sub = '1' and Carry_In = '1') or (Sub = '0' and Carry_In = '1') then
			Full_Carry := "00001";
		else
			Full_Carry := "00000";
		end if;
		Res_i := unsigned("0" & A) + B_i + Full_Carry;
		Carry <= Res_i(4);
		Res <= std_logic_vector(Res_i(3 downto 0));
	end;

	signal	Do_IDTEST		: std_logic;
	signal	Do_ADD			: std_logic;
	signal	Do_SUB			: std_logic;
	signal	Do_DEC			: std_logic;
	signal	Do_INC			: std_logic;
	signal	Do_AND			: std_logic;
	signal	Do_OR			: std_logic;
	signal	Do_XOR			: std_logic;
	signal	Do_COM			: std_logic;
	signal	Do_RRF			: std_logic;
	signal	Do_RLF			: std_logic;
	signal	Do_SWAP			: std_logic;
	signal	Do_BITCLR		: std_logic;
	signal	Do_BITSET		: std_logic;
	signal	Do_BITTESTCLR	: std_logic;
	signal	Do_BITTESTSET	: std_logic;
	signal	Do_CLR			: std_logic;

	signal	Inst_Top		: std_logic_vector(11 downto 0);

	signal	Bit_Pattern		: std_logic_vector(7 downto 0);
	signal	Bit_Test		: std_logic_vector(7 downto 0);

	signal	Q_ID			: std_logic_vector(7 downto 0);
	signal	Q_L				: std_logic_vector(7 downto 0);
	signal	Q_C				: std_logic_vector(7 downto 0);
	signal	Q_RR			: std_logic_vector(7 downto 0);
	signal	Q_RL			: std_logic_vector(7 downto 0);
	signal	Q_S				: std_logic_vector(7 downto 0);
	signal	Q_BC			: std_logic_vector(7 downto 0);
	signal	Q_BS			: std_logic_vector(7 downto 0);

	signal	DC_i			: std_logic;
	signal	AddSubRes		: std_logic_vector(8 downto 0);

	signal	Q_i				: std_logic_vector(7 downto 0);

begin

	Q <= Q_i;

	Inst_Top <= ROM_Data(InstructionLength - 1 downto InstructionLength - 12);

	gNoTri : if not TriState generate
		Q_i <= Q_ID when Do_INC = '1' or Do_DEC = '1' else
			AddSubRes(7 downto 0) when Do_ADD = '1' OR Do_SUB = '1' else
			Q_L when Do_AND = '1' or Do_OR = '1' or Do_XOR = '1' else
			Q_C when Do_COM = '1' else
			Q_RR when Do_RRF = '1' else
			Q_RL when Do_RLF = '1' else
			Q_S when Do_SWAP = '1' else
			Q_BC when Do_BITCLR = '1' else
			Q_BS when Do_BITSET = '1' else
			"00000000";
	end generate;

	gTri : if TriState generate
		Q_i <= Q_ID when Do_INC = '1' or Do_DEC = '1' else "ZZZZZZZZ";
		Q_i <= AddSubRes(7 downto 0) when Do_ADD = '1' OR Do_SUB = '1' else "ZZZZZZZZ";
		Q_i <= Q_L when Do_AND = '1' or Do_OR = '1' or Do_XOR = '1' else "ZZZZZZZZ";
		Q_i <= Q_C when Do_COM = '1' else "ZZZZZZZZ";
		Q_i <= Q_RR when Do_RRF = '1' else "ZZZZZZZZ";
		Q_i <= Q_RL when Do_RLF = '1' else "ZZZZZZZZ";
		Q_i <= Q_S when Do_SWAP = '1' else "ZZZZZZZZ";
		Q_i <= Q_BC when Do_BITCLR = '1' else "ZZZZZZZZ";
		Q_i <= Q_BS when Do_BITSET = '1' else "ZZZZZZZZ";
		Q_i <= "00000000" when Do_CLR = '1' else "ZZZZZZZZ";
	end generate;

	process (Clk)
	begin
		if Clk'event and Clk = '1' then
			Do_ADD <= '0';
			Do_SUB <= '0';
			Do_AND <= '0';
			Do_OR <= '0';
			Do_XOR <= '0';
			Do_IDTEST <= '0';
			Do_INC <= '0';
			Do_DEC <= '0';
			Do_COM <= '0';
			Do_RRF <= '0';
			Do_RLF <= '0';
			Do_SWAP <= '0';
			Do_BITCLR <= '0';
			Do_BITSET <= '0';
			Do_BITTESTCLR <= '0';
			Do_BITTESTSET <= '0';
			Do_CLR <= '0';
			if Skip = '0' then
				if InstructionLength = 12 then
					if Inst_Top(11 downto 6) = "000111" then
						-- ADDWF
						Do_ADD <= '1';
					end if;
					if Inst_Top(11 downto 6) = "000010" then
						-- SUBWF
						Do_SUB <= '1';
					end if;
					if Inst_Top(11 downto 6) = "000101" or Inst_Top(11 downto 8) = "1110" then
						-- ANDWF, ANDLW
						Do_AND <= '1';
					end if;
					if Inst_Top(11 downto 6) = "000100" or Inst_Top(11 downto 8) = "1101" then
						-- IORWF, IORLW
						Do_OR <= '1';
					end if;
					if Inst_Top(11 downto 6) = "000110" or Inst_Top(11 downto 8) = "1111" then
						-- XORWF, XORLW
						Do_XOR <= '1';
					end if;
				else
					if Inst_Top(11 downto 6) = "000111" or Inst_Top(11 downto 7) = "11111" then
						-- ADDWF, ADDLW
						Do_ADD <= '1';
					end if;
					if Inst_Top(11 downto 6) = "000010" or Inst_Top(11 downto 7) = "11110" then
						-- SUBWF, SUBLW
						Do_SUB <= '1';
					end if;
					if Inst_Top(11 downto 6) = "000101" or Inst_Top(11 downto 6) = "111001" then
						-- ANDWF, ANDLW
						Do_AND <= '1';
					end if;
					if Inst_Top(11 downto 6) = "000100" or Inst_Top(11 downto 6) = "111000" then
						-- IORWF, IORLW
						Do_OR <= '1';
					end if;
					if Inst_Top(11 downto 6) = "000110" or Inst_Top(11 downto 6) = "111010" then
						-- XORWF, XORLW
						Do_XOR <= '1';
					end if;
				end if;

				if Inst_Top(11 downto 9) = "001" and Inst_Top(7 downto 6) = "11" then
					-- INC/DEC w conditional skip
					Do_IDTEST <= '1';
				end if;
				if Inst_Top(11 downto 6) = "001010" or Inst_Top(11 downto 6) = "001111" then
					-- INCF, INCFSZ
					Do_INC <= '1';
				end if;
				if Inst_Top(11 downto 6) = "000011" or Inst_Top(11 downto 6) = "001011" then
					-- DECF, DECFSZ, 
					Do_DEC <= '1';
				end if;
				if Inst_Top(11 downto 6) = "001001" then
					-- COMF
					Do_COM <= '1';
				end if;
				if Inst_Top(11 downto 6) = "001100" then
					-- RRF
					Do_RRF <= '1';
				end if;
				if Inst_Top(11 downto 6) = "001101" then
					-- RLF
					Do_RLF <= '1';
				end if;
				if Inst_Top(11 downto 6) = "001110" then
					-- SWAPF
					Do_SWAP <= '1';
				end if;
				if Inst_Top(11 downto 8) = "0100" then
					-- BCF
					Do_BITCLR <= '1';
				end if;
				if Inst_Top(11 downto 8) = "0101" then
					-- BSF
					Do_BITSET <= '1';
				end if;
				if Inst_Top(11 downto 8) = "0110" then
					-- BTFSC
					Do_BITTESTCLR <= '1';
				end if;
				if Inst_Top(11 downto 8) = "0111" then
					-- BTFSS
					Do_BITTESTSET <= '1';
				end if;
				if Inst_Top(11 downto 6) = "000001" then
					-- CLRF, CLRW
					Do_CLR <= '1';
				end if;
			end if;

			case Inst_Top(7 downto 5) is
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

	Q_ID <= std_logic_vector(unsigned(A) + 1) when Do_INC = '1' else
			std_logic_vector(unsigned(A) - 1);

	AddSub(A(3 downto 0), B(3 downto 0), Do_SUB, Do_SUB, AddSubRes(3 downto 0), DC_i);
	AddSub(A(7 downto 4), B(7 downto 4), Do_SUB, DC_i, AddSubRes(7 downto 4), AddSubRes(8));

	Q_L <= (A and B) when Do_AND = '1' else
		(A or B) when Do_OR = '1' else
		(A xor B);
	Q_C <= (not A);

	Q_RR <= Carry & A(7 downto 1);
	Q_RL <= A(6 downto 0) & Carry;

	Q_S <= A(3 downto 0) & A(7 downto 4);

	Q_BC <= ((not Bit_Pattern) and A);
	Q_BS <= (Bit_Pattern or A);

	Bit_Test <= Bit_Pattern and A;

	Z_Skip <= '1' when (Do_IDTEST = '1' and Q_ID = "00000000") or
					(Bit_Test /= "00000000" and Do_BITTESTSET = '1') or
					(Bit_Test = "00000000" and Do_BITTESTCLR = '1') else '0';

	STATUS_d(2) <= '1' when Q_i(7 downto 0) = "00000000" else '0';
	STATUS_d(1) <= DC_i;
	STATUS_d(0) <= A(0) when Do_RRF = '1' else
					A(7) when Do_RLF = '1' else
					AddSubRes(8);

	-- Z
	STATUS_Wr(2) <= '1' when Do_SUB = '1' or Do_ADD = '1' or
		((Do_DEC = '1' or Do_INC = '1') and Do_IDTEST = '0') or
		Do_AND = '1' or Do_OR = '1' or Do_XOR = '1' or
		Do_CLR = '1' or Do_COM = '1' else '0';
	-- DC
	STATUS_Wr(1) <= '1' when Do_SUB = '1' or Do_ADD = '1' else '0';
	-- C
	STATUS_Wr(0) <= '1' when Do_SUB = '1' or Do_ADD = '1' or Do_RRF = '1' or Do_RLF = '1' else '0';

end;
