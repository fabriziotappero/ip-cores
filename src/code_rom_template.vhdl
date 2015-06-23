--------------------------------------------------------------------------------
-- @fileinfo@
--------------------------------------------------------------------------------
-- Synthesizable ROM implemented on regular FPGA BLock RAM MPU.
--
-- Meant to be used as bootstrap code ROM in project ION, hence the fixed
-- entity name.
--
-- This package provides constants and types that will be used wherever the code
-- BRAM is implemented, presumably in the mips_mpu module (see that module for
-- an usage example).
--
-- Note that no vendor-specific stuff needs to be used at all to infer the
-- read-only, single port BRAM we're interested in.
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

package code_rom_pkg is

-- BRAM table and address word sizes...
constant CODE_BRAM_SIZE : integer := @code_table_size@;
constant CODE_BRAM_ADDR_SIZE : integer := log2(CODE_BRAM_SIZE);
subtype t_bram_address is std_logic_vector(CODE_BRAM_ADDR_SIZE-1 downto 0);
-- ...and the type of the actual table that will hold the data.
type t_bram is array(0 to (CODE_BRAM_SIZE)-1) of t_word;

-- This constant defines the contents of the BRAM.
constant code_bram :                  t_bram := (@code-32bit@);

end package;
