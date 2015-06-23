-------------------------------------------------------------------------------
--
-- Title       : fp24_delay_line_m2
-- Design      : fp24fftk
-- Author      : Kapitanov
-- Company     :
--
-------------------------------------------------------------------------------
--
-- Description : version 2.0 
--
-------------------------------------------------------------------------------
--
--	Version 1.0  01.11.2013
--			   	 Description: delay line: consist 3 different delay_lines by using RAMB36E1 and Shift-reg on LUTs
--
--	Version 2.0  01.04.2015
--			   	 Fully pipelined.
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
use ieee.std_logic_arith.all;

use work.fp24_m2_pkg.complex_fp24;

package	fp24_delay_line_m2_pkg is
	component fp24_delay_line_m2 is
		generic(
			stages 		: integer:=16;
			stage_num 	: integer:=0
		);
		port(
			ia 		: in complex_fp24;
			ib 		: in complex_fp24;
			din_en 	: in std_logic;
			oa 		: out complex_fp24;
			ob 		: out complex_fp24;
			dout_val: out std_logic;
			reset  	: in std_logic;
			clk 	: in std_logic	
		);	
	end component;
end package;


library ieee;
use ieee.std_logic_1164.all;

use work.fp24_m2_pkg.complex_fp24;
use work.fp24_delay_line_short_m2_pkg.all;
use work.fp24_delay_line_med_m3_pkg.all;
use work.fp24_delay_line_long_m3_pkg.all;

entity fp24_delay_line_m2 is
	generic(
		stages 		: integer:=16;
		stage_num 	: integer:=0
	);
	port(
			ia 		: in complex_fp24;
			ib 		: in complex_fp24;
			din_en 	: in std_logic;
			oa 		: out complex_fp24;
			ob 		: out complex_fp24;
			dout_val: out std_logic;
			reset  	: in std_logic;
			clk 	: in std_logic	
	);	
end fp24_delay_line_m2;

architecture fp24_delay_line_m2 of fp24_delay_line_m2 is

begin	

gen_short: if (stages-stage_num) < 8 generate		
	delay_line_short:	fp24_delay_line_short_m2  
		generic map(
			stages		=> stages, 
			stage_num 	=> stage_num 
		)
		port map(
			ia 			=> ia, 		
			ib 			=> ib, 		
			din_en		=> din_en,	
			oa 			=> oa, 		
			ob 			=> ob, 		
			dout_val	=> dout_val,
			reset  		=> reset,  	
			clk 		=> clk 	
		);
end generate; 

gen_med: if ((((stages-stage_num)>=8) and ((stages-stage_num)<13))) generate    	  
	delay_line_med:		fp24_delay_line_med_m3 
		generic map(
			stages		=> stages, 
			stage_num 	=> stage_num 
		)
		port map(
			ia 			=> ia, 		
			ib 			=> ib, 		
			din_en		=> din_en,	
			oa 			=> oa, 		
			ob 			=> ob, 		
			dout_val	=> dout_val,
			reset  		=> reset,  	
			clk 		=> clk 	    
		);
end generate; 

gen_long: if (stages-stage_num) >= 13 generate     				 
	delay_line_long:	fp24_delay_line_long_m3 
		generic map(
			stages		=> stages, 
			stage_num 	=> stage_num 
		)
		port map(
			ia 			=> ia, 		
			ib 			=> ib, 		
			din_en		=> din_en,	
			oa 			=> oa, 		
			ob 			=> ob, 		
			dout_val	=> dout_val,
			reset  		=> reset,  	
			clk 		=> clk 	    
		);
end generate;
	
end fp24_delay_line_m2;
