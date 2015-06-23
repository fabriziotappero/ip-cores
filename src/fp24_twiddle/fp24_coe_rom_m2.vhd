-------------------------------------------------------------------------------
--
-- Title       : fp24_coe_rom_m2
-- Design      : fp24fftk
-- Author      : Kapitanov
-- Company     :
--
-------------------------------------------------------------------------------
--
-- Description : version 1.0 
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

package	fp24_coe_rom_m2_pkg	is
	component fp24_coe_rom_m2 is
		generic(
			stages		: integer:=10;
			stage_num 	: integer:=0
		);
		port(
			ww			: out complex_fp24;
			clk 		: in std_logic;
			enable 		: in std_logic;
			reset  		: in std_logic
		);
	end component;
end package;

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;

use work.fp24_rambq_init_m1_pkg.all;  
use work.fp24_rambq_init_m2_pkg.all; 
use work.fp24_rambq_init_m3_pkg.all;
use work.fp24_rambq_init_m4_pkg.all;
use work.fp24_m2_pkg.complex_fp24;

entity fp24_coe_rom_m2 is
	generic(
		stages		: integer:=10;
		stage_num 	: integer:=0
	);
	port(
		ww			: out complex_fp24;
		clk 		: in std_logic;
		enable 		: in std_logic;
		reset  		: in std_logic
	);
end fp24_coe_rom_m2;


architecture fp24_coe_rom_m2 of fp24_coe_rom_m2 is 

signal rstn		: std_logic;
signal doa  	: std_logic_vector(47 downto 0);

signal addr 	: std_logic_vector(stage_num-2 downto 0);
signal cnt		: std_logic_vector(stage_num-1 downto 0);

signal negative : std_logic;

begin
	
rstn <= not reset;

pr_cnt: process(clk, reset) is
begin
	if reset = '0' then
		cnt	<=	(others	=>	'0');
	elsif rising_edge(clk) then
		if enable = '1' then
			cnt <= cnt + '1' after 1 ns;
		end if;	
	end if;
end process;	

x_gen_m0: if (stage_num < 2) generate
	
	x_gen_neg0: if stage_num = 0 generate
		negative <= '0'; 
	end generate;
	x_gen_neg: if stage_num = 1 generate
		negative <= cnt(0) after 1 ns;
	end generate;
	
	pr_ww: process(clk, reset) is
	begin
		if reset = '0' then
			ww.im	<=	(others	=>	'0');
			ww.re	<=	(others	=>	'0');
		elsif rising_edge(clk) then
			if negative = '0' then
				ww.re	<= doa(23 downto 00) after 1 ns;
				ww.im	<= doa(47 downto 24) after 1 ns; 
			else
				ww.im	<= doa(23 downto 17) & not doa(16) & doa(15 downto 0) after 1 ns; 
				ww.re	<= doa(47 downto 41) & not doa(40) & doa(39 downto 24) after 1 ns;
			end if;
		end if;
	end process;
	
	rom_coe: fp24_rambq_init_m4 
		port map(
	   		doa  	=>	doa,
			clk  	=>	clk	
	    ); 		
end generate;

x_gen_m1: if (stage_num >= 2) and (stage_num < 6) generate
	
	pr_ww: process(clk, reset) is
	begin
		if reset = '0' then
			ww.im	<=	(others	=>	'0');
			ww.re	<=	(others	=>	'0');
		elsif rising_edge(clk) then
			if negative = '0' then
				ww.re	<= doa(23 downto 00) after 1 ns;
				ww.im	<= doa(47 downto 24) after 1 ns; 
			else
				ww.im	<= doa(23 downto 17) & not doa(16) & doa(15 downto 0) after 1 ns; 
				ww.re	<= doa(47 downto 24) after 1 ns;
			end if;
		end if;
	end process;	
	
	negative <= cnt(stage_num-1) after 1 ns;

	addr <= cnt(stage_num-2 downto 0);
	
	rom_coe: fp24_rambq_init_m3 
		generic map ( 
			sliceM_addr => stage_num	
		    )
		port map(
	   		doa  	=>	doa,
		    addra 	=>	addr(stage_num-2 downto 0),
			clk  	=>	clk	
	    );  	
end generate;

x_gen_m2: if (stage_num >= 6) and (stage_num < 10) generate
	
	pr_ww: process(clk, reset) is
	begin
		if reset = '0' then
			ww.im	<=	(others	=>	'0');
			ww.re	<=	(others	=>	'0');
		elsif rising_edge(clk) then
			if negative = '0' then
				ww.re	<= doa(23 downto 00) after 1 ns;
				ww.im	<= doa(47 downto 24) after 1 ns; 
			else
				ww.im	<= doa(23 downto 17) & not doa(16) & doa(15 downto 0) after 1 ns; 
				ww.re	<= doa(47 downto 24) after 1 ns;
			end if;
		end if;
	end process;	
	
	negative <= cnt(stage_num-1) after 1 ns;
	
	addr <= cnt(stage_num-2 downto 0);

	rom_coe: fp24_rambq_init_m2 
		generic map ( 
			sliceM_addr => stage_num	
		    )
		port map(
	   		doa  	=>	doa,
		    addra 	=>	addr(stage_num-2 downto 0),
			clk  	=>	clk	
	    );  				
end generate;

x_gen_m3: if (stage_num >= 10) and (stage_num < 12) generate
	
	signal addrx : std_logic_vector(stage_num-1 downto 0);

	begin
	negative <= cnt(stage_num-1) after 1 ns when rising_edge(clk);
	addr <= cnt(stage_num-2 downto 0);
	
	xgen10: if (stage_num = 10) generate	
		addrx(stage_num-1 downto 1) <= addr(stage_num-2 downto 0);
		addrx(0) <= '0';
	end generate;
	xgen11: if (stage_num = 11) generate
		addrx(stage_num-1) <= '0';
		addrx(stage_num-2 downto 0) <= addr;
	end generate;	
	
	rom_coe: fp24_rambq_init_m1
	  generic map (
	    fp_teylor => false
	  )
	  port map(
	    doa  	=> doa,  		
	    addra 	=> addrx(9 downto 0),  		
	    addrb 	=> (others=>'0'),  
	    clka  	=> clk,  			
	    clkb  	=> clk,  			
	    dia   	=> (others=>'0'),  
	    dib   	=> (others=>'0'),    
	    ena   	=> '1', --enable,  		
	    enb   	=> '0',  			
	    ssra  	=> rstn,  			
	    ssrb  	=> '0',  			
	    wea   	=> '0',  			
	    web   	=> '0'  			
	); 		
	
	ww.im	<= doa(47 downto 24) after 1 ns when negative = '0' else doa(23 downto 17) & not doa(16) & doa(15 downto 0) after 1 ns; 
	ww.re	<= doa(23 downto 00) after 1 ns when negative = '0' else doa(47 downto 24) after 1 ns;  	
end generate;

end fp24_coe_rom_m2;
