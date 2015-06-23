--
-- PIC16xx compatible microcontroller core
--
-- Version : 0224
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
--	http://www.opencores.org/cvsweb.shtml/ppx16/
--
-- Limitations :
--	Registers implemented in this entity are INDF, PCL, STATUS, FSR, (PCLATH)
--	other registers must be implemented externally including GPR
--
-- File history :
--

library IEEE;
use IEEE.std_logic_1164.all;

entity PPX_Ctrl is
	generic(
		InstructionLength : integer
	);
	port(
		Clk			: in std_logic;
		Reset_n		: in std_logic;
		ROM_Data	: in std_logic_vector(InstructionLength - 1 downto 0);
		Inst		: in std_logic_vector(InstructionLength - 1 downto 0);
		Skip		: in std_logic;
		File_Wr		: out std_logic;
		W_Wr		: out std_logic;
		Imm_Op		: out std_logic;
		A2Res		: out std_logic;
		B2Res		: out std_logic;
		Push		: out std_logic;
		Pop			: out std_logic;
		Goto		: out std_logic;
		IRet		: out std_logic;
		B_Skip		: out std_logic;
		Sleep		: out std_logic
	);
end PPX_Ctrl;

architecture rtl of PPX_Ctrl is

begin

	Imm_Op <= Inst(InstructionLength - 1);

	i12 : if InstructionLength = 12 generate
		B_Skip <= '1' when Inst(11 downto 10) = "10" else '0';
		Sleep <= '1' when ROM_Data(11 downto 0) = "000000000011" else '0';
		W_Wr <= '1' when Inst(11 downto 8) = "1000" or
					Inst(11 downto 10) = "11" or
					(Inst(11 downto 10) = "00" and Inst(5) = '0' and Inst(9 downto 6) /= "0000") else '0';
		IRet <= '0';
		process (Reset_n, Clk)
		begin
			if Reset_n = '0' then
				File_Wr <= '0';
				Goto <= '0';
				Push <= '0';
				Pop <= '0';
				A2Res <= '0';
				B2Res <= '0';
			elsif Clk'event and Clk = '1' then
				File_Wr <= '0';
				Goto <= '0';
				Push <= '0';
				Pop <= '0';
				A2Res <= '0';
				B2Res <= '0';
				if Skip = '0' then
					if (ROM_Data(InstructionLength - 1 downto InstructionLength - 2) = "00" and
						ROM_Data(InstructionLength - 7) = '1') or
						ROM_Data(InstructionLength - 1 downto InstructionLength - 3) = "010" then
						File_Wr <= '1';
					end if;
					if ROM_Data(InstructionLength - 1 downto InstructionLength - 3) = "101" then
						Goto <= '1';
					end if;
					if ROM_Data(11 downto 8) = "1001" then -- CALL
						Push <= '1';
					end if;
					if ROM_Data(11 downto 8) = "1000" then -- RETLW
						Pop <= '1';
					end if;
					if ROM_Data(11 downto 6) = "001000" then
						-- MOVF
						A2Res <= '1';
					end if;
					if ROM_Data(11 downto 8) = "1100" or -- MOVLW
						ROM_Data(11 downto 8) = "1000" or -- RETLW
						ROM_Data(11 downto 6) = "000000" then -- MOVWF/TRIS/OPTION and some others
						B2Res <= '1';
					end if;
				end if;
			end if;
		end process;
	end generate;

	i14 : if InstructionLength = 14 generate
		B_Skip <= '1' when Inst(13 downto 12) = "10" or Inst(13 downto 10) = "1101" or
				Inst(13 downto 1) = "0000000000100" else '0';
		Sleep <= '1' when ROM_Data(13 downto 0) = "00000001100011" else '0';
		W_Wr <= '1' when Inst(13 downto 12) = "11" or
					(Inst(13 downto 12) = "00" and Inst(7) = '0' and Inst(11 downto 8) /= "0000") else '0';
		IRet <= '1' when Inst(13 downto 0) = "00000000001001" else '0'; -- RETFIE
		process (Reset_n, Clk)
		begin
			if Reset_n = '0' then
				File_Wr <= '0';
				Goto <= '0';
				Push <= '0';
				Pop <= '0';
				A2Res <= '0';
				B2Res <= '0';
			elsif Clk'event and Clk = '1' then
				File_Wr <= '0';
				Goto <= '0';
				Push <= '0';
				Pop <= '0';
				A2Res <= '0';
				B2Res <= '0';
				if Skip = '0' then
					if (ROM_Data(InstructionLength - 1 downto InstructionLength - 2) = "00" and
						ROM_Data(InstructionLength - 7) = '1') or
						ROM_Data(InstructionLength - 1 downto InstructionLength - 3) = "010" then
						File_Wr <= '1';
					end if;
					if ROM_Data(InstructionLength - 1 downto InstructionLength - 3) = "101" then
						Goto <= '1';
					end if;
					if ROM_Data(13 downto 11) = "100" then
						Push <= '1'; -- CALL
					end if;
					if ROM_Data(13 downto 10) = "1101" or -- RETLW
						ROM_Data(13 downto 1) = "0000000000100" then -- RETURN, RETFIE
						Pop <= '1';
					end if;
					if ROM_Data(13 downto 8) = "001000" then
						-- MOVF
						A2Res <= '1';
					end if;
					if ROM_Data(13 downto 10) = "1100" or -- MOVLW
						ROM_Data(13 downto 10) = "1101" or -- RETLW
						ROM_Data(13 downto 8) = "000000" then -- MOVWF/TRIS/OPTION and some others
						B2Res <= '1';
					end if;
				end if;
			end if;
		end process;
	end generate;

end;
