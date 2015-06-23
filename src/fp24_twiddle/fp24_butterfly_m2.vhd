-------------------------------------------------------------------------------
--
-- Title       : fp24_butterfly_m2
-- Design      : fp24fftk
-- Author      : Kapitanov
-- Company     :
--
-- Description : FP24 butterfly
--
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--		(c) Copyright 2015 													 
--		Kapitanov.                                          				 
--		All rights reserved.                                                 
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use work.fp24_m2_pkg.all;

package fp24_butterfly_m2_pkg is
	component fp24_butterfly_m2 is
		port(
			IA 		: in complex_fp24;
			IB 		: in complex_fp24;
			DIN_EN 	: in std_logic;
			WW 		: in complex_fp24;
			OA 		: out complex_fp24;
			OB 		: out complex_fp24;
			DOUT_VAL: out std_logic;			
			RESET  	: in std_logic;
			CLK 	: in std_logic	
		);
	end component;
end package;
								  
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.math_real.all;

use work.fp24_m2_pkg.all;

entity fp24_butterfly_m2 is
	port(
		IA 		: in complex_fp24;
		IB 		: in complex_fp24;
		DIN_EN 	: in std_logic;
		WW 		: in complex_fp24;
		OA 		: out complex_fp24;
		OB 		: out complex_fp24;
		DOUT_VAL: out std_logic;			
		RESET  	: in std_logic;
		CLK 	: in std_logic	
	);
end fp24_butterfly_m2;

architecture fp24_butterfly_m2 of fp24_butterfly_m2 is

type complex_fp24_array_22 is array(21 downto 0) of complex_fp24;

signal sum 			: complex_fp24; 
signal dif 			: complex_fp24;
signal sob 			: complex_fp24;

signal re_x_re 		: std_logic_vector(23 downto 0);
signal im_x_im 		: std_logic_vector(23 downto 0);
signal re_x_im 		: std_logic_vector(23 downto 0);
signal im_x_re 		: std_logic_vector(23 downto 0);

signal sum_del 		: complex_fp24_array_22;
signal dval_en		: std_logic_vector(2 downto 0);

begin

add_sub_re: fp24_addsub_m2 
	port map(
	aa 		=> ia.re, 
	bb 		=> ib.re, 
	cc_add	=> sum.re, 
	cc_sub	=> dif.re, 
	enable 	=> DIN_EN, --din_en,
	valid 	=> dval_en(0),
	reset  	=> reset, 
	clk 	=> clk 
	);
add_sub_im: fp24_addsub_m2 
	port map(
	aa 		=> ia.im, 
	bb 		=> ib.im, 
	cc_add	=> sum.im, 
	cc_sub	=> dif.im, 
	enable 	=> DIN_EN, --din_en, 
	reset  	=> reset, 
	clk 	=> clk 
	);

re_re_mul : fp24_mult_m2
	port map (
		aa => dif.re,
		bb => ww.re,
		cc => re_x_re,
		enable => dval_en(0), --din_en,
		reset => reset,
		clk => clk
	);
im_im_mul : fp24_mult_m2
	port map (
		aa => dif.im,
		bb => ww.im,
		cc => im_x_im,
		enable => dval_en(0), --din_en,
		reset => reset,
		clk => clk
	);
re_im_mul : fp24_mult_m2
	port map (
		aa => dif.re,
		bb => ww.im,
		cc => re_x_im,
		enable => dval_en(0), --din_en,
		reset => reset,
		clk => clk
	);
im_re_mul : fp24_mult_m2
	port map (
		aa => dif.im,
		bb => ww.re,
		cc => im_x_re,
		enable => dval_en(0), --din_en,
		valid => dval_en(1),
		reset => reset,
		clk => clk
	);
		
ob_re_sub: fp24_sub_m2 
	port map(
	aa 		=> re_x_re, 		
	bb 		=> im_x_im, 		
	cc 		=> sob.re, --ob.re,		
	enable 	=> dval_en(1), --din_en, 	
	valid 	=> dval_en(2),
	reset  	=> reset,  	
	clk 	=> clk 	
	);

ob_im_add: fp24_add_m2 
	port map(
	aa 		=> re_x_im, 		
	bb 		=> im_x_re, 		
	cc 		=> sob.im, --ob.im,		
	enable 	=> dval_en(1), --din_en, 	
	reset  	=> reset,  	
	clk 	=> clk 	
	);

pr_sumdel: process(clk) is
begin
	if rising_edge(clk) then
		sum_del <= sum_del(20 downto 0) & sum after 1 ns;
	end if;
end process;

	oa		 <=	sum_del(21);
	ob		 <=	sob;
	dout_val <= dval_en(2);

end fp24_butterfly_m2;