-------------------------------------------------------------------------
-- H264 inverse core transform - VHDL
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

-- This is the inverse core transform for H264, without quantisation
-- this acts on a 4x4 matrix

-- This conforms to the H.264:2003 standard paragraph 8.5.8 precisely

-- the intermediate matrix D is placeholder for the input coeffs
-- row E and matrix F is the result of first pair of computations
-- row G and output is result of second pair of computations
-- F00 is x=0,y=0,  FF01 is x=1 etc

-- F and D are largely the same matrix because we can reuse the space (not done!! UNF use alias)
-- other than up to 5 coeffs on input worst case

-- Input: WIN the input matrix X at time TT..TT+15
-- 16 beats of clock output W in reverse zigzag order (than pause of 4 clk min)
-- Outputs: XOUT the output matrix  TT+2 to
-- 4 beats of clock horizontal rows; 4 x 9bit residuals each row; little endian order.

-- XST: old: 409 slices; 149 MHz; Xpower 20mW @ 120MHz

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.ALL;

entity h264invtransform is
	port (
		CLK : in std_logic;					--fast io clock
		ENABLE : in std_logic;				--values input only when this is 1
		WIN : in std_logic_vector(15 downto 0);	--input (reverse zigzag order)
		VALID : out std_logic := '0';				--values output only when this is 1
		XOUT : out std_logic_vector(39 downto 0):= (others => '0')	--4 x 10bit, first px is lsbs
	);
end h264invtransform;

architecture hw of h264invtransform is
	--
	--index to the d and f are (y first) as per std d and f
	signal d01 : std_logic_vector(15 downto 0) := (others => '0');
	signal d02 : std_logic_vector(15 downto 0) := (others => '0');
	signal d03 : std_logic_vector(15 downto 0) := (others => '0');
	signal d11 : std_logic_vector(15 downto 0) := (others => '0');
	signal d12 : std_logic_vector(15 downto 0) := (others => '0');
	signal d13 : std_logic_vector(15 downto 0) := (others => '0');
	signal d21 : std_logic_vector(15 downto 0) := (others => '0');
	signal d22 : std_logic_vector(15 downto 0) := (others => '0');
	signal d23 : std_logic_vector(15 downto 0) := (others => '0');
	signal d31 : std_logic_vector(15 downto 0) := (others => '0');
	signal d32 : std_logic_vector(15 downto 0) := (others => '0');
	signal d33 : std_logic_vector(15 downto 0) := (others => '0');
	signal e0 : std_logic_vector(15 downto 0) := (others => '0');
	signal e1 : std_logic_vector(15 downto 0) := (others => '0');
	signal e2 : std_logic_vector(15 downto 0) := (others => '0');
	signal e3 : std_logic_vector(15 downto 0) := (others => '0');
	signal f00 : std_logic_vector(15 downto 0) := (others => '0');
	signal f01 : std_logic_vector(15 downto 0) := (others => '0');
	signal f02 : std_logic_vector(15 downto 0) := (others => '0');
	signal f03 : std_logic_vector(15 downto 0) := (others => '0');
	signal f10 : std_logic_vector(15 downto 0) := (others => '0');
	signal f11 : std_logic_vector(15 downto 0) := (others => '0');
	signal f12 : std_logic_vector(15 downto 0) := (others => '0');
	signal f13 : std_logic_vector(15 downto 0) := (others => '0');
	signal f20 : std_logic_vector(15 downto 0) := (others => '0');
	signal f21 : std_logic_vector(15 downto 0) := (others => '0');
	signal f22 : std_logic_vector(15 downto 0) := (others => '0');
	signal f23 : std_logic_vector(15 downto 0) := (others => '0');
	signal f30 : std_logic_vector(15 downto 0) := (others => '0');
	signal f31 : std_logic_vector(15 downto 0) := (others => '0');
	signal f32 : std_logic_vector(15 downto 0) := (others => '0');
	signal f33 : std_logic_vector(15 downto 0) := (others => '0');
	signal g0 : std_logic_vector(15 downto 0) := (others => '0');
	signal g1 : std_logic_vector(15 downto 0) := (others => '0');
	signal g2 : std_logic_vector(15 downto 0) := (others => '0');
	signal g3 : std_logic_vector(15 downto 0) := (others => '0');
	signal h00 : std_logic_vector(9 downto 0) := (others => '0');
	signal h01 : std_logic_vector(9 downto 0) := (others => '0');
	signal h02 : std_logic_vector(9 downto 0) := (others => '0');
	signal h10 : std_logic_vector(9 downto 0) := (others => '0');
	signal h11 : std_logic_vector(9 downto 0) := (others => '0');
	signal h12 : std_logic_vector(9 downto 0) := (others => '0');
	signal h13 : std_logic_vector(9 downto 0) := (others => '0');
	signal h20 : std_logic_vector(9 downto 0) := (others => '0');
	signal h21 : std_logic_vector(9 downto 0) := (others => '0');
	signal h22 : std_logic_vector(9 downto 0) := (others => '0');
	signal h23 : std_logic_vector(9 downto 0) := (others => '0');
	signal h30 : std_logic_vector(9 downto 0) := (others => '0');
	signal h31 : std_logic_vector(9 downto 0) := (others => '0');
	signal h32 : std_logic_vector(9 downto 0) := (others => '0');
	signal h33 : std_logic_vector(9 downto 0) := (others => '0');
	signal hx0 : std_logic_vector(15 downto 0) := (others => '0');
	signal hx1 : std_logic_vector(15 downto 0) := (others => '0');
	signal hx2 : std_logic_vector(15 downto 0) := (others => '0');
	signal hx3 : std_logic_vector(15 downto 0) := (others => '0');
	--
	signal iww : std_logic_vector(3 downto 0) := b"0000";
	signal ixx : std_logic_vector(3 downto 0) := b"0000";
	--
	alias xout0 : std_logic_vector(9 downto 0) is XOUT(9 downto 0);
	alias xout1 : std_logic_vector(9 downto 0) is XOUT(19 downto 10);
	alias xout2 : std_logic_vector(9 downto 0) is XOUT(29 downto 20);
	alias xout3 : std_logic_vector(9 downto 0) is XOUT(39 downto 30);
begin
	--
process(CLK)
	variable d00 : std_logic_vector(15 downto 0) := (others => '0');
	variable d10 : std_logic_vector(15 downto 0) := (others => '0');
	variable d20 : std_logic_vector(15 downto 0) := (others => '0');
	variable d30 : std_logic_vector(15 downto 0) := (others => '0');
	variable h0 : std_logic_vector(15 downto 0) := (others => '0');
	variable h1 : std_logic_vector(15 downto 0) := (others => '0');
	variable h2 : std_logic_vector(15 downto 0) := (others => '0');
	variable h3 : std_logic_vector(15 downto 0) := (others => '0');
	variable h03 : std_logic_vector(9 downto 0) := (others => '0');
begin
	if rising_edge(CLK) then
		if ENABLE='1' or iww /= 0 then
			iww <= iww + 1;
		end if;
		if iww=15 or ixx /= 0 then
			ixx <= ixx + 1;
		end if;
	end if;
	if rising_edge(CLK) then
		--input: in reverse zigzag order
		if iww = 0 then
			d33 <= WIN;	--ROW3&COL3;
		elsif iww = 1 then
			d32 <= WIN;	--ROW3&COL2 
		elsif iww = 2 then
			d23 <= WIN;	--ROW2&COL3 
		elsif iww = 3 then
			d13 <= WIN;	--ROW1&COL3 
		elsif iww = 4 then
			d22 <= WIN;	--ROW2&COL2 
		elsif iww = 5 then
			d31 <= WIN;	--ROW3&COL1 
		elsif iww = 6 then
			d30 := WIN;	--ROW3&COL0
			e0 <= d30 + d32;	--process ROW3
			e1 <= d30 - d32;
			e2 <= (d31(15)&d31(15 downto 1)) - d33;
			e3 <= d31 + (d33(15)&d33(15 downto 1));
		elsif iww = 7 then
			f30 <= e0 + e3;
			f31 <= e1 + e2;
			f32 <= e1 - e2;
			f33 <= e0 - e3;
			d21 <= WIN;	--ROW2&COL1 
		elsif iww = 8 then
			d12 <= WIN;	--ROW1&COL2 
		elsif iww = 9 then
			d03 <= WIN;	--ROW0&COL3
		elsif iww = 10 then
			d02 <= WIN;	--ROW0&COL2
		elsif iww = 11 then
			d11 <= WIN;	--ROW1&COL1 
		elsif iww = 12 then
			d20 := WIN;	--ROW2&COL0 
			e0 <= d20 + d22;	--process ROW2
			e1 <= d20 - d22;
			e2 <= (d21(15)&d21(15 downto 1)) - d23;
			e3 <= d21 + (d23(15)&d23(15 downto 1));
		elsif iww = 13 then
			f20 <= e0 + e3;
			f21 <= e1 + e2;
			f22 <= e1 - e2;
			f23 <= e0 - e3;
			d10 := WIN;	--ROW1&COL0
			e0 <= d10 + d12;	--process ROW1
			e1 <= d10 - d12;
			e2 <= (d11(15)&d11(15 downto 1)) - d13;
			e3 <= d11 + (d13(15)&d13(15 downto 1));
		elsif iww = 14 then
			f10 <= e0 + e3;
			f11 <= e1 + e2;
			f12 <= e1 - e2;
			f13 <= e0 - e3;
			d01 <= WIN;	--ROW0&COL1
		elsif iww = 15 then
			d00 := WIN;	--ROW0&COL0
			e0 <= d00 + d02;	--process ROW1
			e1 <= d00 - d02;
			e2 <= (d01(15)&d01(15 downto 1)) - d03;
			e3 <= d01 + (d03(15)&d03(15 downto 1));
		end if;
		--output stages (immediately after input stage 15)
		if ixx = 1 then
			f00 <= e0 + e3;	--complete input stage
			f01 <= e1 + e2;
			f02 <= e1 - e2;
			f03 <= e0 - e3;
		elsif ixx = 2 then
			g0 <= f00 + f20;		--col 0
			g1 <= f00 - f20;
			g2 <= (f10(15)&f10(15 downto 1)) - f30;
			g3 <= f10 + (f30(15)&f30(15 downto 1));
		elsif ixx = 3 then
			h0 := (g0 + g3) + 32;	--32 is rounding factor
			h1 := (g1 + g2) + 32;
			h2 := (g1 - g2) + 32;
			h3 := (g0 - g3) + 32;
			h00 <= h0(15 downto 6);
			h10 <= h1(15 downto 6);
			h20 <= h2(15 downto 6);
			h30 <= h3(15 downto 6);
			--VALID <= '1';
			g0 <= f01 + f21;		--col 1
			g1 <= f01 - f21;
			g2 <= (f11(15)&f11(15 downto 1)) - f31;
			g3 <= f11 + (f31(15)&f31(15 downto 1));
			--XOUT <= (see above)
		elsif ixx = 4 then
			h0 := (g0 + g3) + 32;	--32 is rounding factor
			h1 := (g1 + g2) + 32;
			h2 := (g1 - g2) + 32;
			h3 := (g0 - g3) + 32;
			h01 <= h0(15 downto 6);
			h11 <= h1(15 downto 6);
			h21 <= h2(15 downto 6);
			h31 <= h3(15 downto 6);
			g0 <= f02 + f22;		--col 2
			g1 <= f02 - f22;
			g2 <= (f12(15)&f12(15 downto 1)) - f32;
			g3 <= f12 + (f32(15)&f32(15 downto 1));
		elsif ixx = 5 then
			h0 := (g0 + g3) + 32;	--32 is rounding factor
			h1 := (g1 + g2) + 32;
			h2 := (g1 - g2) + 32;
			h3 := (g0 - g3) + 32;
			h02 <= h0(15 downto 6);
			h12 <= h1(15 downto 6);
			h22 <= h2(15 downto 6);
			h32 <= h3(15 downto 6);
			g0 <= f03 + f23;		--col 3
			g1 <= f03 - f23;
			g2 <= (f13(15)&f13(15 downto 1)) - f33;
			g3 <= f13 + (f33(15)&f33(15 downto 1));
		elsif ixx = 6 then
			h0 := (g0 + g3) + 32;	--32 is rounding factor
			h1 := (g1 + g2) + 32;
			h2 := (g1 - g2) + 32;
			h3 := (g0 - g3) + 32;
			h03 := h0(15 downto 6);
			h13 <= h1(15 downto 6);
			h23 <= h2(15 downto 6);
			h33 <= h3(15 downto 6);
			VALID <= '1';
			xout0 <= h00;
			xout1 <= h01;
			xout2 <= h02;
			xout3 <= h03;
		elsif ixx=7 then
			xout0 <= h10;
			xout1 <= h11;
			xout2 <= h12;
			xout3 <= h13;
		elsif ixx=8 then
			xout0 <= h20;
			xout1 <= h21;
			xout2 <= h22;
			xout3 <= h23;
		elsif ixx=9 then
			xout0 <= h30;
			xout1 <= h31;
			xout2 <= h32;
			xout3 <= h33;
		elsif ixx=10 then
			VALID <= '0';
		end if;
		hx0 <= h0;--DEBUG
		hx1 <= h1;
		hx2 <= h2;
		hx3 <= h3;
	end if;
end process;
	--
end hw; --of h264invtransform;
