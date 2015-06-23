-------------------------------------------------------------------------
-- H264 dequantise for residuals - VHDL
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

-- This is the core inverse-quantisation for H264 for 4x4 residuals

-- Input: Z (clipped scaled quantised coefficients) in reverse zigzag order at TU
-- Output: W (de-quantised prescaled for inverse transform) at TU+3

-- ENABLE should be high for duration of 4x4 subblock
-- when ENABLE goes low, counters will be reset to prepare for new transform
-- there is no requirement for ENABLE to go low; subblocks can be back-to-back
-- only one quantise per clock in this version
-- DCCI is input saying it's a 2x2 DC block and quantising it appropriately
-- this also copes with resetting counters for next 4x4 block

-- 3 clock latency on dequantise: latch, multiply, scale
-- there's no clipping by definition

-- XST: was 67 slices + 1 MULT18X18; 204 MHz; Xpower 2mW @ 120MHz

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;	--note: signed
use ieee.numeric_std.ALL;

entity h264dequantise is
	generic (
		LASTADVANCE : integer := 1
	);
	port (
		CLK : in std_logic;					--pixel clock
		ENABLE : in std_logic;				--values transfered only when this is 1
		QP : in std_logic_vector(5 downto 0);	--0..51 as specified in standard
		ZIN : in std_logic_vector(15 downto 0);
		DCCI : in std_logic;					--2x2 DC chroma in
		LAST : out std_logic := '0';			--set when last coeff about to be input
		WOUT : out std_logic_vector(15 downto 0) := (others=>'0');
		DCCO : out std_logic := '0';			--2x2 DC chroma out
		VALID : out std_logic := '0'			-- enable delayed to same as YOUT timing
	);
end h264dequantise;

architecture hw of h264dequantise is
	--
	signal zig : std_logic_vector(3 downto 0) := x"F";
	signal qmf : std_logic_vector(5 downto 0) := (others=>'0');
	signal qmfA : std_logic_vector(4 downto 0) := (others=>'0');
	signal qmfB : std_logic_vector(4 downto 0) := (others=>'0');
	signal qmfC : std_logic_vector(4 downto 0) := (others=>'0');
	signal enab1 : std_logic := '0';
	signal enab2 : std_logic := '0';
	signal dcc1 : std_logic := '0';
	signal dcc2 : std_logic := '0';
	signal z1 : std_logic_vector(15 downto 0) := (others=>'0');
	signal w2 : std_logic_vector(22 downto 0) := (others=>'0');
	--
begin
	--quantisation multiplier factors as per std
	--we need to multiply by qmf and shift by QP/6
	qmfA <=
		CONV_STD_LOGIC_VECTOR(10,5) when ('0'&QP)=0 or ('0'&QP)=6 or ('0'&QP)=12 or ('0'&QP)=18 or ('0'&QP)=24 or ('0'&QP)=30 or ('0'&QP)=36 or ('0'&QP)=42 or ('0'&QP)=48 else
		CONV_STD_LOGIC_VECTOR(11,5) when ('0'&QP)=1 or ('0'&QP)=7 or ('0'&QP)=13 or ('0'&QP)=19 or ('0'&QP)=25 or ('0'&QP)=31 or ('0'&QP)=37 or ('0'&QP)=43 or ('0'&QP)=49 else
		CONV_STD_LOGIC_VECTOR(13,5) when ('0'&QP)=2 or ('0'&QP)=8 or ('0'&QP)=14 or ('0'&QP)=20 or ('0'&QP)=26 or ('0'&QP)=32 or ('0'&QP)=38 or ('0'&QP)=44 or ('0'&QP)=50 else
		CONV_STD_LOGIC_VECTOR(14,5) when ('0'&QP)=3 or ('0'&QP)=9 or ('0'&QP)=15 or ('0'&QP)=21 or ('0'&QP)=27 or ('0'&QP)=33 or ('0'&QP)=39 or ('0'&QP)=45 or ('0'&QP)=51 else
		CONV_STD_LOGIC_VECTOR(16,5) when ('0'&QP)=4 or ('0'&QP)=10 or ('0'&QP)=16 or ('0'&QP)=22 or ('0'&QP)=28 or ('0'&QP)=34 or ('0'&QP)=40 or ('0'&QP)=46 else
		CONV_STD_LOGIC_VECTOR(18,5);
	qmfB <=
		CONV_STD_LOGIC_VECTOR(16,5) when ('0'&QP)=0 or ('0'&QP)=6 or ('0'&QP)=12 or ('0'&QP)=18 or ('0'&QP)=24 or ('0'&QP)=30 or ('0'&QP)=36 or ('0'&QP)=42 or ('0'&QP)=48 else
		CONV_STD_LOGIC_VECTOR(18,5) when ('0'&QP)=1 or ('0'&QP)=7 or ('0'&QP)=13 or ('0'&QP)=19 or ('0'&QP)=25 or ('0'&QP)=31 or ('0'&QP)=37 or ('0'&QP)=43 or ('0'&QP)=49 else
		CONV_STD_LOGIC_VECTOR(20,5) when ('0'&QP)=2 or ('0'&QP)=8 or ('0'&QP)=14 or ('0'&QP)=20 or ('0'&QP)=26 or ('0'&QP)=32 or ('0'&QP)=38 or ('0'&QP)=44 or ('0'&QP)=50 else
		CONV_STD_LOGIC_VECTOR(23,5) when ('0'&QP)=3 or ('0'&QP)=9 or ('0'&QP)=15 or ('0'&QP)=21 or ('0'&QP)=27 or ('0'&QP)=33 or ('0'&QP)=39 or ('0'&QP)=45 or ('0'&QP)=51 else
		CONV_STD_LOGIC_VECTOR(25,5) when ('0'&QP)=4 or ('0'&QP)=10 or ('0'&QP)=16 or ('0'&QP)=22 or ('0'&QP)=28 or ('0'&QP)=34 or ('0'&QP)=40 or ('0'&QP)=46 else
		CONV_STD_LOGIC_VECTOR(29,5);
	qmfC <=
		CONV_STD_LOGIC_VECTOR(13,5) when ('0'&QP)=0 or ('0'&QP)=6 or ('0'&QP)=12 or ('0'&QP)=18 or ('0'&QP)=24 or ('0'&QP)=30 or ('0'&QP)=36 or ('0'&QP)=42 or ('0'&QP)=48 else
		CONV_STD_LOGIC_VECTOR(14,5) when ('0'&QP)=1 or ('0'&QP)=7 or ('0'&QP)=13 or ('0'&QP)=19 or ('0'&QP)=25 or ('0'&QP)=31 or ('0'&QP)=37 or ('0'&QP)=43 or ('0'&QP)=49 else
		CONV_STD_LOGIC_VECTOR(16,5) when ('0'&QP)=2 or ('0'&QP)=8 or ('0'&QP)=14 or ('0'&QP)=20 or ('0'&QP)=26 or ('0'&QP)=32 or ('0'&QP)=38 or ('0'&QP)=44 or ('0'&QP)=50 else
		CONV_STD_LOGIC_VECTOR(18,5) when ('0'&QP)=3 or ('0'&QP)=9 or ('0'&QP)=15 or ('0'&QP)=21 or ('0'&QP)=27 or ('0'&QP)=33 or ('0'&QP)=39 or ('0'&QP)=45 or ('0'&QP)=51 else
		CONV_STD_LOGIC_VECTOR(20,5) when ('0'&QP)=4 or ('0'&QP)=10 or ('0'&QP)=16 or ('0'&QP)=22 or ('0'&QP)=28 or ('0'&QP)=34 or ('0'&QP)=40 or ('0'&QP)=46 else
		CONV_STD_LOGIC_VECTOR(23,5);
	--
process(CLK)
begin
	if rising_edge(CLK) then
		if ENABLE='0' or DCCI='1' then
			zig <= x"F";
		else
			zig <= zig - 1;
		end if;
		--
		if zig=LASTADVANCE then
			LAST <= '1';
		else
			LAST <= '0';
		end if;
		--
		enab1 <= ENABLE;
		enab2 <= enab1;
		VALID <= enab2;
		dcc1 <= DCCI;
		dcc2 <= dcc1;
		DCCO <= dcc2;
		--
		if ENABLE='1' then
			if DCCI='1' then
				--positions 0,0 use table A; x1
				qmf <= '0'&qmfA;
			elsif zig=0 or zig=3 or zig=5 or zig=11 or DCCI='1' then
				--positions 0,0; 0,2; 2,0; 2,2 use table A; x2
				qmf <= qmfA&'0';
			elsif zig=4 or zig=10 or zig=12 or zig=15 then
				--positions 1,1; 1,3; 3,1; 3,3 need table B; x2
				qmf <= qmfB&'0';
			else
				--other positions: table C; x2
				qmf <= qmfC&'0';
			end if;
			z1 <= ZIN;	--data ready for scaling
		end if;
		if enab1='1' then
			w2 <= z1 * ('0'&qmf);		-- quantise
		end if;
		if enab2='1' then
			--here apply ">>1" to undo the x2 above, unless DCC where ">>1" needed
			--we don't clip because the stream is guarranteed to fit in 16bits
			--bit(0) is forced to zero in non-DC cases to meet standard
			if ('0'&QP) < 6 then
				WOUT <= w2(16 downto 1);
			elsif ('0'&QP) < 12 then
				WOUT <= w2(15 downto 1)&(w2(0) and dcc2);
			elsif ('0'&QP) < 18 then
				WOUT <= w2(14 downto 1)&(w2(0) and dcc2)&b"0";
			elsif ('0'&QP) < 24 then
				WOUT <= w2(13 downto 1)&(w2(0) and dcc2)&b"00";
			elsif ('0'&QP) < 30 then
				WOUT <= w2(12 downto 1)&(w2(0) and dcc2)&b"000";
			elsif ('0'&QP) < 36 then
				WOUT <= w2(11 downto 1)&(w2(0) and dcc2)&b"0000";
			elsif ('0'&QP) < 42 then
				WOUT <= w2(10 downto 1)&(w2(0) and dcc2)&b"00000";
			else
				WOUT <= w2(9 downto 1)&(w2(0) and dcc2)&b"000000";
			end if;
		end if;
	end if;
end process;
	--
end hw;
