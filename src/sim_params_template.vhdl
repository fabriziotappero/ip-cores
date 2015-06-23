--------------------------------------------------------------------------------
-- @fileinfo@
--------------------------------------------------------------------------------
-- Stuff used in the simulation of external ROM (FLASH).
--
-- This package provides constants and types to be used when simulating an 
-- external ROM (FLASH) connected to the MCU. It is only meant to be used 
-- in the test bench.
--------------------------------------------------------------------------------
-- Copyright (C) 2011 Jose A. Ruiz
--                                                              
-- This source file may be used and distributed without         
-- restriction provided that this copyright statement is not    
-- removed from the file and that any derivative work contains  
-- the original copyright notice and the associated disclaimer. 
--                                                              
-- This source file is free software; you can redistribute it   
-- and/or modify it under the terms of the GNU Lesser General   
-- Public License as published by the Free Software Foundation; 
-- either version 2.1 of the License, or (at your option) any   
-- later version.                                               
--                                                              
-- This source is distributed in the hope that it will be       
-- useful, but WITHOUT ANY WARRANTY; without even the implied   
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
-- PURPOSE.  See the GNU Lesser General Public License for more 
-- details.                                                     
--                                                              
-- You should have received a copy of the GNU Lesser General    
-- Public License along with this source; if not, download it   
-- from http://www.opencores.org/lgpl.shtml
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.mips_pkg.all;

package sim_params_pkg is

---- General simulation parameters ---------------------------------------------

-- Master clock period...
constant T : time               := 20 ns;
-- ...and matching clock rate
-- FIXME define them once, use formula with clumsy VHDL type conversion
constant CLOCK_RATE : integer   := 50000000;

-- Simulation length in clock cycles, should be long enough. 
-- This is adjusted by trial and error for each code sample.
constant SIMULATION_LENGTH : integer := @sim_len@;

-- This is the address that will trigger logging when fetched from
constant LOG_TRIGGER_ADDRESS : t_word := @log_trigger_addr@;


---- Data for the simulation of external FLASH ---------------------------------

-- Simulated FLASH table and address sizes...
constant PROM_SIZE : integer := @prom_size@;
constant PROM_ADDR_SIZE : integer := log2(PROM_SIZE);
-- ...and the type of the table that will hold the simulated data
subtype t_prom_address is std_logic_vector(PROM_ADDR_SIZE-1 downto 0);
type t_prom is array(0 to PROM_SIZE-1) of t_word;

-- This constant is where the simulated FLASH contents are defined.
constant PROM_DATA : t_prom := (@flash@);

---- Data for the simulation of external 16-bit-wide SRAM ----------------------

-- Simulated external SRAM size in 32-bit words 
constant SRAM_SIZE : integer := @xram_size@;

-- External SRAM address length
-- Memory is 16 bits wide so we stick an extra address bit
constant SRAM_ADDR_SIZE : integer := log2(SRAM_SIZE)+1;

-- This is a 16-bit SRAM split in 2 byte slices; so each slice will have two
-- bytes for each word of SRAM_SIZE
-- FIXME in simulation we can use a simpler 16-bit-wide table
type t_sram is array(0 to SRAM_SIZE*2-1) of std_logic_vector(7 downto 0);

end package;
