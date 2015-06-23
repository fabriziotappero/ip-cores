-------------------------------------------------------------------------
-- H264 convert bits to bytes - VHDL
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

-- Coverts a "wide bits" VE/VL stream to a NAL byte stream
-- inserts 03 if needed (stuffing) after 00 00 before 00..03

-- This version eats up to 4 bits per clock, and emits up to 1 byte/clock

-- input accepted when VALID high; READY indicates if can accept lots more
-- but can always accept about 20 more words even if READY low.
-- VE is 31 bits long, but only 20 bits implemented, others 0.
-- most significant bit of VE is sent first, this may be a 0 bit.

-- special case of 4<VL<16 and VE(16)=1 means BYTE ALIGN by truncating
-- to a byte after data is pushed, typically add 7 bits of 0s in VE
-- with BYTE ALIGN, but VE(17) may be set to indicate DONE
-- this pulses the DONE flag after outputting the last byte.

-- Input: VALID/VE/VL
-- Output: STROBE/BYTE

-- XST: 199 slices; 158 MHz

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.ALL;

entity h264tobytes is
	port (
		CLK : in std_logic;					--pixel clock
		VALID : in std_logic;				--data ready to be read
		READY : out std_logic := '1';		--soft ready signal (can accept 40 more words when clear)
		VE : in std_logic_vector(24 downto 0) := (others=>'0');
		VL : in std_logic_vector(4 downto 0) := (others=>'0');
		BYTE : out std_logic_vector(7 downto 0) := (others=>'0');
		STROBE : out std_logic := '0';			--set when BYTE valid
		DONE : out std_logic := '0'				--set after aligned with DONE flag (end of NAL)
	);
end h264tobytes;

architecture hw of h264tobytes is
	--
	type Tave is array(63 downto 0) of std_logic_vector(24 downto 0);
	type Tavl is array(63 downto 0) of std_logic_vector(4 downto 0);
	signal aVE : Tave;
	signal aVL : Tavl;
	signal ain : std_logic_vector(5 downto 0) := (others => '0');
	signal aout : std_logic_vector(5 downto 0) := (others => '0');
	signal adiff : std_logic_vector(5 downto 0) := (others => '0');
	signal VE1 : std_logic_vector(24 downto 0) := (others=>'0');
	signal VL1 : std_logic_vector(4 downto 0) := (others=>'0');
	--
	signal ptr : std_logic_vector(4 downto 0) := (others => '0');	--ptr, initally VL
	signal sel : std_logic_vector(2 downto 0) := (others => '0');	--part of VL
	signal vbuf : std_logic_vector(24 downto 0) := (others=>'0');	--initially VE
	signal bbuf : std_logic_vector(10 downto 0) := (others => '0');	--buffer for byte
	signal count : std_logic_vector(3 downto 0) := (others => '0');	--count of valid bits
	signal alignflg : std_logic := '0';
	signal doneflg : std_logic := '0';
	signal pbyte : std_logic_vector(7 downto 0) := (others => '0');	--output (pre stuffing)
	signal pstrobe : std_logic := '0';
	signal pzeros : std_logic_vector(1 downto 0) := (others => '0');
	signal vbufsel : std_logic_vector(3 downto 0) := (others=>'0');	--selection of vbuf
	signal pop : std_logic := '0';
	--
begin
	--
	vbufsel <=  vbuf(3 downto 0) when sel=0 else
				vbuf(7 downto 4) when sel=1 else
				vbuf(11 downto 8) when sel=2 else
				vbuf(15 downto 12) when sel=3 else
				vbuf(19 downto 16) when sel=4 else
				vbuf(23 downto 20) when sel=5 else
				b"000"&vbuf(24) when sel=6 else
				x"0";
	--
	adiff <= ain - aout;
	ready <= '1' when adiff < 24 else '0';
	pop <= '1' when ain/=aout and ptr<=4 and alignflg='0' else '0';
	VE1 <= aVE(conv_integer(aout));
	VL1 <= aVL(conv_integer(aout));
	--
process(CLK)
begin
	if rising_edge(CLK) then
		--fifo
		if VALID='1' then
			aVE(conv_integer(ain)) <= VE;
			aVL(conv_integer(ain)) <= VL;
			ain <= ain + 1;
			assert adiff /= 63 report "fifo overflow" severity ERROR;
		end if;
		if POP='1' then
			aout <= aout + 1;
		end if;
		--convert to bytes
		if ptr>0 then
			--process up to 4 bits
			if ptr(1 downto 0) = 0 then
				bbuf <= bbuf(6 downto 0) & vbufsel(3 downto 0);		--process 4 bits
				count <= ('0'&count(2 downto 0)) + 4;
			elsif ptr(1 downto 0) = 3 then
				bbuf <= bbuf(7 downto 0) & vbufsel(2 downto 0);		--process 3 bits
				count <= ('0'&count(2 downto 0)) + 3;
			elsif ptr(1 downto 0) = 2 then
				bbuf <= bbuf(8 downto 0) & vbufsel(1 downto 0);		--process 2 bits
				count <= ('0'&count(2 downto 0)) + 2;
			else --1
				bbuf <= bbuf(9 downto 0) & vbufsel(0);		--process 1 bit
				count <= ('0'&count(2 downto 0)) + 1;
			end if;
		else --nothing to process
			count(3) <= '0';	--keep low 3 bits, but this (the "available byte") clears
		end if;
		--
		if ptr<=4 and alignflg='1' then
			if ptr=0 and pstrobe='0' and count(3)='0' then
				count(2 downto 0) <= b"000";	--waste a cycle for alignment
				alignflg <= '0';
				DONE <= doneflg;
			else
				ptr <= b"00000";
			end if;
		elsif POP='1' then	--here to POP
			ptr <= VL1;
			vbuf <= VE1;
			alignflg <= VE1(16) and not VL1(4);	--if VL<16 and VE(16) set
			doneflg <= VE1(17) and not VL1(4);	--if VL<16 and VE(17) set
			if VL1(1 downto 0) = 0 then
				sel <= VL1(4 downto 2)-1;
			else
				sel <= VL1(4 downto 2);
			end if;
		else		--process stuff in register
			if ptr(1 downto 0) /= 0 then
				ptr(1 downto 0) <= b"00";
				sel <= ptr(4 downto 2)-1;
			elsif ptr/=0 then
				ptr(4 downto 2) <= ptr(4 downto 2)-1;
				sel <= ptr(4 downto 2)-2;
			end if;
		end if;
		--
		if count(3)='1' then
			if count(1 downto 0)=0 then
				pbyte <= bbuf(7 downto 0);
			elsif count(1 downto 0)=1 then
				pbyte <= bbuf(8 downto 1);
			elsif count(1 downto 0)=2 then
				pbyte <= bbuf(9 downto 2);
			else
				pbyte <= bbuf(10 downto 3);
			end if;
		end if;
		if pstrobe='1' and pzeros<2 and pbyte=0 then
			pzeros <= pzeros + 1;
		elsif pstrobe='1' then
			pzeros <= b"00";	--either because stuffed or non-zero
		end if;
		if pstrobe='1' and pzeros=2 and pbyte<4 then	
			BYTE <= x"03";			--stuff!!
			--leave pstrobe unchanged
		else
			BYTE <= pbyte;
			pstrobe <= count(3);
		end if;
		if alignflg='0' and doneflg='1' then
			DONE <= '0';
			doneflg <= '0';
		end if;
		STROBE <= pstrobe;
	end if;
end process;
	--
end hw;

