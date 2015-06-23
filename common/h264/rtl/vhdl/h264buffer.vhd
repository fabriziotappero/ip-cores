-------------------------------------------------------------------------
-- H264 buffer - VHDL
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

-- This is the buffer which takes intra or inter predicted output
-- after transform and quantise, and stores it pending the moment
-- to feed it to the CAVLC unit for output.

-- It is stored in the buffer partly so the luma and chroma prediction
-- and transform computations can be overlapped, and later output
-- in the correct order, but also so the header information can be
-- output before the data.

-- We store it before the CAVLC pass because, although typically larger,
-- the size is more predictable.  There's enough size to store two chroma
-- copies but only one luma copy because the chroma is output last.

-- input order:
-- luma0, chromadcA, chromaA0, luma1
-- luma2, chromaA1, luma3
-- luma4, chromaA2, luma6
-- luma6, chromaA3, luma7
-- luma8, chromadcB, chromaB0, luma9
-- luma10, chromaB1, luma11
-- luma12, chromaB2, luma13
-- luma14, chromaB3, luma15

-- output order (once all luma is in):
-- luma0..luma15
-- chromadcA, chromadcB
-- chromaA0..3, chromaB0..3

-- nb: chroma comes in as 16beat packets, out as 15beat ones (no final dc coeff)

-- Amount of storage: 16x16 = 256 words of luma
-- 4x15 = 60 words of ac chroma, Cr and Cb x two sets = 240
-- 4 words of ac chroma, Cr and Cb x two sets = 16

-- XST: 200MHz, 64 slices + 1 BRAM

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.ALL;

entity h264buffer is
	port (
		CLK : in std_logic;					--clock
		NEWSLICE : in std_logic;			--reset: this is the first in a slice
		NEWLINE : in std_logic;				--this is the first in a line
		--
		VALIDI : in std_logic;				--luma/chroma data here (15/16/4 of these)
		ZIN : in std_logic_vector(11 downto 0);	--luma/chroma data
		READYI : out std_logic := '0';		--set when ready for next luma/chroma
		CCIN : out std_logic := '0';		--set when inputting chroma
		DONE : out std_logic := '0';		--set when all done and quiescent
		--
		VOUT : out std_logic_vector(11 downto 0) := (others=>'0');	--luma/chroma data
		VALIDO : out std_logic := '0';		--strobe for data out
		--
		NLOAD : out std_logic := '0';		--load for CAVLC NOUT
		NX : out std_logic_vector(2 downto 0) := b"000";	--X value for NIN/NOUT
		NY : out std_logic_vector(2 downto 0) := b"000";	--Y value for NIN/NOUT
		NV : out std_logic_vector(1 downto 0) := b"00";	--valid flags for NIN/NOUT (1=left, 2=top, 3=avg)
		NXINC : out std_logic := '0';		--increment for X macroblock counter
		--
		READYO : in std_logic;				--from cavlc module (goes inactive after block starts)
		TREADYO : in std_logic;				--from tobytes module: tells it to freeze
		HVALID : in std_logic				--when header module outputting
	);
end h264buffer;

architecture hw of h264buffer is
	type Tbuf is array(511 downto 0) of std_logic_vector(11 downto 0);
	signal buf : Tbuf;
	--
	signal ix : std_logic_vector(3 downto 0) := x"0";	--index inside block
	signal isubmb : std_logic_vector(3 downto 0) := x"0";--index to blocks of luma
	signal ichsubmb : std_logic_vector(2 downto 0) := b"000";--index to blocks of chroma
	signal ichf : std_logic := '0';						--chroma flag
	signal ichdc : std_logic := '0';					--dc chroma flag
	signal imb : std_logic_vector(1 downto 0) := b"00";	--odd/even mb for chroma
	signal ox : std_logic_vector(3 downto 0) := x"0";	--index inside block
	signal osubmb : std_logic_vector(3 downto 0) := x"0";--index to blocks of luma
	signal ochf : std_logic := '0';						--chroma flag
	signal ochdc : std_logic := '0';					--dc chroma flag
	signal omb : std_logic_vector(1 downto 0) := b"00";	--odd/even mb for chroma
	signal nloadi : std_logic := '0';					--flag for nload (delay by 1)
	signal nxinci : std_logic := '0';					--flag for nload (delay by 1)
	signal nv0 : std_logic := '0';					--for NV(0)
	signal nv1 : std_logic := '0';					--for NV(1)
	signal nlvalid: std_logic := '0';					--left N is valid
	signal ntvalid: std_logic := '0';					--top N is valid
	signal ccinf : std_logic := '0';					--chroma in
	--
begin
	--
	READYI <= '1' when omb=imb or (ochf='1' and isubmb < 12) or 
			(isubmb+1 < osubmb and isubmb < 12) else '0';
	DONE <= '1' when omb=imb and isubmb=0 and osubmb=0 and READYO='1' else '0';
	nv0 <= '1' when nlvalid='1' or (osubmb(2)='1' and ochf='0') or osubmb(0)='1' else '0';
	nv1 <= '1' when ntvalid='1' or (osubmb(3)='1' and ochf='0') or osubmb(1)='1' else '0';
	--
process(CLK)
	variable addr : std_logic_vector(8 downto 0);
begin
	if rising_edge(CLK) then
		if NEWSLICE='1' then
			ix <= x"0";		--reset
			isubmb <= x"0";
			ichsubmb <= b"000";
			ichf <= '0';
			ichdc <= '0';
			imb <= b"00";
			ox <= x"0";
			osubmb <= x"0";
			ochf <= '0';
			ochdc <= '0';
			omb <= b"00";
			nloadi <= '0';
			nlvalid <= '0';
			ntvalid <= '0';
		elsif NEWLINE='1' then
			nlvalid <= '0';
			ntvalid <= '1';
		end if;
		--
		if VALIDI='1' and NEWSLICE='0' then
			if ichf='0' then
				addr := '0' & isubmb & ix;		
			elsif ichdc='0' then
				addr := '1' & imb(0) & ichsubmb & ix;
			else
				addr := '1' & imb(0) & ichsubmb(2) & (not ix(1 downto 0)) & x"F";
			end if;
			assert not is_x(ZIN) report "Problems with ZIN" severity WARNING;
			if ichf='0' or ix/=15 then
				buf(conv_integer(addr)) <= ZIN;
			end if;
			if ichf='0' then	--luma
				ix <= ix + 1;
				if ix=15 then
					isubmb <= isubmb+1;
					ichf <= not isubmb(0);	--switch to chroma after even blocks
					if isubmb=0 or isubmb=8 then
						ichdc <= '1';
					end if;
					if isubmb=15 then
						imb <= imb+1;
					end if;
					assert isubmb/=osubmb or ochf='1' or ox>ix or imb=omb report "xbuffer overflow?" severity ERROR;
				end if;
			elsif ichdc='1' then	--chromadc
				if ix=3 then
					ix <= x"0";
					ichdc <= '0';
				else
					ix <= ix + 1;
				end if;
			elsif ichdc='0' then
				ix <= ix + 1;
				if ix=15 then
					ichsubmb <= ichsubmb + 1;
					ichf <= '0';
				end if;
			end if;
		end if;
		if VALIDI='0' and NEWSLICE='0' then
			assert ix=0 report "VALIDI has fallen when in middle of block" severity WARNING;
		end if;
		--
		if NEWSLICE='0' and HVALID='0' and imb/=omb and ((TREADYO='1' and READYO='1') or ox/=0) then
			--output
			if ochf='0' then
				addr := '0' & osubmb & ox;
			elsif ochdc='1' then
				addr := '1' & omb(0) & osubmb(2) & ox(1 downto 0) & x"F";
			else
				addr := '1' & omb(0) & osubmb(2 downto 0) & ox;
			end if;	
			VOUT <= buf(conv_integer(addr));
			assert not is_x(buf(conv_integer(addr))) report "Problems with VOUT" severity WARNING;
			VALIDO <= '1';
			if ochf='0' then
				NX <= '0'&osubmb(2)&osubmb(0);
				NY <= '0'&osubmb(3)&osubmb(1);
			else
				NX <= '1'&osubmb(2)&osubmb(0);	--osubmb(2) is Cr/Cb flag
				NY <= '1'&osubmb(2)&osubmb(1);
			end if;
			if ochf='0' then
				ox <= ox+1;
				if ox=15 then
					osubmb <= osubmb+1;
					if osubmb=15 then
						ochf <= '1';
						ochdc <= '1';	--DC chroma follows Luma
					end if;
					nloadi <= '1';
				end if;
			elsif ochdc='1' then
				if ox/=3 then
					ox <= ox+1;
				else
					ox <= x"0";					
					osubmb(2) <= not osubmb(2);
					if osubmb(2)='1' then
						ochdc <= '0';	--AC chroma follows both DC chroma
					end if;
				end if;
			else
				if ox/=14 then
					ox <= ox+1;
				else
					ox <= x"0";
					osubmb(2 downto 0) <= osubmb(2 downto 0)+1;
					if osubmb(2 downto 0)=7 then
						ochf <= '0';
						omb <= omb+1;
						nxinci <= '1';
					end if;
					nloadi <= '1';
				end if;
			end if;
		else
			VALIDO <= '0';
		end if;
		NLOAD <= nloadi;
		NXINC <= nxinci;
		NV <= nv1&nv0;
		if nloadi='1' then
			nloadi <= '0';
		end if;
		if nxinci='1' then
			nxinci <= '0';
			nlvalid <= '1';
		end if;
		--
		ccinf <= ichf and VALIDI;
		CCIN <= ccinf;
	end if;
end process;
	--
end hw;	--h264buffer

