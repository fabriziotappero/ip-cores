-- logic analyser (LA) for FPGAs
-- ver 1.0
-- Author: Ernest Jamro

--//////////////////////////////////////////////////////////////////////
--//// Copyright (C) 2001 Authors and OPENCORES.ORG                 ////
--////                                                              ////
--//// This source file may be used and distributed without         ////
--/// restriction provided that this copyright statement is not    ////
--//// removed from the file and that any derivative work contains  ////
--//// the original copyright notice and the associated disclaimer. ////
--////                                                              ////
--//// This source file is free software; you can redistribute it   ////
--//// and/or modify it under the terms of the GNU Lesser General   ////
--//// Public License as published by the Free Software Foundation; ////
--//// either version 2.1 of the License, or (at your option) any   ////
--//// later version.                                               ////
--////                                                              ////
--//// This source is distributed in the hope that it will be       ////
--//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
--//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
--//// PURPOSE. See the GNU Lesser General Public License for more  ////
--//// details.                                                     ////
--////                                                              ////
--//// You should have received a copy of the GNU Lesser General    ////
--//// Public License along with this source; if not, download it   ////
--//// from <http://www.opencores.org/lgpl.shtml>                   ////


-- internal memory description
-- only for Xilinx BlockRAM


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity la_mem is				  
  generic ( data_width: integer:= 16; -- width of the data (la interface)
    mem_adr_width: integer:= 8; -- width of the address (address width cannot be greater than max_address width (for data_width=1)
  	c_adr_width: integer:= 9; -- control interface address width = adr_width + log2(data_width/8)
	two_clocks: integer:= 0 -- use two seperate clocks =1 or a single one =0
	); 
  port (arst: in std_logic; -- asynchronous reset (mainly for simulation purposes
    -- first port interface (for control and data read)
	c_clk: in std_logic; -- clock
	c_do: out std_logic_vector(7 downto 0); -- control interface signals
	c_adr: in std_logic_vector(c_adr_width-1 downto 0);
    -- second port for logic analyser data write
	la_clk: in std_logic; -- ignored when two_clocks=0
	la_we: in std_logic; -- write enable
    la_di: in std_logic_vector(data_width-1 downto 0); 
  	la_adr: in std_logic_vector(mem_adr_width-1 downto 0));
end la_mem;

architecture la_mem_arch of la_mem is
 -- define!!! these constants for different FPGA families: Virtex: 16 and 4096; Virtex II 32 and 16*1024
 constant BRAM_max_data_width: integer:= 16; -- max data width for BlockRAM (16-for Virtex, 32-for Virtex II)
 constant BRAM_size: integer:= 4*1024; -- BlockRAM memory size [bits](the la_mem is build with blocks of this RAMs

component la_bram -- single port memory
  generic (data_width: integer:= 8; -- width of the data
    adr_width: integer:= 9; -- width of the address 
  	two_clocks: integer:= 0); -- =0 only one clock is used, =1 two seprrate clocks are used
  port (clka, wea: in std_logic;
    dia: in std_logic_vector(data_width-1 downto 0);
  	addra: in std_logic_vector(adr_width-1 downto 0);
	-- dual port interface (Wishbone interface)
	clkb: in std_logic; 
	dob: out std_logic_vector(data_width-1 downto 0);
	addrb: in std_logic_vector(adr_width-1 downto 0));
  end component;  
  
-- find width of data bus for each BlockRAM
function BramDataWidth(data_width: integer; adr_width: integer;
	BRAM_max_data_width: integer; BRAM_size: integer) return integer is
  variable ret: integer;
  variable no_bram: integer; -- number of bram used
begin
  no_bram:= (data_width*(2**adr_width))/BRAM_size;
  if no_bram<1 then no_bram:= 1; end if;
  ret:= data_width/no_bram;
  if BRAM_max_data_width < ret then
	ret:= BRAM_max_data_width;
  end if;
  return ret;
end BramDataWidth;
-- find number of BRAMs 
function NumberBram(data_width: integer; adr_width: integer; bram_data_width: integer;
	BRAM_max_data_width: integer; BRAM_size: integer) return integer is
  variable ret: integer;
begin
  ret:= BRAM_size/(data_width*(2**adr_width));
  if BRAM_max_data_width>bram_data_width then
	  ret:= BRAM_max_data_width / bram_data_width;
  end if;
  return ret;
end NumberBram;
	
  constant bram_data_width: integer:= BramDataWidth(data_width, 
     mem_adr_width, BRAM_max_data_width, BRAM_size); -- DATA WIDTH OF bram
  constant no_bram: INTEGER:= NumberBram(data_width, mem_adr_width, 
     bram_data_width, BRAM_max_data_width, BRAM_size); -- number of BRAM used

  signal d_data: std_logic_vector(data_width-1 downto 0); -- data read from the dual port
  constant mux_size: integer:= c_adr_width-mem_adr_width; -- address width for c_do multiplexer 
  signal mux_adr: std_logic_vector(mux_size downto 0); -- the MSB is never used (only becuase vector_width>0)  
  
begin 

gi: for i in 0 to no_bram-1 generate 
	ri: la_bram
	generic map(data_width=> bram_data_width, adr_width=> mem_adr_width, 
		two_clocks=>two_clocks)
    port map (clka=>la_clk, wea=> la_we, 
	   dia=> la_di((i+1)*bram_data_width-1 downto i*bram_data_width), addra=> la_adr,
	   -- dual port interface (Wishbone interface)
	   clkb=> c_clk, dob=> d_data((i+1)*bram_data_width-1 downto i*bram_data_width),
	   addrb=> c_adr(c_adr_width-1 downto mux_size));
end generate;

 -- generate multiplexer that will select proper c_do data from d_data
g0: if mux_size=0 generate
	c_do<= d_data;
end generate;

 ----------------------------------------------
 -- remove the below section if data width for different ports is different (data out multiplexer is not needed)
		 

gen_adr: if mux_size>0 generate	
	-- generate c_adr flip flops (BRAM memory generates one clk delay - so must the multiplexer
  process (c_clk, arst) begin 
 	if arst='1' then mux_adr(mux_size-1 downto 0)<= (others=>'0');
	elsif c_clk'event and c_clk = '1' then  
 		mux_adr(mux_size-1 downto 0)<= c_adr(mux_size-1 downto 0);
 	end if; 
 end process; 
end generate;

g1: if mux_size=1 generate -- mux 2:1
  	c_do <= d_data(15 downto 8) when mux_adr(0)='1' else
	        d_data(7 downto 0);
end generate;
  
g2: if mux_size=2 generate
	c_do <= d_data(31 downto 24) when mux_adr(1 downto 0)="11" else
	        d_data(23 downto 16) when  mux_adr(1 downto 0)="10" else
	        d_data(15 downto 8) when  mux_adr(1 downto 0)="01" else
			d_data(7 downto 0); -- when "00"
end generate;

end la_mem_arch;