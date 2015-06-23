-------------------------------------------------------------------------------
--
-- Title       : fp24_fftNk_m1
-- Design      : fp24fftk
-- Author      : Kapitanov
-- Company     :
--
-------------------------------------------------------------------------------
--
-- Description : version 1.0: fp24fftk 64k: used delay_line, bytterfly, coe_generator 
--																   for twiddle
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
use work.fp24_m2_pkg.all;

package	fp24_fftNk_m1_pkg is
	component fp24_fftNk_m1 is
		generic(
			stages		: integer :=16
		);
		port(
			data_in0	: in complex_fp24;
			data_in1	: in complex_fp24;		   
			data_en		: in std_logic;

			dout0 		: out complex_fp24;
			dout1 		: out complex_fp24;
			dout_val	: out std_logic;
			
			reset  		: in std_logic;
			clk 		: in std_logic;		  
			
			din0_re		: in std_logic_vector(15 downto 0);
			din0_im		: in std_logic_vector(15 downto 0);
			din1_re		: in std_logic_vector(15 downto 0);
			din1_im		: in std_logic_vector(15 downto 0);
			
			fix_en		: in std_logic
			
			);
	end component;
end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.fp24_m2_pkg.all;
use work.fp24_butterfly_m2_pkg.all;
use work.fp24_twiddle_rom_m2_pkg.all; 
use work.fp24_delay_line_m2_pkg.all;

entity fp24_fftNk_m1 is
	generic(
		stages		: integer :=16
	);	
	port(
		data_in0	: in complex_fp24;
		data_in1	: in complex_fp24;		   
		data_en		: in std_logic;

		dout0 		: out complex_fp24;
		dout1 		: out complex_fp24;
		dout_val	: out std_logic;
		
		reset  		: in std_logic;
		clk 		: in std_logic;		  
		
		din0_re		: in std_logic_vector(15 downto 0);
		din0_im		: in std_logic_vector(15 downto 0);
		din1_re		: in std_logic_vector(15 downto 0);
		din1_im		: in std_logic_vector(15 downto 0);
		
		fix_en		: in std_logic	
	);
end fp24_fftNk_m1;

architecture fp24_fftNk_m1 of fp24_fftNk_m1 is	

type complex_fp24xN 	is array (stages-1 downto 0) of complex_fp24;
type complex_16xfp24xN  is array (15 downto 0) of complex_fp24xN;

signal ia 				: complex_fp24xN;
signal ib 				: complex_fp24xN;  
signal ias 				: complex_fp24xN;
signal ibs 				: complex_fp24xN;

signal oa 				: complex_fp24xN;
signal ob 				: complex_fp24xN; 
signal oad 				: complex_fp24xN;
signal obd 				: complex_fp24xN;
signal ww 				: complex_fp24xN; 		
signal coe_enable		: std_logic_vector(stages-1 downto 0);

signal butter_din_en	: std_logic_vector(stages-1 downto 0);
signal butter_din_ens	: std_logic_vector(stages downto 0);

signal butter_dout_val	: std_logic_vector(stages-1 downto 0);
signal dell_din_en		: std_logic_vector(stages-2 downto 0);
signal dell_dout_val	: std_logic_vector(stages-1 downto 0);   

signal ia_z     		: complex_16xfp24xN;
signal ib_z     		: complex_16xfp24xN;

signal din0_re_z		: std_logic_vector(15 downto 0 );
signal din0_im_z		: std_logic_vector(15 downto 0 );
signal din1_re_z		: std_logic_vector(15 downto 0 );
signal din1_im_z		: std_logic_vector(15 downto 0 );	 

constant g_stages		: integer:=stages;

begin

butter_din_ens(0) <= data_en after 1 ns;		 
ias(0) <= data_in0 after 1 ns;
ibs(0) <= data_in1 after 1 ns;

stage_gen: for ii in 0 to stages-1 generate	
	signal butter_din_en_z	: std_logic_vector(15 downto 0);
begin		
	
	butterfly: fp24_butterfly_m2
		port map(
			ia 		=> ia(ii), 
			ib 		=> ib(ii),
			din_en	=> butter_din_en(ii),
			ww 		=> ww(ii),
			oa 		=> oa(ii), 
			ob 		=> ob(ii),
			dout_val=> butter_dout_val(ii),
			reset  	=> reset , 
			clk 	=> clk 	 
		); 									   
	
	coe_rom: fp24_twiddle_rom_m2
	generic map(
		stages		=> stages,
		ii 			=> ii
	)
	port map(
		ww			=> ww(ii),
		clk 		=> clk,
		coe_enable 	=> coe_enable(ii),
		reset  		=> reset
	);
	
	l_rom_del_tey: if (stages-ii > 12) generate		
		ia(ii) <= ia_z(1)(ii);	   --<--------<<<<< для компенсации увеличевшейся задержки в coe_rom_teylor...
		ib(ii) <= ib_z(1)(ii);
		
		butter_din_en(ii) <= butter_din_en_z(1);
		coe_enable(ii) <= butter_din_ens(ii);
	end generate;			
	s_rom_del_coe: if (stages-ii <= 12) generate	
		ia(ii) <= ia_z(0)(ii); --1	   --<--------<<<<< для компенсации увеличевшейся задержки в coe_rom_teylor...
		ib(ii) <= ib_z(0)(ii); --1
		
		butter_din_en(ii) <= butter_din_en_z(0);		
		coe_enable(ii) <= butter_din_en_z(15) after 1 ns when rising_edge(clk);	
	end generate;	
	
	process(clk) is
	begin
		if rising_edge(clk) then			
			ia_z(0) <= ias after 1 ns;
			ib_z(0) <= ibs after 1 ns;
			for kk in 0 to 14 loop
				ia_z(kk+1)	<= ia_z(kk) after 1 ns;
				ib_z(kk+1)	<= ib_z(kk) after 1 ns;
			end loop;	
		end if;
	end process;
	
	process(clk, reset) is
	begin
		if reset = '0' then
			butter_din_en_z <= (others => '0');
		elsif rising_edge(clk) then			
			butter_din_en_z(0) <= butter_din_ens(ii) after 1 ns;
			for kk in 0 to 14 loop
				butter_din_en_z(kk+1) <= butter_din_en_z(kk) after 1 ns;
			end loop;	
		end if;
	end process;	

	butter_din_ens(ii+1) <= dell_dout_val(ii); 
end generate;

stage_gen2: for ii in 0 to stages-2 generate 	
	del_line : fp24_delay_line_m2
		generic map (
			stages 		=> stages,
			stage_num 	=> ii
		)
		port map (
			ia 			=> oad(ii),           
			ib 			=> obd(ii),           
			din_en 		=> dell_din_en(ii),  
			oa 			=> ias(ii+1),        
			ob 			=> ibs(ii+1),        
			dout_val	=> dell_dout_val(ii),
			reset 		=> reset,            
			clk 		=> clk               
		);
		dell_din_en(ii) <= butter_dout_val(ii) after 1 ns when rising_edge(clk); -- after 1 ns;
end generate;	  

oad <= oa after 1 ns when rising_edge(clk); 
obd <= ob after 1 ns when rising_edge(clk); 

process(clk, reset) is
begin
	if reset = '0' then
		dout0 <= (others => (others => '0')); 
		dout1 <= (others => (others => '0')); 
	elsif rising_edge(clk) then
		if fix_en = '1' then			
			dout0.re(23 downto 16)	<= (others => din0_re_z(15)) after 1 ns;
			dout0.re(15 downto 0) 	<= din0_re_z(15 downto 0) after 1 ns;
			dout0.im(23 downto 16) 	<= (others => din0_im_z(15)) after 1 ns;
			dout0.im(15 downto 0) 	<= din0_im_z(15 downto 0) after 1 ns;
			
			dout1.re(23 downto 16) 	<= (others => din1_re_z(15)) after 1 ns;
			dout1.re(15 downto 0) 	<= din1_re_z(15 downto 0) after 1 ns;
			dout1.im(23 downto 16) 	<= (others => din1_im_z(15)) after 1 ns;
			dout1.im(15 downto 0) 	<= din1_im_z(15 downto 0) after 1 ns; 			
		else
			dout0 <= oa(stages-1) after 1 ns;
			dout1 <= ob(stages-1) after 1 ns;			
		end if;
	end if;
end process;

din0_re_z <= din0_re when rising_edge(clk);
din0_im_z <= din0_im when rising_edge(clk);
din1_re_z <= din1_re when rising_edge(clk);
din1_im_z <= din1_im when rising_edge(clk);

process(clk, reset) is
begin
	if reset = '0' then
		dout_val <= '0' after 1 ns;
	elsif rising_edge(clk) then  		
		if fix_en = '1' then
			dout_val <= '1';
			--dout_val <= coe_enable(0) after 1 ns;--15
		else
			dout_val <= butter_dout_val(stages-1) after 1 ns;--15
		end if;
	end if;
end process;

end fp24_fftNk_m1;