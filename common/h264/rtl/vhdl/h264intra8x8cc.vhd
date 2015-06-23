-------------------------------------------------------------------------
-- H264 intra 8x8 chroma prediction - VHDL
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

-- Converts a macroblock to residuals for transform, using the block
-- immediately above and to the left as basis for prediction
-- This works on pairs of 8x8 Chroma blocks

-- Predicts one of type (for both blocks):
-- (0) DC
-- (1) Horizontal (NOT USED IN THIS MODULE)
-- (2) Vertical (NOT USED IN THIS MODULE)
-- (3) Plane (NOT USED IN THIS MODULE)

-- This version ALWAYS uses the DC prediction type

-- Input: DATAI(8bit)x4, STROBEI, NEWLINE, TOPI
-- Output: DATAO(9bit)x4, STROBEO, CMODEO
-- also DCDATAO(13bit), DCSTROBO -- dc components

-- The DC components of each block are computed and output via
-- a separate interface which allows speedy transfer to dctransform
-- without waiting for all four blocks to be output.

-- There are 64 pixels in the macroblock (8x8) for each Chroma
-- component, transfered four at a time on the wide bus
-- (lsbits = first pixel).

-- Data in is in raster scan order...
-- 1 1 1 1 2 2 2 2 for Cb
-- 3 3 3 3 4 4 4 4 
-- ....
-- 15...15 16...16
-- 1 1 1 1 2 2 2 2 for Cr
-- 3 3 3 3 4 4 4 4 
-- ....
-- 15...15 16...16

-- Before the first macroblock in a line NEWLINE is set
-- this initialises all pointers and resets the prediction mode to
-- no adjacent blocks.  NEWLINE should be set for at least 1 CLK before
-- STROBEI goes high.
-- If this is the first in a slice, NEWSLICE should be set at the same
-- time as newline.

-- Data is clocked in by STROBEI; because of lag between READYI and
-- data from (possibly external) ram, then a limited amount of data
-- may be clocked in even after READYI falls (up to 16 words).

-- Note the pixels from the previous line are NOT stored by this module
-- but input via TOPI.  Those on the left are stored internally,
-- For this reason, an entire line of macroblocks must be encoded at once.
-- External to this module is a simple storage interface which stores TOP
-- pixels and block types.
-- XXO indicates which TOPI should be read but also which to latch the
-- feedback data into when it appears.

-- FEEDBI provides the pixel feedback to the left column, and FBSTROBE
-- when it is valid.  This comes from the transform/quantise/dequant/detransform
-- loop and gives the pixels as seen by the decoder.

-- XST: 

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.ALL;

entity h264intra8x8cc is
	port (
		CLK2 : in std_logic;				--2x clock
		--
		-- in interface:
		NEWSLICE : in std_logic;			--indication this is the first in a slice
		NEWLINE : in std_logic;				--indication this is the first on a line
		STROBEI : in std_logic;				--data here
		DATAI : in std_logic_vector(31 downto 0);
		READYI : out std_logic := '0';
		--
		-- top interface:
		TOPI : in std_logic_vector(31 downto 0);	--top pixels (to predict against)
		XXO : out std_logic_vector(1 downto 0) := b"00";		--which macroblock X
		XXC : out std_logic := '0';				--carry from XXO, to add to macroblock
		XXINC : out std_logic := '0';			--when to increment XX macroblock
		--
		-- feedback interface:
		FEEDBI : in std_logic_vector(7 downto 0);	--feedback for pixcol
		FBSTROBE : in std_logic;					--feedback valid
		--
		-- out interface:
		STROBEO : out std_logic := '0';				--data here
		DATAO : out std_logic_vector(35 downto 0) := (others => '0');
		BASEO : out std_logic_vector(31 downto 0) := (others => '0');	--base for reconstruct
		READYO : in std_logic := '1';
		DCSTROBEO : out std_logic := '0';			--dc data here
		DCDATAO : out std_logic_vector(15 downto 0) := (others => '0');
		CMODEO : out std_logic_vector(1 downto 0) := (others => '0')	--prediction type
	);
end h264intra8x8cc;

architecture hw of h264intra8x8cc is
	--pixels
	type Tpix is array(31 downto 0) of std_logic_vector(31 downto 0);
	signal pix : Tpix := (others => (others => '0'));	--macroblock data; first half is Cb, then Cr
	type Tpixcol is array(15 downto 0) of std_logic_vector(7 downto 0);
	signal pixleft : Tpixcol := (others => x"00");		--previous col, first half is Cb, then Cr
	signal lvalid : std_logic := '0';					--set if pixels on left are valid
	signal tvalid : std_logic := '0';					--set if TOP valid (not first line)
	signal topil : std_logic_vector(31 downto 0) := (others=>'0');
	signal topir : std_logic_vector(31 downto 0) := (others=>'0');
	signal topii : std_logic_vector(31 downto 0) := (others=>'0');
	--input states
	signal istate : std_logic_vector(4 downto 0) := (others=>'0');	--which input word
	--processing states	
	signal crcb : std_logic := '0';			--which of cr/cb
	signal quad : std_logic_vector(1 downto 0) := b"00";	--which of 4 blocks
	constant IDLE : std_logic_vector(3 downto 0) := b"0000";
	signal state : std_logic_vector(3 downto 0) := IDLE;	--state/row for processing
	--output state
	signal oquad : std_logic_vector(1 downto 0) := b"00";	--which of 4 blocks output
	signal fquad : std_logic_vector(1 downto 0) := b"00";	--which of 4 blocks for feedback
	signal ddc1  : std_logic := '0';						--output flag dc
	signal ddc2  : std_logic := '0';						--output flag dc
	signal fbpending : std_logic := '0';					--wait for feedback
	signal fbptr : std_logic_vector(3 downto 0) := b"0000";
	--type out
	--signal cmodeoi : std_logic_vector(1 downto 0) := b"00";	--always DC=0 this version
	--data path
	signal dat0 : std_logic_vector(31 downto 0) := (others=>'0');
	--data channels
	alias datai0 : std_logic_vector(7 downto 0) is dat0(7 downto 0);
	alias datai1 : std_logic_vector(7 downto 0) is dat0(15 downto 8);
	alias datai2 : std_logic_vector(7 downto 0) is dat0(23 downto 16);
	alias datai3 : std_logic_vector(7 downto 0) is dat0(31 downto 24);
	--top channels
	alias topii0 : std_logic_vector(7 downto 0) is topii(7 downto 0);
	alias topii1 : std_logic_vector(7 downto 0) is topii(15 downto 8);
	alias topii2 : std_logic_vector(7 downto 0) is topii(23 downto 16);
	alias topii3 : std_logic_vector(7 downto 0) is topii(31 downto 24);
	--diffs for mode 2 dc
	signal lindex : std_logic_vector(1 downto 0) :=  (others=>'0');
	signal left0 : std_logic_vector(7 downto 0) :=  (others=>'0');
	signal left1 : std_logic_vector(7 downto 0) :=  (others=>'0');
	signal left2 : std_logic_vector(7 downto 0) :=  (others=>'0');
	signal left3 : std_logic_vector(7 downto 0) :=  (others=>'0');
	signal ddif0 : std_logic_vector(8 downto 0) :=  (others=>'0');
	signal ddif1 : std_logic_vector(8 downto 0) :=  (others=>'0');
	signal ddif2 : std_logic_vector(8 downto 0) :=  (others=>'0');
	signal ddif3 : std_logic_vector(8 downto 0) :=  (others=>'0');
	signal dtot : std_logic_vector(12 downto 0) :=  (others=>'0');
	--averages for mode 2 dc
	signal sumt : std_logic_vector(9 downto 0) :=  (others=>'0');
	signal suml : std_logic_vector(9 downto 0) :=  (others=>'0');
	signal sumtl : std_logic_vector(10 downto 0) :=  (others=>'0');
	alias avg  : std_logic_vector(7 downto 0) is sumtl(10 downto 3);
	--
begin
	-- 
	XXO <= crcb & fquad(0);
	XXINC <= '1' when state=15 and crcb='1' else '0';
	READYI <= '1' when state=IDLE or istate(4) /= crcb else '0';
	DCDATAO <= sxt(dtot,16);
	--
	topii <= topil when quad(0)='0' else topir;
	lindex <= crcb & quad(1);
	left0 <= pixleft(conv_integer(lindex & b"00"));
	left1 <= pixleft(conv_integer(lindex & b"01"));
	left2 <= pixleft(conv_integer(lindex & b"10"));
	left3 <= pixleft(conv_integer(lindex & b"11"));
	--
	--CMODEO <= cmodeoi;	--always 00
	--
process(CLK2)
begin
	if rising_edge(CLK2) then
		--
		if STROBEI='1' then
			pix(conv_integer(istate)) <= DATAI;
			istate <= istate + 1;
		elsif NEWLINE='1' then
			istate <= (others=>'0');
			lvalid <= '0';
			state <= IDLE;
			crcb <= '0';
			quad <= b"00";
		end if;
		if NEWSLICE='1' then
			tvalid <= '0';
		elsif NEWLINE='1' then
			tvalid <= '1';
		end if;
		--
		if NEWLINE='0' then
			if state=IDLE and istate(4)=crcb then
				null;	--wait for enough data
			elsif state=7 and oquad/=3 then
				state <= IDLE+4;			--loop to load all DC coeffs
			elsif state=8 and READYO='0' then
				null;	--wait before output
			elsif state=14 and (fbpending='1' or FBSTROBE='1') then
				null;	--wait before feedback
			elsif state=14 and quad/=0 then
				state <= IDLE+8;			--loop for all blocks
			else
				state <= state+1;
			end if;
			--
			if state=15 then
				crcb <= not crcb;
				if crcb='1' then
					lvalid <= '1';	--new macroblk
				end if;
			end if;
			--
			if state=5 or state=9 then
				quad <= quad+1;
			end if;
			if state=7 or state=11 then
				oquad <= quad;
			end if;
			if state=0 or state=1 then
				fquad(0) <= state(0);	--for latching topir/topil
			elsif state=9 then
				fquad <= quad;
			end if;
		end if;
		--
		if state=1 then
			topil <= TOPI;
		elsif state=2 then
			topir <= TOPI;
		end if;
		sumt <= (b"00"&topii0) + (b"00"&topii1) + (b"00"&topii2) + (b"00"&topii3);
		suml <= (b"00"&left0) + (b"00"&left1) + (b"00"&left2) + (b"00"&left3);
		if state=4 or state=8 then
			-- set avg by setting sumtl
			-- note: quad 1 and 2 don't use sumt+suml but prefer sumt or suml if poss
			if lvalid='1' and tvalid='1' and (quad=0 or quad=3) then	--left+top valid
				sumtl <= ('0'&sumt) + ('0'&suml) + 4;
			elsif lvalid='1' and (tvalid='0' or quad=2) then
				sumtl <= (suml&'0') + 4;
			elsif (lvalid='0' or quad=1) and tvalid='1' then
				sumtl <= (sumt&'0') + 4;
			else
				sumtl <= x"80"&b"000";
			end if;
		end if;
		--
		--states 4..7, 8..11
		dat0 <= pix(conv_integer(crcb & oquad(1) & state(1 downto 0) & oquad(0)));
		if state=7 then
			ddc1 <= '1';
		else
			ddc1 <= '0';
		end if;
		--
		--states 5..(8), 9..12
		ddif0 <= ('0'&datai0) - ('0'&avg);
		ddif1 <= ('0'&datai1) - ('0'&avg);
		ddif2 <= ('0'&datai2) - ('0'&avg);
		ddif3 <= ('0'&datai3) - ('0'&avg);
		ddc2 <= ddc1;
		--
		--states 6..(9)
		if state=6 then
			dtot <= sxt(ddif0,13) + sxt(ddif1,13) + sxt(ddif2,13) + sxt(ddif3,13);
		else
			dtot <= dtot + sxt(ddif0,13) + sxt(ddif1,13) + sxt(ddif2,13) + sxt(ddif3,13);
		end if;
		DCSTROBEO <= ddc2;
		--
		--states 10..13
		if state>=10 and state<=13 then
			DATAO <= ddif3 & ddif2 & ddif1 & ddif0;
			BASEO <= avg&avg&avg&avg;
			STROBEO <= '1';
		else
			STROBEO <= '0';
		end if;
		--		
		if state=9 then	--set feedback ptr to get later feedback
			fbptr <= crcb & quad(1) & b"00";
			fbpending <= '1';
		end if;
		--
		-- this comes back from transform/quantise/dequant/detransform loop
		-- some time later... (state=13 waits for it)
		--
		if FBSTROBE='1' and state>=12 then
			if quad(0)='0' then
				pixleft(conv_integer(fbptr)) <= FEEDBI;
			end if;
			fbptr <= fbptr + 1;
			fbpending <= '0';
		end if;
		--
	end if;
end process;
	--
end hw;	--h264intra8x8cc
