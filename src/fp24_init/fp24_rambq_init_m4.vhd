-------------------------------------------------------------------------------
--
-- Title       : fp24_rambq_init_m4_pkg
-- Design      : fp24fftk
-- Author      : Kapitanov
-- Company     :
--
-------------------------------------------------------------------------------
--
-- Description :  ramb initialization for coe_rom: xilinx primitive FDE
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

package	fp24_rambq_init_m4_pkg is
	component fp24_rambq_init_m4 is
	  port(
   		doa  	: out std_logic_vector(47 downto 0);
		clk  	: in std_ulogic
	    );	
	end component;
end package;

library ieee;
use ieee.std_logic_1164.all;   
library unisim;
use unisim.vcomponents.all; 

use work.fp24_init1_pkg.all;
use work.fp24_type_pkg.bit_array_1024x44;

entity fp24_rambq_init_m4 is
  port(
  	doa  	: out std_logic_vector(47 downto 0);
    clk  	: in std_ulogic
    );
end fp24_rambq_init_m4;

architecture fp24_rambq_init_m4 of fp24_rambq_init_m4 is

signal	dpo			: std_logic_vector(43 downto 0);

type std_logic_array_48x16 is array (43 downto 0) of bit_vector(15 downto 0);

function read_ini_file(ii : integer) return bit is
variable mem_inis	: bit_array_1024x44;
variable ramb_init	: bit;
begin 
	x_conv: for kk in 0 to 1023 loop
		x_48to44_lo: for ll in 0 to 21 loop
			mem_inis(kk)(ll) := mem_init1(kk)(ll+1);
		end loop;
		x_48to44_hi: for ll in 22 to 43 loop
			mem_inis(kk)(ll) := mem_init1(kk)(ll+3);
		end loop;		
	end loop;
	--for jj in 0 to 43 loop
		ramb_init:=mem_inis(0)(ii); 
	--end loop;		
	return ramb_init;
end read_ini_file;	 

begin
 
doa  <= ('0' & dpo(43 downto 22) & '0') & ('0' & dpo(21 downto 0) & '0'); -- after 1 ns when rising_edge(clk); 

gen_sliceM: for ii in 0 to 43 generate
	constant const_init : bit:=read_ini_file(ii); 	
begin		
	fde_slice: FDE
	generic map (
    	INIT => const_init
    )
	port map ( 
		Q	=> dpo(ii),
		D	=> '0',
		CE	=> '0',
		C  	=> clk				
	);		
end generate;

end fp24_rambq_init_m4;