-- ****
-- T80(b) core. In an effort to merge and maintain bug fixes ....
--
--
-- Ver 301 parity flag is just parity for 8080, also overflow for Z80, by Sean Riddle
-- Ver 300 started tidyup
-- MikeJ March 2005
-- Latest version from www.fpgaarcade.com (original www.opencores.org)
--
-- ****
--
-- Z80 compatible microprocessor core
--
-- Version : 0247
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
--      http://www.opencores.org/cvsweb.shtml/t80/
--
-- Limitations :
--
-- File history :
--
--      0214 : Fixed mostly flags, only the block instructions now fail the zex regression test
--
--      0238 : Fixed zero flag for 16 bit SBC and ADC
--
--      0240 : Added GB operations
--
--      0242 : Cleanup
--
--      0247 : Cleanup
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity T80_ALU is
	generic(
		Mode : integer := 0;
		Flag_C : integer := 0;
		Flag_N : integer := 1;
		Flag_P : integer := 2;
		Flag_X : integer := 3;
		Flag_H : integer := 4;
		Flag_Y : integer := 5;
		Flag_Z : integer := 6;
		Flag_S : integer := 7
	);
	port(
		Arith16         : in  std_logic;
		Z16             : in  std_logic;
		ALU_Op          : in  std_logic_vector(3 downto 0);
		IR              : in  std_logic_vector(5 downto 0);
		ISet            : in  std_logic_vector(1 downto 0);
		BusA            : in  std_logic_vector(7 downto 0);
		BusB            : in  std_logic_vector(7 downto 0);
		F_In            : in  std_logic_vector(7 downto 0);
		Q               : out std_logic_vector(7 downto 0);
		F_Out           : out std_logic_vector(7 downto 0)
	);
end T80_ALU;

architecture rtl of T80_ALU is

	procedure AddSub(A        : std_logic_vector;
					 B        : std_logic_vector;
					 Sub      : std_logic;
					 Carry_In : std_logic;
			  signal Res      : out std_logic_vector;
			  signal Carry    : out std_logic) is

		variable B_i          : unsigned(A'length - 1 downto 0);
		variable Res_i        : unsigned(A'length + 1 downto 0);
	begin
		if Sub = '1' then
			B_i := not unsigned(B);
		else
			B_i :=     unsigned(B);
		end if;

		Res_i := unsigned("0" & A & Carry_In) + unsigned("0" & B_i & "1");
		Carry <= Res_i(A'length + 1);
		Res <= std_logic_vector(Res_i(A'length downto 1));
	end;

	-- AddSub variables (temporary signals)
	signal UseCarry                : std_logic;
	signal Carry7_v                : std_logic;
	signal Overflow_v              : std_logic;
	signal HalfCarry_v             : std_logic;
	signal Carry_v                 : std_logic;
	signal Q_v                     : std_logic_vector(7 downto 0);

	signal BitMask                 : std_logic_vector(7 downto 0);

begin

	with IR(5 downto 3) select BitMask <= "00000001" when "000",
										  "00000010" when "001",
										  "00000100" when "010",
										  "00001000" when "011",
										  "00010000" when "100",
										  "00100000" when "101",
										  "01000000" when "110",
										  "10000000" when others;

	UseCarry <= not ALU_Op(2) and ALU_Op(0);
	AddSub(BusA(3 downto 0), BusB(3 downto 0), ALU_Op(1), ALU_Op(1) xor (UseCarry and F_In(Flag_C)), Q_v(3 downto 0), HalfCarry_v);
	AddSub(BusA(6 downto 4), BusB(6 downto 4), ALU_Op(1), HalfCarry_v, Q_v(6 downto 4), Carry7_v);
	AddSub(BusA(7 downto 7), BusB(7 downto 7), ALU_Op(1), Carry7_v, Q_v(7 downto 7), Carry_v);

	-- bug fix - parity flag is just parity for 8080, also overflow for Z80
	process (Carry_v, Carry7_v, Q_v)
	begin
		if(Mode=2) then
			OverFlow_v <= not (Q_v(0) xor Q_v(1) xor Q_v(2) xor Q_v(3) xor
					   Q_v(4) xor Q_v(5) xor Q_v(6) xor Q_v(7));  else
			OverFlow_v <= Carry_v xor Carry7_v;
		end if;
	end process;

	process (Arith16, ALU_OP, F_In, BusA, BusB, IR, Q_v, Carry_v, HalfCarry_v, OverFlow_v, BitMask, ISet, Z16)
		variable Q_t : std_logic_vector(7 downto 0);
		variable DAA_Q : unsigned(8 downto 0);
	begin
		Q_t := "--------";
		F_Out <= F_In;
		DAA_Q := "---------";
		case ALU_Op is
		when "0000" | "0001" |  "0010" | "0011" | "0100" | "0101" | "0110" | "0111" =>
			F_Out(Flag_N) <= '0';
			F_Out(Flag_C) <= '0';
			case ALU_OP(2 downto 0) is
			when "000" | "001" => -- ADD, ADC
				Q_t := Q_v;
				F_Out(Flag_C) <= Carry_v;
				F_Out(Flag_H) <= HalfCarry_v;
				F_Out(Flag_P) <= OverFlow_v;
			when "010" | "011" | "111" => -- SUB, SBC, CP
				Q_t := Q_v;
				F_Out(Flag_N) <= '1';
				F_Out(Flag_C) <= not Carry_v;
				F_Out(Flag_H) <= not HalfCarry_v;
				F_Out(Flag_P) <= OverFlow_v;
			when "100" => -- AND
				Q_t(7 downto 0) := BusA and BusB;
				F_Out(Flag_H) <= '1';
			when "101" => -- XOR
				Q_t(7 downto 0) := BusA xor BusB;
				F_Out(Flag_H) <= '0';
			when others => -- OR "110"
				Q_t(7 downto 0) := BusA or BusB;
				F_Out(Flag_H) <= '0';
			end case;
			if ALU_Op(2 downto 0) = "111" then -- CP
				F_Out(Flag_X) <= BusB(3);
				F_Out(Flag_Y) <= BusB(5);
			else
				F_Out(Flag_X) <= Q_t(3);
				F_Out(Flag_Y) <= Q_t(5);
			end if;
			if Q_t(7 downto 0) = "00000000" then
				F_Out(Flag_Z) <= '1';
				if Z16 = '1' then
					F_Out(Flag_Z) <= F_In(Flag_Z);      -- 16 bit ADC,SBC
				end if;
			else
				F_Out(Flag_Z) <= '0';
			end if;
			F_Out(Flag_S) <= Q_t(7);
			case ALU_Op(2 downto 0) is
			when "000" | "001" | "010" | "011" | "111" => -- ADD, ADC, SUB, SBC, CP
			when others =>
				F_Out(Flag_P) <= not (Q_t(0) xor Q_t(1) xor Q_t(2) xor Q_t(3) xor
					Q_t(4) xor Q_t(5) xor Q_t(6) xor Q_t(7));
			end case;
			if Arith16 = '1' then
				F_Out(Flag_S) <= F_In(Flag_S);
				F_Out(Flag_Z) <= F_In(Flag_Z);
				F_Out(Flag_P) <= F_In(Flag_P);
			end if;
		when "1100" =>
			-- DAA
			F_Out(Flag_H) <= F_In(Flag_H);
			F_Out(Flag_C) <= F_In(Flag_C);
			DAA_Q(7 downto 0) := unsigned(BusA);
			DAA_Q(8) := '0';
			if F_In(Flag_N) = '0' then
				-- After addition
				-- Alow > 9 or H = 1
				if DAA_Q(3 downto 0) > 9 or F_In(Flag_H) = '1' then
					if (DAA_Q(3 downto 0) > 9) then
						F_Out(Flag_H) <= '1';
					else
						F_Out(Flag_H) <= '0';
					end if;
					DAA_Q := DAA_Q + 6;
				end if;
				-- new Ahigh > 9 or C = 1
				if DAA_Q(8 downto 4) > 9 or F_In(Flag_C) = '1' then
					DAA_Q := DAA_Q + 96; -- 0x60
				end if;
			else
				-- After subtraction
				if DAA_Q(3 downto 0) > 9 or F_In(Flag_H) = '1' then
					if DAA_Q(3 downto 0) > 5 then
						F_Out(Flag_H) <= '0';
					end if;
					DAA_Q(7 downto 0) := DAA_Q(7 downto 0) - 6;
				end if;
				if unsigned(BusA) > 153 or F_In(Flag_C) = '1' then
					DAA_Q := DAA_Q - 352; -- 0x160
				end if;
			end if;
			F_Out(Flag_X) <= DAA_Q(3);
			F_Out(Flag_Y) <= DAA_Q(5);
			F_Out(Flag_C) <= F_In(Flag_C) or DAA_Q(8);
			Q_t := std_logic_vector(DAA_Q(7 downto 0));
			if DAA_Q(7 downto 0) = "00000000" then
				F_Out(Flag_Z) <= '1';
			else
				F_Out(Flag_Z) <= '0';
			end if;
			F_Out(Flag_S) <= DAA_Q(7);
			F_Out(Flag_P) <= not (DAA_Q(0) xor DAA_Q(1) xor DAA_Q(2) xor DAA_Q(3) xor
				DAA_Q(4) xor DAA_Q(5) xor DAA_Q(6) xor DAA_Q(7));
		when "1101" | "1110" =>
			-- RLD, RRD
			Q_t(7 downto 4) := BusA(7 downto 4);
			if ALU_Op(0) = '1' then
				Q_t(3 downto 0) := BusB(7 downto 4);
			else
				Q_t(3 downto 0) := BusB(3 downto 0);
			end if;
			F_Out(Flag_H) <= '0';
			F_Out(Flag_N) <= '0';
			F_Out(Flag_X) <= Q_t(3);
			F_Out(Flag_Y) <= Q_t(5);
			if Q_t(7 downto 0) = "00000000" then
				F_Out(Flag_Z) <= '1';
			else
				F_Out(Flag_Z) <= '0';
			end if;
			F_Out(Flag_S) <= Q_t(7);
			F_Out(Flag_P) <= not (Q_t(0) xor Q_t(1) xor Q_t(2) xor Q_t(3) xor
				Q_t(4) xor Q_t(5) xor Q_t(6) xor Q_t(7));
		when "1001" =>
			-- BIT
			Q_t(7 downto 0) := BusB and BitMask;
			F_Out(Flag_S) <= Q_t(7);
			if Q_t(7 downto 0) = "00000000" then
				F_Out(Flag_Z) <= '1';
				F_Out(Flag_P) <= '1';
			else
				F_Out(Flag_Z) <= '0';
				F_Out(Flag_P) <= '0';
			end if;
			F_Out(Flag_H) <= '1';
			F_Out(Flag_N) <= '0';
			F_Out(Flag_X) <= '0';
			F_Out(Flag_Y) <= '0';
			if IR(2 downto 0) /= "110" then
				F_Out(Flag_X) <= BusB(3);
				F_Out(Flag_Y) <= BusB(5);
			end if;
		when "1010" =>
			-- SET
			Q_t(7 downto 0) := BusB or BitMask;
		when "1011" =>
			-- RES
			Q_t(7 downto 0) := BusB and not BitMask;
		when "1000" =>
			-- ROT
			case IR(5 downto 3) is
			when "000" => -- RLC
				Q_t(7 downto 1) := BusA(6 downto 0);
				Q_t(0) := BusA(7);
				F_Out(Flag_C) <= BusA(7);
			when "010" => -- RL
				Q_t(7 downto 1) := BusA(6 downto 0);
				Q_t(0) := F_In(Flag_C);
				F_Out(Flag_C) <= BusA(7);
			when "001" => -- RRC
				Q_t(6 downto 0) := BusA(7 downto 1);
				Q_t(7) := BusA(0);
				F_Out(Flag_C) <= BusA(0);
			when "011" => -- RR
				Q_t(6 downto 0) := BusA(7 downto 1);
				Q_t(7) := F_In(Flag_C);
				F_Out(Flag_C) <= BusA(0);
			when "100" => -- SLA
				Q_t(7 downto 1) := BusA(6 downto 0);
				Q_t(0) := '0';
				F_Out(Flag_C) <= BusA(7);
			when "110" => -- SLL (Undocumented) / SWAP
				if Mode = 3 then
					Q_t(7 downto 4) := BusA(3 downto 0);
					Q_t(3 downto 0) := BusA(7 downto 4);
					F_Out(Flag_C) <= '0';
				else
					Q_t(7 downto 1) := BusA(6 downto 0);
					Q_t(0) := '1';
					F_Out(Flag_C) <= BusA(7);
				end if;
			when "101" => -- SRA
				Q_t(6 downto 0) := BusA(7 downto 1);
				Q_t(7) := BusA(7);
				F_Out(Flag_C) <= BusA(0);
			when others => -- SRL
				Q_t(6 downto 0) := BusA(7 downto 1);
				Q_t(7) := '0';
				F_Out(Flag_C) <= BusA(0);
			end case;
			F_Out(Flag_H) <= '0';
			F_Out(Flag_N) <= '0';
			F_Out(Flag_X) <= Q_t(3);
			F_Out(Flag_Y) <= Q_t(5);
			F_Out(Flag_S) <= Q_t(7);
			if Q_t(7 downto 0) = "00000000" then
				F_Out(Flag_Z) <= '1';
			else
				F_Out(Flag_Z) <= '0';
			end if;
			F_Out(Flag_P) <= not (Q_t(0) xor Q_t(1) xor Q_t(2) xor Q_t(3) xor
				Q_t(4) xor Q_t(5) xor Q_t(6) xor Q_t(7));
			if ISet = "00" then
				F_Out(Flag_P) <= F_In(Flag_P);
				F_Out(Flag_S) <= F_In(Flag_S);
				F_Out(Flag_Z) <= F_In(Flag_Z);
			end if;
		when others =>
			null;
		end case;
		Q <= Q_t;
	end process;
end;
