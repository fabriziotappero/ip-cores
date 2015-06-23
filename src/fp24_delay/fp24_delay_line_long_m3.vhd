-------------------------------------------------------------------------------
--
-- Title       : fp24_delay_line_long_m3
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
--	Version 1.1  14.01.2015
--			   	 Description: delay line on RAMB16_S9_S9, stages: 16 (always), stage_num: [0:3]
--								Summary: 6 delay lines with 2^N delay width.
--
--								Changelog: added LOOP statements for data path
--
--	Version 2.0  19.01.2015
--			   	 Changelog: RAMB16_SXX PRIMITIVE USED (REDUCED BRAM LOGIC) !!
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

package	fp24_delay_line_long_m3_pkg is
	component fp24_delay_line_long_m3 is
		generic(
			stages		: integer:=16;
			stage_num 	: integer:=3
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

use work.fp24_m2_pkg.complex_fp24;
--use work.ramb_init0_pkg.all;

entity fp24_delay_line_long_m3 is
	generic(
		stages		: integer:=16;
		stage_num 	: integer:=3
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
end fp24_delay_line_long_m3;

architecture fp24_delay_line_long_m3 of fp24_delay_line_long_m3 is 

constant stage_num_inv: integer:=stages-stage_num-2; 

constant Narr		: integer:=2**(stage_num+16-stages);	-- array ramb
constant Nwidth		: integer:=6*(2**(stages-13-stage_num));


signal rstn			: std_logic;
signal cnt_wr 		: std_logic_vector(stage_num_inv downto 0);	
signal cnt_wrcr		: std_logic_vector(stage_num_inv downto 0);
signal addr			: std_logic_vector(stages-3-stage_num downto 0); 
signal addr1		: std_logic_vector(stages-3-stage_num downto 0); 
signal addrs		: std_logic_vector(stages-3-stage_num downto 0); 
signal addrs1		: std_logic_vector(stages-3-stage_num downto 0);
signal addrz		: std_logic_vector(stages-3-stage_num downto 0); 
signal addrz1		: std_logic_vector(stages-3-stage_num downto 0);

signal cross		: std_logic;
signal ob_e			: complex_fp24;
signal ob_z			: complex_fp24;	

signal iaz 			: std_logic_vector(47 downto 0);
signal ia_ze		: complex_fp24;
signal dir_cross	: std_logic;
signal dir_dia		: complex_fp24;
signal dir_dob		: complex_fp24;
signal obz			: complex_fp24;	  

signal oa_e			: complex_fp24;	
signal we			: std_logic;
signal we1			: std_logic;
signal wes			: std_logic;
signal wes1			: std_logic;
signal wez			: std_logic;
signal wez1			: std_logic;
signal val			: std_logic;

type std_logic_array_NarrxNwidth is array (Nwidth-1 downto 0) of std_logic_vector(Narr-1 downto 0);	

signal dob0			: std_logic_array_NarrxNwidth;
signal dob1			: std_logic_array_NarrxNwidth;
signal ram0_din		: std_logic_array_NarrxNwidth;
signal ram1_din		: std_logic_array_NarrxNwidth;
signal ram0_dout	: std_logic_vector(47 downto 0);
signal ram1_dout	: std_logic_vector(47 downto 0);

signal ib_reim		: std_logic_vector(47 downto 0);

signal del_i		: std_logic_vector(0 downto 0);
signal del_o		: std_logic_vector(0 downto 0);
signal cntd			: std_logic_vector(stages-3-stage_num downto 0);
signal addrd		: std_logic_vector(13 downto 0);
signal din_enz		: std_logic;

begin
 
rstn <= not reset;

din_enz <= din_en after 1 ns when rising_edge(clk);	
we	<=	din_en after 1 ns when rising_edge(clk);
we1	<=	del_o(0) after 1 ns;
wez	<=	we after 1 ns when rising_edge(clk);
wez1 <=	we1 after 1 ns when rising_edge(clk); 
wes	<=	wez after 1 ns when rising_edge(clk);
wes1 <=	wez1 after 1 ns when rising_edge(clk); 

addr(stage_num_inv-1 downto 0)	<= cnt_wrcr(stage_num_inv-1 downto 0);-- after 1 ns when rising_edge(clk);
addr(10 downto stage_num_inv)	<= (others => '0');
addr1(stage_num_inv-1 downto 0)	<= cnt_wr(stage_num_inv-1 downto 0);
addr1(10 downto stage_num_inv)	<= (others => '0');
addrz <= addr after 1 ns when rising_edge(clk);
addrz1 <= addr1 after 1 ns when rising_edge(clk);	
addrs <= addrz after 1 ns when rising_edge(clk);
addrs1 <= addrz1 after 1 ns when rising_edge(clk);

pr_cnt_wrcr: process(clk, reset) is
begin
	if reset = '0' then 
		cnt_wrcr <= (others => '0' );
	elsif rising_edge(clk) then
		if din_enz = '1' then
			cnt_wrcr <= cnt_wrcr + '1' after 1 ns;
		else
			null;
		end if;	
	end if;
end process;
cross <= cnt_wrcr(stage_num_inv) after 1 ns when rising_edge(clk);	
dir_cross <= cross after 1 ns when rising_edge(clk); 	

pr_cnt_wr: process(clk, reset) is
begin
	if reset = '0' then 
		cnt_wr <= (others => '0' );
	elsif rising_edge(clk) then
		if del_o(0) = '1' then
			cnt_wr <= cnt_wr + '1' after 1 ns;
		else
			null;
		end if;			
	end if;
end process;

del_i(0) <= din_en; --after 1 ns when rising_edge(clk);
test: process(clk, reset) is
begin
	if reset = '0' then 	 
		cntd <= (others => '0');
	elsif rising_edge(clk) then	
	   	cntd <= cntd + '1' after 1 ns;
	end if;
end process;
addrd(stage_num_inv-1 downto 0)	<= cntd(stage_num_inv-1 downto 0);
addrd(13 downto stage_num_inv)	<= (others => '0' );

val <= wes1 after 1 ns when rising_edge(clk);
dout_val <= val after 1 ns when rising_edge(clk);
	
	
ib_reim <= ib.im(23 downto 0) & ib.re(23 downto 0);-- after 1 ns when rising_edge(clk);

pr_din: process(clk, reset) is
begin
	if reset = '0' then		
		ram0_din <= (others => (others => '0'));
		ram1_din <= (others => (others => '0'));
	elsif rising_edge(clk) then
		ia_ze	<= ia after 1 ns;
		iaz <= ia_ze.im & ia_ze.re after 1 ns;

		if din_en = '1' then
			for ii in 0 to Nwidth-1 loop
				ram0_din(ii)(Narr-1 downto 0) <= ib_reim((Narr-1)+Narr*ii downto Narr*ii) after 1 ns;	
			end loop;		
		else
			null;
		end if;	
		
		if cross = '1'  then
			for ii in 0 to Nwidth-1 loop
				ram1_din(ii)(Narr-1 downto 0) <= ram0_dout((Narr-1)+Narr*ii downto Narr*ii) after 1 ns;	
			end loop;
		else
			for ii in 0 to Nwidth-1 loop
				ram1_din(ii)(Narr-1 downto 0) <= iaz((Narr-1)+Narr*ii downto Narr*ii) after 1 ns;	
			end loop;				
		end if;	 
	end if;
end process; 


pr_oa: process(clk, reset) is
begin
	if reset = '0' then		
		oa_e <= (others => (others => '0'));
	elsif rising_edge(clk) then		
		oa_e.re	<=	ram1_dout(23 downto 0) after 1 ns;
		oa_e.im	<=	ram1_dout(47 downto 24) after 1 ns;
	end if;
end process;

pr_ob: process(clk, reset) is
begin
	if reset = '0' then		
		ob_e <= (others => (others => '0'));
	elsif rising_edge(clk) then		
		if cross = '1' then
			ob_e <= dir_dia after 1 ns;   			
		else
			ob_e <= dir_dob after 1 ns; 			
		end if;
	end if;
end process;

dir_dia.re	<= iaz(23 downto 0);
dir_dia.im	<= iaz(47 downto 24);
dir_dob.re	<= ram0_dout(23 downto 0);		
dir_dob.im	<= ram0_dout(47 downto 24);		


oa	<=	oa_e;
ob_z <= ob_e after 1 ns when rising_edge(clk);
ob	<=	ob_z after 1 ns when rising_edge(clk);
---------------- ramb16 init ----------------
x_stage13: if stages-stage_num = 13 generate
	ram0: for ii in 0 to 5 generate 
		ramb0: ramb16_s9_s9
		generic	map(
	    WRITE_MODE_A => "READ_FIRST",
	    WRITE_MODE_B => "READ_FIRST"
		)
	  port map(
	    dob  	=> dob0(ii)(7 downto 0),  			
	    addra 	=> addr(10 downto 0),	 		
	    addrb 	=> addr1(10 downto 0),	 
	    clka  	=> clk,  			
	    clkb  	=> clk,  			
	    dia   	=> ram0_din(ii)(7 downto 0),  
	    dib   	=> (others => '0'),      
	    dipa  	=> (others => '0'),--ram0_din(ii)(17 downto 16), 
		dipb  	=> (others => '0'),
	    ena   	=> we,   		
	    enb   	=> we1,   			
	    ssra  	=> rstn,  			
	    ssrb  	=> rstn,  			
	    wea   	=> '1', 			
	    web   	=> '0'  			
	    );
		
		ram0_dout(7+8*ii downto ii*8) <= dob0(ii)(7 downto 0); 
	end generate;	
	
	ram1: for ii in 0 to 5 generate 
		ramb1: ramb16_s9_s9
		generic	map(
	    WRITE_MODE_A => "READ_FIRST",
	    WRITE_MODE_B => "READ_FIRST"
		)
	  port map(
	    dob  	=> dob1(ii)(7 downto 0),  						
	    addra 	=> addrs,	 		
	    addrb 	=> addrs1,	 
	    clka  	=> clk,  			
	    clkb  	=> clk,  			
	    dia   	=> ram1_din(ii)(7 downto 0),  
	    dib   	=> (others => '0'),      
	    dipa  	=> (others => '0'),--ram1_din(ii)(17 downto 16), 
		dipb  	=> (others => '0'),
	    ena   	=> wes,   		
	    enb   	=> wes1,   			
	    ssra  	=> rstn,  			
	    ssrb  	=> rstn,  			
	    wea   	=> '1', 			
	    web   	=> '0'  			
	    ); 
		
		ram1_dout(7+8*ii downto ii*8) <= dob1(ii)(7 downto 0);	
	end generate; 
	
	ramb_del: ramb16_s1_s1
	  generic map(
	    WRITE_MODE_A => "READ_FIRST",
	    WRITE_MODE_B => "READ_FIRST"
		)
	  port map(
	    dob  	=> del_o,  			
	    addra 	=> addrd,	 		
	    addrb 	=> addrd,	 
	    clka  	=> clk,  			
	    clkb  	=> clk,  			
	    dia   	=> del_i,  
	    dib   	=> (others => '0'),      
	    ena   	=> '1',   		
	    enb   	=> '1',   			
	    ssra  	=> rstn,  			
	    ssrb  	=> rstn,  			
	    wea   	=> '1', 			
	    web   	=> '0'  			
	    );	
end generate;

x_stage14: if stages-stage_num = 14 generate
	ram0: for ii in 0 to 11 generate 
		ramb0: ramb16_s4_s4
		generic	map(
	    WRITE_MODE_A => "READ_FIRST",
	    WRITE_MODE_B => "READ_FIRST"
		)
	  port map(
	    dob  	=> dob0(ii)(3 downto 0),  			
	    addra 	=> addr,	 		
	    addrb 	=> addr1,	 
	    clka  	=> clk,  			
	    clkb  	=> clk,  			
	    dia   	=> ram0_din(ii)(3 downto 0),  
	    dib   	=> (others => '0'),      
	    ena   	=> we,   		
	    enb   	=> we1,   			
	    ssra  	=> rstn,  			
	    ssrb  	=> rstn,  			
	    wea   	=> '1', 			
	    web   	=> '0'  			
	    );
		
		ram0_dout(3+4*ii downto ii*4) <= dob0(ii)(3 downto 0); 
	end generate;	
	
	ram1: for ii in 0 to 11 generate 
		ramb1: ramb16_s4_s4
		generic	map(
	    WRITE_MODE_A => "READ_FIRST",
	    WRITE_MODE_B => "READ_FIRST"
		)
	  port map(
	    dob  	=> dob1(ii)(3 downto 0),  						
	    addra 	=> addrs,	 		
	    addrb 	=> addrs1,	 
	    clka  	=> clk,  			
	    clkb  	=> clk,  			
	    dia   	=> ram1_din(ii)(3 downto 0),  
	    dib   	=> (others => '0'),      
	    ena   	=> wes,   		
	    enb   	=> wes1,   			
	    ssra  	=> rstn,  			
	    ssrb  	=> rstn,  			
	    wea   	=> '1', 			
	    web   	=> '0'  			
	    );
		
		ram1_dout(3+4*ii downto ii*4) <= dob1(ii)(3 downto 0);	
	end generate;  
	
	ramb_del: ramb16_s1_s1
	  generic map(
	    WRITE_MODE_A => "READ_FIRST",
	    WRITE_MODE_B => "READ_FIRST"
		)
	  port map(
	    dob  	=> del_o,  			
	    addra 	=> addrd,	 		
	    addrb 	=> addrd,	 
	    clka  	=> clk,  			
	    clkb  	=> clk,  			
	    dia   	=> del_i,  
	    dib   	=> (others => '0'),      
	    ena   	=> '1',   		
	    enb   	=> '1',   			
	    ssra  	=> rstn,  			
	    ssrb  	=> rstn,  			
	    wea   	=> '1', 			
	    web   	=> '0'  			
	    );	
end generate;

x_stage15: if stages-stage_num = 15 generate
	ram0: for ii in 0 to 23 generate 
		ramb0: ramb16_s2_s2
		generic	map(
	    WRITE_MODE_A => "READ_FIRST",
	    WRITE_MODE_B => "READ_FIRST"
		)
	  port map(
	    dob  	=> dob0(ii)(1 downto 0),  			
	    addra 	=> addr,	 		
	    addrb 	=> addr1,	 
	    clka  	=> clk,  			
	    clkb  	=> clk,  			
	    dia   	=> ram0_din(ii)(1 downto 0),  
	    dib   	=> (others => '0'),      
	    ena   	=> we,   		
	    enb   	=> we1,   			
	    ssra  	=> rstn,  			
	    ssrb  	=> rstn,  			
	    wea   	=> '1', 			
	    web   	=> '0'  			
	    );
		
		ram0_dout(1+2*ii downto ii*2) <= dob0(ii)(1 downto 0); 
	end generate;	
	
	ram1: for ii in 0 to 23 generate 
		ramb1: ramb16_s2_s2
		generic	map(
	    WRITE_MODE_A => "READ_FIRST",
	    WRITE_MODE_B => "READ_FIRST"
		)
	  port map(
	    dob  	=> dob1(ii)(1 downto 0),  						
	    addra 	=> addrs,	 		
	    addrb 	=> addrs1,	 
	    clka  	=> clk,  			
	    clkb  	=> clk,  			
	    dia   	=> ram1_din(ii)(1 downto 0),  
	    dib   	=> (others => '0'),      
	    ena   	=> wes,   		
	    enb   	=> wes1,   			
	    ssra  	=> rstn,  			
	    ssrb  	=> rstn,  			
	    wea   	=> '1', 			
	    web   	=> '0'  			
	    );
		
		ram1_dout(1+2*ii downto ii*2) <= dob1(ii)(1 downto 0);	
	end generate;

	ramb_del: ramb16_s1_s1
	  generic map(
	    WRITE_MODE_A => "READ_FIRST",
	    WRITE_MODE_B => "READ_FIRST"
		)
	  port map(
	    dob  	=> del_o,  			
	    addra 	=> addrd,	 		
	    addrb 	=> addrd,	 
	    clka  	=> clk,  			
	    clkb  	=> clk,  			
	    dia   	=> del_i,  
	    dib   	=> (others => '0'),      
	    ena   	=> '1',   		
	    enb   	=> '1',   			
	    ssra  	=> rstn,  			
	    ssrb  	=> rstn,  			
	    wea   	=> '1', 			
	    web   	=> '0'  			
	    );	
end generate;

x_stage16: if stages-stage_num = 16 generate
	ram0: for ii in 0 to 47 generate 
		ramb0: ramb16_s1_s1
		generic	map(
	    WRITE_MODE_A => "READ_FIRST",
	    WRITE_MODE_B => "READ_FIRST"
		)
	  port map(
	    dob  	=> dob0(ii)(0 downto 0),  			
	    addra 	=> addr,	 		
	    addrb 	=> addr1,	 
	    clka  	=> clk,  			
	    clkb  	=> clk,  			
	    dia   	=> ram0_din(ii)(0 downto 0),  
	    dib   	=> (others => '0'),      
	    ena   	=> we,   		
	    enb   	=> we1,   			
	    ssra  	=> rstn,  			
	    ssrb  	=> rstn,  			
	    wea   	=> '1', 			
	    web   	=> '0'  			
	    );
		
		ram0_dout(ii downto ii) <= dob0(ii)(0 downto 0); 
	end generate;	
	
	ram1: for ii in 0 to 47 generate 
		ramb1: ramb16_s1_s1
		generic	map(
	    WRITE_MODE_A => "READ_FIRST",
	    WRITE_MODE_B => "READ_FIRST"
		)
	  port map(
	    dob  	=> dob1(ii)(0 downto 0),  						
	    addra 	=> addrs,	 		
	    addrb 	=> addrs1,	 
	    clka  	=> clk,  			
	    clkb  	=> clk,  			
	    dia   	=> ram1_din(ii)(0 downto 0),  
	    dib   	=> (others => '0'),      
	    ena   	=> wes,   		
	    enb   	=> wes1,   			
	    ssra  	=> rstn,  			
	    ssrb  	=> rstn,  			
	    wea   	=> '1', 			
	    web   	=> '0'  			
	    );
		
		ram1_dout(ii downto ii) <= dob1(ii)(0 downto 0);	
	end generate;
	
	ramb_del: ramb16_s1_s1
	  generic map(
	    WRITE_MODE_A => "READ_FIRST",
	    WRITE_MODE_B => "READ_FIRST"
		)
	  port map(
	    dob  	=> del_o,  			
	    addra 	=> addrd,	 		
	    addrb 	=> addrd,	 
	    clka  	=> clk,  			
	    clkb  	=> clk,  			
	    dia   	=> del_i,  
	    dib   	=> (others => '0'),      
	    ena   	=> '1',   		
	    enb   	=> '1',   			
	    ssra  	=> rstn,  			
	    ssrb  	=> rstn,  			
	    wea   	=> '1', 			
	    web   	=> '0'  			
	    );	
end generate;
--ram0_dout <=  dopb0(5) & dob0(47 downto 40) & dopb0(4) & dob0(39 downto 32) & dopb0(3) & dob0(31 downto 24) & dopb0(2) & dob0(23 downto 16) & dopb0(1) & dob0(15 downto 8) & dopb0(0) & dob0(7 downto 0);  
--ram1_dout <=  dopb1(5) & dob1(47 downto 40) & dopb1(4) & dob1(39 downto 32) & dopb1(3) & dob1(31 downto 24) & dopb1(2) & dob1(23 downto 16) & dopb1(1) & dob1(15 downto 8) & dopb1(0) & dob1(7 downto 0);  
------------------------------------------------	
end fp24_delay_line_long_m3;
