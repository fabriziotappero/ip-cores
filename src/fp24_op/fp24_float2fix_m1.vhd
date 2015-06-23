 -------------------------------------------------------------------------------
--
-- Title       : fp24_float2fix_v10
-- Design      : fp24fftk
-- Author      : Kapitanov
-- Company     :
--
-------------------------------------------------------------------------------
--
-- Description : version 1.0 
--
-------------------------------------------------------------------------------
--
--	Version 1.0  15.08.2013
--			   	 Description:
--					Bus width for:
--					din = 24
--					dout = 31	
-- 					exp = 10
-- 					sign = 1
-- 					mant = 16 + 1
--				 Math expression: 
--					A = (-1)^sign(A) * 2^(exp(A)-32) * mant(A)
--				 NB: 
--				 Converting from float to fixed takes only ??? clock cycles
--
--
--				another algorithm: double precision with 2 DSP48E1.
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

package	fp24_float2fix_m1_pkg is
	component fp24_float2fix_m1 is
		port(
			din				: in std_logic_vector(23 downto 0);	
			dout			: out std_logic_vector(31 downto 0);
			clk				: in std_logic;
			reset			: in std_logic;
			din_en			: in std_logic;                       
			scale			: in std_logic_vector(6 downto 0);    
			dout_val		: out std_logic;                      
			overflow		: out std_logic                                        			
		);
	end component;
end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library unisim;
use unisim.vcomponents.all;

use work.sp_addsub_m1_pkg.all;
use work.sp_msb_decoder_m1_pkg.all;
use work.sp_dsp48e1_casc_m1_pkg.all;

entity fp24_float2fix_m1 is
	port(
			din				: in std_logic_vector(23 downto 0);	
			dout			: out std_logic_vector(31 downto 0);
			clk				: in std_logic;
			reset			: in std_logic;
			din_en			: in std_logic;                       
			scale			: in std_logic_vector(6 downto 0);    
			dout_val		: out std_logic;                      
			overflow		: out std_logic                       
	);
end fp24_float2fix_m1;

architecture fp24_float2fix_m1 of fp24_float2fix_m1 is 

type std_logic_array_4x6 is array (3 downto 0) of std_logic_vector(5 downto 0);
type std_logic_array_9x6 is array (8 downto 0) of std_logic_vector(5 downto 0);
type std_logic_array_4x18 is array (3 downto 0) of std_logic_vector(17 downto 0);
type std_logic_array_4x13 is array (3 downto 0) of std_logic_vector(12 downto 0);

signal exp_dif			: std_logic_vector(6 downto 0);	  --
signal sh_mask_aligne	: std_logic_vector(31 downto 0);
signal sh_mask_align	: std_logic_vector(31 downto 0);
signal man, man_z		: std_logic_vector(17 downto 0);
--signal sh_mask_alignx	: std_logic_vector(31 downto 0);
signal sh_mask_dsp48	: std_logic_vector(41 downto 0);
signal rstn				: std_logic;
signal implied			: std_logic;
signal din_z			: std_logic_vector(23 downto 0);  -- 
signal sign_z			: std_logic_vector(6 downto 0);	
signal din_en_z			: std_logic_vector(7 downto 0);	
signal overflow_z		: std_logic;
signal overflow_zz		: std_logic; 
signal overflow_zzz		: std_logic;
signal overflow_i		: std_logic;
signal res_dsp			: std_logic_vector(59 downto 0);

signal exp				: std_logic_vector(6 downto 0);
signal expo_z			: std_logic_vector(6 downto 0);

begin	
  
exp <= 	din_z(23 downto 17);
	
exp_subtr: sp_addsub_m1
	generic map(N => 6) 
	port map(
	data_a 	=> exp, 
	data_b 	=> expo_z, 
	data_c 	=> exp_dif, 		
	add_sub	=> '0', 				
	cin     => '1',--0 	
	--cout    => c_zero,	
	clk    	=> clk, 				
	ce 		=> din_en_z(0), 						
	aclr  	=> rstn 				
	);

mask_align_gen: for ii in 0 to 31 generate
constant init: bit_vector(63 downto 0):=to_bitvector(conv_std_logic_vector(2**(31-ii),64));
begin
	mask_align_lut: LUT6 
	  generic map(init => init)	
	  port map(
	    i0 => exp_dif(0),
	    i1 => exp_dif(1),
	    i2 => exp_dif(2),
	    i3 => exp_dif(3),
	    i4 => exp_dif(4),
	    i5 => exp_dif(5),
	    o  => sh_mask_aligne(31-ii)		
	    );	  
	pr_sh_align: process(clk, reset) is
	begin
		if reset = '0' then 
			sh_mask_align(ii) <= '0';	
			--din_en_z <= (others => '0');
		elsif rising_edge(clk) then
			sh_mask_align(ii) <= sh_mask_aligne(ii) and not exp_dif(6);
			--din_en_z <= din_en_z(6 downto 0) & din_en;
		end if;
end process;		
end generate;

pr_sh_align: process(clk, reset) is
	begin
		if reset = '0' then 
			din_en_z <= (others => '0');
		elsif rising_edge(clk) then
			din_en_z <= din_en_z(6 downto 0) & din_en after 1 ns;
		end if;
end process;	


--sh_mask_alignx <= sh_mask_align(31 downto 0);	-- (29 downto 1)
sh_mask_dsp48 <= x"00" & "00" & sh_mask_align(31 downto 0); 

--expo_z <= "0000010000";
expo_z <= scale after 1 ns when rising_edge(clk);

-----------------------------------------------------------------------	
process(clk, reset) is
begin 
	if reset = '0' then
		implied 	<= '0';
		din_z 		<= (others => '0');
		man 		<= (others => '0');
		sign_z 		<= (others => '0');
	elsif rising_edge(clk) then
		if din(23 downto 17) = "0000000" then
			implied	<='0';
		else 
			implied	<='1';
		end if;	
		din_z	<= din after 1 ns;
		sign_z	<= sign_z(5 downto 0) & din_z(16) after 1 ns;
		
		if din_en_z(0) = '1' then
			man	<=	'0' & implied & din_z(15 downto 0) after 1 ns;
		else
			null;
		end if;
	end if;
end process;

man_z <= man after 1 ns when rising_edge(clk);

mega_dsp: sp_dsp48e1_casc_m1
	port map(
	d_a 	=> sh_mask_dsp48, 
	d_b 	=> man_z, 
	d_c 	=> res_dsp, 		
	clk    	=> clk, 										
	reset  	=> reset 				
	);
  
rstn <= not reset; 

process(clk, reset) is
begin
	if reset = '0' then
		dout <= (others => '0');
	elsif rising_edge(clk) then
		for ii in 0 to 31 loop
			dout(ii) <=	res_dsp(16+ii) xor sign_z(3) after 1 ns;	 
		end loop;	
	end if;	
end process;

overflow_lut: LUT6 
  generic map(init => x"8000000000000000")	   -- A000000000000000
  port map(
    i0 => exp_dif(6),
    i1 => exp_dif(5),
    i2 => exp_dif(4),
    i3 => exp_dif(3),
    i4 => exp_dif(2),	
    i5 => exp_dif(1),		
    o  => overflow_i		
    );	

process(clk, reset) is
begin
	if reset = '0' then
		overflow_z <= '0';
	elsif rising_edge(clk) then
		overflow_z 		<= overflow_i after 1 ns;
		overflow_zz 	<= overflow_z after 1 ns;
		overflow_zzz 	<= overflow_zz after 1 ns;
	end if;
end process;	

overflow <= overflow_i;
dout_val <= din_en_z(5);	
 
end fp24_float2fix_m1;