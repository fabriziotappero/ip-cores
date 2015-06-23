-------------------------------------------------------------------------------
--
-- Title       : fp24_rambq_init_m2_pkg
-- Design      : fp24fftk
-- Author      : Kapitanov
-- Company     :
--
-------------------------------------------------------------------------------
--
-- Description :  ramb initialization for coe_rom: xilinx primitive RAM128X1D - RAM16X1D
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

package	fp24_rambq_init_m2_pkg is
	component fp24_rambq_init_m2 is
	  generic ( sliceM_addr	: integer:=8
	    );
	  port(
   		doa  	: out std_logic_vector(47 downto 0);
	
	    addra 	: in std_logic_vector(sliceM_addr-2 downto 0);
		clk  	: in std_ulogic
	    );	
	end component;
end package;

library ieee;
use ieee.std_logic_1164.all; 

library unisim;
use unisim.vcomponents.all; 

use work.fp24_init1_pkg.all;
use work.fp24_type_pkg.bit_array_1024x48;
use work.fp24_type_pkg.bit_array_1024x44;

entity fp24_rambq_init_m2 is
  generic ( sliceM_addr	: integer:=8
    );
  port(
  	doa  	: out std_logic_vector(47 downto 0);

    addra 	: in std_logic_vector(sliceM_addr-2 downto 0);
    clk  	: in std_ulogic
    );
	
end fp24_rambq_init_m2;

architecture fp24_rambq_init_m2 of fp24_rambq_init_m2 is

signal	dpo			: std_logic_vector(43 downto 0);

type std_logic_array_48xNN 	is array (47 downto 0) of bit_vector(2**(sliceM_addr-1)-1 downto 0);

function read_ini_file(ramb_sel: integer) return std_logic_array_48xNN is
variable mem_inis	: bit_array_1024x44;
variable ramb_init	: std_logic_array_48xNN;
begin 
	x_conv: for kk in 0 to 1023 loop
		x_48to44_lo: for ll in 0 to 21 loop
			mem_inis(kk)(ll) := mem_init1(kk)(ll+1);
		end loop;
		x_48to44_hi: for ll in 22 to 43 loop
			mem_inis(kk)(ll) := mem_init1(kk)(ll+3);
		end loop;		
	end loop;	
	
	for jj in 0 to 43 loop
		for ii in 0 to 2**(ramb_sel-1)-1 loop
				ramb_init(jj)(ii):=mem_inis(ii*(2**(11-ramb_sel)))(jj); 
		end loop;
	end loop;		
	return ramb_init;
end read_ini_file;	 

begin
 
doa  <= ('0' & dpo(43 downto 22) & '0') & ('0' & dpo(21 downto 0) & '0'); -- after 1 ns when rising_edge(clk); 

gen_sliceM: for ii in 0 to 43 generate
	constant const_init : std_logic_array_48xNN:=read_ini_file(sliceM_addr); 	
begin
	x_gen8: if sliceM_addr = 9 generate 
		ramb_slicem128: RAM256X1S
		generic map(
			INIT => const_init(ii)
		)
		port map (
			O 		=> dpo(ii),			  -- Read/Write port 1-bit ouput            
			D     	=> '0',				  -- RAM data input                      
			A  		=> addra,			  -- Read port 7-bit address input       
			WCLK  	=> clk,				  -- Write clock input                   
			WE   	=> '0'				  -- RAM data input                      
			);
	end generate;	
	
	x_gen7: if sliceM_addr = 8 generate 
		ramb_slicem128: RAM128X1D
		generic map(
			INIT => const_init(ii)
		)
		port map (
			DPO 	=> dpo(ii),			  -- Read/Write port 1-bit ouput            
			--SPO 	=> spo(ii),			  -- Read port 1-bit output              
			A     	=> (others => '0'),	  -- Read/Write port 7-bit address input 
			D     	=> '0',				  -- RAM data input                      
			DPRA  	=> addra(6 downto 0),-- Read port 7-bit address input       
			WCLK  	=> clk,				  -- Write clock input                   
			WE   	=> '0'				  -- RAM data input                      
			);
	end generate;	
	x_gen6: if sliceM_addr = 7 generate 
		ramb_slicem64: RAM64X1D
		generic map(
			INIT => const_init(ii)
		)
		port map (
			DPO 	=> dpo(ii),			  -- Read/Write port 1-bit ouput            
			--SPO 	=> spo(ii),			  -- Read port 1-bit output              
			A0    	=> '0',	  
    		A1    	=> '0',	  
    		A2    	=> '0',	  
    		A3    	=> '0',	  
   		 	A4    	=> '0',	  
   			A5    	=> '0',	  
			DPRA0	=> addra(0),
			DPRA1   => addra(1),
			DPRA2   => addra(2),
			DPRA3   => addra(3),
			DPRA4	=> addra(4),
			DPRA5	=> addra(5),
			D     	=> '0',				  -- RAM data input                      
			WCLK  	=> clk,				  -- Write clock input                   
			WE   	=> '0'				  -- RAM data input                      
			);
	end generate;	
	x_gen5: if sliceM_addr = 6 generate 
		ramb_slicem32: RAM32X1D
		generic map(
			INIT => const_init(ii)
		)
		port map (
			DPO 	=> dpo(ii),			  -- Read/Write port 1-bit ouput            
			--SPO 	=> spo(ii),			  -- Read port 1-bit output              
			A0    	=> '0',	  
    		A1    	=> '0',	  
    		A2    	=> '0',	  
    		A3    	=> '0',	  
   		 	A4    	=> '0',	    
			DPRA0	=> addra(0),
			DPRA1   => addra(1),
			DPRA2   => addra(2),
			DPRA3   => addra(3),
			DPRA4	=> addra(4),
			D     	=> '0',				  -- RAM data input                             
			WCLK  	=> clk,				  -- Write clock input                   
			WE   	=> '0'				  -- RAM data input                      
			);
	end generate;					
end generate;

end fp24_rambq_init_m2;