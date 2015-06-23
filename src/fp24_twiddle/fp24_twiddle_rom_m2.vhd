-------------------------------------------------------------------------------
--
-- Title       : fp24_twiddle_rom_m2
-- Design      : fp24fftk
-- Author      : Kapitanov
-- Company     :
--
-------------------------------------------------------------------------------
--
-- Description : version 2.0 
--
-- TWIDDLE FACTOR for FFT
-- 4 COE BLOCKS
--				 
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--		(c) Copyright 2015 													 
--		Kapitanov.                                          				 
--		All rights reserved.                                                 
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;

use work.fp24_m2_pkg.complex_fp24;

package	fp24_twiddle_rom_m2_pkg	is
	component fp24_twiddle_rom_m2 is
		generic(
			stages		: integer:=16;
			ii 			: integer:=0
		);
		port(
			ww			: out complex_fp24;
			clk 		: in std_logic;
			coe_enable 	: in std_logic;
			reset  		: in std_logic
		);
	end component;
end package;

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_unsigned.all;

use work.fp24_coe_rom_m2_pkg.all;
use work.fp24_coe_teylor_m2_pkg.all;
use work.fp24_m2_pkg.complex_fp24;

entity fp24_twiddle_rom_m2 is
	generic(
		stages		: integer:=16;
		ii 			: integer:=0
	);
	port(
		ww			: out complex_fp24;
		clk 		: in std_logic;
		coe_enable 	: in std_logic;
		reset  		: in std_logic
	);
end fp24_twiddle_rom_m2;


architecture fp24_twiddle_rom_m2 of fp24_twiddle_rom_m2 is 

begin 
	
	l_rom_gen: if (stages-ii > 12) generate
	begin
		coe_rom: fp24_coe_teylor_m2 
			generic map(
				
				stages		=> stages,
				stage_num 	=> ii
			)
			port map(
				ww			=> ww,
				clk 		=> clk,
				enable 		=> coe_enable,
				reset  		=> reset
			); 		
	end generate;
	
	m_rom_gen_v0: if (stages-ii <= 12) generate	-- 10 !!!
	begin
		coe_rom: fp24_coe_rom_m2 
			generic map(
				stages		=> 12, -- 10 !!!
				stage_num 	=> stages-1-ii
			)
			port map(
				ww			=> ww,
				clk 		=> clk,
				enable 		=> coe_enable,
				reset  		=> reset
			);					
	end generate;		

end fp24_twiddle_rom_m2;