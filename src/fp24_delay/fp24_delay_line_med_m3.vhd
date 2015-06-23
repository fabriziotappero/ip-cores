-------------------------------------------------------------------------------
--
-- Title       : fp24_delay_line_med_m3
-- Design      : fp24fftk
-- Author      : Kapitanov
-- Company     :
--
-------------------------------------------------------------------------------
--
-- Description : version 3.0 
--
-------------------------------------------------------------------------------
--
--	Version 1.0  01.04.2015
--			   	 Description: delay line on SRLC32E, stages: 16 (always), stage_num: [4:8]
--								Summary: 6 delay lines with 2^N delay width.
--				 				Fully pipelined.
-- 
--	Version 1.0  01.04.2015
--				 				Xilinx SHIFT REG from COREGEN used.
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
use work.fp24_m2_pkg.complex_fp24;

package	fp24_delay_line_med_m3_pkg is
	component fp24_delay_line_med_m3 is
		generic(
			stages 		: integer:=16;
			stage_num 	: integer:=14
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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all; 

use work.fp24_delay_med_pkg.all;
use work.fp24_m2_pkg.complex_fp24;

entity fp24_delay_line_med_m3 is
	generic(
		stages 		: integer:=16;
		stage_num 	: integer:=14
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
end fp24_delay_line_med_m3;

architecture fp24_delay_line_med_m3 of fp24_delay_line_med_m3 is

constant stage_num_inv	: integer:=stages-stage_num-2;

signal cnt_wrcr			: std_logic_vector(stage_num_inv downto 0);	 -- (9 downto 0);
signal cross			: std_logic;
signal din_en_del		: std_logic_vector(2**(stage_num_inv)-1 downto 0);
signal din_del0			: std_logic_vector(47 downto 0);
signal dout_del0    	: std_logic_vector(47 downto 0);
signal din_del1			: std_logic_vector(47 downto 0);
signal dout_del1    	: std_logic_vector(47 downto 0);
signal oa_e				: complex_fp24;
signal ob_e				: complex_fp24;				

signal rstn				: std_logic;

begin
 
rstn <= not reset;	
	
pr_din0: process(clk, reset) is
begin
	if reset = '0' then					
		din_del0 <=	(others => '0');
	elsif rising_edge(clk) then
		if din_en = '1' then
			din_del0 <=	ib.im  & ib.re after 1 ns;
		else
			null;
		end if;	
	end if;
end process; 

pr_cnt_wrcr: process(clk, reset) is
begin
	if reset = '0' then 
		cnt_wrcr <= (others => '0' );
	elsif rising_edge(clk) then
		if din_en = '1' then
			cnt_wrcr <= cnt_wrcr + '1' after 1 ns;
		else
			null;
		end if;	
	end if;
end process;


pr_ena: process(clk, reset) is
begin
	if reset = '0' then
		din_en_del <= (others => '0');
	elsif rising_edge(clk) then
		din_en_del <= din_en_del(2**(stage_num_inv)-2 downto 0) & din_en after 1 ns;
	end if;
end process;

pr_ob: process(clk, reset) is
begin
	if reset = '0' then		
		ob_e		<= (others => (others => '0'));
	elsif rising_edge(clk) then		
		if din_en_del(2**(stage_num_inv)-1) = '1' then
			if cross = '1' then
				ob_e.re		<= ia.re after 1 ns;   			
				ob_e.im		<= ia.im after 1 ns; 
			else
				ob_e.re		<= dout_del0(23 downto 0) after 1 ns; 			
				ob_e.im		<= dout_del0(47 downto 24) after 1 ns;
			end if;
		end if;
	end if;
end process;  

pr_oa: process(clk, reset) is
begin
	if reset = '0' then		
		oa_e		<= (others => (others => '0'));
	elsif rising_edge(clk) then		
		if din_en_del(2**(stage_num_inv)-1) = '1' then
			oa_e.re	<=	dout_del1(23 downto 0) after 1 ns;
			oa_e.im	<=	dout_del1(47 downto 24) after 1 ns;
		end if;
	end if;
end process;

pr_din1: process(clk, reset) is
begin
	if reset = '0' then		
		din_del1	<= (others => '0');
	elsif rising_edge(clk) then
		if cross = '1' then
			din_del1	<= dout_del0 after 1 ns; 
		else
			din_del1	<= ia.im  & ia.re after 1 ns; 
		end if;			
	end if;
end process; 

oa	<=	oa_e;
ob	<=	ob_e; 
cross <= cnt_wrcr(stage_num_inv);
dout_val <= din_en_del(2**(stage_num_inv)-1) after 1 ns when rising_edge(clk);

------------------------------------------------
---------------- SHIFT REGISTERS ---------------
------------------------------------------------
gen_grt6: if (stage_num_inv = 6) generate
	del0_re: fp24_sh24x64r
	  port map(
	    d 		=> din_del0(23 downto 0),
	    clk 	=> clk,
	    ce 		=> '1',
	    sclr 	=> rstn,
	    q 		=> dout_del0(23 downto 0)
	  );
	del0_im: fp24_sh24x64r
	  port map(
	    d 		=> din_del0(47 downto 24),
	    clk 	=> clk,
	    ce 		=> '1',
	    sclr 	=> rstn,
	    q 		=> dout_del0(47 downto 24)
	  );	  
	  
	del1_re: fp24_sh24x64r
	  port map(
	    d 		=> din_del1(23 downto 0),
	    clk 	=> clk,
	    ce 		=> '1',
	    sclr 	=> rstn,
	    q 		=> dout_del1(23 downto 0)
	  );
	del1_im: fp24_sh24x64r
	  port map(
	    d 		=> din_del1(47 downto 24),
	    clk 	=> clk,
	    ce 		=> '1',
	    sclr 	=> rstn,
	    q 		=> dout_del1(47 downto 24)
	  );	
end generate;

gen_grt7: if (stage_num_inv = 7) generate
	del0_re: fp24_sh24x128r
	  port map(
	    d 		=> din_del0(23 downto 0),
	    clk 	=> clk,
	    ce 		=> '1',
	    sclr 	=> rstn,
	    q 		=> dout_del0(23 downto 0)
	  );
	del0_im: fp24_sh24x128r
	  port map(
	    d 		=> din_del0(47 downto 24),
	    clk 	=> clk,
	    ce 		=> '1',
	    sclr 	=> rstn,
	    q 		=> dout_del0(47 downto 24)
	  );	  
	  
	del1_re: fp24_sh24x128r
	  port map(
	    d 		=> din_del1(23 downto 0),
	    clk 	=> clk,
	    ce 		=> '1',
	    sclr 	=> rstn,
	    q 		=> dout_del1(23 downto 0)
	  );
	del1_im: fp24_sh24x128r
	  port map(
	    d 		=> din_del1(47 downto 24),
	    clk 	=> clk,
	    ce 		=> '1',
	    sclr 	=> rstn,
	    q 		=> dout_del1(47 downto 24)
	  );	
end generate;

gen_grt8: if (stage_num_inv = 8) generate
	del0_re: fp24_sh24x256r
	  port map(
	    d 		=> din_del0(23 downto 0),
	    clk 	=> clk,
	    ce 		=> '1',
	    sclr 	=> rstn,
	    q 		=> dout_del0(23 downto 0)
	  );
	del0_im: fp24_sh24x256r
	  port map(
	    d 		=> din_del0(47 downto 24),
	    clk 	=> clk,
	    ce 		=> '1',
	    sclr 	=> rstn,
	    q 		=> dout_del0(47 downto 24)
	  );	  
	  
	del1_re: fp24_sh24x256r
	  port map(
	    d 		=> din_del1(23 downto 0),
	    clk 	=> clk,
	    ce 		=> '1',
	    sclr 	=> rstn,
	    q 		=> dout_del1(23 downto 0)
	  );
	del1_im: fp24_sh24x256r
	  port map(
	    d 		=> din_del1(47 downto 24),
	    clk 	=> clk,
	    ce 		=> '1',
	    sclr 	=> rstn,
	    q 		=> dout_del1(47 downto 24)
	  );	
end generate;

gen_grt9: if (stage_num_inv = 9) generate
	del0_re: fp24_sh24x512r
	  port map(
	    d 		=> din_del0(23 downto 0),
	    clk 	=> clk,
	    ce 		=> '1',
	    sclr 	=> rstn,
	    q 		=> dout_del0(23 downto 0)
	  );
	del0_im: fp24_sh24x512r
	  port map(
	    d 		=> din_del0(47 downto 24),
	    clk 	=> clk,
	    ce 		=> '1',
	    sclr 	=> rstn,
	    q 		=> dout_del0(47 downto 24)
	  );	  
	  
	del1_re: fp24_sh24x512r
	  port map(
	    d 		=> din_del1(23 downto 0),
	    clk 	=> clk,
	    ce 		=> '1',
	    sclr 	=> rstn,
	    q 		=> dout_del1(23 downto 0)
	  );
	del1_im: fp24_sh24x512r
	  port map(
	    d 		=> din_del1(47 downto 24),
	    clk 	=> clk,
	    ce 		=> '1',
	    sclr 	=> rstn,
	    q 		=> dout_del1(47 downto 24)
	  );	
end generate;

gen_grt10: if (stage_num_inv = 10) generate
	del0_re: fp24_sh24x1kr
	  port map(
	    d 		=> din_del0(23 downto 0),
	    clk 	=> clk,
	    ce 		=> '1',
	    sclr 	=> rstn,
	    q 		=> dout_del0(23 downto 0)
	  );
	del0_im: fp24_sh24x1kr
	  port map(
	    d 		=> din_del0(47 downto 24),
	    clk 	=> clk,
	    ce 		=> '1',
	    sclr 	=> rstn,
	    q 		=> dout_del0(47 downto 24)
	  );	  
	  
	del1_re: fp24_sh24x1kr
	  port map(
	    d 		=> din_del1(23 downto 0),
	    clk 	=> clk,
	    ce 		=> '1',
	    sclr 	=> rstn,
	    q 		=> dout_del1(23 downto 0)
	  );
	del1_im: fp24_sh24x1kr
	  port map(
	    d 		=> din_del1(47 downto 24),
	    clk 	=> clk,
	    ce 		=> '1',
	    sclr 	=> rstn,
	    q 		=> dout_del1(47 downto 24)
	  );	
end generate;
------------------------------------------------
end fp24_delay_line_med_m3;