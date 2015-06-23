-------------------------------------------------------------------------------
--
-- Title       : fp24_fft_ifft_logic
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
use work.fp24_fftNk_m1_pkg.all;
use work.fp24_ifftNk_m1_pkg.all;


use work.fft_input_bufN_m1_pkg.all;
use work.fp24_fix2float_m1_pkg.all;
use work.fp24_ofbuf_m1_pkg.all;

------------ testt
use work.fp24_delay_line_m2_pkg.all;



entity fp24_fft_ifft_logic is
	generic(
		stages		: integer :=16
	);	
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
end fp24_fft_ifft_logic;

architecture fp24_fft_ifft_logic of fp24_fft_ifft_logic is   		  

signal	ias			: complex_fp24;  		
signal	ibs			: complex_fp24;  		
signal	din_en 		: std_logic;     		
signal	dout0_fft 	: complex_fp24; 		
signal	dout1_fft	: complex_fp24; 		
signal	dout_val	: std_logic;    		   		

signal	start_z		: std_logic;
signal	fft_cnt		: std_logic_vector(stages-2 downto 0);

signal	ca_re		: std_logic_vector(15 downto 0);
signal	ca_im		: std_logic_vector(15 downto 0);
signal	cb_re		: std_logic_vector(15 downto 0);
signal	cb_im		: std_logic_vector(15 downto 0);		

signal	fix_en		: std_logic:='1'; 



type fp17x12_array	is array (12 downto 0) of complex_fp24;

attribute box_type : string;
--attribute box_type of input_buf	: label is "black_box";
--attribute box_type of fft	: label is "black_box";
--attribute box_type of fix0	: label is "black_box";	
--attribute box_type of fix1	: label is "black_box";	
--attribute box_type of fix2	: label is "black_box";	
--attribute box_type of fix3	: label is "black_box";	

--attribute buffer_type 	: string;
--attribute buffer_type  of aclk: signal is "none";	
--attribute buffer_type  of gclk: signal is "none";	

signal dout0_ifft, dout1_ifft	: complex_fp24;	

signal d_out_val				: std_logic;
signal dout_val_ifft			: std_logic;
signal d_val_bit				: std_logic;

signal fft_even_z, fft_odd_z	: fp17x12_array;	

signal of_re_even				: std_logic_vector(15 downto 0);
signal of_re_odd				: std_logic_vector(15 downto 0);
signal of_im_even				: std_logic_vector(15 downto 0);
signal of_im_odd				: std_logic_vector(15 downto 0);

signal dof_val					: std_logic;

signal of_even, of_odd			: complex_fp24;
signal cm_even, cm_odd			: complex_fp24;

signal cm_val0, cm_val1 		: std_logic;
signal fpof_val					: std_logic;

begin	

--d0 	<= cm_even;
--d1 	<= cm_odd; 
--d_val <= cm_val0; 

--d0 	<= of_even;
--d1 	<= of_odd;
--d_val <= fpof_val; 

d0 	<= dout0_fft;
d1 	<= dout1_fft; 
d_val <= dout_val;

--d0 	<= dout0_ifft;			
--d1 	<= dout1_ifft; 
--d_val <= dout_val_ifft;

fft_even_z	<= fft_even_z(11 downto 0) & dout0_fft after 1 ns when rising_edge(aclk);
fft_odd_z	<= fft_odd_z(11 downto 0) & dout1_fft after 1 ns when rising_edge(aclk);


-------------------- INPUT BUFFER --------------------
input_buf: fft_input_bufN_m1
	generic map (
		stages 		=> stages)
	port map(	
		ia_re		=> d0_re,
		ia_im		=> d0_im,		
		ib_re		=> d1_re,		
		ib_im		=> d1_im,		

		clk_in		=> gclk,	-- clock ADC 250 MHz
		start 		=> start,
		--cnt_in		=> fft_cnt,
		cnt_out		=> fft_cnt,

		reset  		=> reset, 
		clk 		=> aclk,	-- clock FFT 125, 180 MHz (MMCM generate)
		
		ca_re		=> ca_re,		
		ca_im		=> ca_im,		
		cb_re		=> cb_re,		
		cb_im		=> cb_im,			
		fix_en		=> fix_en
	); 
------------------ FIX to FLOAT IN --------------------	
fix0_if: fp24_fix2float_m1 
		port map(
			din			=> ca_re,
			din_en		=> fix_en,
			dout		=> ias.re,
			dout_val	=> din_en,
			clk			=> aclk,
			reset		=> reset
		);		
		
fix1_if: fp24_fix2float_m1 
		port map(
			din			=> ca_im,
			din_en		=> fix_en,
			dout		=> ias.im,
			--dout_val	=> dout_val,
			clk			=> aclk,
			reset		=> reset
		);

fix2_if: fp24_fix2float_m1 
		port map(
			din			=> cb_re,
			din_en		=> fix_en,
			dout		=> ibs.re,
			--dout_val	=> dout_val,
			clk			=> aclk,
			reset		=> reset
		);
		
fix3_if: fp24_fix2float_m1 
		port map(
			din			=> cb_im,
			din_en		=> fix_en,
			dout		=> ibs.im,
			--dout_val	=> dout_val,
			clk			=> aclk,
			reset		=> reset
		);

------------------ fp24FFT64k --------------------		
fft: fp24_fftNk_m1
	generic map (
		stages 		=> stages)
	port map(						               
		data_in0	=> ias,		
		data_in1	=> ibs,			   
		data_en		=> din_en,		
						            
		dout0 		=> dout0_fft,
		dout1 		=> dout1_fft,
		dout_val	=> dout_val,
		
		reset  		=> reset, 
		clk 		=> aclk,	-- FFT clock

		din0_re		=> ca_re,
		din0_im		=> ca_im,
		din1_re		=> cb_re,
		din1_im		=> cb_im,
		
		fix_en		=> fix_float -- '0'
	); 		  
------------------ OF BUFFER --------------------		
of_buf:	fp24_ofbuf_m1 
	generic map (
		stages 		=> stages)
	port map(
		of_re		=> of_re,
		of_im		=> of_im,
 			
		reset  		=> reset,
		clk			=> aclk, 			
		clk_in		=> gclk,						
			
		din_en		=> of_en,
		rw_en		=> of_rw,
		dout_en		=> dout_val,
			
		of_re_even	=> of_re_even,
		of_re_odd	=> of_re_odd,
		of_im_even	=> of_im_even,
		of_im_odd	=> of_im_odd,	
	
		dout_val	=> dof_val
	);



------------------ FIX to FLOAT OF --------------------	
fix0_of: fp24_fix2float_m1 
		port map(
			din			=> of_re_even,
			din_en		=> dof_val,
			dout		=> of_even.re,
			dout_val	=> fpof_val,
			clk			=> aclk,
			reset		=> reset
		);		
		
fix1_of: fp24_fix2float_m1 
		port map(
			din			=> of_im_even,
			din_en		=> dof_val,
			dout		=> of_even.im,
			--dout_val	=> dout_val,
			clk			=> aclk,
			reset		=> reset
		);

fix2_of: fp24_fix2float_m1 
		port map(
			din			=> of_re_odd,
			din_en		=> dof_val,
			dout		=> of_odd.re,
			--dout_val	=> dout_val,
			clk			=> aclk,
			reset		=> reset
		);
		
fix3_of: fp24_fix2float_m1 
		port map(
			din			=> of_im_odd,
			din_en		=> dof_val,
			dout		=> of_odd.im,
			--dout_val	=> dout_val,
			clk			=> aclk,
			reset		=> reset
		);	   

------------------ COMPLEX MULTIPLIERS --------------------		
x_comp_even: fp24_cmult_m2
	port map (
		aa 		=> fft_even_z(12), 
		bb 		=> of_even,
		cc 		=> cm_even,
		enable 	=> fpof_val,
		reset  	=> reset,
		clk 	=> aclk,
		dout_v	=> cm_val0
	);		
	
x_comp_odd: fp24_cmult_m2
	port map (
		aa 		=> fft_odd_z(12), 
		bb 		=> of_odd,
		cc 		=> cm_odd,
		enable 	=> fpof_val,
		reset  	=> reset,
		clk 	=> aclk,
		dout_v	=> cm_val1
	);	
	
ifft: fp24_ifftNk_m1
	generic map (
		stages 		=> stages)
	port map(						               
		data_in0	=> cm_even,		
		data_in1	=> cm_odd,			   
		data_en		=> cm_val0,		
						            
		dout0 		=> dout0_ifft,
		dout1 		=> dout1_ifft,
		dout_val	=> dout_val_ifft,
	
		reset  		=> reset, 
		clk 		=> aclk
	); 
	
end fp24_fft_ifft_logic;