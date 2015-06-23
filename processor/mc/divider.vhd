-- ==============================================================================
-- Generic signed/unsigned restoring divider 
-- 
-- This library is free software; you can redistribute it and/or modify it 
-- under the terms of the GNU Lesser General Public License as published 
-- by the Free Software Foundation; either version 2.1 of the License, or 
-- (at your option) any later version.
-- 
-- This library is distributed in the hope that it will be useful, but WITHOUT
-- ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
-- FITNESS FOR A PARTICULAR PURPOSE.   See the GNU Lesser General Public 
-- License for more details.   See http://www.gnu.org/copyleft/lesser.txt
-- 
-- ------------------------------------------------------------------------------
-- Version   Author          Date          Changes
-- 0.1       Hans Tiggeler   07/18/02      Tested on Modelsim SE 5.6
-- ==============================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity divider is
  GENERIC(WIDTH_DIVID : Integer := 32;			  -- Width Dividend
  		  WIDTH_DIVIS : Integer := 16);			  -- Width Divisor
   port(dividend  : in     std_logic_vector (WIDTH_DIVID-1 downto 0);
      	divisor   : in     std_logic_vector (WIDTH_DIVIS-1 downto 0);
      	quotient  : out    std_logic_vector (WIDTH_DIVID-1 downto 0);
      	remainder : out    std_logic_vector (WIDTH_DIVIS-1 downto 0);
      	twocomp   : in     std_logic);			  -- '1' = 2's Complement, 
end divider ;      								  -- '0' = Unsigned
											   

architecture rtl of divider is
	type stdarray	is array(WIDTH_DIVID downto 0) of std_logic_vector(WIDTH_DIVIS downto 0);
	signal addsub_s   	: stdarray;
   signal dividend_s 	: std_logic_vector(WIDTH_DIVID-1 downto 0);
   signal didi_s		: std_logic_vector(WIDTH_DIVID-1 downto 0);	
   signal divisor_s  	: std_logic_vector(WIDTH_DIVIS downto 0);	 
   signal disi_s 		: std_logic_vector(WIDTH_DIVIS downto 0);	
	signal divn_s     	: std_logic_vector(WIDTH_DIVIS downto 0);
	signal div_s     	: std_logic_vector(WIDTH_DIVIS downto 0);
   signal signquot_s   : std_logic;
	signal signremain_s : std_logic;	
   signal remain_s     : std_logic_vector(WIDTH_DIVIS+1 downto 0); 
	signal remainder_s  : std_logic_vector(WIDTH_DIVIS+1 downto 0); 
	signal quot_s       : std_logic_vector(WIDTH_DIVID-1 downto 0);
	signal quotient_s   : std_logic_vector(WIDTH_DIVID-1 downto 0);
begin
	--  Sign Quotient
	signquot_s    <= (dividend(WIDTH_DIVID-1) xor divisor(WIDTH_DIVIS-1)) and twocomp;
	
	--  Sign Remainder
	signremain_s  <= (signquot_s xor divisor(WIDTH_DIVIS-1)) and twocomp;

	--  Rectify Dividend   	
	didi_s <= not(dividend) when (dividend(WIDTH_DIVID-1) and twocomp)='1' else dividend;
	dividend_s <= didi_s + (dividend(WIDTH_DIVID-1) and twocomp);

	--  Rectify Divisor  	
	disi_s <= not('1'&divisor)  when (divisor(WIDTH_DIVIS-1) and twocomp)='1'  else ('0'&divisor);
	divisor_s  <= disi_s + (divisor(WIDTH_DIVIS-1) and twocomp);

	--  Create 2-Complement negative divisor
   divn_s <= not(divisor_s) + '1';

	--  Positive Divisor
	div_s  <= divisor_s;

	-- Note first stage dividend_s(WIDTH_DIVID-1) is always '0'
	addsub_s(WIDTH_DIVID) <= divn_s;

	stages : for i in WIDTH_DIVID-1 downto 0 generate
		addsub_s(i) <= ((addsub_s(i+1)(WIDTH_DIVIS-1 downto 0) & dividend_s(i)) + div_s) when addsub_s(i+1)(WIDTH_DIVIS)='1' else
			((addsub_s(i+1)(WIDTH_DIVIS-1 downto 0) & dividend_s(i)) + divn_s);
	end generate;

	remain_s <= ((addsub_s(0)(WIDTH_DIVIS)&addsub_s(0)) + ('0'&div_s)) when addsub_s(0)(WIDTH_DIVIS)='1' else '0'&addsub_s(0);

	-- Quotient
	outstage : for i in WIDTH_DIVID-1 downto 0 generate
		quot_s(i)  <= not(addsub_s(i)(WIDTH_DIVIS));
	end generate;

	remainder_s <= ((not(remain_s)) + '1') when signremain_s='1' else remain_s;	 	-- correct remainder sign

	quotient_s 	<= ((not(quot_s)) + '1') when signquot_s='1' else quot_s;			-- correct quotient sign

	remainder	<= remainder_s(WIDTH_DIVIS-1 downto 0) when twocomp='1' else 
		(remainder_s(WIDTH_DIVIS-1 downto 0)+remainder_s(WIDTH_DIVIS+1));

	quotient    <= quotient_s;
end rtl;