-------------------------------------------------------------------------------
--
-- Title       : fp24_FFT_logic
-- Design      : fp24fftk
-- Author      : Kapitanov
-- Company     :
--
-- Description : FP logic
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
library unisim;
use unisim.vcomponents.all;	
use work.fp24_m2_pkg.all; 

use ieee.std_logic_arith.all;
use ieee.math_real.all;

use ieee.std_logic_textio.all;
use std.textio.all;	

use work.fp24_float2fix_m1_pkg.all;

entity fp24_fft_ifft_logic_test is 
	port(	
		
		d0 			: out complex_fp24;
		d1 			: out complex_fp24;		
		d_val		: out std_logic
		
		);
end fp24_fft_ifft_logic_test;

architecture fp24_fft_ifft_logic_test of fp24_fft_ifft_logic_test is   		  

component fp24_fbro_v0 
	port(	
		reset		: in std_logic;  	
		clk			: in std_logic;
		
		d0_in		: in complex_fp24;
		d_ena		: in std_logic;
		
		d0_out 		: out complex_fp24;
		d1_out		: out complex_fp24;
		d_val		: out std_logic
		);			
end component;

component fp24_fft_ifft_logic
	generic(
		stages	: integer :=16);
	port(	
		reset		: in std_logic;  	
		--clk			: in std_logic;

		aclk		: in std_logic;
		gclk		: in std_logic;
		start 		: in std_logic;
		
		fix_float	: in std_logic;
	
		of_re		: in std_logic_vector(15 downto 0);
		of_im		: in std_logic_vector(15 downto 0);	
		of_en		: in std_logic;
		of_rw		: in std_logic;		
		
		d0_re		: in std_logic_vector(15 downto 0);
		d0_im		: in std_logic_vector(15 downto 0);
		d1_re		: in std_logic_vector(15 downto 0);
		d1_im		: in std_logic_vector(15 downto 0);
		
		d0 			: out complex_fp24;
		d1 			: out complex_fp24;		
		d_val		: out std_logic
	);
end component; 

component fp24_float2fix_m2 is
	port(
		din				: in std_logic_vector(26 downto 0);	
		dout			: out std_logic_vector(31 downto 0);
		--enable			: in std_logic;
		clk				: in std_logic;
		reset			: in std_logic;
		din_en			: in std_logic;                       
		scale			: in std_logic_vector(9 downto 0);    
		dout_val		: out std_logic;                      
		overflow		: out std_logic                                        			
	);
end component;

-- ******************************** --
-- CHANGE STAGES TO EDIT FFT TEST!! --
constant stages : integer:=16; 
-- ******************************** --	
-- CHANGE: 0 - FFT, 1 - NONE YET
signal fix_float: std_logic:='0';  
-- ******************************** --
constant Nst	: integer:=2**(stages-1); 
constant Nst2x	: integer:=2**(stages);
-- ******************************** --

signal clk		: std_logic:='0';
signal reset	: std_logic:='0';
signal aclk		: std_logic:='0';
signal gclk		: std_logic:='0';
signal start	: std_logic:='0';


signal d0_re	: std_logic_vector(15 downto 0):=x"0000"; 
signal d0_im	: std_logic_vector(15 downto 0):=x"0000"; 
signal d1_re	: std_logic_vector(15 downto 0):=x"0000"; 
signal d1_im	: std_logic_vector(15 downto 0):=x"0000";

signal dout0_bit, dout1_bit : complex_fp24;	 

signal dout0, dout1 		: complex_fp24;
signal d_val_bit			: std_logic;

signal dm0_re, dm1_re 			: complex_m;
signal dm0_im, dm1_im 			: complex_m;

signal fix0_re, fix1_re	: std_logic_vector(31 downto 0);
signal fix0_im, fix1_im	: std_logic_vector(31 downto 0);

signal ovr				: std_logic_vector(3 downto 0);

signal d_out_val		: std_logic;
signal start_del		: std_logic_vector(7 downto 0):=x"00";
signal st				: std_logic:='0';
	
constant t0				: time := 5 ns;
constant res_time		: time := 100 ns;
constant tst			: time := 35 ns;
constant tt				: time := t0*Nst;
constant tt2x			: time := t0*Nst2x+t0;


signal fix_dout0_re			: std_logic_vector(31 downto 0);
signal fix_dout1_re			: std_logic_vector(31 downto 0);
signal fix_dout0_im			: std_logic_vector(31 downto 0);
signal fix_dout1_im			: std_logic_vector(31 downto 0);

signal scale			: std_logic_vector(6 downto 0):="0010000";

signal val				: std_logic_vector(3 downto 0);
signal over				: std_logic_vector(3 downto 0);

signal of_re			: std_logic_vector(15 downto 0):=x"0000";
signal of_im			: std_logic_vector(15 downto 0):=x"0000";

signal of_en			: std_logic:='0';
signal of_rw			: std_logic;

begin 
 
dm0_re <= flt_decode(dout0.re) after 1 ns when rising_edge(aclk);
dm0_im <= flt_decode(dout0.im) after 1 ns when rising_edge(aclk);
dm1_re <= flt_decode(dout1.re) after 1 ns when rising_edge(aclk);
dm1_im <= flt_decode(dout1.im) after 1 ns when rising_edge(aclk);
	
fix0re: fp24_float2fix_m1
	port map (
		din			=> dout0.re,	
		dout		=> fix_dout0_re,
		clk			=> aclk,
		reset		=> reset,
		din_en		=> d_out_val,
		scale		=> scale,  
		dout_val	=> val(0),                      
		overflow	=> over(0)                                       			
	);	
	
	
fix1re: fp24_float2fix_m1
	port map (
		din			=> dout1.re,	
		dout		=> fix_dout1_re,
		clk			=> aclk,
		reset		=> reset,
		din_en		=> d_out_val,
		scale		=> scale,  
		dout_val	=> val(2),                      
		overflow	=> over(2)                                       			
	);	
	
fix0im: fp24_float2fix_m1
	port map (
		din			=> dout0.im,	
		dout		=> fix_dout0_im,
		clk			=> aclk,
		reset		=> reset,
		din_en		=> d_out_val,
		scale		=> scale,  
		dout_val	=> val(1),                      
		overflow	=> over(1)                                       			
	);	
			
fix1im: fp24_float2fix_m1
	port map (
		din			=> dout1.im,	
		dout		=> fix_dout1_im,
		clk			=> aclk,
		reset		=> reset,
		din_en		=> d_out_val,
		scale		=> scale,  
		dout_val	=> val(3),                      
		overflow	=> over(3)                                       			
	);		
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
writing_fix: process(aclk) is    -- write file_io.out (++ done goes to '1')
	file log 					: TEXT open WRITE_MODE is "src/log/fp24int_FFT_RESULT.dat";
	variable str 				: LINE;
	variable cnt 				: integer range -1 to 1600000000;	
begin
	if rising_edge(aclk) then
		if reset = '0' then
			cnt := -1;		
		elsif val(0) = '1' then
			cnt := cnt + 1;	
			--------------------------------
			write(str, CONV_INTEGER(fix_dout0_re), LEFT);
			write(str, "    ");			
			--------------------------------
			write(str, CONV_INTEGER(fix_dout0_im), LEFT);
			write(str, "    ");				
			--------------------------------
			write(str, CONV_INTEGER(fix_dout1_re), LEFT);
			write(str, "    ");			
			--------------------------------
			write(str, CONV_INTEGER(fix_dout1_im), LEFT);
			write(str, "    ");			
			--------------------------------
			write(str, cnt, LEFT);
			writeline(log, str);
		else
			null;
		end if;
	end if;
end process; 		

-- RULE: gclk = 2ns, aclk = 2.5	
clk <= not clk after 2.5 ns;
gclk <=	not gclk after 2.5 ns;  -- CLK ADC
aclk <= not aclk after 2.5 ns;-- CLK FFT
reset <= '0', '1' after res_time;

pr_start: process
	begin
		start <= '0';
		wait for res_time+t0*2;
		loop 
			start <= '1'; 
			wait for 10 ns; 
			start <= '0'; 
			wait for tt; -- 327.68 
			start <= '0'; 
			wait for 21000 ns; -- 21000 ns --- TIME_START 
		end loop;	
end process;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
pr_data: process is
variable l			: line;
variable re_even	: integer;	
variable re_odd		: integer; 
variable im_even	: integer;	
variable im_odd		: integer; 
file file_OF		: text;	
variable count		: integer:=-1;
begin  	  	
	file_open( file_OF, "src\log\ab_in_fp24.dat", READ_MODE );
	wait for 1 ns;
	if (reset = '0') then  	
	else
		lp_inf: for k in 0 to 31 loop
			count :=0;
			file_open( file_OF, "src\log\ab_in_fp24.dat", READ_MODE );		
			wait for tst;
			lp_32k: for k in 0 to Nst-1 loop
				--while not endfile(file_OF) loop
				wait until rising_edge(aclk);	
				count := count + 1;
				readline( file_OF, l );
				read( l, re_even);	 			
				read( l, im_even);	
				read( l, re_odd);	 			
				read( l, im_odd);				
				d0_re <= conv_std_logic_vector( re_even, 16 ) after 1 ns;			
				d0_im <= conv_std_logic_vector( im_even, 16 ) after 1 ns;				
				d1_re <= conv_std_logic_vector( re_odd, 16 ) after 1 ns;				
				d1_im <= conv_std_logic_vector( im_odd, 16 ) after 1 ns;				
			end loop;
			wait for 20975 ns; --- TIME_START -----------------------
			file_close(file_OF);
		end loop;
	end if;
end process; 

d0 <= dout0;
d1 <= dout1;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
	
start_del(0) <= start when rising_edge(gclk);
start_del(1) <= start_del(0) when rising_edge(gclk);	
start_del(2) <= start_del(1) when rising_edge(gclk);	
start_del(3) <= start_del(2) when rising_edge(gclk);
start_del(4) <= start_del(3) when rising_edge(gclk);
start_del(5) <= start_del(4) when rising_edge(gclk);
start_del(6) <= start_del(5) when rising_edge(gclk);
start_del(7) <= start_del(6) when rising_edge(gclk);

st <= start_del(7) when rising_edge(gclk);
		
d_val <= d_out_val after 1 ns;

of_rw <= '0', '1' after res_time+tst, '0' after tt2x+res_time+tst;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
pr_data_of: process is
variable l			: line;
variable re_of		: integer;	
variable im_of		: integer; 
file file_OF		: text;	
variable count		: integer:=-1;
begin  	  	
	file_open( file_OF, "src\log\of_fp24.dat", READ_MODE );
	wait for 1 ns;
	if (reset = '0') then
	else
		if of_rw = '1' then
		--lp_inf: for k in 0 to 31 loop
			count :=0;
			file_open( file_OF, "src\log\of_fp24.dat", READ_MODE );		
			wait for 0 ns;
			lp_32k: for k in 0 to Nst2x-1 loop
				--while not endfile(file_OF) loop
				wait until rising_edge(aclk);	
				count := count + 1;
				readline( file_OF, l );
				read( l, im_of);	 			
				read( l, re_of);
				of_en <= '1' after 0.5 ns;
				of_re <= conv_std_logic_vector( re_of, 16 ) after 0.5 ns;			
				of_im <= conv_std_logic_vector( im_of, 16 ) after 0.5 ns;							
			end loop;
			wait for t0;
			of_en <= '0' after 0.5 ns;
			of_re <= x"0000" after 0.5 ns;			
			of_im <= x"0000" after 0.5 ns;
			wait for 20975 ns; --- TIME_START -----------------------
			file_close(file_OF);
		end if;
			--end loop;
	end if;
end process; 

d0 <= dout0;
d1 <= dout1;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
uut: fp24_fft_ifft_logic
generic map (
	stages 		=> stages
	)
port map ( 
	reset		=> reset,	
	--clk			=> clk,
	        
	aclk		=> aclk,	
	gclk		=> gclk,	
	start		=> start,
	fix_float 	=> fix_float,
	        
	d0_re		=> d0_re,	
	d0_im		=> d0_im,
	d1_re		=> d1_re,	
	d1_im		=> d1_im,	
	
	of_re		=> of_re,	
	of_im		=> of_im,
	of_en		=> of_en,	
	of_rw		=> of_rw,	
	
	d0			=> dout0, 		
	d1			=> dout1, 		
	d_val		=> d_out_val);	
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
end fp24_fft_ifft_logic_test;