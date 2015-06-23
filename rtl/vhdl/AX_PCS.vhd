--
-- AT90Sxxxx compatible microcontroller core
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
--	http://www.opencores.org/cvsweb.shtml/ax8/
--
-- Limitations :
--	Four level stack
--
-- File history :
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity AX_PCS is
	generic(
		HW_Stack	: boolean
	);
	port(
		Clk			: in std_logic;
		Reset_n		: in std_logic;
		Offs_In		: in std_logic_vector(11 downto 0);
		Z			: in unsigned(15 downto 0);
		Data_In		: in std_logic_vector(7 downto 0);
		Pause		: in std_logic;
		Push		: in std_logic;
		Pop			: in std_logic;
		HRet		: in std_logic;
		LRet		: in std_logic;
		ZJmp		: in std_logic;
		RJmp		: in std_logic;
		CInt		: in std_logic_vector(3 downto 0);
		IPending	: in std_logic;
		IPush		: out std_logic;
		NPC			: out std_logic_vector(15 downto 0);
		PC			: out std_logic_vector(15 downto 0)
	);
end AX_PCS;

architecture rtl of AX_PCS is

	signal	PC_i	: unsigned(15 downto 0);
	signal	NPC_i	: unsigned(15 downto 0);
	signal	IPush_i	: std_logic;

	type Stack_Image is array (3 downto 0) of unsigned(15 downto 0);
	signal	Stack : Stack_Image;

	signal	StackPtr : unsigned(1 downto 0);

begin

	NPC <= std_logic_vector(NPC_i);
	PC <= std_logic_vector(PC_i);
	IPush <= IPush_i;

	process (PC_i, Pause, IPending, IPush_i, Push, Pop, Stack, Data_In, Offs_In, CInt, HRet, LRet, RJmp, ZJmp, Z)
	begin
		NPC_i <= PC_i;
		if Pause = '0' then
			if IPending = '0' then
				NPC_i <= PC_i + 1;
			end if;
			if IPending = '0' and IPush_i = '1' then
				NPC_i(15 downto 4) <= "000000000000";
				NPC_i(3 downto 0) <= unsigned(CInt);
			end if;
		end if;
		if Pop = '1' and HW_Stack then
			NPC_i <= Stack(to_integer(StackPtr - 1));
		end if;
		if HRet = '1' then
			NPC_i(15 downto 8) <= unsigned(Data_In);
		end if;
		if LRet = '1' then
			NPC_i(7 downto 0) <= unsigned(Data_In);
		end if;
		if ZJmp = '1' then
			NPC_i <= Z;
		end if;
		if RJmp = '1' then
			NPC_i <= PC_i + unsigned(resize(signed(Offs_In), 16));
		end if;
	end process;

	process (Reset_n, Clk)
	begin
		if Reset_n = '0' then
			PC_i <= (others => '0');
			IPush_i <= '0';
			if HW_Stack then
				Stack <= (others => (others => '0'));
				StackPtr <= "00";
			end if;
		elsif Clk'event and Clk = '1' then
			PC_i <= NPC_i;
			if Pause = '0' then
				IPush_i <= IPending;
				if IPending = '0' and IPush_i = '1' then
					if HW_Stack then
						Stack(to_integer(StackPtr)) <= PC_i;
						StackPtr <= StackPtr + 1;
					end if;
				end if;
			end if;
			if Push = '1' and HW_Stack then
				Stack(to_integer(StackPtr)) <= PC_i;
				StackPtr <= StackPtr + 1;
			end if;
			if Pop = '1' and HW_Stack then
				StackPtr <= StackPtr - 1;
			end if;
		end if;
	end process;

end;
