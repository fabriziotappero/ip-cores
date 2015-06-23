-------------------------------------------------------------------------
-- H264 CAVLC encoding - VHDL
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

-- This is the CAVLC encoding for H264

-- Context Adaptive Variable Length Coding (CAVLC) encodes all co-efficients
-- from 4x4 (or 2x2) residuals in an efficient way.  It is context dependant in that
-- it uses different tables depending on recent 4x4 encodings (or 2x2 encoding)

-- Input: VIN - value to be encoded in reverse zigzag order (1 per clock)
--  also: NIN - number of coefficients in adjacent blocks (Nu+Nl/2)

-- Output: VE,VL - encoded value as "wide" bits
--   also: NOUT - number of coefficients this block (set 1clk after ENABLE low)

-- Wide bits output format consists of words of:
-- 25 bits of data (VE) (aligned right), plus 5 bits of length (VL)
-- valid lengths (VL) are 1..31 (unspecified bits are zero)

-- ENABLE should be high for duration of 4x4 (or 2x2) subblock encoding
-- and must remain high for exactly 16 (4x4), 15 (4x4-1) or 4 (2x2) clocks
-- then must be low for at least 5 clocks.
-- Latency for output of all data is <= 20 clocks from last VIN.
-- If switching to ChromaDC 2x2 blocks after 4x4 blocks, allow an extra 12
-- clocks for data to be output, but similar size blocks may be pipelined.

-- READY is 1 when ENABLE may be set, but it goes to 0 a CLK2 after ENABLE
-- is set; ENABLE must continue to be set for entire 4x4 (2x2) block.

-- Typically 18 CLK2's to input (4x4) subblock - 16 + 2 idle.
-- Worst case is 18 CLK's to output all parameters (CTOKEN + 16 COEFFS +
-- RUNBF state, or <=15 COEFFS and TZEROS, or <=15 COEFFS and T1SIGN).
-- This is unlikely and most will be output in 9 CLKs

-- VALID is set when output VE/VL is valid

-- Internal operation:
--
-- When ENABLE goes high: STATE_READ is entered, data is read in and parsed, setting
-- parameters maxcoeffs totalcoeffs totalzeros trailingones t1signs and loading
-- tables with raw non-zero/non-t1 coeffs and raw run lengths
-- when ENABLE falls, STATE_CTOKEN is entered, and the coeff_token computed and output.
-- the next clock enters STATE_T1SIGNS where all T1 sign bits are output (if any)
-- the next clock enters STATE_COEFFS where all the coefficient levels are computed
-- and output, if any, this might take up to 16 clocks
-- then STATE_TZEROS is entered, and if needed totalzeros is output
-- the next clock enters STATE_RUNBF and, once the runbefore subprocessor has completed,
-- this outputs the result of the runbefore string in a single clock.
-- then STATE_IDLE is entered, and the totals are zeroed ready for the next 4x4 block.
--
-- Runnbefore subprocessor:
-- starts when ENABLE falls, uses the run information collected to compute the run
-- length string; this might take up to 16 clocks to run, so it done simultaneously with
-- the other states.  The entire string is only about 18 bits long worst case.
-- when the system enters STATE_RUNBF and the subprocessor has finished, the word is output
-- and totalls are zeroed ready for next time.

-- Spartan3: 800 slices; 224MHz/91MHz (CLK2/CLK); Xpower: 21mW @ 180MHz/90Mhz
-- CycloneIII: 2012 LEs; 187MHz/90MHz (CLK2/CLK); Power: 

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.ALL;

entity h264cavlc is
	port (
		CLK : in std_logic;					--main clock / output clock
		CLK2 : in std_logic;				--input clock (typically twice CLK)
		ENABLE : in std_logic;				--values transfered only when this is 1
		READY : out std_logic;				--enable can fall when this 1
		VIN : in std_logic_vector(11 downto 0);	--12bits max (+/- 2048)
		NIN : in std_logic_vector(4 downto 0);	--N coeffs nearby mb
		SIN : in std_logic := '0';				--stream/strobe flag, copied to VS
		VS : out std_logic := '0';				--stream/strobe flag sync'd with VL/VE
		VE : out std_logic_vector(24 downto 0) := (others=>'0');
		VL : out std_logic_vector(4 downto 0) := (others=>'0');
		VALID : out std_logic := '0';			-- enable delayed to same as VE/VL
		XSTATE : out std_logic_vector(2 downto 0); 	--debug only
		NOUT : out std_logic_vector(4 downto 0) := b"00000"	--N coeffs for this mb
	);
end h264cavlc;

architecture hw of h264cavlc is
	-- information collected from input when ENABLE=1
	-- all thse are in the "CLK2" timing domain
	signal eenable : std_logic := '0';			--1 if ENABLE=1 seen
	signal eparity : std_logic := '0';			--which register bank to use
	signal emaxcoeffs : std_logic_vector(4 downto 0) := b"00000";
	signal etotalcoeffs : std_logic_vector(4 downto 0) := b"00000";
	signal etotalzeros : std_logic_vector(4 downto 0) := b"00000";
	signal etrailingones : std_logic_vector(1 downto 0) := b"00";	--max 3 allowed
	signal ecnz : std_logic := '0';		--flag set if coeff nz so far
	signal ecgt1 : std_logic := '0';	--flag set if coeff >1 so far
	signal et1signs : std_logic_vector(2 downto 0) := b"000";		--signs of above (1=-ve)
	signal erun : std_logic_vector(3 downto 0) := b"0000";		--run before next coeff
	signal eindex : std_logic_vector(3 downto 0) := b"0000";	--index into coeff table
	signal etable : std_logic_vector(1 downto 0);
	signal es : std_logic := '0';				--s (stream) flag
	-- holding buffer; "CLK2" timing domain
	signal hvalidi : std_logic := '0';			--1 if holding buffer valid
	signal hvalid : std_logic := '0';			--1 if holding buffer valid (delayed 1 clk)
	signal hparity : std_logic := '0';			--which register bank to use
	signal hmaxcoeffs : std_logic_vector(4 downto 0) := b"00000";
	signal htotalcoeffs : std_logic_vector(4 downto 0) := b"00000";
	signal htotalzeros : std_logic_vector(4 downto 0) := b"00000";
	signal htrailingones : std_logic_vector(1 downto 0) := b"00";	--max 3 allowed
	signal htable : std_logic_vector(1 downto 0);
	signal hs : std_logic := '0';				--s (stream) flag
	signal t1signs : std_logic_vector(2 downto 0) := b"000";		--signs of above (1=-ve)
	--
	--information copied from above during STATE_IDLE or RUNBF
	--this is in the "CLK" domain
	signal maxcoeffs : std_logic_vector(4 downto 0) := b"00000";
	signal totalcoeffs : std_logic_vector(4 downto 0) := b"00000";
	signal totalzeros : std_logic_vector(4 downto 0) := b"00000";
	signal trailingones : std_logic_vector(1 downto 0) := b"00";	--max 3 allowed
	signal parity : std_logic := '0';			--which register bank to use
	--
	-- states private to this processing engine
	constant STATE_IDLE   : std_logic_vector(2 downto 0) := b"000";
	constant STATE_READ   : std_logic_vector(2 downto 0) := b"001";
	constant STATE_CTOKEN : std_logic_vector(2 downto 0) := b"010";
	constant STATE_T1SIGN : std_logic_vector(2 downto 0) := b"011";
	constant STATE_COEFFS : std_logic_vector(2 downto 0) := b"100";
	constant STATE_TZEROS : std_logic_vector(2 downto 0) := b"101";
	constant STATE_RUNBF  : std_logic_vector(2 downto 0) := b"110";
	signal state : std_logic_vector(2 downto 0) := STATE_IDLE;
	--
	-- runbefore subprocessor state
	signal rbstate : std_logic := '0';		--1=running 0=done
	--
	--stuff used during processing
	signal cindex : std_logic_vector(3 downto 0) := b"0000";	--index into coeff table
	signal abscoeff : std_logic_vector(10 downto 0);
	signal abscoeffa : std_logic_vector(10 downto 0);			--adjusted version of abscoeff
	signal signcoeff : std_logic := '0';
	signal suffixlen : std_logic_vector(2 downto 0);			--0..6
	signal rbindex : std_logic_vector(3 downto 0) := b"0000";	--index into coeff table
	signal runb : std_logic_vector(3 downto 0) := b"0000";		--run before next coeff
	signal rbzerosleft : std_logic_vector(4 downto 0) := b"00000";
	signal rbve : std_logic_vector(24 downto 0) := (others => '0');
	signal rbvl : std_logic_vector(4 downto 0) := b"00000";
	--tables
	signal coeff_token : std_logic_vector(5 downto 0);
	signal ctoken_len : std_logic_vector(4 downto 0);
	constant CTABLE0 : std_logic_vector(2 downto 0) := b"000";
	constant CTABLE1 : std_logic_vector(2 downto 0) := b"001";
	constant CTABLE2 : std_logic_vector(2 downto 0) := b"010";
	constant CTABLE3 : std_logic_vector(2 downto 0) := b"011";
	constant CTABLE4 : std_logic_vector(2 downto 0) := b"100";
	signal ctable : std_logic_vector(2 downto 0) := CTABLE0;
	signal ztoken : std_logic_vector(2 downto 0);
	signal ztoken_len : std_logic_vector(3 downto 0);
	signal ztable : std_logic := '0';
	signal rbtoken : std_logic_vector(2 downto 0);
	--data arrays
	type Tcoeffarray is array(31 downto 0) of std_logic_vector(11 downto 0);
	type Trunbarray is array(31 downto 0) of std_logic_vector(3 downto 0);
	signal coeffarray : Tcoeffarray := (others=>x"000");
	signal runbarray : Trunbarray := (others=>x"0");
	--
begin
	XSTATE <= state;	--DEBUG only
	--
	-- tables for coeff_token
	--
	coeff_token <=
		b"000001" when trailingones=0 and totalcoeffs=0 and ctable=0 else
		b"000101" when trailingones=0 and totalcoeffs=1 and ctable=0 else
		b"000001" when trailingones=1 and totalcoeffs=1 and ctable=0 else
		b"000111" when trailingones=0 and totalcoeffs=2 and ctable=0 else
		b"000100" when trailingones=1 and totalcoeffs=2 and ctable=0 else
		b"000001" when trailingones=2 and totalcoeffs=2 and ctable=0 else
		b"000111" when trailingones=0 and totalcoeffs=3 and ctable=0 else
		b"000110" when trailingones=1 and totalcoeffs=3 and ctable=0 else
		b"000101" when trailingones=2 and totalcoeffs=3 and ctable=0 else
		b"000011" when trailingones=3 and totalcoeffs=3 and ctable=0 else
		b"000111" when trailingones=0 and totalcoeffs=4 and ctable=0 else
		b"000110" when trailingones=1 and totalcoeffs=4 and ctable=0 else
		b"000101" when trailingones=2 and totalcoeffs=4 and ctable=0 else
		b"000011" when trailingones=3 and totalcoeffs=4 and ctable=0 else
		b"000111" when trailingones=0 and totalcoeffs=5 and ctable=0 else
		b"000110" when trailingones=1 and totalcoeffs=5 and ctable=0 else
		b"000101" when trailingones=2 and totalcoeffs=5 and ctable=0 else
		b"000100" when trailingones=3 and totalcoeffs=5 and ctable=0 else
		b"001111" when trailingones=0 and totalcoeffs=6 and ctable=0 else
		b"000110" when trailingones=1 and totalcoeffs=6 and ctable=0 else
		b"000101" when trailingones=2 and totalcoeffs=6 and ctable=0 else
		b"000100" when trailingones=3 and totalcoeffs=6 and ctable=0 else
		b"001011" when trailingones=0 and totalcoeffs=7 and ctable=0 else
		b"001110" when trailingones=1 and totalcoeffs=7 and ctable=0 else
		b"000101" when trailingones=2 and totalcoeffs=7 and ctable=0 else
		b"000100" when trailingones=3 and totalcoeffs=7 and ctable=0 else
		b"001000" when trailingones=0 and totalcoeffs=8 and ctable=0 else
		b"001010" when trailingones=1 and totalcoeffs=8 and ctable=0 else
		b"001101" when trailingones=2 and totalcoeffs=8 and ctable=0 else
		b"000100" when trailingones=3 and totalcoeffs=8 and ctable=0 else
		b"001111" when trailingones=0 and totalcoeffs=9 and ctable=0 else
		b"001110" when trailingones=1 and totalcoeffs=9 and ctable=0 else
		b"001001" when trailingones=2 and totalcoeffs=9 and ctable=0 else
		b"000100" when trailingones=3 and totalcoeffs=9 and ctable=0 else
		b"001011" when trailingones=0 and totalcoeffs=10 and ctable=0 else
		b"001010" when trailingones=1 and totalcoeffs=10 and ctable=0 else
		b"001101" when trailingones=2 and totalcoeffs=10 and ctable=0 else
		b"001100" when trailingones=3 and totalcoeffs=10 and ctable=0 else
		b"001111" when trailingones=0 and totalcoeffs=11 and ctable=0 else
		b"001110" when trailingones=1 and totalcoeffs=11 and ctable=0 else
		b"001001" when trailingones=2 and totalcoeffs=11 and ctable=0 else
		b"001100" when trailingones=3 and totalcoeffs=11 and ctable=0 else
		b"001011" when trailingones=0 and totalcoeffs=12 and ctable=0 else
		b"001010" when trailingones=1 and totalcoeffs=12 and ctable=0 else
		b"001101" when trailingones=2 and totalcoeffs=12 and ctable=0 else
		b"001000" when trailingones=3 and totalcoeffs=12 and ctable=0 else
		b"001111" when trailingones=0 and totalcoeffs=13 and ctable=0 else
		b"000001" when trailingones=1 and totalcoeffs=13 and ctable=0 else
		b"001001" when trailingones=2 and totalcoeffs=13 and ctable=0 else
		b"001100" when trailingones=3 and totalcoeffs=13 and ctable=0 else
		b"001011" when trailingones=0 and totalcoeffs=14 and ctable=0 else
		b"001110" when trailingones=1 and totalcoeffs=14 and ctable=0 else
		b"001101" when trailingones=2 and totalcoeffs=14 and ctable=0 else
		b"001000" when trailingones=3 and totalcoeffs=14 and ctable=0 else
		b"000111" when trailingones=0 and totalcoeffs=15 and ctable=0 else
		b"001010" when trailingones=1 and totalcoeffs=15 and ctable=0 else
		b"001001" when trailingones=2 and totalcoeffs=15 and ctable=0 else
		b"001100" when trailingones=3 and totalcoeffs=15 and ctable=0 else
		b"000100" when trailingones=0 and totalcoeffs=16 and ctable=0 else
		b"000110" when trailingones=1 and totalcoeffs=16 and ctable=0 else
		b"000101" when trailingones=2 and totalcoeffs=16 and ctable=0 else
		b"001000" when trailingones=3 and totalcoeffs=16 and ctable=0 else
		--
		b"000011" when trailingones=0 and totalcoeffs=0 and ctable=1 else
		b"001011" when trailingones=0 and totalcoeffs=1 and ctable=1 else
		b"000010" when trailingones=1 and totalcoeffs=1 and ctable=1 else
		b"000111" when trailingones=0 and totalcoeffs=2 and ctable=1 else
		b"000111" when trailingones=1 and totalcoeffs=2 and ctable=1 else
		b"000011" when trailingones=2 and totalcoeffs=2 and ctable=1 else
		b"000111" when trailingones=0 and totalcoeffs=3 and ctable=1 else
		b"001010" when trailingones=1 and totalcoeffs=3 and ctable=1 else
		b"001001" when trailingones=2 and totalcoeffs=3 and ctable=1 else
		b"000101" when trailingones=3 and totalcoeffs=3 and ctable=1 else
		b"000111" when trailingones=0 and totalcoeffs=4 and ctable=1 else
		b"000110" when trailingones=1 and totalcoeffs=4 and ctable=1 else
		b"000101" when trailingones=2 and totalcoeffs=4 and ctable=1 else
		b"000100" when trailingones=3 and totalcoeffs=4 and ctable=1 else
		b"000100" when trailingones=0 and totalcoeffs=5 and ctable=1 else
		b"000110" when trailingones=1 and totalcoeffs=5 and ctable=1 else
		b"000101" when trailingones=2 and totalcoeffs=5 and ctable=1 else
		b"000110" when trailingones=3 and totalcoeffs=5 and ctable=1 else
		b"000111" when trailingones=0 and totalcoeffs=6 and ctable=1 else
		b"000110" when trailingones=1 and totalcoeffs=6 and ctable=1 else
		b"000101" when trailingones=2 and totalcoeffs=6 and ctable=1 else
		b"001000" when trailingones=3 and totalcoeffs=6 and ctable=1 else
		b"001111" when trailingones=0 and totalcoeffs=7 and ctable=1 else
		b"000110" when trailingones=1 and totalcoeffs=7 and ctable=1 else
		b"000101" when trailingones=2 and totalcoeffs=7 and ctable=1 else
		b"000100" when trailingones=3 and totalcoeffs=7 and ctable=1 else
		b"001011" when trailingones=0 and totalcoeffs=8 and ctable=1 else
		b"001110" when trailingones=1 and totalcoeffs=8 and ctable=1 else
		b"001101" when trailingones=2 and totalcoeffs=8 and ctable=1 else
		b"000100" when trailingones=3 and totalcoeffs=8 and ctable=1 else
		b"001111" when trailingones=0 and totalcoeffs=9 and ctable=1 else
		b"001010" when trailingones=1 and totalcoeffs=9 and ctable=1 else
		b"001001" when trailingones=2 and totalcoeffs=9 and ctable=1 else
		b"000100" when trailingones=3 and totalcoeffs=9 and ctable=1 else
		b"001011" when trailingones=0 and totalcoeffs=10 and ctable=1 else
		b"001110" when trailingones=1 and totalcoeffs=10 and ctable=1 else
		b"001101" when trailingones=2 and totalcoeffs=10 and ctable=1 else
		b"001100" when trailingones=3 and totalcoeffs=10 and ctable=1 else
		b"001000" when trailingones=0 and totalcoeffs=11 and ctable=1 else
		b"001010" when trailingones=1 and totalcoeffs=11 and ctable=1 else
		b"001001" when trailingones=2 and totalcoeffs=11 and ctable=1 else
		b"001000" when trailingones=3 and totalcoeffs=11 and ctable=1 else
		b"001111" when trailingones=0 and totalcoeffs=12 and ctable=1 else
		b"001110" when trailingones=1 and totalcoeffs=12 and ctable=1 else
		b"001101" when trailingones=2 and totalcoeffs=12 and ctable=1 else
		b"001100" when trailingones=3 and totalcoeffs=12 and ctable=1 else
		b"001011" when trailingones=0 and totalcoeffs=13 and ctable=1 else
		b"001010" when trailingones=1 and totalcoeffs=13 and ctable=1 else
		b"001001" when trailingones=2 and totalcoeffs=13 and ctable=1 else
		b"001100" when trailingones=3 and totalcoeffs=13 and ctable=1 else
		b"000111" when trailingones=0 and totalcoeffs=14 and ctable=1 else
		b"001011" when trailingones=1 and totalcoeffs=14 and ctable=1 else
		b"000110" when trailingones=2 and totalcoeffs=14 and ctable=1 else
		b"001000" when trailingones=3 and totalcoeffs=14 and ctable=1 else
		b"001001" when trailingones=0 and totalcoeffs=15 and ctable=1 else
		b"001000" when trailingones=1 and totalcoeffs=15 and ctable=1 else
		b"001010" when trailingones=2 and totalcoeffs=15 and ctable=1 else
		b"000001" when trailingones=3 and totalcoeffs=15 and ctable=1 else
		b"000111" when trailingones=0 and totalcoeffs=16 and ctable=1 else
		b"000110" when trailingones=1 and totalcoeffs=16 and ctable=1 else
		b"000101" when trailingones=2 and totalcoeffs=16 and ctable=1 else
		b"000100" when trailingones=3 and totalcoeffs=16 and ctable=1 else
		--
		b"001111" when trailingones=0 and totalcoeffs=0 and ctable=2 else
		b"001111" when trailingones=0 and totalcoeffs=1 and ctable=2 else
		b"001110" when trailingones=1 and totalcoeffs=1 and ctable=2 else
		b"001011" when trailingones=0 and totalcoeffs=2 and ctable=2 else
		b"001111" when trailingones=1 and totalcoeffs=2 and ctable=2 else
		b"001101" when trailingones=2 and totalcoeffs=2 and ctable=2 else
		b"001000" when trailingones=0 and totalcoeffs=3 and ctable=2 else
		b"001100" when trailingones=1 and totalcoeffs=3 and ctable=2 else
		b"001110" when trailingones=2 and totalcoeffs=3 and ctable=2 else
		b"001100" when trailingones=3 and totalcoeffs=3 and ctable=2 else
		b"001111" when trailingones=0 and totalcoeffs=4 and ctable=2 else
		b"001010" when trailingones=1 and totalcoeffs=4 and ctable=2 else
		b"001011" when trailingones=2 and totalcoeffs=4 and ctable=2 else
		b"001011" when trailingones=3 and totalcoeffs=4 and ctable=2 else
		b"001011" when trailingones=0 and totalcoeffs=5 and ctable=2 else
		b"001000" when trailingones=1 and totalcoeffs=5 and ctable=2 else
		b"001001" when trailingones=2 and totalcoeffs=5 and ctable=2 else
		b"001010" when trailingones=3 and totalcoeffs=5 and ctable=2 else
		b"001001" when trailingones=0 and totalcoeffs=6 and ctable=2 else
		b"001110" when trailingones=1 and totalcoeffs=6 and ctable=2 else
		b"001101" when trailingones=2 and totalcoeffs=6 and ctable=2 else
		b"001001" when trailingones=3 and totalcoeffs=6 and ctable=2 else
		b"001000" when trailingones=0 and totalcoeffs=7 and ctable=2 else
		b"001010" when trailingones=1 and totalcoeffs=7 and ctable=2 else
		b"001001" when trailingones=2 and totalcoeffs=7 and ctable=2 else
		b"001000" when trailingones=3 and totalcoeffs=7 and ctable=2 else
		b"001111" when trailingones=0 and totalcoeffs=8 and ctable=2 else
		b"001110" when trailingones=1 and totalcoeffs=8 and ctable=2 else
		b"001101" when trailingones=2 and totalcoeffs=8 and ctable=2 else
		b"001101" when trailingones=3 and totalcoeffs=8 and ctable=2 else
		b"001011" when trailingones=0 and totalcoeffs=9 and ctable=2 else
		b"001110" when trailingones=1 and totalcoeffs=9 and ctable=2 else
		b"001010" when trailingones=2 and totalcoeffs=9 and ctable=2 else
		b"001100" when trailingones=3 and totalcoeffs=9 and ctable=2 else
		b"001111" when trailingones=0 and totalcoeffs=10 and ctable=2 else
		b"001010" when trailingones=1 and totalcoeffs=10 and ctable=2 else
		b"001101" when trailingones=2 and totalcoeffs=10 and ctable=2 else
		b"001100" when trailingones=3 and totalcoeffs=10 and ctable=2 else
		b"001011" when trailingones=0 and totalcoeffs=11 and ctable=2 else
		b"001110" when trailingones=1 and totalcoeffs=11 and ctable=2 else
		b"001001" when trailingones=2 and totalcoeffs=11 and ctable=2 else
		b"001100" when trailingones=3 and totalcoeffs=11 and ctable=2 else
		b"001000" when trailingones=0 and totalcoeffs=12 and ctable=2 else
		b"001010" when trailingones=1 and totalcoeffs=12 and ctable=2 else
		b"001101" when trailingones=2 and totalcoeffs=12 and ctable=2 else
		b"001000" when trailingones=3 and totalcoeffs=12 and ctable=2 else
		b"001101" when trailingones=0 and totalcoeffs=13 and ctable=2 else
		b"000111" when trailingones=1 and totalcoeffs=13 and ctable=2 else
		b"001001" when trailingones=2 and totalcoeffs=13 and ctable=2 else
		b"001100" when trailingones=3 and totalcoeffs=13 and ctable=2 else
		b"001001" when trailingones=0 and totalcoeffs=14 and ctable=2 else
		b"001100" when trailingones=1 and totalcoeffs=14 and ctable=2 else
		b"001011" when trailingones=2 and totalcoeffs=14 and ctable=2 else
		b"001010" when trailingones=3 and totalcoeffs=14 and ctable=2 else
		b"000101" when trailingones=0 and totalcoeffs=15 and ctable=2 else
		b"001000" when trailingones=1 and totalcoeffs=15 and ctable=2 else
		b"000111" when trailingones=2 and totalcoeffs=15 and ctable=2 else
		b"000110" when trailingones=3 and totalcoeffs=15 and ctable=2 else
		b"000001" when trailingones=0 and totalcoeffs=16 and ctable=2 else
		b"000100" when trailingones=1 and totalcoeffs=16 and ctable=2 else
		b"000011" when trailingones=2 and totalcoeffs=16 and ctable=2 else
		b"000010" when trailingones=3 and totalcoeffs=16 and ctable=2 else
		--
		b"000011" when trailingones=0 and totalcoeffs=0 and ctable=3 else
		b"000000" when trailingones=0 and totalcoeffs=1 and ctable=3 else
		b"000001" when trailingones=1 and totalcoeffs=1 and ctable=3 else
		b"000100" when trailingones=0 and totalcoeffs=2 and ctable=3 else
		b"000101" when trailingones=1 and totalcoeffs=2 and ctable=3 else
		b"000110" when trailingones=2 and totalcoeffs=2 and ctable=3 else
		b"001000" when trailingones=0 and totalcoeffs=3 and ctable=3 else
		b"001001" when trailingones=1 and totalcoeffs=3 and ctable=3 else
		b"001010" when trailingones=2 and totalcoeffs=3 and ctable=3 else
		b"001011" when trailingones=3 and totalcoeffs=3 and ctable=3 else
		b"001100" when trailingones=0 and totalcoeffs=4 and ctable=3 else
		b"001101" when trailingones=1 and totalcoeffs=4 and ctable=3 else
		b"001110" when trailingones=2 and totalcoeffs=4 and ctable=3 else
		b"001111" when trailingones=3 and totalcoeffs=4 and ctable=3 else
		b"010000" when trailingones=0 and totalcoeffs=5 and ctable=3 else
		b"010001" when trailingones=1 and totalcoeffs=5 and ctable=3 else
		b"010010" when trailingones=2 and totalcoeffs=5 and ctable=3 else
		b"010011" when trailingones=3 and totalcoeffs=5 and ctable=3 else
		b"010100" when trailingones=0 and totalcoeffs=6 and ctable=3 else
		b"010101" when trailingones=1 and totalcoeffs=6 and ctable=3 else
		b"010110" when trailingones=2 and totalcoeffs=6 and ctable=3 else
		b"010111" when trailingones=3 and totalcoeffs=6 and ctable=3 else
		b"011000" when trailingones=0 and totalcoeffs=7 and ctable=3 else
		b"011001" when trailingones=1 and totalcoeffs=7 and ctable=3 else
		b"011010" when trailingones=2 and totalcoeffs=7 and ctable=3 else
		b"011011" when trailingones=3 and totalcoeffs=7 and ctable=3 else
		b"011100" when trailingones=0 and totalcoeffs=8 and ctable=3 else
		b"011101" when trailingones=1 and totalcoeffs=8 and ctable=3 else
		b"011110" when trailingones=2 and totalcoeffs=8 and ctable=3 else
		b"011111" when trailingones=3 and totalcoeffs=8 and ctable=3 else
		b"100000" when trailingones=0 and totalcoeffs=9 and ctable=3 else
		b"100001" when trailingones=1 and totalcoeffs=9 and ctable=3 else
		b"100010" when trailingones=2 and totalcoeffs=9 and ctable=3 else
		b"100011" when trailingones=3 and totalcoeffs=9 and ctable=3 else
		b"100100" when trailingones=0 and totalcoeffs=10 and ctable=3 else
		b"100101" when trailingones=1 and totalcoeffs=10 and ctable=3 else
		b"100110" when trailingones=2 and totalcoeffs=10 and ctable=3 else
		b"100111" when trailingones=3 and totalcoeffs=10 and ctable=3 else
		b"101000" when trailingones=0 and totalcoeffs=11 and ctable=3 else
		b"101001" when trailingones=1 and totalcoeffs=11 and ctable=3 else
		b"101010" when trailingones=2 and totalcoeffs=11 and ctable=3 else
		b"101011" when trailingones=3 and totalcoeffs=11 and ctable=3 else
		b"101100" when trailingones=0 and totalcoeffs=12 and ctable=3 else
		b"101101" when trailingones=1 and totalcoeffs=12 and ctable=3 else
		b"101110" when trailingones=2 and totalcoeffs=12 and ctable=3 else
		b"101111" when trailingones=3 and totalcoeffs=12 and ctable=3 else
		b"110000" when trailingones=0 and totalcoeffs=13 and ctable=3 else
		b"110001" when trailingones=1 and totalcoeffs=13 and ctable=3 else
		b"110010" when trailingones=2 and totalcoeffs=13 and ctable=3 else
		b"110011" when trailingones=3 and totalcoeffs=13 and ctable=3 else
		b"110100" when trailingones=0 and totalcoeffs=14 and ctable=3 else
		b"110101" when trailingones=1 and totalcoeffs=14 and ctable=3 else
		b"110110" when trailingones=2 and totalcoeffs=14 and ctable=3 else
		b"110111" when trailingones=3 and totalcoeffs=14 and ctable=3 else
		b"111000" when trailingones=0 and totalcoeffs=15 and ctable=3 else
		b"111001" when trailingones=1 and totalcoeffs=15 and ctable=3 else
		b"111010" when trailingones=2 and totalcoeffs=15 and ctable=3 else
		b"111011" when trailingones=3 and totalcoeffs=15 and ctable=3 else
		b"111100" when trailingones=0 and totalcoeffs=16 and ctable=3 else
		b"111101" when trailingones=1 and totalcoeffs=16 and ctable=3 else
		b"111110" when trailingones=2 and totalcoeffs=16 and ctable=3 else
		b"111111" when trailingones=3 and totalcoeffs=16 and ctable=3 else
		--
		b"000001" when trailingones=0 and totalcoeffs=0 and ctable=4 else
		b"000111" when trailingones=0 and totalcoeffs=1 and ctable=4 else
		b"000001" when trailingones=1 and totalcoeffs=1 and ctable=4 else
		b"000100" when trailingones=0 and totalcoeffs=2 and ctable=4 else
		b"000110" when trailingones=1 and totalcoeffs=2 and ctable=4 else
		b"000001" when trailingones=2 and totalcoeffs=2 and ctable=4 else
		b"000011" when trailingones=0 and totalcoeffs=3 and ctable=4 else
		b"000011" when trailingones=1 and totalcoeffs=3 and ctable=4 else
		b"000010" when trailingones=2 and totalcoeffs=3 and ctable=4 else
		b"000101" when trailingones=3 and totalcoeffs=3 and ctable=4 else
		b"000010" when trailingones=0 and totalcoeffs=4 and ctable=4 else
		b"000011" when trailingones=1 and totalcoeffs=4 and ctable=4 else
		b"000010" when trailingones=2 and totalcoeffs=4 and ctable=4 else
		b"000000"; --  trailingones=3 and totalcoeffs=4 and ctable=4
	--
	ctoken_len <=
		b"00001" when trailingones=0 and totalcoeffs=0 and ctable=0 else
		b"00110" when trailingones=0 and totalcoeffs=1 and ctable=0 else
		b"00010" when trailingones=1 and totalcoeffs=1 and ctable=0 else
		b"01000" when trailingones=0 and totalcoeffs=2 and ctable=0 else
		b"00110" when trailingones=1 and totalcoeffs=2 and ctable=0 else
		b"00011" when trailingones=2 and totalcoeffs=2 and ctable=0 else
		b"01001" when trailingones=0 and totalcoeffs=3 and ctable=0 else
		b"01000" when trailingones=1 and totalcoeffs=3 and ctable=0 else
		b"00111" when trailingones=2 and totalcoeffs=3 and ctable=0 else
		b"00101" when trailingones=3 and totalcoeffs=3 and ctable=0 else
		b"01010" when trailingones=0 and totalcoeffs=4 and ctable=0 else
		b"01001" when trailingones=1 and totalcoeffs=4 and ctable=0 else
		b"01000" when trailingones=2 and totalcoeffs=4 and ctable=0 else
		b"00110" when trailingones=3 and totalcoeffs=4 and ctable=0 else
		b"01011" when trailingones=0 and totalcoeffs=5 and ctable=0 else
		b"01010" when trailingones=1 and totalcoeffs=5 and ctable=0 else
		b"01001" when trailingones=2 and totalcoeffs=5 and ctable=0 else
		b"00111" when trailingones=3 and totalcoeffs=5 and ctable=0 else
		b"01101" when trailingones=0 and totalcoeffs=6 and ctable=0 else
		b"01011" when trailingones=1 and totalcoeffs=6 and ctable=0 else
		b"01010" when trailingones=2 and totalcoeffs=6 and ctable=0 else
		b"01000" when trailingones=3 and totalcoeffs=6 and ctable=0 else
		b"01101" when trailingones=0 and totalcoeffs=7 and ctable=0 else
		b"01101" when trailingones=1 and totalcoeffs=7 and ctable=0 else
		b"01011" when trailingones=2 and totalcoeffs=7 and ctable=0 else
		b"01001" when trailingones=3 and totalcoeffs=7 and ctable=0 else
		b"01101" when trailingones=0 and totalcoeffs=8 and ctable=0 else
		b"01101" when trailingones=1 and totalcoeffs=8 and ctable=0 else
		b"01101" when trailingones=2 and totalcoeffs=8 and ctable=0 else
		b"01010" when trailingones=3 and totalcoeffs=8 and ctable=0 else
		b"01110" when trailingones=0 and totalcoeffs=9 and ctable=0 else
		b"01110" when trailingones=1 and totalcoeffs=9 and ctable=0 else
		b"01101" when trailingones=2 and totalcoeffs=9 and ctable=0 else
		b"01011" when trailingones=3 and totalcoeffs=9 and ctable=0 else
		b"01110" when trailingones=0 and totalcoeffs=10 and ctable=0 else
		b"01110" when trailingones=1 and totalcoeffs=10 and ctable=0 else
		b"01110" when trailingones=2 and totalcoeffs=10 and ctable=0 else
		b"01101" when trailingones=3 and totalcoeffs=10 and ctable=0 else
		b"01111" when trailingones=0 and totalcoeffs=11 and ctable=0 else
		b"01111" when trailingones=1 and totalcoeffs=11 and ctable=0 else
		b"01110" when trailingones=2 and totalcoeffs=11 and ctable=0 else
		b"01110" when trailingones=3 and totalcoeffs=11 and ctable=0 else
		b"01111" when trailingones=0 and totalcoeffs=12 and ctable=0 else
		b"01111" when trailingones=1 and totalcoeffs=12 and ctable=0 else
		b"01111" when trailingones=2 and totalcoeffs=12 and ctable=0 else
		b"01110" when trailingones=3 and totalcoeffs=12 and ctable=0 else
		b"10000" when trailingones=0 and totalcoeffs=13 and ctable=0 else
		b"01111" when trailingones=1 and totalcoeffs=13 and ctable=0 else
		b"01111" when trailingones=2 and totalcoeffs=13 and ctable=0 else
		b"01111" when trailingones=3 and totalcoeffs=13 and ctable=0 else
		b"10000" when trailingones=0 and totalcoeffs=14 and ctable=0 else
		b"10000" when trailingones=1 and totalcoeffs=14 and ctable=0 else
		b"10000" when trailingones=2 and totalcoeffs=14 and ctable=0 else
		b"01111" when trailingones=3 and totalcoeffs=14 and ctable=0 else
		b"10000" when trailingones=0 and totalcoeffs=15 and ctable=0 else
		b"10000" when trailingones=1 and totalcoeffs=15 and ctable=0 else
		b"10000" when trailingones=2 and totalcoeffs=15 and ctable=0 else
		b"10000" when trailingones=3 and totalcoeffs=15 and ctable=0 else
		b"10000" when trailingones=0 and totalcoeffs=16 and ctable=0 else
		b"10000" when trailingones=1 and totalcoeffs=16 and ctable=0 else
		b"10000" when trailingones=2 and totalcoeffs=16 and ctable=0 else
		b"10000" when trailingones=3 and totalcoeffs=16 and ctable=0 else
		--
		b"00010" when trailingones=0 and totalcoeffs=0 and ctable=1 else
		b"00110" when trailingones=0 and totalcoeffs=1 and ctable=1 else
		b"00010" when trailingones=1 and totalcoeffs=1 and ctable=1 else
		b"00110" when trailingones=0 and totalcoeffs=2 and ctable=1 else
		b"00101" when trailingones=1 and totalcoeffs=2 and ctable=1 else
		b"00011" when trailingones=2 and totalcoeffs=2 and ctable=1 else
		b"00111" when trailingones=0 and totalcoeffs=3 and ctable=1 else
		b"00110" when trailingones=1 and totalcoeffs=3 and ctable=1 else
		b"00110" when trailingones=2 and totalcoeffs=3 and ctable=1 else
		b"00100" when trailingones=3 and totalcoeffs=3 and ctable=1 else
		b"01000" when trailingones=0 and totalcoeffs=4 and ctable=1 else
		b"00110" when trailingones=1 and totalcoeffs=4 and ctable=1 else
		b"00110" when trailingones=2 and totalcoeffs=4 and ctable=1 else
		b"00100" when trailingones=3 and totalcoeffs=4 and ctable=1 else
		b"01000" when trailingones=0 and totalcoeffs=5 and ctable=1 else
		b"00111" when trailingones=1 and totalcoeffs=5 and ctable=1 else
		b"00111" when trailingones=2 and totalcoeffs=5 and ctable=1 else
		b"00101" when trailingones=3 and totalcoeffs=5 and ctable=1 else
		b"01001" when trailingones=0 and totalcoeffs=6 and ctable=1 else
		b"01000" when trailingones=1 and totalcoeffs=6 and ctable=1 else
		b"01000" when trailingones=2 and totalcoeffs=6 and ctable=1 else
		b"00110" when trailingones=3 and totalcoeffs=6 and ctable=1 else
		b"01011" when trailingones=0 and totalcoeffs=7 and ctable=1 else
		b"01001" when trailingones=1 and totalcoeffs=7 and ctable=1 else
		b"01001" when trailingones=2 and totalcoeffs=7 and ctable=1 else
		b"00110" when trailingones=3 and totalcoeffs=7 and ctable=1 else
		b"01011" when trailingones=0 and totalcoeffs=8 and ctable=1 else
		b"01011" when trailingones=1 and totalcoeffs=8 and ctable=1 else
		b"01011" when trailingones=2 and totalcoeffs=8 and ctable=1 else
		b"00111" when trailingones=3 and totalcoeffs=8 and ctable=1 else
		b"01100" when trailingones=0 and totalcoeffs=9 and ctable=1 else
		b"01011" when trailingones=1 and totalcoeffs=9 and ctable=1 else
		b"01011" when trailingones=2 and totalcoeffs=9 and ctable=1 else
		b"01001" when trailingones=3 and totalcoeffs=9 and ctable=1 else
		b"01100" when trailingones=0 and totalcoeffs=10 and ctable=1 else
		b"01100" when trailingones=1 and totalcoeffs=10 and ctable=1 else
		b"01100" when trailingones=2 and totalcoeffs=10 and ctable=1 else
		b"01011" when trailingones=3 and totalcoeffs=10 and ctable=1 else
		b"01100" when trailingones=0 and totalcoeffs=11 and ctable=1 else
		b"01100" when trailingones=1 and totalcoeffs=11 and ctable=1 else
		b"01100" when trailingones=2 and totalcoeffs=11 and ctable=1 else
		b"01011" when trailingones=3 and totalcoeffs=11 and ctable=1 else
		b"01101" when trailingones=0 and totalcoeffs=12 and ctable=1 else
		b"01101" when trailingones=1 and totalcoeffs=12 and ctable=1 else
		b"01101" when trailingones=2 and totalcoeffs=12 and ctable=1 else
		b"01100" when trailingones=3 and totalcoeffs=12 and ctable=1 else
		b"01101" when trailingones=0 and totalcoeffs=13 and ctable=1 else
		b"01101" when trailingones=1 and totalcoeffs=13 and ctable=1 else
		b"01101" when trailingones=2 and totalcoeffs=13 and ctable=1 else
		b"01101" when trailingones=3 and totalcoeffs=13 and ctable=1 else
		b"01101" when trailingones=0 and totalcoeffs=14 and ctable=1 else
		b"01110" when trailingones=1 and totalcoeffs=14 and ctable=1 else
		b"01101" when trailingones=2 and totalcoeffs=14 and ctable=1 else
		b"01101" when trailingones=3 and totalcoeffs=14 and ctable=1 else
		b"01110" when trailingones=0 and totalcoeffs=15 and ctable=1 else
		b"01110" when trailingones=1 and totalcoeffs=15 and ctable=1 else
		b"01110" when trailingones=2 and totalcoeffs=15 and ctable=1 else
		b"01101" when trailingones=3 and totalcoeffs=15 and ctable=1 else
		b"01110" when trailingones=0 and totalcoeffs=16 and ctable=1 else
		b"01110" when trailingones=1 and totalcoeffs=16 and ctable=1 else
		b"01110" when trailingones=2 and totalcoeffs=16 and ctable=1 else
		b"01110" when trailingones=3 and totalcoeffs=16 and ctable=1 else
		--
		b"00100" when trailingones=0 and totalcoeffs=0 and ctable=2 else
		b"00110" when trailingones=0 and totalcoeffs=1 and ctable=2 else
		b"00100" when trailingones=1 and totalcoeffs=1 and ctable=2 else
		b"00110" when trailingones=0 and totalcoeffs=2 and ctable=2 else
		b"00101" when trailingones=1 and totalcoeffs=2 and ctable=2 else
		b"00100" when trailingones=2 and totalcoeffs=2 and ctable=2 else
		b"00110" when trailingones=0 and totalcoeffs=3 and ctable=2 else
		b"00101" when trailingones=1 and totalcoeffs=3 and ctable=2 else
		b"00101" when trailingones=2 and totalcoeffs=3 and ctable=2 else
		b"00100" when trailingones=3 and totalcoeffs=3 and ctable=2 else
		b"00111" when trailingones=0 and totalcoeffs=4 and ctable=2 else
		b"00101" when trailingones=1 and totalcoeffs=4 and ctable=2 else
		b"00101" when trailingones=2 and totalcoeffs=4 and ctable=2 else
		b"00100" when trailingones=3 and totalcoeffs=4 and ctable=2 else
		b"00111" when trailingones=0 and totalcoeffs=5 and ctable=2 else
		b"00101" when trailingones=1 and totalcoeffs=5 and ctable=2 else
		b"00101" when trailingones=2 and totalcoeffs=5 and ctable=2 else
		b"00100" when trailingones=3 and totalcoeffs=5 and ctable=2 else
		b"00111" when trailingones=0 and totalcoeffs=6 and ctable=2 else
		b"00110" when trailingones=1 and totalcoeffs=6 and ctable=2 else
		b"00110" when trailingones=2 and totalcoeffs=6 and ctable=2 else
		b"00100" when trailingones=3 and totalcoeffs=6 and ctable=2 else
		b"00111" when trailingones=0 and totalcoeffs=7 and ctable=2 else
		b"00110" when trailingones=1 and totalcoeffs=7 and ctable=2 else
		b"00110" when trailingones=2 and totalcoeffs=7 and ctable=2 else
		b"00100" when trailingones=3 and totalcoeffs=7 and ctable=2 else
		b"01000" when trailingones=0 and totalcoeffs=8 and ctable=2 else
		b"00111" when trailingones=1 and totalcoeffs=8 and ctable=2 else
		b"00111" when trailingones=2 and totalcoeffs=8 and ctable=2 else
		b"00101" when trailingones=3 and totalcoeffs=8 and ctable=2 else
		b"01000" when trailingones=0 and totalcoeffs=9 and ctable=2 else
		b"01000" when trailingones=1 and totalcoeffs=9 and ctable=2 else
		b"00111" when trailingones=2 and totalcoeffs=9 and ctable=2 else
		b"00110" when trailingones=3 and totalcoeffs=9 and ctable=2 else
		b"01001" when trailingones=0 and totalcoeffs=10 and ctable=2 else
		b"01000" when trailingones=1 and totalcoeffs=10 and ctable=2 else
		b"01000" when trailingones=2 and totalcoeffs=10 and ctable=2 else
		b"00111" when trailingones=3 and totalcoeffs=10 and ctable=2 else
		b"01001" when trailingones=0 and totalcoeffs=11 and ctable=2 else
		b"01001" when trailingones=1 and totalcoeffs=11 and ctable=2 else
		b"01000" when trailingones=2 and totalcoeffs=11 and ctable=2 else
		b"01000" when trailingones=3 and totalcoeffs=11 and ctable=2 else
		b"01001" when trailingones=0 and totalcoeffs=12 and ctable=2 else
		b"01001" when trailingones=1 and totalcoeffs=12 and ctable=2 else
		b"01001" when trailingones=2 and totalcoeffs=12 and ctable=2 else
		b"01000" when trailingones=3 and totalcoeffs=12 and ctable=2 else
		b"01010" when trailingones=0 and totalcoeffs=13 and ctable=2 else
		b"01001" when trailingones=1 and totalcoeffs=13 and ctable=2 else
		b"01001" when trailingones=2 and totalcoeffs=13 and ctable=2 else
		b"01001" when trailingones=3 and totalcoeffs=13 and ctable=2 else
		b"01010" when trailingones=0 and totalcoeffs=14 and ctable=2 else
		b"01010" when trailingones=1 and totalcoeffs=14 and ctable=2 else
		b"01010" when trailingones=2 and totalcoeffs=14 and ctable=2 else
		b"01010" when trailingones=3 and totalcoeffs=14 and ctable=2 else
		b"01010" when trailingones=0 and totalcoeffs=15 and ctable=2 else
		b"01010" when trailingones=1 and totalcoeffs=15 and ctable=2 else
		b"01010" when trailingones=2 and totalcoeffs=15 and ctable=2 else
		b"01010" when trailingones=3 and totalcoeffs=15 and ctable=2 else
		b"01010" when trailingones=0 and totalcoeffs=16 and ctable=2 else
		b"01010" when trailingones=1 and totalcoeffs=16 and ctable=2 else
		b"01010" when trailingones=2 and totalcoeffs=16 and ctable=2 else
		b"01010" when trailingones=3 and totalcoeffs=16 and ctable=2 else
		--
		b"00110" when ctable=3 else
		--
		b"00010" when trailingones=0 and totalcoeffs=0 and ctable=4 else
		b"00110" when trailingones=0 and totalcoeffs=1 and ctable=4 else
		b"00001" when trailingones=1 and totalcoeffs=1 and ctable=4 else
		b"00110" when trailingones=0 and totalcoeffs=2 and ctable=4 else
		b"00110" when trailingones=1 and totalcoeffs=2 and ctable=4 else
		b"00011" when trailingones=2 and totalcoeffs=2 and ctable=4 else
		b"00110" when trailingones=0 and totalcoeffs=3 and ctable=4 else
		b"00111" when trailingones=1 and totalcoeffs=3 and ctable=4 else
		b"00111" when trailingones=2 and totalcoeffs=3 and ctable=4 else
		b"00110" when trailingones=3 and totalcoeffs=3 and ctable=4 else
		b"00110" when trailingones=0 and totalcoeffs=4 and ctable=4 else
		b"01000" when trailingones=1 and totalcoeffs=4 and ctable=4 else
		b"01000" when trailingones=2 and totalcoeffs=4 and ctable=4 else
		b"00111"; --  trailingones=3 and totalcoeffs=4 and ctable=4
	--
	-- tables for TotalZeros token
	--
	ztoken <=
		b"001" when totalzeros=0 and totalcoeffs=1 and ztable='0' else
		b"011" when totalzeros=1 and totalcoeffs=1 and ztable='0' else
		b"010" when totalzeros=2 and totalcoeffs=1 and ztable='0' else
		b"011" when totalzeros=3 and totalcoeffs=1 and ztable='0' else
		b"010" when totalzeros=4 and totalcoeffs=1 and ztable='0' else
		b"011" when totalzeros=5 and totalcoeffs=1 and ztable='0' else
		b"010" when totalzeros=6 and totalcoeffs=1 and ztable='0' else
		b"011" when totalzeros=7 and totalcoeffs=1 and ztable='0' else
		b"010" when totalzeros=8 and totalcoeffs=1 and ztable='0' else
		b"011" when totalzeros=9 and totalcoeffs=1 and ztable='0' else
		b"010" when totalzeros=10 and totalcoeffs=1 and ztable='0' else
		b"011" when totalzeros=11 and totalcoeffs=1 and ztable='0' else
		b"010" when totalzeros=12 and totalcoeffs=1 and ztable='0' else
		b"011" when totalzeros=13 and totalcoeffs=1 and ztable='0' else
		b"010" when totalzeros=14 and totalcoeffs=1 and ztable='0' else
		b"001" when totalzeros=15 and totalcoeffs=1 and ztable='0' else
		b"111" when totalzeros=0 and totalcoeffs=2 and ztable='0' else
		b"110" when totalzeros=1 and totalcoeffs=2 and ztable='0' else
		b"101" when totalzeros=2 and totalcoeffs=2 and ztable='0' else
		b"100" when totalzeros=3 and totalcoeffs=2 and ztable='0' else
		b"011" when totalzeros=4 and totalcoeffs=2 and ztable='0' else
		b"101" when totalzeros=5 and totalcoeffs=2 and ztable='0' else
		b"100" when totalzeros=6 and totalcoeffs=2 and ztable='0' else
		b"011" when totalzeros=7 and totalcoeffs=2 and ztable='0' else
		b"010" when totalzeros=8 and totalcoeffs=2 and ztable='0' else
		b"011" when totalzeros=9 and totalcoeffs=2 and ztable='0' else
		b"010" when totalzeros=10 and totalcoeffs=2 and ztable='0' else
		b"011" when totalzeros=11 and totalcoeffs=2 and ztable='0' else
		b"010" when totalzeros=12 and totalcoeffs=2 and ztable='0' else
		b"001" when totalzeros=13 and totalcoeffs=2 and ztable='0' else
		b"000" when totalzeros=14 and totalcoeffs=2 and ztable='0' else
		b"101" when totalzeros=0 and totalcoeffs=3 and ztable='0' else
		b"111" when totalzeros=1 and totalcoeffs=3 and ztable='0' else
		b"110" when totalzeros=2 and totalcoeffs=3 and ztable='0' else
		b"101" when totalzeros=3 and totalcoeffs=3 and ztable='0' else
		b"100" when totalzeros=4 and totalcoeffs=3 and ztable='0' else
		b"011" when totalzeros=5 and totalcoeffs=3 and ztable='0' else
		b"100" when totalzeros=6 and totalcoeffs=3 and ztable='0' else
		b"011" when totalzeros=7 and totalcoeffs=3 and ztable='0' else
		b"010" when totalzeros=8 and totalcoeffs=3 and ztable='0' else
		b"011" when totalzeros=9 and totalcoeffs=3 and ztable='0' else
		b"010" when totalzeros=10 and totalcoeffs=3 and ztable='0' else
		b"001" when totalzeros=11 and totalcoeffs=3 and ztable='0' else
		b"001" when totalzeros=12 and totalcoeffs=3 and ztable='0' else
		b"000" when totalzeros=13 and totalcoeffs=3 and ztable='0' else
		b"011" when totalzeros=0 and totalcoeffs=4 and ztable='0' else
		b"111" when totalzeros=1 and totalcoeffs=4 and ztable='0' else
		b"101" when totalzeros=2 and totalcoeffs=4 and ztable='0' else
		b"100" when totalzeros=3 and totalcoeffs=4 and ztable='0' else
		b"110" when totalzeros=4 and totalcoeffs=4 and ztable='0' else
		b"101" when totalzeros=5 and totalcoeffs=4 and ztable='0' else
		b"100" when totalzeros=6 and totalcoeffs=4 and ztable='0' else
		b"011" when totalzeros=7 and totalcoeffs=4 and ztable='0' else
		b"011" when totalzeros=8 and totalcoeffs=4 and ztable='0' else
		b"010" when totalzeros=9 and totalcoeffs=4 and ztable='0' else
		b"010" when totalzeros=10 and totalcoeffs=4 and ztable='0' else
		b"001" when totalzeros=11 and totalcoeffs=4 and ztable='0' else
		b"000" when totalzeros=12 and totalcoeffs=4 and ztable='0' else
		b"101" when totalzeros=0 and totalcoeffs=5 and ztable='0' else
		b"100" when totalzeros=1 and totalcoeffs=5 and ztable='0' else
		b"011" when totalzeros=2 and totalcoeffs=5 and ztable='0' else
		b"111" when totalzeros=3 and totalcoeffs=5 and ztable='0' else
		b"110" when totalzeros=4 and totalcoeffs=5 and ztable='0' else
		b"101" when totalzeros=5 and totalcoeffs=5 and ztable='0' else
		b"100" when totalzeros=6 and totalcoeffs=5 and ztable='0' else
		b"011" when totalzeros=7 and totalcoeffs=5 and ztable='0' else
		b"010" when totalzeros=8 and totalcoeffs=5 and ztable='0' else
		b"001" when totalzeros=9 and totalcoeffs=5 and ztable='0' else
		b"001" when totalzeros=10 and totalcoeffs=5 and ztable='0' else
		b"000" when totalzeros=11 and totalcoeffs=5 and ztable='0' else
		b"001" when totalzeros=0 and totalcoeffs=6 and ztable='0' else
		b"001" when totalzeros=1 and totalcoeffs=6 and ztable='0' else
		b"111" when totalzeros=2 and totalcoeffs=6 and ztable='0' else
		b"110" when totalzeros=3 and totalcoeffs=6 and ztable='0' else
		b"101" when totalzeros=4 and totalcoeffs=6 and ztable='0' else
		b"100" when totalzeros=5 and totalcoeffs=6 and ztable='0' else
		b"011" when totalzeros=6 and totalcoeffs=6 and ztable='0' else
		b"010" when totalzeros=7 and totalcoeffs=6 and ztable='0' else
		b"001" when totalzeros=8 and totalcoeffs=6 and ztable='0' else
		b"001" when totalzeros=9 and totalcoeffs=6 and ztable='0' else
		b"000" when totalzeros=10 and totalcoeffs=6 and ztable='0' else
		b"001" when totalzeros=0 and totalcoeffs=7 and ztable='0' else
		b"001" when totalzeros=1 and totalcoeffs=7 and ztable='0' else
		b"101" when totalzeros=2 and totalcoeffs=7 and ztable='0' else
		b"100" when totalzeros=3 and totalcoeffs=7 and ztable='0' else
		b"011" when totalzeros=4 and totalcoeffs=7 and ztable='0' else
		b"011" when totalzeros=5 and totalcoeffs=7 and ztable='0' else
		b"010" when totalzeros=6 and totalcoeffs=7 and ztable='0' else
		b"001" when totalzeros=7 and totalcoeffs=7 and ztable='0' else
		b"001" when totalzeros=8 and totalcoeffs=7 and ztable='0' else
		b"000" when totalzeros=9 and totalcoeffs=7 and ztable='0' else
		b"001" when totalzeros=0 and totalcoeffs=8 and ztable='0' else
		b"001" when totalzeros=1 and totalcoeffs=8 and ztable='0' else
		b"001" when totalzeros=2 and totalcoeffs=8 and ztable='0' else
		b"011" when totalzeros=3 and totalcoeffs=8 and ztable='0' else
		b"011" when totalzeros=4 and totalcoeffs=8 and ztable='0' else
		b"010" when totalzeros=5 and totalcoeffs=8 and ztable='0' else
		b"010" when totalzeros=6 and totalcoeffs=8 and ztable='0' else
		b"001" when totalzeros=7 and totalcoeffs=8 and ztable='0' else
		b"000" when totalzeros=8 and totalcoeffs=8 and ztable='0' else
		b"001" when totalzeros=0 and totalcoeffs=9 and ztable='0' else
		b"000" when totalzeros=1 and totalcoeffs=9 and ztable='0' else
		b"001" when totalzeros=2 and totalcoeffs=9 and ztable='0' else
		b"011" when totalzeros=3 and totalcoeffs=9 and ztable='0' else
		b"010" when totalzeros=4 and totalcoeffs=9 and ztable='0' else
		b"001" when totalzeros=5 and totalcoeffs=9 and ztable='0' else
		b"001" when totalzeros=6 and totalcoeffs=9 and ztable='0' else
		b"001" when totalzeros=7 and totalcoeffs=9 and ztable='0' else
		b"001" when totalzeros=0 and totalcoeffs=10 and ztable='0' else
		b"000" when totalzeros=1 and totalcoeffs=10 and ztable='0' else
		b"001" when totalzeros=2 and totalcoeffs=10 and ztable='0' else
		b"011" when totalzeros=3 and totalcoeffs=10 and ztable='0' else
		b"010" when totalzeros=4 and totalcoeffs=10 and ztable='0' else
		b"001" when totalzeros=5 and totalcoeffs=10 and ztable='0' else
		b"001" when totalzeros=6 and totalcoeffs=10 and ztable='0' else
		b"000" when totalzeros=0 and totalcoeffs=11 and ztable='0' else
		b"001" when totalzeros=1 and totalcoeffs=11 and ztable='0' else
		b"001" when totalzeros=2 and totalcoeffs=11 and ztable='0' else
		b"010" when totalzeros=3 and totalcoeffs=11 and ztable='0' else
		b"001" when totalzeros=4 and totalcoeffs=11 and ztable='0' else
		b"011" when totalzeros=5 and totalcoeffs=11 and ztable='0' else
		b"000" when totalzeros=0 and totalcoeffs=12 and ztable='0' else
		b"001" when totalzeros=1 and totalcoeffs=12 and ztable='0' else
		b"001" when totalzeros=2 and totalcoeffs=12 and ztable='0' else
		b"001" when totalzeros=3 and totalcoeffs=12 and ztable='0' else
		b"001" when totalzeros=4 and totalcoeffs=12 and ztable='0' else
		b"000" when totalzeros=0 and totalcoeffs=13 and ztable='0' else
		b"001" when totalzeros=1 and totalcoeffs=13 and ztable='0' else
		b"001" when totalzeros=2 and totalcoeffs=13 and ztable='0' else
		b"001" when totalzeros=3 and totalcoeffs=13 and ztable='0' else
		b"000" when totalzeros=0 and totalcoeffs=14 and ztable='0' else
		b"001" when totalzeros=1 and totalcoeffs=14 and ztable='0' else
		b"001" when totalzeros=2 and totalcoeffs=14 and ztable='0' else
		b"000" when totalzeros=0 and totalcoeffs=15 and ztable='0' else
		b"001" when totalzeros=1 and totalcoeffs=15 and ztable='0' else
		--
		b"001" when totalzeros=0 and totalcoeffs=1 and ztable='1' else
		b"001" when totalzeros=1 and totalcoeffs=1 and ztable='1' else
		b"001" when totalzeros=2 and totalcoeffs=1 and ztable='1' else
		b"000" when totalzeros=3 and totalcoeffs=1 and ztable='1' else
		b"001" when totalzeros=0 and totalcoeffs=2 and ztable='1' else
		b"001" when totalzeros=1 and totalcoeffs=2 and ztable='1' else
		b"000" when totalzeros=2 and totalcoeffs=2 and ztable='1' else
		b"001" when totalzeros=0 and totalcoeffs=3 and ztable='1' else
		b"000"; --  totalzeros=1 and totalcoeffs=3 and ztable='1'
	--
	ztoken_len <=
		b"0001" when totalzeros=0 and totalcoeffs=1 and ztable='0' else
		b"0011" when totalzeros=1 and totalcoeffs=1 and ztable='0' else
		b"0011" when totalzeros=2 and totalcoeffs=1 and ztable='0' else
		b"0100" when totalzeros=3 and totalcoeffs=1 and ztable='0' else
		b"0100" when totalzeros=4 and totalcoeffs=1 and ztable='0' else
		b"0101" when totalzeros=5 and totalcoeffs=1 and ztable='0' else
		b"0101" when totalzeros=6 and totalcoeffs=1 and ztable='0' else
		b"0110" when totalzeros=7 and totalcoeffs=1 and ztable='0' else
		b"0110" when totalzeros=8 and totalcoeffs=1 and ztable='0' else
		b"0111" when totalzeros=9 and totalcoeffs=1 and ztable='0' else
		b"0111" when totalzeros=10 and totalcoeffs=1 and ztable='0' else
		b"1000" when totalzeros=11 and totalcoeffs=1 and ztable='0' else
		b"1000" when totalzeros=12 and totalcoeffs=1 and ztable='0' else
		b"1001" when totalzeros=13 and totalcoeffs=1 and ztable='0' else
		b"1001" when totalzeros=14 and totalcoeffs=1 and ztable='0' else
		b"1001" when totalzeros=15 and totalcoeffs=1 and ztable='0' else
		b"0011" when totalzeros=0 and totalcoeffs=2 and ztable='0' else
		b"0011" when totalzeros=1 and totalcoeffs=2 and ztable='0' else
		b"0011" when totalzeros=2 and totalcoeffs=2 and ztable='0' else
		b"0011" when totalzeros=3 and totalcoeffs=2 and ztable='0' else
		b"0011" when totalzeros=4 and totalcoeffs=2 and ztable='0' else
		b"0100" when totalzeros=5 and totalcoeffs=2 and ztable='0' else
		b"0100" when totalzeros=6 and totalcoeffs=2 and ztable='0' else
		b"0100" when totalzeros=7 and totalcoeffs=2 and ztable='0' else
		b"0100" when totalzeros=8 and totalcoeffs=2 and ztable='0' else
		b"0101" when totalzeros=9 and totalcoeffs=2 and ztable='0' else
		b"0101" when totalzeros=10 and totalcoeffs=2 and ztable='0' else
		b"0110" when totalzeros=11 and totalcoeffs=2 and ztable='0' else
		b"0110" when totalzeros=12 and totalcoeffs=2 and ztable='0' else
		b"0110" when totalzeros=13 and totalcoeffs=2 and ztable='0' else
		b"0110" when totalzeros=14 and totalcoeffs=2 and ztable='0' else
		b"0100" when totalzeros=0 and totalcoeffs=3 and ztable='0' else
		b"0011" when totalzeros=1 and totalcoeffs=3 and ztable='0' else
		b"0011" when totalzeros=2 and totalcoeffs=3 and ztable='0' else
		b"0011" when totalzeros=3 and totalcoeffs=3 and ztable='0' else
		b"0100" when totalzeros=4 and totalcoeffs=3 and ztable='0' else
		b"0100" when totalzeros=5 and totalcoeffs=3 and ztable='0' else
		b"0011" when totalzeros=6 and totalcoeffs=3 and ztable='0' else
		b"0011" when totalzeros=7 and totalcoeffs=3 and ztable='0' else
		b"0100" when totalzeros=8 and totalcoeffs=3 and ztable='0' else
		b"0101" when totalzeros=9 and totalcoeffs=3 and ztable='0' else
		b"0101" when totalzeros=10 and totalcoeffs=3 and ztable='0' else
		b"0110" when totalzeros=11 and totalcoeffs=3 and ztable='0' else
		b"0101" when totalzeros=12 and totalcoeffs=3 and ztable='0' else
		b"0110" when totalzeros=13 and totalcoeffs=3 and ztable='0' else
		b"0101" when totalzeros=0 and totalcoeffs=4 and ztable='0' else
		b"0011" when totalzeros=1 and totalcoeffs=4 and ztable='0' else
		b"0100" when totalzeros=2 and totalcoeffs=4 and ztable='0' else
		b"0100" when totalzeros=3 and totalcoeffs=4 and ztable='0' else
		b"0011" when totalzeros=4 and totalcoeffs=4 and ztable='0' else
		b"0011" when totalzeros=5 and totalcoeffs=4 and ztable='0' else
		b"0011" when totalzeros=6 and totalcoeffs=4 and ztable='0' else
		b"0100" when totalzeros=7 and totalcoeffs=4 and ztable='0' else
		b"0011" when totalzeros=8 and totalcoeffs=4 and ztable='0' else
		b"0100" when totalzeros=9 and totalcoeffs=4 and ztable='0' else
		b"0101" when totalzeros=10 and totalcoeffs=4 and ztable='0' else
		b"0101" when totalzeros=11 and totalcoeffs=4 and ztable='0' else
		b"0101" when totalzeros=12 and totalcoeffs=4 and ztable='0' else
		b"0100" when totalzeros=0 and totalcoeffs=5 and ztable='0' else
		b"0100" when totalzeros=1 and totalcoeffs=5 and ztable='0' else
		b"0100" when totalzeros=2 and totalcoeffs=5 and ztable='0' else
		b"0011" when totalzeros=3 and totalcoeffs=5 and ztable='0' else
		b"0011" when totalzeros=4 and totalcoeffs=5 and ztable='0' else
		b"0011" when totalzeros=5 and totalcoeffs=5 and ztable='0' else
		b"0011" when totalzeros=6 and totalcoeffs=5 and ztable='0' else
		b"0011" when totalzeros=7 and totalcoeffs=5 and ztable='0' else
		b"0100" when totalzeros=8 and totalcoeffs=5 and ztable='0' else
		b"0101" when totalzeros=9 and totalcoeffs=5 and ztable='0' else
		b"0100" when totalzeros=10 and totalcoeffs=5 and ztable='0' else
		b"0101" when totalzeros=11 and totalcoeffs=5 and ztable='0' else
		b"0110" when totalzeros=0 and totalcoeffs=6 and ztable='0' else
		b"0101" when totalzeros=1 and totalcoeffs=6 and ztable='0' else
		b"0011" when totalzeros=2 and totalcoeffs=6 and ztable='0' else
		b"0011" when totalzeros=3 and totalcoeffs=6 and ztable='0' else
		b"0011" when totalzeros=4 and totalcoeffs=6 and ztable='0' else
		b"0011" when totalzeros=5 and totalcoeffs=6 and ztable='0' else
		b"0011" when totalzeros=6 and totalcoeffs=6 and ztable='0' else
		b"0011" when totalzeros=7 and totalcoeffs=6 and ztable='0' else
		b"0100" when totalzeros=8 and totalcoeffs=6 and ztable='0' else
		b"0011" when totalzeros=9 and totalcoeffs=6 and ztable='0' else
		b"0110" when totalzeros=10 and totalcoeffs=6 and ztable='0' else
		b"0110" when totalzeros=0 and totalcoeffs=7 and ztable='0' else
		b"0101" when totalzeros=1 and totalcoeffs=7 and ztable='0' else
		b"0011" when totalzeros=2 and totalcoeffs=7 and ztable='0' else
		b"0011" when totalzeros=3 and totalcoeffs=7 and ztable='0' else
		b"0011" when totalzeros=4 and totalcoeffs=7 and ztable='0' else
		b"0010" when totalzeros=5 and totalcoeffs=7 and ztable='0' else
		b"0011" when totalzeros=6 and totalcoeffs=7 and ztable='0' else
		b"0100" when totalzeros=7 and totalcoeffs=7 and ztable='0' else
		b"0011" when totalzeros=8 and totalcoeffs=7 and ztable='0' else
		b"0110" when totalzeros=9 and totalcoeffs=7 and ztable='0' else
		b"0110" when totalzeros=0 and totalcoeffs=8 and ztable='0' else
		b"0100" when totalzeros=1 and totalcoeffs=8 and ztable='0' else
		b"0101" when totalzeros=2 and totalcoeffs=8 and ztable='0' else
		b"0011" when totalzeros=3 and totalcoeffs=8 and ztable='0' else
		b"0010" when totalzeros=4 and totalcoeffs=8 and ztable='0' else
		b"0010" when totalzeros=5 and totalcoeffs=8 and ztable='0' else
		b"0011" when totalzeros=6 and totalcoeffs=8 and ztable='0' else
		b"0011" when totalzeros=7 and totalcoeffs=8 and ztable='0' else
		b"0110" when totalzeros=8 and totalcoeffs=8 and ztable='0' else
		b"0110" when totalzeros=0 and totalcoeffs=9 and ztable='0' else
		b"0110" when totalzeros=1 and totalcoeffs=9 and ztable='0' else
		b"0100" when totalzeros=2 and totalcoeffs=9 and ztable='0' else
		b"0010" when totalzeros=3 and totalcoeffs=9 and ztable='0' else
		b"0010" when totalzeros=4 and totalcoeffs=9 and ztable='0' else
		b"0011" when totalzeros=5 and totalcoeffs=9 and ztable='0' else
		b"0010" when totalzeros=6 and totalcoeffs=9 and ztable='0' else
		b"0101" when totalzeros=7 and totalcoeffs=9 and ztable='0' else
		b"0101" when totalzeros=0 and totalcoeffs=10 and ztable='0' else
		b"0101" when totalzeros=1 and totalcoeffs=10 and ztable='0' else
		b"0011" when totalzeros=2 and totalcoeffs=10 and ztable='0' else
		b"0010" when totalzeros=3 and totalcoeffs=10 and ztable='0' else
		b"0010" when totalzeros=4 and totalcoeffs=10 and ztable='0' else
		b"0010" when totalzeros=5 and totalcoeffs=10 and ztable='0' else
		b"0100" when totalzeros=6 and totalcoeffs=10 and ztable='0' else
		b"0100" when totalzeros=0 and totalcoeffs=11 and ztable='0' else
		b"0100" when totalzeros=1 and totalcoeffs=11 and ztable='0' else
		b"0011" when totalzeros=2 and totalcoeffs=11 and ztable='0' else
		b"0011" when totalzeros=3 and totalcoeffs=11 and ztable='0' else
		b"0001" when totalzeros=4 and totalcoeffs=11 and ztable='0' else
		b"0011" when totalzeros=5 and totalcoeffs=11 and ztable='0' else
		b"0100" when totalzeros=0 and totalcoeffs=12 and ztable='0' else
		b"0100" when totalzeros=1 and totalcoeffs=12 and ztable='0' else
		b"0010" when totalzeros=2 and totalcoeffs=12 and ztable='0' else
		b"0001" when totalzeros=3 and totalcoeffs=12 and ztable='0' else
		b"0011" when totalzeros=4 and totalcoeffs=12 and ztable='0' else
		b"0011" when totalzeros=0 and totalcoeffs=13 and ztable='0' else
		b"0011" when totalzeros=1 and totalcoeffs=13 and ztable='0' else
		b"0001" when totalzeros=2 and totalcoeffs=13 and ztable='0' else
		b"0010" when totalzeros=3 and totalcoeffs=13 and ztable='0' else
		b"0010" when totalzeros=0 and totalcoeffs=14 and ztable='0' else
		b"0010" when totalzeros=1 and totalcoeffs=14 and ztable='0' else
		b"0001" when totalzeros=2 and totalcoeffs=14 and ztable='0' else
		b"0001" when totalzeros=0 and totalcoeffs=15 and ztable='0' else
		b"0001" when totalzeros=1 and totalcoeffs=15 and ztable='0' else
	--
		b"0001" when totalzeros=0 and totalcoeffs=1 and ztable='1' else
		b"0010" when totalzeros=1 and totalcoeffs=1 and ztable='1' else
		b"0011" when totalzeros=2 and totalcoeffs=1 and ztable='1' else
		b"0011" when totalzeros=3 and totalcoeffs=1 and ztable='1' else
		b"0001" when totalzeros=0 and totalcoeffs=2 and ztable='1' else
		b"0010" when totalzeros=1 and totalcoeffs=2 and ztable='1' else
		b"0010" when totalzeros=2 and totalcoeffs=2 and ztable='1' else
		b"0001" when totalzeros=0 and totalcoeffs=3 and ztable='1' else
		b"0001"; --  totalzeros=1 and totalcoeffs=3 and ztable='1'
	--
	-- tables for run_before, up to 6
	rbtoken <=
		b"111" when runb=0 else
		b"000" when runb=1 and rbzerosleft=1 else
		b"001" when runb=1 and rbzerosleft=2 else
		b"010" when runb=1 and rbzerosleft=3 else
		b"010" when runb=1 and rbzerosleft=4 else
		b"010" when runb=1 and rbzerosleft=5 else
		b"000" when runb=1 and rbzerosleft=6 else
		b"110" when runb=1 else
		b"000" when runb=2 and rbzerosleft=2 else
		b"001" when runb=2 and rbzerosleft=3 else
		b"001" when runb=2 and rbzerosleft=4 else
		b"011" when runb=2 and rbzerosleft=5 else
		b"001" when runb=2 and rbzerosleft=6 else
		b"101" when runb=2 else
		b"000" when runb=3 and rbzerosleft=3 else
		b"001" when runb=3 and rbzerosleft=4 else
		b"010" when runb=3 and rbzerosleft=5 else
		b"011" when runb=3 and rbzerosleft=6 else
		b"100" when runb=3 else
		b"000" when runb=4 and rbzerosleft=4 else
		b"001" when runb=4 and rbzerosleft=5 else
		b"010" when runb=4 and rbzerosleft=6 else
		b"011" when runb=4 else
		b"000" when runb=5 and rbzerosleft=5 else
		b"101" when runb=5 and rbzerosleft=6 else
		b"010" when runb=5 else
		b"100" when runb=6 and rbzerosleft=6 else
		b"001"; --runb=6
	--
	READY <= not eenable;
	NOUT <= etotalcoeffs;
	--
process(CLK2)
begin
	if rising_edge(CLK2) then
		--reading subprocess
		--principle variables start 'e' so are separate pipeline stage from output
		--t1sign is used by output before overwritten here; likewise arrays
		if ENABLE='1' then
			eenable <= '1';
			emaxcoeffs <= emaxcoeffs + 1;	--this is a coefficient
			es <= SIN;
			if VIN /= 0 then
				etotalcoeffs <= etotalcoeffs + 1;	--total nz coefficients
				ecnz <= '1';						--we've seen a non-zero
				if VIN = 1 or VIN = x"FFF" then		-- 1 or -1
					if ecgt1 = '0' and etrailingones /= 3 then
						etrailingones <= etrailingones + 1;
						et1signs <= et1signs(1 downto 0) & VIN(11);	--encode sign
					end if;
				else
					ecgt1 <= '1';		--we've seen a greater-than-1
				end if;
				--put coeffs into array; put runs into array
				--coeff is coded as sign & abscoeff
				if VIN(11)='1' then
					coeffarray(conv_integer(eparity&eindex)) <= '1'&(b"00000000000"-VIN(10 downto 0));
				else
					coeffarray(conv_integer(eparity&eindex)) <= VIN;
				end if;
				runbarray(conv_integer(eparity&eindex)) <= erun;
				erun <= x"0";
				eindex <= eindex+1;
			elsif ecnz='1' then	--VIN=0 and ecnz
				etotalzeros <= etotalzeros + 1;		--totalzeros after first nz coeff
				erun <= erun + 1;
			end if;
			--select table for coeff_token (assume 4x4)
			if NIN < 2 then
				etable <= CTABLE0(1 downto 0);
			elsif NIN < 4 then
				etable <= CTABLE1(1 downto 0);
			elsif NIN < 8 then
				etable <= CTABLE2(1 downto 0);
			else
				etable <= CTABLE3(1 downto 0);
			end if;
		else -- ENABLE=0
			if hvalid='0' and eenable='1' then
				--transfer to holding stage
				hmaxcoeffs <= emaxcoeffs;
				htotalcoeffs <= etotalcoeffs;
				htotalzeros <= etotalzeros;
				htrailingones <= etrailingones;
				htable <= etable;
				hs <= es;
				t1signs <= et1signs;
				hparity <= eparity;
				hvalidi <= '1';
				assert emaxcoeffs=16 or emaxcoeffs=15 or emaxcoeffs=4 
					report "H264CAVLC: maxcoeffs is not a valid value" severity ERROR;
				--
				eenable <= '0';
				emaxcoeffs <= b"00000";
				etotalcoeffs <= b"00000";
				etotalzeros <= b"00000";
				etrailingones <= b"00";
				erun <= x"0";
				eindex <= x"0";
				ecnz <= '0';
				ecgt1 <= '0';
				eparity <= not eparity;
			end if;
		end if;
		if hvalid='1' and state=STATE_COEFFS and cindex > totalcoeffs(4 downto 1) and parity=hparity then
			--ok to clear holding register
			hvalidi <= '0';
		end if;
		hvalid <= hvalidi;	--delay 1 cycle to overcome CLK/CLK2 sync problems
	end if;
end process;
--
process(CLK)
	variable coeff : std_logic_vector(11 downto 0);
	variable tmpindex : std_logic_vector(4 downto 0);
begin
	if rising_edge(CLK) then
		-- maintain state
		if state = STATE_IDLE then
			VALID <= '0';
		end if;
		if (state=STATE_IDLE or (state=STATE_RUNBF and rbstate = '0')) and hvalid='1' then	--done read, start processing
			maxcoeffs <= hmaxcoeffs;
			totalcoeffs <= htotalcoeffs;
			totalzeros <= htotalzeros;
			trailingones <= htrailingones;
			parity <= hparity;
			if hmaxcoeffs=4 then
				ctable <= CTABLE4;	--special table for ChromaDC
				ztable <= '1';		--ditto
			else
				ctable <= '0'&htable;	--normal tables
				ztable <= '0';		--ditto
			end if;
			state <= STATE_CTOKEN;
			cindex <= b"00"&htrailingones;
			if htotalcoeffs>1 then
				rbstate <= '1';	--runbefore processing starts
			end if;
			rbindex <= x"2";
			tmpindex := hparity&x"1";
			runb <= runbarray(conv_integer(tmpindex));
			rbzerosleft <= htotalzeros;
			rbvl <= b"00000";
			rbve <= (others => '0');
		end if;
		if state = STATE_CTOKEN then
			if trailingones /= 0 then
				state <= STATE_T1SIGN;
			else
				state <= STATE_COEFFS;	--skip T1SIGN
			end if;
		end if;
		if state = STATE_T1SIGN then 
			state <= STATE_COEFFS;
		end if;
		if state = STATE_COEFFS and (cindex>=totalcoeffs or cindex=0) then
			if totalcoeffs/=maxcoeffs and totalcoeffs/=0 then
				state <= STATE_TZEROS;
			else
				state <= STATE_RUNBF;	--skip TZEROS
			end if;
		end if;
		if state = STATE_TZEROS then
			state <= STATE_RUNBF;
		end if;
		if state = STATE_RUNBF and rbstate = '1' then		--wait
			VALID <= '0';
		elsif state = STATE_RUNBF and rbstate = '0' then		--all done; reset and get ready to go again
			if hvalid='0' then
				state <= STATE_IDLE;
			end if;
			if rbvl /= 0 and totalzeros /= 0 then
				VALID <= '1';
				VE <= rbve;		--results of runbefore subprocessor
				VL <= rbvl;
			else
				VALID <= '0';
			end if;
		end if;
		--
		--
		--runbefore subprocess
		--uses rbzerosleft, runarray with rbstate,rbindex,runb
		--(runb=runarray(0) when it starts)(no effect if rbzerosleft=0)
		if rbstate = '1' then
			if runb <= 7 then	--normal processing
				runb <= runbarray(conv_integer(parity&rbindex));
				rbindex <= rbindex+1;
				if rbindex=totalcoeffs or rbzerosleft<=runb then
					rbstate <= '0';	--done
				end if;
				--runb is currently runbarray(rbindex-1), since rbindex not yet loaded
				if rbzerosleft + runb <= 2 then		--1 bit code
					rbve <= rbve(23 downto 0) & (not runb(0));
					rbvl <= rbvl + 1;
				elsif rbzerosleft + runb <= 6 then	--2 bit code
					rbve <= rbve(22 downto 0) & rbtoken(1 downto 0);
					rbvl <= rbvl + 2;
				elsif runb <= 6 then				--3 bit code
					rbve <= rbve(21 downto 0) & rbtoken(2 downto 0);
					rbvl <= rbvl + 3;
				else	--runb=7					--4bit code
					rbve <= rbve(20 downto 0) & b"0001";
					rbvl <= rbvl + 4;
				end if;
				rbzerosleft <= rbzerosleft-runb;
			else		--runb > 7, emit a zero and reduce counters by 1
				rbve <= rbve(23 downto 0) & b"0";
				rbvl <= rbvl + 1;
				rbzerosleft <= rbzerosleft-1;
				runb <= runb-1;
			end if;		
		end if;
		assert rbvl <= 25 report "rbve overflow";
		--
		-- output stuff...
		-- CTOKEN
		if state = STATE_CTOKEN then
			--output coeff_token based on (totalcoeffs,trailingones)
			VE <= x"0000" & b"000" & coeff_token;	--from tables above
			VL <= ctoken_len;
			VALID <= '1';
			VS <= hs;
			--setup for COEFFS (do it here 'cos T1SIGN may be skipped)
			--start at cindex=trailingones since we don't need to encode those
			coeff := coeffarray(conv_integer(parity&b"00"&trailingones));
			cindex <= (b"00"&trailingones) + 1;
			signcoeff <= coeff(11);
			abscoeff <= coeff(10 downto 0);
			if trailingones=3 then
				abscoeffa <= coeff(10 downto 0) - 1;	--normal case
			else
				abscoeffa <= coeff(10 downto 0) - 2;	--special case for t1s<3
			end if;
			if totalcoeffs>10 and trailingones/=3 then
				suffixlen <= b"001";	--start at 1
			else
				suffixlen <= b"000";	--start at zero (normal)
			end if;
		end if;
		-- T1SIGN
		if state = STATE_T1SIGN then
			assert trailingones /= 0 severity ERROR;
			VALID <= '1';
			VE <= x"00000" & b"00" & t1signs;
			VL <= b"000" & trailingones;
		end if;
		-- COEFFS
		-- uses suffixlen, lesstwo, coeffarray, abscoeff, signcoeff, cindex
		if state = STATE_COEFFS then
			--uses abscoeff, signcoeff loaded from array last time
			--if "lessone" then already applied to abscoeff
			--and +ve has 1 subtracted from it
			if suffixlen = 0 then
				--three sub-cases depending on size of abscoeff
				if abscoeffa < 7 then
					--normal, just levelprefix which is unary encoded
					VE <= '0'&x"000001";
					VL <= (abscoeffa(3 downto 0)&signcoeff) + 1;
				elsif abscoeffa < 15 then		--7..14
					--use level 14 with 4bit suffix
					--subtract 7 and use 3 bits of abscoeffa (same as add 1)
					VE <= '0'&x"00001" & (abscoeffa(2 downto 0)+1) & signcoeff;
					VL <= b"10011";	--14+1+4 = 19 bits
				else
					--use level 15 with 12bit suffix
					VE <= '0'&x"001" & (abscoeffa-15) & signcoeff;
					VL <= b"11100";	--15+1+12 = 28 bits
				end if;
				if abscoeff > 3 then
					suffixlen <= b"010";	--double increment
				else
					suffixlen <= b"001";	--always increment
				end if;
			else --suffixlen > 0: 1..6
				if (suffixlen=1 and abscoeffa < 15) then
					VE <= '0'&x"00000" & b"001" & signcoeff;
					VL <= abscoeffa(4 downto 0) + 2;
				elsif (suffixlen=2 and abscoeffa < 30) then
					VE <= '0'&x"00000" & b"01" & abscoeffa(0) & signcoeff;
					VL <= abscoeffa(5 downto 1) + 3;
				elsif (suffixlen=3 and abscoeffa < 60) then
					VE <= '0'&x"00000" & b"1" & abscoeffa(1 downto 0) & signcoeff;
					VL <= abscoeffa(6 downto 2) + 4;
				elsif (suffixlen=4 and abscoeffa < 120) then
					VE <= '0'&x"00001" & abscoeffa(2 downto 0) & signcoeff;
					VL <= abscoeffa(7 downto 3) + 5;
				elsif (suffixlen=5 and abscoeffa < 240) then
					VE <= '0'&x"0000" & b"001" & abscoeffa(3 downto 0) & signcoeff;
					VL <= abscoeffa(8 downto 4) + 6;
				elsif (suffixlen=6 and abscoeffa < 480) then
					VE <= '0'&x"0000" & b"01" & abscoeffa(4 downto 0) & signcoeff;
					VL <= abscoeffa(9 downto 5) + 7;
				elsif suffixlen=1 then			--use level 15 with 12bit suffix, VLC1
					VE <= '0'&x"001" & (abscoeffa-15) & signcoeff;
					VL <= b"11100";	--15+1+12 = 28 bits
				elsif suffixlen=2 then			--use level 15 with 12bit suffix, VLC2
					VE <= '0'&x"001" & (abscoeffa-30) & signcoeff;
					VL <= b"11100";	--15+1+12 = 28 bits
				elsif suffixlen=3 then			--use level 15 with 12bit suffix, VLC3
					VE <= '0'&x"001" & (abscoeffa-60) & signcoeff;
					VL <= b"11100";	--15+1+12 = 28 bits
				elsif suffixlen=4 then			--use level 15 with 12bit suffix, VLC4
					VE <= '0'&x"001" & (abscoeffa-120) & signcoeff;
					VL <= b"11100";	--15+1+12 = 28 bits
				elsif suffixlen=5 then			--use level 15 with 12bit suffix, VLC5
					VE <= '0'&x"001" & (abscoeffa-240) & signcoeff;
					VL <= b"11100";	--15+1+12 = 28 bits
				else			--use level 15 with 12bit suffix, VLC6
					VE <= '0'&x"001" & (abscoeffa-480) & signcoeff;
					VL <= b"11100";	--15+1+12 = 28 bits
				end if;
				if (suffixlen=1 and abscoeff > 3) or
				   (suffixlen=2 and abscoeff > 6) or
				   (suffixlen=3 and abscoeff > 12) or
				   (suffixlen=4 and abscoeff > 24) or
				   (suffixlen=5 and abscoeff > 48) then
					suffixlen <= suffixlen + 1;
				end if;
			end if;
			if cindex<=totalcoeffs and totalcoeffs /= 0 then
				VALID <= '1';
			else
				VALID <= '0';
			end if;
			--next coeff
			coeff := coeffarray(conv_integer(parity&cindex));
			signcoeff <= coeff(11);
			abscoeff <= coeff(10 downto 0);
			abscoeffa <= coeff(10 downto 0) - 1;
			cindex <= cindex+1;
		end if;
		-- TZEROS
		if state = STATE_TZEROS then
			assert totalcoeffs/=maxcoeffs and totalcoeffs/=0 severity ERROR;
			VALID <= '1';
			VE <= x"00000" & b"00" & ztoken;
			VL <= b"0" & ztoken_len;
		end if;
		--
	end if;
end process;
	--
end hw;

