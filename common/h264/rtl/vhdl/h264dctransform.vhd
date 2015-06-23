-------------------------------------------------------------------------
-- H264 dc transform - VHDL
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

-- This is the dc transform for H264, without quantisation
-- this acts on a 2x2 matrix
-- this is both the forward and inverse transform

-- both input and output can be in stages, hence RESET input.

-- XST: 50 slices; 214 MHz

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.ALL;

entity h264dctransform is
	generic (	
		TOGETHER : integer := 0				--1 if output kept together as one block
	);
	port (
		CLK2 : in std_logic;				--fast clock
		RESET : in std_logic;				--reset when 1
		READYI : out std_logic := '0';		--set when ready for ENABLE
		ENABLE : in std_logic;				--values input only when this is 1
		XXIN : in std_logic_vector(15 downto 0);	--input data values (reverse order)
		VALID : out std_logic := '0';				--values output only when this is 1
		YYOUT : out std_logic_vector(15 downto 0);	--output values (reverse order)
		READYO : in std_logic := '0'		--set when ready for ENABLE
	);
end h264dctransform;

architecture hw of h264dctransform is
	--
	signal xxii : std_logic_vector(15 downto 0) := (others => '0');
	signal enablei : std_logic := '0';
	signal xx00 : std_logic_vector(15 downto 0) := (others => '0');
	signal xx01 : std_logic_vector(15 downto 0) := (others => '0');
	signal xx10 : std_logic_vector(15 downto 0) := (others => '0');
	signal xx11 : std_logic_vector(15 downto 0) := (others => '0');
	signal ixx : std_logic_vector(1 downto 0) := b"00";
	signal iout : std_logic := '0';
	--
begin
	READYI <= not iout;
	--
process(CLK2)
begin
	if rising_edge(CLK2) then
		if RESET='1' then
			ixx <= b"00";
			iout <= '0';
		end if;
		enablei <= ENABLE;
		xxii <= XXIN;
		if enablei='1' and RESET='0' then	--input in raster scan order
			if ixx=0 then
				xx00 <= xxii;
			elsif ixx=1 then
				xx00 <= xx00 + xxii;	--compute 2nd stage
				xx01 <= xx00 - xxii;
			elsif ixx=2 then
				xx10 <= xxii;
			else
				xx10 <= xx10 + xxii;	--compute 2nd stage
				xx11 <= xx10 - xxii;
				iout <= '1';
			end if;
			ixx <= ixx+1;
		end if;
		if iout='1' and (READYO='1' or (TOGETHER=1 and ixx/=0)) and RESET='0' then
			if ixx=0 then
				YYOUT <= xx00 + xx10;	--out in raster scan order
			elsif ixx=1 then
				YYOUT <= xx01 + xx11;
			elsif ixx=2 then
				YYOUT <= xx00 - xx10;
			else
				YYOUT <= xx01 - xx11;
				iout <= '0';
			end if;
			ixx <= ixx+1;
			VALID <= '1';
		else
			VALID <= '0';
		end if;
	end if;
end process;
	--
end hw; --of h264dctransform



