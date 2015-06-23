-------------------------------------------------------------------------
-- H264 intra 4x4 luma prediction - VHDL
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
-- Predicts one of type:
-- (0) Vertical
-- (1) Horizontal
-- (2) DC
-- (3) (NOT USED)
-- (4) Diagonal down right (45deg) (NOT CURRENTLY)
-- (5) Vertical right (22deg) (NOT CURRENTLY)
-- (6) Horizonal down (22deg) (NOT CURRENTLY)
-- (7) (NOT USED)
-- (8) Horizonal up (22deg) (NOT CURRENTLY)

-- Input: DATAI(8bit)x4, STROBEI, NEWLINE, TOPI
-- Output: DATAO(9bit)x4, STROBEO, MODEO

-- There are 256 pixels in a macroblock (16x16), transfered
-- four at a time on the wide bus (lsbits = first pixel)

-- Data in/out is in raster scan order...
-- 1 1 1 1 2 2 2 2 3 3 3 3 4 4 4 4 
-- 5.....5 6.....6 7.....7 8.....8
--                ...
-- 61...61 62...62 63...63 64...64 

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
-- pixels and block types.  TOPMI is the top blocks's mode.
-- (these are ignored if first line in slice).
-- XXO indicates which TOPI should be read but also which to latch the
-- FEEDB data into when it appears.

-- FEEDBI provides the pixel feedback to the left column, and FBSTROBE
-- when it is valid.  This comes from the transform/quantise/dequant/detransform
-- loop and gives the pixels as seen by the decoder.

-- XST: 387 slices+1BRAM; 116 MHz; XPower: 8mW

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.ALL;

entity h264intra4x4 is
	port (
		CLK : in std_logic;					--pixel clock
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
		TOPMI : in std_logic_vector(3 downto 0);	--top block's mode (for P/RMODEO)
		XXO : out std_logic_vector(1 downto 0) := b"00";		--which macroblock X
		XXINC : out std_logic := '0';				--when to increment XX macroblock
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
		MSTROBEO : out std_logic := '0';			--modeo here
		MODEO : out std_logic_vector(3 downto 0) := (others => '0');	--0..8 prediction type
		PMODEO : out std_logic := '0';				--prev_i4x4_pred_mode_flag
		RMODEO : out std_logic_vector(2 downto 0) := (others => '0');	--rem_i4x4_pred_mode_flag
		--
		CHREADY :  out std_logic := '0'				--ready line to chroma
	);
end h264intra4x4;

architecture hw of h264intra4x4 is
	--pixels on left
	type Tpix is array(63 downto 0) of std_logic_vector(31 downto 0);
	signal pix : Tpix := (others => (others => '0'));	--macroblock data
	type Tpixcol is array(15 downto 0) of std_logic_vector(7 downto 0);
	signal pixleft : Tpixcol := (others => x"00");		--previous col
	signal pixlefttop : std_logic_vector(7 downto 0);	--previous top col
	signal lvalid : std_logic := '0';					--set if pixels on left are valid
	signal tvalid : std_logic := '0';					--set if TOP valid (not first line)
	signal dconly : std_logic := '0';					--dconly as per std
	signal topih : std_logic_vector(31 downto 0) := (others=>'0');
	signal topii : std_logic_vector(31 downto 0) := (others=>'0');
	--
	--input states	
	signal statei : std_logic_vector(5 downto 0) := b"000000";	--state(rowcol) for input
	--processing states	
	constant IDLE : std_logic_vector(4 downto 0) := b"00000";
	signal state : std_logic_vector(4 downto 0) := IDLE;	--state/row for processing
	--output state
	signal outf1 : std_logic := '0';						--output flag
	signal outf : std_logic := '0';							--output flag
	signal chreadyi : std_logic := '0';						--chready anticipated
	signal chreadyii : std_logic := '0';					--chready anticipated 2
	signal readyod : std_logic := '0';						--delayed READYO in
	--
	--position of sub macroblock in macroblock
	signal submb : std_logic_vector(3 downto 0) := x"0";	--which of 16 submb in mb
	signal xx : std_logic_vector(1 downto 0) := b"00";
	signal yy : std_logic_vector(1 downto 0) := b"00";
	signal yyfull : std_logic_vector(3 downto 0) := x"0";
	signal oldxx : std_logic_vector(1 downto 0) := b"00";
	signal fbptr : std_logic_vector(3 downto 0) := x"0";
	signal fbpending : std_logic := '0';
	--type out
	signal modeoi : std_logic_vector(3 downto 0) := x"0";
	signal prevmode : std_logic_vector(3 downto 0) := x"0";
	type Tlmode is array(3 downto 0) of std_logic_vector(3 downto 0);
	signal lmode : Tlmode := (others => x"9");
	--data path
	signal dat0 : std_logic_vector(31 downto 0) := (others=>'0');
	--data channels
	alias datai0 : std_logic_vector(7 downto 0) is dat0(7 downto 0);
	alias datai1 : std_logic_vector(7 downto 0) is dat0(15 downto 8);
	alias datai2 : std_logic_vector(7 downto 0) is dat0(23 downto 16);
	alias datai3 : std_logic_vector(7 downto 0) is dat0(31 downto 24);
	--top channels
	alias topi0 : std_logic_vector(7 downto 0) is TOPI(7 downto 0);
	alias topi1 : std_logic_vector(7 downto 0) is TOPI(15 downto 8);
	alias topi2 : std_logic_vector(7 downto 0) is TOPI(23 downto 16);
	alias topi3 : std_logic_vector(7 downto 0) is TOPI(31 downto 24);
	alias topii0 : std_logic_vector(7 downto 0) is topii(7 downto 0);
	alias topii1 : std_logic_vector(7 downto 0) is topii(15 downto 8);
	alias topii2 : std_logic_vector(7 downto 0) is topii(23 downto 16);
	alias topii3 : std_logic_vector(7 downto 0) is topii(31 downto 24);
	--diffs for mode 0 vertical
	signal vdif0 : std_logic_vector(8 downto 0) :=  (others=>'0');
	signal vdif1 : std_logic_vector(8 downto 0) :=  (others=>'0');
	signal vdif2 : std_logic_vector(8 downto 0) :=  (others=>'0');
	signal vdif3 : std_logic_vector(8 downto 0) :=  (others=>'0');
	signal vabsdif0 : std_logic_vector(7 downto 0) :=  (others=>'0');
	signal vabsdif1 : std_logic_vector(7 downto 0) :=  (others=>'0');
	signal vabsdif2 : std_logic_vector(7 downto 0) :=  (others=>'0');
	signal vabsdif3 : std_logic_vector(7 downto 0) :=  (others=>'0');
	signal vtotdif : std_logic_vector(11 downto 0) :=  (others=>'0');
	--diffs for mode 1 horizontal
	signal leftp : std_logic_vector(7 downto 0) :=  (others=>'0');
	signal leftpd : std_logic_vector(7 downto 0) :=  (others=>'0');
	signal hdif0 : std_logic_vector(8 downto 0) :=  (others=>'0');
	signal hdif1 : std_logic_vector(8 downto 0) :=  (others=>'0');
	signal hdif2 : std_logic_vector(8 downto 0) :=  (others=>'0');
	signal hdif3 : std_logic_vector(8 downto 0) :=  (others=>'0');
	signal habsdif0 : std_logic_vector(7 downto 0) :=  (others=>'0');
	signal habsdif1 : std_logic_vector(7 downto 0) :=  (others=>'0');
	signal habsdif2 : std_logic_vector(7 downto 0) :=  (others=>'0');
	signal habsdif3 : std_logic_vector(7 downto 0) :=  (others=>'0');
	signal htotdif : std_logic_vector(11 downto 0) :=  (others=>'0');
	--diffs for mode 2 dc
	signal left0 : std_logic_vector(7 downto 0) :=  (others=>'0');
	signal left1 : std_logic_vector(7 downto 0) :=  (others=>'0');
	signal left2 : std_logic_vector(7 downto 0) :=  (others=>'0');
	signal left3 : std_logic_vector(7 downto 0) :=  (others=>'0');
	signal ddif0 : std_logic_vector(8 downto 0) :=  (others=>'0');
	signal ddif1 : std_logic_vector(8 downto 0) :=  (others=>'0');
	signal ddif2 : std_logic_vector(8 downto 0) :=  (others=>'0');
	signal ddif3 : std_logic_vector(8 downto 0) :=  (others=>'0');
	signal dabsdif0 : std_logic_vector(7 downto 0) :=  (others=>'0');
	signal dabsdif1 : std_logic_vector(7 downto 0) :=  (others=>'0');
	signal dabsdif2 : std_logic_vector(7 downto 0) :=  (others=>'0');
	signal dabsdif3 : std_logic_vector(7 downto 0) :=  (others=>'0');
	signal dtotdif : std_logic_vector(11 downto 0) :=  (others=>'0');
	--averages for mode 2 dc
	signal sumt : std_logic_vector(9 downto 0) :=  (others=>'0');
	signal suml : std_logic_vector(9 downto 0) :=  (others=>'0');
	signal sumtl : std_logic_vector(10 downto 0) :=  (others=>'0');
	alias avg  : std_logic_vector(7 downto 0) is sumtl(10 downto 3);
	--
begin
	--
	xx <= submb(2)&submb(0);
	yy <= submb(3)&submb(1);
	--
	XXO <= xx when state=2 or state=16 else oldxx;
	XXINC <= '1' when state=20 else '0';
	READYI <= '1' when statei(5 downto 4) /= yy-2 and statei(5 downto 4) /= yy-1 else '0';
	--
	yyfull <= yy & state(1 downto 0);
	left0 <= pixleft(conv_integer(yy & b"00"));
	left1 <= pixleft(conv_integer(yy & b"01"));
	left2 <= pixleft(conv_integer(yy & b"10"));
	left3 <= pixleft(conv_integer(yy & b"11"));
	--
	MODEO <= modeoi;
	--
	CHREADY <= chreadyii and READYO;
	--
process(CLK)
	variable xi: integer;
	variable yi: integer;
begin
	if rising_edge(CLK) then
		--
		if STROBEI='1' then
			pix(conv_integer(statei)) <= DATAI;
			statei <= statei + 1;
		elsif NEWLINE='1' then
			statei <= b"000000";
			lvalid <= '0';
			state <= IDLE;
			STROBEO <= '0';
			fbpending <= '0';
		end if;
		if NEWSLICE='1' then
			tvalid <= '0';
		elsif NEWLINE='1' then
			tvalid <= '1';
		end if;
		--
		if state=15 then
			submb <= submb+1;
		end if;
		if state=1 or state=15 then
			oldxx <= xx;
		end if;
		if state=IDLE and statei=0 then
			null;	--wait for some data
		elsif state=3 and statei(5 downto 4)=yy then
			null;	--wait for enough data
		elsif state=11 and (READYO='0' or FBSTROBE='1' or fbpending='1') then
			null;	--wait before output
		elsif state=15 and xx(0)='1' and submb/=15 then
			state <= IDLE+2;	--quickly onto next (no need to await strobe)
		elsif state=19 and (FBSTROBE='1' or fbpending='1' or chreadyi='1' or chreadyii='1') then
			null;	--wait for fb / chready complete
		elsif state=19 and submb/=0 then
			state <= IDLE+3;	--onto next
		elsif state=20 then
			--new macroblock, XXINC is set this state
			state <= IDLE;		--reload new TOP stuff
		else
			state <= state+1;
		end if;
		if state=15 and xx(0)='0' then
			chreadyi <= '1';
		end if;
		if outf='0' and chreadyi='1' and READYO='0' then
			chreadyii <= '1';
			chreadyi <= '0';
		elsif READYO='0' and readyod='1' and chreadyii='1' then
			chreadyii <= '0';
		end if;
		readyod <= READYO;
		--
		if state=2 or state=16 then
			--read TOPMI for this submb (only if tvalid&lvalid)
			if TOPMI < lmode(conv_integer(yy)) then
				prevmode <= TOPMI;
			else
				prevmode <= lmode(conv_integer(yy));
			end if;
			--
			sumt <= (b"00"&topi0) + (b"00"&topi1) + (b"00"&topi2) + (b"00"&topi3);
			topih <= TOPI;
		end if;
		suml <= (b"00"&left0) + (b"00"&left1) + (b"00"&left2) + (b"00"&left3);
		if state=3 then
			-- set avg by setting sumtl
			if lvalid='1' or xx/=0 then	--left valid
				if tvalid='1' or yy/=0 then				--top valid
					sumtl <= ('0'&sumt) + ('0'&suml) + 4;
				else
					sumtl <= (suml&'0') + 4;
				end if;
			else
				if tvalid='1' or yy/=0 then				--top valid
					sumtl <= (sumt&'0') + 4;
				else
					sumtl <= x"80"&b"000";
				end if;
			end if;
			topii <= topih;
		end if;
		--
		-- states 4..7(pass1) 12..15(pass2)
		dat0 <= pix(conv_integer(yy & state(1 downto 0) & xx));
		leftp <= pixleft(conv_integer(yyfull));
		--
		-- states 5..8 (pass1) 13..16 (pass2)
		vdif0 <= ('0'&datai0) - ('0'&topii0);
		vdif1 <= ('0'&datai1) - ('0'&topii1);
		vdif2 <= ('0'&datai2) - ('0'&topii2);
		vdif3 <= ('0'&datai3) - ('0'&topii3);
		--
		hdif0 <= ('0'&datai0) - ('0'&leftp);
		hdif1 <= ('0'&datai1) - ('0'&leftp);
		hdif2 <= ('0'&datai2) - ('0'&leftp);
		hdif3 <= ('0'&datai3) - ('0'&leftp);
		leftpd <= leftp;
		--
		ddif0 <= ('0'&datai0) - ('0'&avg);
		ddif1 <= ('0'&datai1) - ('0'&avg);
		ddif2 <= ('0'&datai2) - ('0'&avg);
		ddif3 <= ('0'&datai3) - ('0'&avg);
		--
		-- states 6..9
		if vdif0(8)='0' then
			vabsdif0 <= vdif0(7 downto 0);
		else
			vabsdif0 <= x"00"-vdif0(7 downto 0);
		end if;
		if vdif1(8)='0' then
			vabsdif1 <= vdif1(7 downto 0);
		else
			vabsdif1 <= x"00"-vdif1(7 downto 0);
		end if;
		if vdif2(8)='0' then
			vabsdif2 <= vdif2(7 downto 0);
		else
			vabsdif2 <= x"00"-vdif2(7 downto 0);
		end if;
		if vdif3(8)='0' then
			vabsdif3 <= vdif3(7 downto 0);
		else
			vabsdif3 <= x"00"-vdif3(7 downto 0);
		end if;
		--
		if hdif0(8)='0' then
			habsdif0 <= hdif0(7 downto 0);
		else
			habsdif0 <= x"00"-hdif0(7 downto 0);
		end if;
		if hdif1(8)='0' then
			habsdif1 <= hdif1(7 downto 0);
		else
			habsdif1 <= x"00"-hdif1(7 downto 0);
		end if;
		if hdif2(8)='0' then
			habsdif2 <= hdif2(7 downto 0);
		else
			habsdif2 <= x"00"-hdif2(7 downto 0);
		end if;
		if hdif3(8)='0' then
			habsdif3 <= hdif3(7 downto 0);
		else
			habsdif3 <= x"00"-hdif3(7 downto 0);
		end if;
		--
		if ddif0(8)='0' then
			dabsdif0 <= ddif0(7 downto 0);
		else
			dabsdif0 <= x"00"-ddif0(7 downto 0);
		end if;
		if ddif1(8)='0' then
			dabsdif1 <= ddif1(7 downto 0);
		else
			dabsdif1 <= x"00"-ddif1(7 downto 0);
		end if;
		if ddif2(8)='0' then
			dabsdif2 <= ddif2(7 downto 0);
		else
			dabsdif2 <= x"00"-ddif2(7 downto 0);
		end if;
		if ddif3(8)='0' then
			dabsdif3 <= ddif3(7 downto 0);
		else
			dabsdif3 <= x"00"-ddif3(7 downto 0);
		end if;
		--
		if state=6 then
			vtotdif <= (others => '0');
			htotdif <= (others => '0');
			dtotdif <= (others => '0');
			if (tvalid='1' or yy/=0) and (lvalid='1' or xx/=0) then
				dconly <= '0';
			else
				dconly <= '1';
			end if;
		end if;
		-- states 7..10
		if state>=7 and state<=10 then
			vtotdif <= (x"0"&vabsdif0) + (x"0"&vabsdif1) + (x"0"&vabsdif2) + (x"0"&vabsdif3) + vtotdif;
			htotdif <= (x"0"&habsdif0) + (x"0"&habsdif1) + (x"0"&habsdif2) + (x"0"&habsdif3) + htotdif;
			dtotdif <= (x"0"&dabsdif0) + (x"0"&dabsdif1) + (x"0"&dabsdif2) + (x"0"&dabsdif3) + dtotdif;
		end if;
		--
		if state=11 then
			if vtotdif <= htotdif and vtotdif <= dtotdif and dconly='0' then
				modeoi <= x"0";		--vertical prefer
			elsif htotdif <= dtotdif and dconly='0' then
				modeoi <= x"1";		--horizontal prefer
			else
				modeoi <= x"2";		--DC
			end if;
		end if;
		if state=12 then
			lmode(conv_integer(yy)) <= modeoi;
			assert modeoi=2 or dconly='0' report "modeoi wrong for dconly";
			if dconly='1' or prevmode = modeoi then
				PMODEO <= '1';
			elsif modeoi < prevmode then
				PMODEO <= '0';
				RMODEO <= modeoi(2 downto 0);
			else
				PMODEO <= '0';
				RMODEO <= modeoi(2 downto 0) - 1;
			end if;
		end if;
		if state>=12 and state<=15 then
			outf1 <= '1';
		else
			outf1 <= '0';
		end if;
		outf <= outf1;
		-- states 14..17
		if outf='1' then
			STROBEO <= '1';
			MSTROBEO <= not outf1;
			if modeoi=0 then
				DATAO <= vdif3&vdif2&vdif1&vdif0;
				BASEO <= topii;
			elsif modeoi=1 then
				DATAO <= hdif3&hdif2&hdif1&hdif0;
				BASEO <= leftpd&leftpd&leftpd&leftpd;
			elsif modeoi=2 then
				DATAO <= ddif3&ddif2&ddif1&ddif0;
				BASEO <= avg&avg&avg&avg;
			end if;
		else
			STROBEO <= '0';
			MSTROBEO <= '0';
		end if;
		if state=15 and FBSTROBE='0' then	--set feedback ptr to get later feedback
			fbptr <= yy & b"00";
			fbpending <= '1';
		end if;
		--
		-- this comes back from transform/quantise/dequant/detransform loop
		-- some time later...
		--
		if FBSTROBE='1' then
			pixleft(conv_integer(fbptr)) <= FEEDBI;
			fbptr <= fbptr + 1;
			fbpending <= '0';
			if (submb=14 or submb=15) and NEWLINE='0' then
				lvalid <= '1';
			end if;
		end if;
		--
	end if;
end process;
	--
end hw;	--h264intra4x4

