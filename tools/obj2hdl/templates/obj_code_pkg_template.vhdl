--------------------------------------------------------------------------------
-- obj_code_pkg.vhdl -- Application object code in vhdl constant string format.
--------------------------------------------------------------------------------
-- This is where the application code lives.
-- FIXME should only be used from top level entity
-- FIXME name of package should be application-related
-- FIXME convert to vhdl template
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
use ieee.numeric_std.all;

package @obj_pkg_name@ is

constant object_code : 
  array(0 to @obj_size@) of std_logic_vector(7 downto 0) := (
    @obj_bytes@
    );


end package @obj_pkg_name@;
