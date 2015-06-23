--
-- I2S from binary file
--
-- Version : 0146
--
-- Copyright (c) 2001 Daniel Wallner (jesus@opencores.org)
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

entity I2SStim is
	generic(
		FileName		: string;
		Bytes			: integer := 2;		-- Number of bytes per word (1 to 4)
		LittleEndian	: boolean := true	-- Byte order
	);
	port(
		BClk			: in std_logic;
		FSync			: in std_logic;
		SData			: out std_logic
	);
end I2SStim;

architecture behaviour of I2SStim is

begin
	process (BClk)
		type ChFile is file of character;
		file InFile				: ChFile open read_mode is FileName;
		variable Inited			: boolean := false;
		variable CharTmp		: character;
		variable IntTmp			: integer;
		variable Data			: std_logic_vector(Bytes * 8 - 1 downto 0);
		variable BPhase			: integer;
		variable OldFS			: std_logic;
	begin
		if not Inited then
			Inited := true;
			BPhase := 64;
			Data := (others => '0');
			SData <= '0';
		end if;
		if BClk'event and BClk = '0' then
			if BPhase = 0 or BPhase = 32 then
				if LittleEndian then
					for i in integer range 0 to Bytes - 1 loop
						read(InFile, CharTmp);
						IntTmp := character'pos(CharTmp);
						Data(i * 8 + 7 downto i * 8) := std_logic_vector(to_unsigned(IntTmp, 8));
					end loop;
				else
					for i in integer range Bytes - 1 downto 0 loop
						read(InFile, CharTmp);
						IntTmp := character'pos(CharTmp);
						Data(i * 8 + 7 downto i * 8) := std_logic_vector(to_unsigned(IntTmp, 8));
					end loop;
				end if;
			end if;

			if BPhase mod 32 < Bytes * 8 then
				SData <= Data(Bytes * 8 - 1);
				Data(Bytes * 8 - 1 downto 1) := Data(Bytes * 8 - 2 downto 0);
			else
				SData <= '0';
			end if;
		end if;
		if BClk'event and BClk = '1' then
			if OldFS = '1' and FSync = '0' then
				BPhase := 0;
			else
				BPhase := BPhase + 1;
			end if;
			OldFS := FSync;
		end if;
	end process;
end;
