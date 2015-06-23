----------------------------------------------------------------------------
--  This file is a part of the LM VHDL IP LIBRARY
--  Copyright (C) 2009 Jose Nunez-Yanez
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  See the file COPYING for the full details of the license.
--
--  The license allows free and unlimited use of the library and tools for research and education purposes. 
--  The full LM core supports many more advanced motion estimation features and it is available under a 
--  low-cost commercial license. See the readme file to learn more or contact us at 
--  eejlny@byacom.co.uk or www.byacom.co.uk
-------------------------------------------
--  entity       = forward_engine        --
--  version      = 1.0                   --
--  last update  = 1/10/07               --
--  author       = Jose Nunez            --
-------------------------------------------


-- FUNCTION
-- forward data into distance engine memories for fp data

library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned."+";
use work.config.all;

entity forward_engine is
port(
    clk : in std_logic;
    clear : in std_logic;
    reset : in std_logic;
    enable_hp_inter : in std_logic; -- when hp interpolation is being performed in the background
    write_register : in std_logic;
    mode_in : in mode_type;
    in_pixels : in std_logic_vector(63 downto 0);
    partition_count_in : in std_logic_vector(3 downto 0);
    write_block1 : out std_logic;  -- control which of the two blocks is being read and written (interpolate and dist engine)
    rma_address : out std_logic_vector(4 downto 0); -- extracted reference pixels use this address
    rma_we : out std_logic;
    out_pixels : out std_logic_vector(63 downto 0)
    );
end forward_engine;

architecture behav of forward_engine is

type state_type is (idle,write_line_m8x8,write_line_m8x16,write_line_m16x8,write_line,wait_for_distance_engine,wait_for_distance_engine2); -- me control unit states

type state_register_type is record
   state : state_type;
   rma_address : std_logic_vector(5 downto 0); -- address for the reference macroblock memory
   write_block1 : std_logic; -- flag
   pixel_registers : std_logic_vector(63 downto 0); 
end record;


signal r,r_in : state_register_type;
signal pixels : std_logic_vector(127 downto 0);

begin
    
    
shift : process(r,in_pixels,write_register,enable_hp_inter)

variable v : state_register_type;

begin
    
    v.pixel_registers := r.pixel_registers;
    if (write_register = '1' and enable_hp_inter = '0') then -- in enable hp inter then this unit should wait
        v.pixel_registers := in_pixels;
    end if;   
    r_in.pixel_registers <= v.pixel_registers;
    
end process shift;


control :process(r,write_register,pixels,mode_in,enable_hp_inter,partition_count_in)
variable vrma_we : std_logic;
variable v : state_register_type;
begin

   v.state := r.state;
   v.rma_address := r.rma_address;
   v.write_block1 := r.write_block1;
   vrma_we := '0';
   
   
   case v.state is

     when idle =>    
		 v.rma_address := "000000"; 
	     if (write_register = '1' and enable_hp_inter = '0') then
	      		v.rma_address := v.rma_address + "000001";
				v.state := write_line;
		 end if;
     when write_line =>
   	      vrma_we := '1';
   	      v.rma_address := v.rma_address + "00001";
   	      if (r.rma_address = "100000")then -- 16 lines in 32 locations 
   	             v.state := idle;
   	             v.rma_address := (others => '0'); 
   	             v.write_block1 := not(v.write_block1);
   	      elsif (write_register = '0') then
   	             v.state := idle;
   	      end if;   
   	when others => null;
   	end case;
 
   	 rma_we <= vrma_we;
   	 rma_we <= vrma_we;
   	 r_in.rma_address <= v.rma_address;
   	 r_in.state <= v.state;
   	 r_in.write_block1 <= v.write_block1;
   	 
end process control;

out_pixels <= r.pixel_registers;
rma_address <= r.rma_address(4 downto 0);
write_block1 <= r.write_block1;

regs : process(clk,clear)

begin

 if (clear = '1') then
   r.state <= idle;
   r.write_block1 <= '1';
   r.rma_address <= (others => '0');
	r.pixel_registers <= (others => '0');
 elsif rising_edge(clk) then 
		if (reset = '1') then -- general enable
               r.state <= idle;
               r.write_block1 <= '1';
               r.rma_address <= (others => '0');
		   r.pixel_registers <= (others => '0');
		else
		   r <= r_in;
		end if;
 end if;

end process regs; 


end behav; -- end of architecture





