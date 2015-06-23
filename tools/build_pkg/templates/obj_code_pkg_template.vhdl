--------------------------------------------------------------------------------
-- obj_code_pkg.vhdl -- Application object code in vhdl constant string format.
--------------------------------------------------------------------------------
-- Built for project '@project_name@'.
--------------------------------------------------------------------------------
-- This file contains object code in the form of a VHDL byte table constant.
-- This constant can be used to initialize FPGA memories for synthesis or
-- simulation.
-- Note that the object code is stored as a plain byte table in byte address
-- order. This table knows nothing of data endianess and can be used to 
-- initialize 32-, 16- or 8-bit-wide memory -- memory initialization functions 
-- can be found in package mips_pkg.
--------------------------------------------------------------------------------
-- Copyright (C) 2012 Jose A. Ruiz
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
use ieee.numeric_std.all;
use work.mips_pkg.all;

package @obj_pkg_name@ is

-- Hardcoded simulation parameters ---------------------------------------------

-- Simulation clock rate
constant CLOCK_RATE : integer   := 50e6;
-- Simulation clock period
constant T : time               := (1.0e9/real(CLOCK_RATE)) * 1 ns;

-- Other simulation parameters -------------------------------------------------

@constants@

-- Memory initialization data --------------------------------------------------

@obj_tables@

end package @obj_pkg_name@;
