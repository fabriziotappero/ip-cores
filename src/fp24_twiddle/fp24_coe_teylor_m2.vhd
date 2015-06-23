-------------------------------------------------------------------------------
--
-- Title       : fp24_coe_teylor_m2
-- Design      : fp24fftk
-- Author      : Kapitanov
-- Company     :
--
-------------------------------------------------------------------------------
--
-- Description : version 1.0
--
-- WITHOUT DSP BLOCKS ! (I don't know what will happen if we use this version instead of v0)
-- 
-- It isn't Taylor COE_ROM, but it works anyway!
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
use work.fp24_m2_pkg.all;

package	fp24_coe_teylor_m2_pkg	is
	component fp24_coe_teylor_m2 is
		generic(
			stages		: integer:=16;
			stage_num 	: integer:=0
			);
		port(
			ww			: out complex_fp24;
			--ww_val		: out std_logic;
			clk 		: in std_logic;
			enable 		: in std_logic;
			reset  		: in std_logic
		);
	end component;
end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.fp24_rambq_init_m1_pkg.all;
use work.fp24_m2_pkg.all;

entity fp24_coe_teylor_m2 is
	generic(
		stages		: integer:=16;
		stage_num 	: integer:=0
		);
	port(
		ww			: out complex_fp24;
		--ww_val		: out std_logic;
		clk 		: in std_logic;
		enable 		: in std_logic;
		reset  		: in std_logic
	);
end fp24_coe_teylor_m2;


architecture fp24_coe_teylor_m2 of fp24_coe_teylor_m2 is 

signal rstn		: std_logic;

signal doa  	: std_logic_vector(47 downto 0);
signal addrx	: std_logic_vector(9 downto 0);
signal addr 	: std_logic_vector(stages-3 downto 0);
signal cnt		: std_logic_vector(stages-2 downto 0);

signal ww_node	: complex_fp24;
signal prod		: complex_fp24;
signal delta	: std_logic_vector(4 downto 0);


type fp24xZ11 	is array (11 downto 0) of complex_fp24;
signal prod_z11	: fp24xZ11;

signal negative : std_logic:='0';

begin	
	
rstn <= not reset;

negative <= cnt(stages-2-stage_num) when rising_edge(clk);

process(clk, reset) is
begin
	if reset = '0' then
		cnt		 <= (others => '0');
	elsif rising_edge(clk) then
		if enable = '1' then
			cnt  <= cnt + '1';
		end if;
	end if;
end process;

addr((stages-3) downto stage_num) <= cnt((stages-3-stage_num) downto 0) when cnt(stages-2-stage_num) = '0' else not cnt((stages-3-stage_num) downto 0);
addr(stage_num-2 downto 0)	<= (others => '0');

addrx <= addr(stages-3 downto stages-12);

rom_coe: fp24_rambq_init_m1
  generic map ( 
  	fp_teylor => false 
  )
  port map(
    doa  	=> doa,  		
    --dob  	=> ,  			
    --dopa 	=> dopa,  		
    --dopb 	=> ,  			
 
    addra 	=> addrx,  		
    addrb 	=> (others=>'0'),  
    clka  	=> clk,  			
    clkb  	=> clk,  			
    dia   	=> (others=>'0'),  
    dib   	=> (others=>'0'),  
    --dipa  	=> (others=>'0'),  
    --dipb  	=> (others=>'0'),  
    ena   	=> '1', --enable,  		
    enb   	=> '0',  			
    ssra  	=> rstn,  			
    ssrb  	=> '0',  			
    wea   	=> '0',  			
    web   	=> '0'  			
    );

process(clk) is
begin			
	if rising_edge(clk) then
		ww_node.im	<= doa(47 downto 24) after 1 ns; 
		if negative = '0' then
			ww_node.re	<= doa(23 downto 00) after 1 ns;
		else
			ww_node.re	<= doa(23 downto 17) & not doa(16) & doa(15 downto 0) after 1 ns;
		end if;
	end if;
end process;	

process(clk, reset) is
begin
	if reset = '0' then
		prod_z11	<= (others => (others => (others => '0')));	
	elsif rising_edge(clk) then
		prod_z11 <= prod_z11(10 downto 0) & ww_node after 1 ns;
	end if;
end process;

ww <= prod_z11(11) after 1 ns when rising_edge(clk);

end fp24_coe_teylor_m2;
