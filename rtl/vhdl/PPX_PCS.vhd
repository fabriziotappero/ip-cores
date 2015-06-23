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

entity PPX_PCS is
	generic(
		PC_Width		: integer;
		StackAddrWidth	: integer;
		TopBoot			: boolean
	);
	port(
		Clk				: in std_logic;
		Reset_n			: in std_logic;
		CS				: in std_logic;
		Wr				: in std_logic;
		Data_In			: in std_logic_vector(7 downto 0);
		Addr_In			: in std_logic_vector(PC_Width - 3 downto 0);
		PCLATH			: in std_logic_vector(4 downto 0);
		STATUS			: in std_logic_vector(6 downto 5);
		NPC				: out std_logic_vector(PC_Width - 1 downto 0);
		Int				: in std_logic;
		Sleep			: in std_logic;
		Push			: in std_logic;
		Pop				: in std_logic;
		Goto			: in std_logic
	);
end PPX_PCS;

architecture rtl of PPX_PCS is

	signal	PC_i	: unsigned(PC_Width - 1 downto 0);
	signal	NPC_i	: unsigned(PC_Width - 1 downto 0);

	type Stack_Image is array (2 ** StackAddrWidth - 1 downto 0) of unsigned(PC_Width - 1 downto 0);
	signal	Stack		: Stack_Image;

	signal	StackPtr	: unsigned(StackAddrWidth -1 downto 0);

begin

	NPC <= std_logic_vector(NPC_i);

	process (Clk)
	begin
		if Clk'event and Clk = '1' then
			if Push = '1' then
				Stack(to_integer(StackPtr)) <= PC_i;
			end if;
			if Int = '1' then
				Stack(to_integer(StackPtr)) <= PC_i - 1;
			end if;
		end if;
	end process;

	process (PC_i, Sleep, CS, Wr, PCLATH, STATUS, Push, Pop, Goto, Data_In, Addr_In, Int, Stack, StackPtr)
	begin
		NPC_i <= PC_i;
		if Sleep = '0' then
			NPC_i <= PC_i + 1;
		end if;
		if CS = '1' and Wr = '1' then
			if PC_Width = 13 then
				NPC_i(7 downto 0) <= unsigned(Data_In);
				NPC_i(PC_Width - 1 downto PC_Width - 5) <= unsigned(PCLATH);
			end if;
			if PC_Width = 11 then
				NPC_i(7 downto 0) <= unsigned(Data_In);
				NPC_i(8) <= '0';
				NPC_i(10 downto 9) <= unsigned(STATUS);
			end if;
		end if;
		if Push = '1' then
			if PC_Width = 13 then
				NPC_i(10 downto 0) <= unsigned(Addr_In);
				NPC_i(PC_Width - 1 downto PC_Width - 2) <= unsigned(PCLATH(4 downto 3));
			end if;
			if PC_Width = 11 then
				NPC_i(7 downto 0) <= unsigned(Addr_In(7 downto 0));
				NPC_i(8) <= '0';
				NPC_i(10 downto 9) <= unsigned(STATUS);
			end if;
		end if;
		if Pop = '1' then
			NPC_i <= Stack(to_integer(StackPtr - 1));
		end if;
		if Goto = '1' then
			if PC_Width = 13 then
				NPC_i(10 downto 0) <= unsigned(Addr_In);
				NPC_i(PC_Width - 1 downto PC_Width - 2) <= unsigned(PCLATH(4 downto 3));
			end if;
			if PC_Width = 11 then
				NPC_i(8 downto 0) <= unsigned(Addr_In);
				NPC_i(10 downto 9) <= unsigned(STATUS);
			end if;
		end if;
		if Int = '1' then
			NPC_i <= (others => '0');
			NPC_i(2) <= '1';
		end if;
	end process;

	process (Reset_n, Clk)
	begin
		if Reset_n = '0' then
			PC_i <= (others => '1');
			if TopBoot then
				PC_i(0) <= '0';
			end if;
			StackPtr <= (others => '0');
		elsif Clk'event and Clk = '1' then
			PC_i <= NPC_i;
			if Push = '1' then
				StackPtr <= StackPtr + 1;
			end if;
			if Pop = '1' then
				StackPtr <= StackPtr - 1;
			end if;
			if Int = '1' then
				StackPtr <= StackPtr + 1;
			end if;
		end if;
	end process;

end;
