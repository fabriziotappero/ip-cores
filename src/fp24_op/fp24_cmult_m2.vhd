--------------------------------------------------------------------------------
--
-- Title       : fp24_cmult_m2
-- Design      : fp24fftk
-- Author      : Kapitanov
-- Company     :
--
-- Description : FP complex multiplier = 24;
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
use ieee.std_logic_unsigned.all; 

use work.fp24_m2_pkg.all;

entity fp24_cmult_m2 is
	port(
		aa 		: in complex_fp24;
		bb 		: in complex_fp24;
		cc 		: out complex_fp24;
		enable 	: in std_logic;
		reset  	: in std_logic;
		clk 	: in std_logic;
		dout_v	: out std_logic
	);	
end fp24_cmult_m2; 

architecture fp24_cmult_m2 of fp24_cmult_m2 is 

signal re_x_re		: std_logic_vector(23 downto 0);
signal im_x_im 		: std_logic_vector(23 downto 0);
signal re_x_im		: std_logic_vector(23 downto 0);
signal im_x_re		: std_logic_vector(23 downto 0);
signal cct			: complex_fp24;

signal valid		: std_logic;
signal valm			: std_logic;

SIGNAL c_re			: complex_m;
SIGNAL c_im			: complex_m;

begin
	
re_re_mul : fp24_mult_m2
	port map (
		aa => aa.re,
		bb => bb.re,
		cc => re_x_re,
		enable => enable,
		valid => valm,
		reset => reset,
		clk => clk
	);
im_im_mul : fp24_mult_m2
	port map (
		aa => aa.im,
		bb => bb.im,
		cc => im_x_im,
		enable => enable,
		reset => reset,
		clk => clk
	);
re_im_mul : fp24_mult_m2
	port map (
		aa => aa.re,
		bb => bb.im,
		cc => re_x_im,
		enable => enable,
		reset => reset,
		clk => clk
	);
im_re_mul : fp24_mult_m2
	port map (
		aa => aa.im,
		bb => bb.re,
		cc => im_x_re,
		enable => enable,
		reset => reset,
		clk => clk
	);				   
	
--------------------------------		
ob_re_sub: fp24_sub_m2 
	port map(
		aa 		=> re_x_re, 		
		bb 		=> im_x_im, 		
		cc 		=> cct.re, 	
		enable 	=> valm,
		valid 	=> valid,
		reset  	=> reset,  	
		clk 	=> clk 	
	);

ob_im_add: fp24_add_m2 
	port map(
		aa 		=> re_x_im, 		
		bb 		=> im_x_re, 		
		cc 		=> cct.im, 	
		enable 	=> valm, 	
		reset  	=> reset,  	
		clk 	=> clk 	
	);
	
c_re <= flt_decode(cct.re) after 1 ns when rising_edge(clk);	
c_im <= flt_decode(cct.im) after 1 ns when rising_edge(clk);

cc <= cct after 1 ns when rising_edge(clk); 
dout_v <= valid after 1 ns when rising_edge(clk);

end fp24_cmult_m2;
