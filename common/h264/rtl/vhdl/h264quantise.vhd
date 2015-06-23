-------------------------------------------------------------------------
-- H264 quantise for residuals - VHDL
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

-- This is the core quantisation for H264 for 4x4 residuals

-- Input: YN00..YN33 the input matrix in zigzag order (at time TQ)
-- Output: Z (clipped scaled quantised coefficients) in reverse zigzag order at TQ+4

-- ENABLE should be high for duration of 4x4 subblock
-- when ENABLE goes low, counters will be reset to prepare for new transform
-- there is no requirement for ENABLE to go low; subblocks can be back-to-back
-- only one quantise per clock in this version

-- 4 clock latency on quantise: latch, multiply, scale, clip.

-- XST: 93 slices + 1 MULT18X18; 211 MHz; Xpower 2mW @ 120MHz
-- CycloneIII: 156 LEs + 2 MUL(9bit); 163 MHz

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;	--note: signed
use ieee.numeric_std.ALL;

entity h264quantise is
	port (
		CLK : in std_logic;					--pixel clock
		ENABLE : in std_logic;				--values transfered only when this is 1
		QP : in std_logic_vector(5 downto 0);	--0..51 as specified in standard
		DCCI : in std_logic;					--2x2 DC chroma in
		YNIN : in std_logic_vector(15 downto 0);
		ZOUT : out std_logic_vector(11 downto 0) := (others=>'0');
		DCCO : out std_logic;					--2x2 DC chroma out
		VALID : out std_logic := '0'			-- enable delayed to same as YOUT timing
	);
end h264quantise;

architecture hw of h264quantise is
	--
	signal zig : std_logic_vector(3 downto 0) := x"F";
	signal qmf : std_logic_vector(13 downto 0) := (others=>'0');
	signal qmfA : std_logic_vector(13 downto 0) := (others=>'0');
	signal qmfB : std_logic_vector(13 downto 0) := (others=>'0');
	signal qmfC : std_logic_vector(13 downto 0) := (others=>'0');
	signal enab1 : std_logic := '0';
	signal enab2 : std_logic := '0';
	signal enab3 : std_logic := '0';
	signal dcc1 : std_logic := '0';
	signal dcc2 : std_logic := '0';
	signal dcc3 : std_logic := '0';
	signal yn1 : std_logic_vector(15 downto 0);
	signal zr : std_logic_vector(30 downto 0);
	signal zz : std_logic_vector(15 downto 0);
	--
begin
	--quantisation multiplier factors
	--we need to multiply by PF (to complete transform) and divide by quantisation qstep (ie QP rescaled)
	--so we transform it PF/qstep(QP) to qmf/2^n and do a single multiply
	qmfA <=
		CONV_STD_LOGIC_VECTOR(13107,14) when ('0'&QP)=0 or ('0'&QP)=6 or ('0'&QP)=12 or ('0'&QP)=18 or ('0'&QP)=24 or ('0'&QP)=30 or ('0'&QP)=36 or ('0'&QP)=42 or ('0'&QP)=48 else
		CONV_STD_LOGIC_VECTOR(11916,14) when ('0'&QP)=1 or ('0'&QP)=7 or ('0'&QP)=13 or ('0'&QP)=19 or ('0'&QP)=25 or ('0'&QP)=31 or ('0'&QP)=37 or ('0'&QP)=43 or ('0'&QP)=49 else
		CONV_STD_LOGIC_VECTOR(10082,14) when ('0'&QP)=2 or ('0'&QP)=8 or ('0'&QP)=14 or ('0'&QP)=20 or ('0'&QP)=26 or ('0'&QP)=32 or ('0'&QP)=38 or ('0'&QP)=44 or ('0'&QP)=50 else
		CONV_STD_LOGIC_VECTOR(9362,14) when ('0'&QP)=3 or ('0'&QP)=9 or ('0'&QP)=15 or ('0'&QP)=21 or ('0'&QP)=27 or ('0'&QP)=33 or ('0'&QP)=39 or ('0'&QP)=45 or ('0'&QP)=51 else
		CONV_STD_LOGIC_VECTOR(8192,14) when ('0'&QP)=4 or ('0'&QP)=10 or ('0'&QP)=16 or ('0'&QP)=22 or ('0'&QP)=28 or ('0'&QP)=34 or ('0'&QP)=40 or ('0'&QP)=46 else
		CONV_STD_LOGIC_VECTOR(7282,14);
	qmfB <=
		CONV_STD_LOGIC_VECTOR(5243,14) when ('0'&QP)=0 or ('0'&QP)=6 or ('0'&QP)=12 or ('0'&QP)=18 or ('0'&QP)=24 or ('0'&QP)=30 or ('0'&QP)=36 or ('0'&QP)=42 or ('0'&QP)=48 else
		CONV_STD_LOGIC_VECTOR(4660,14) when ('0'&QP)=1 or ('0'&QP)=7 or ('0'&QP)=13 or ('0'&QP)=19 or ('0'&QP)=25 or ('0'&QP)=31 or ('0'&QP)=37 or ('0'&QP)=43 or ('0'&QP)=49 else
		CONV_STD_LOGIC_VECTOR(4194,14) when ('0'&QP)=2 or ('0'&QP)=8 or ('0'&QP)=14 or ('0'&QP)=20 or ('0'&QP)=26 or ('0'&QP)=32 or ('0'&QP)=38 or ('0'&QP)=44 or ('0'&QP)=50 else
		CONV_STD_LOGIC_VECTOR(3647,14) when ('0'&QP)=3 or ('0'&QP)=9 or ('0'&QP)=15 or ('0'&QP)=21 or ('0'&QP)=27 or ('0'&QP)=33 or ('0'&QP)=39 or ('0'&QP)=45 or ('0'&QP)=51 else
		CONV_STD_LOGIC_VECTOR(3355,14) when ('0'&QP)=4 or ('0'&QP)=10 or ('0'&QP)=16 or ('0'&QP)=22 or ('0'&QP)=28 or ('0'&QP)=34 or ('0'&QP)=40 or ('0'&QP)=46 else
		CONV_STD_LOGIC_VECTOR(2893,14);
	qmfC <=
		CONV_STD_LOGIC_VECTOR(8066,14) when ('0'&QP)=0 or ('0'&QP)=6 or ('0'&QP)=12 or ('0'&QP)=18 or ('0'&QP)=24 or ('0'&QP)=30 or ('0'&QP)=36 or ('0'&QP)=42 or ('0'&QP)=48 else
		CONV_STD_LOGIC_VECTOR(7490,14) when ('0'&QP)=1 or ('0'&QP)=7 or ('0'&QP)=13 or ('0'&QP)=19 or ('0'&QP)=25 or ('0'&QP)=31 or ('0'&QP)=37 or ('0'&QP)=43 or ('0'&QP)=49 else
		CONV_STD_LOGIC_VECTOR(6554,14) when ('0'&QP)=2 or ('0'&QP)=8 or ('0'&QP)=14 or ('0'&QP)=20 or ('0'&QP)=26 or ('0'&QP)=32 or ('0'&QP)=38 or ('0'&QP)=44 or ('0'&QP)=50 else
		CONV_STD_LOGIC_VECTOR(5825,14) when ('0'&QP)=3 or ('0'&QP)=9 or ('0'&QP)=15 or ('0'&QP)=21 or ('0'&QP)=27 or ('0'&QP)=33 or ('0'&QP)=39 or ('0'&QP)=45 or ('0'&QP)=51 else
		CONV_STD_LOGIC_VECTOR(5243,14) when ('0'&QP)=4 or ('0'&QP)=10 or ('0'&QP)=16 or ('0'&QP)=22 or ('0'&QP)=28 or ('0'&QP)=34 or ('0'&QP)=40 or ('0'&QP)=46 else
		CONV_STD_LOGIC_VECTOR(4559,14);
	--
process(CLK)
	variable rr : std_logic_vector(2 downto 0);
begin
	if rising_edge(CLK) then
		if ENABLE='0' or DCCI='1' then
			zig <= x"F";
		else
			zig <= zig - 1;
		end if;
		--
		enab1 <= ENABLE;
		enab2 <= enab1;
		enab3 <= enab2;
		VALID <= enab3;
		--
		dcc1 <= DCCI;
		dcc2 <= dcc1;
		dcc3 <= dcc2;
		DCCO <= dcc3;
		--
		if ENABLE='1' then
			if DCCI='1' then
				--dc uses 0,0 parameters div 2
				qmf <= '0'&qmfA(13 downto 1);
			elsif zig=0 or zig=3 or zig=5 or zig=11 then
				--positions 0,0; 0,2; 2,0; 2,2 need one set of parameters
				qmf <= qmfA;
			elsif zig=4 or zig=10 or zig=12 or zig=15 then
				--positions 1,1; 1,3; 3,1; 3,3 need another set of parameters
				qmf <= qmfB;
			else
				--other positions: default parameters
				qmf <= qmfC;
			end if;
			yn1 <= YNIN;	--data ready for scaling
		end if;
		if enab1='1' then
			zr <= yn1 * ('0'&qmf);		--quantise
		end if;
		--two bits of rounding (and leading zero)
		--rr := b"010";			--simple round-to-middle
		--rr := b"000";			--no rounding (=> -ve numbers round away from zero)
		rr := b"0"&zr(29)&'1';	--round to zero if <0.75
		if enab2='1' then
			if ('0'&QP) < 6 then
				zz <= zr(28 downto 13) + rr;
			elsif ('0'&QP) < 12 then
				zz <= zr(29 downto 14) + rr;
			elsif ('0'&QP) < 18 then
				zz <= zr(30 downto 15) + rr;
			elsif ('0'&QP) < 24 then
				zz <= sxt(zr(30 downto 16),16) + rr;
			elsif ('0'&QP) < 30 then
				zz <= sxt(zr(30 downto 17),16) + rr;
			elsif ('0'&QP) < 36 then
				zz <= sxt(zr(30 downto 18),16) + rr;
			elsif ('0'&QP) < 42 then
				zz <= sxt(zr(30 downto 19),16) + rr;
			else
				zz <= sxt(zr(30 downto 20),16) + rr;
			end if;
		end if;
		if enab3='1' then
			if zz(15)=zz(14) and zz(15)=zz(13) and zz(13 downto 2)/=x"800" then
				ZOUT <= zz(13 downto 2);
			elsif zz(15)='0' then
				ZOUT <= x"7FF";		--clip max
			else
				ZOUT <= x"801";		--clip min
			end if;
		end if;
	end if;
end process;
	--
end hw;
