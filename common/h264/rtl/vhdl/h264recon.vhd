-------------------------------------------------------------------------
-- H264 reconstruct - VHDL
-- 
-- Written by Andy Henson
-- Copyright (c) 2008 Zexia Access Ltd
-- All rights reserved.
--
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:
--    * Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in the
--      documentation and/or other materials provided with the distribution.
--    * Neither the name of the Zexia Access Ltd nor the
--      names of its contributors may be used to endorse or promote products
--      derived from this software without specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY ZEXIA ACCESS LTD ``AS IS'' AND ANY
-- EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL ZEXIA ACCESS LTD OR ANDY HENSON BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-------------------------------------------------------------------------

-- Converts residuals back to pixels by adding back base values (std 8.5.1)
-- BASE values may be clocked in some time in advance, and residual data
-- somewhat later.

-- Spartan3: 210MHz; 76 slices
-- CycloneIII: 163MHz; 376 LEs

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.ALL;

entity h264recon is
	port (
		CLK2 : in std_logic;				--x2 clock
		--
		-- in interface:
		NEWSLICE : in std_logic;			--reset
		STROBEI : in std_logic;				--data here
		DATAI : in std_logic_vector(39 downto 0);		--4x10bit
		BSTROBEI : in std_logic;				--base data here
		BCHROMAI : in std_logic;				--set if base is chroma
		BASEI : in std_logic_vector(31 downto 0);		--4x8bit
		--
		-- out interface:
		STROBEO : out std_logic := '0';				--data here (luma)
		CSTROBEO : out std_logic := '0';			--data here (chroma)
		DATAO : out std_logic_vector(31 downto 0) := (others => '0')
	);
end h264recon;

architecture hw of h264recon is
	type Tbase is array(7 downto 0) of std_logic_vector(31 downto 0);
	signal chromaf : std_logic_vector(1 downto 0);
	signal basevec : Tbase := (others=>(others=>'0'));
	signal basex : std_logic_vector(31 downto 0);
	signal basein : std_logic_vector(3 downto 0) := b"0000";
	signal baseout : std_logic_vector(3 downto 0) := b"0000";
	signal byte0 : std_logic_vector(9 downto 0) := (others=>'0');
	signal byte1 : std_logic_vector(9 downto 0) := (others=>'0');
	signal byte2 : std_logic_vector(9 downto 0) := (others=>'0');
	signal byte3 : std_logic_vector(9 downto 0) := (others=>'0');
	signal strobex : std_logic := '0';
	signal chromax : std_logic := '0';
begin
	basex <= basevec(conv_integer(baseout(2 downto 0)));
	--
process(CLK2)
begin
	if rising_edge(CLK2) then
		if NEWSLICE='1' then	--reset
			basein <= b"0000";
			baseout <= b"0000";
		end if;
		--load in base
		if BSTROBEI='1' and NEWSLICE='0' then
			basevec(conv_integer(basein(2 downto 0))) <= BASEI;
			chromaf(conv_integer(basein(2))) <= BCHROMAI;
			basein <= basein + 1;
			assert basein+8 /= baseout report "basein wrapped";
		else
			assert basein(1 downto 0)=0 report "basein not aligned when strobe falls";
		end if;
		--reconstruct +0: add
		byte0 <= (b"00"&basex(7 downto 0))   + DATAI(9 downto 0);
		byte1 <= (b"00"&basex(15 downto 8))  + DATAI(19 downto 10);
		byte2 <= (b"00"&basex(23 downto 16)) + DATAI(29 downto 20);
		byte3 <= (b"00"&basex(31 downto 24)) + DATAI(39 downto 30);
		chromax <= chromaf(conv_integer(baseout(2)));
		strobex <= STROBEI;
		if STROBEI='1' and NEWSLICE='0' then
			baseout <= baseout + 1;
			assert baseout /= basein report "baseout wrapped";
		else
			assert baseout(1 downto 0)=0 report "baseout not aligned when strobe falls";
		end if;
		--reconstruct +1: clip to [0,255]
		if byte0(9 downto 8) = b"01" or byte0(9 downto 7) = b"100" then
			DATAO(7 downto 0) <= x"FF";
		elsif byte0(9) = '1' and byte0(9 downto 7) /= b"100" then
			DATAO(7 downto 0) <= x"00";
		else
			DATAO(7 downto 0) <= byte0(7 downto 0);
		end if;
		if byte1(9 downto 8) = b"01" or byte1(9 downto 7) = b"100" then
			DATAO(15 downto 8) <= x"FF";
		elsif byte1(9) = '1' and byte1(9 downto 7) /= b"100" then
			DATAO(15 downto 8) <= x"00";
		else
			DATAO(15 downto 8) <= byte1(7 downto 0);
		end if;
		if byte2(9 downto 8) = b"01" or byte2(9 downto 7) = b"100" then
			DATAO(23 downto 16) <= x"FF";
		elsif byte2(9) = '1' and byte2(9 downto 7) /= b"100" then
			DATAO(23 downto 16) <= x"00";
		else
			DATAO(23 downto 16) <= byte2(7 downto 0);
		end if;
		if byte3(9 downto 8) = b"01" or byte3(9 downto 7) = b"100" then
			DATAO(31 downto 24) <= x"FF";
		elsif byte3(9) = '1' and byte3(9 downto 7) /= b"100" then
			DATAO(31 downto 24) <= x"00";
		else
			DATAO(31 downto 24) <= byte3(7 downto 0);
		end if;
		STROBEO <= strobex and not chromax;
		CSTROBEO <= strobex and chromax;
	end if;	
end process;
	--
end hw;

