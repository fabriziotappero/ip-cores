/*
        Tauhop Solutions common types.
        
        Author(s): 
        - Daniel C.K. Kho, daniel.kho@opencores.org | daniel.kho@tauhop.com
        
        Copyright (C) 2012-2013 Authors and OPENCORES.ORG
        
        This source file may be used and distributed without 
        restriction provided that this copyright statement is not 
        removed from the file and that any derivative work contains 
        the original copyright notice and the associated disclaimer.
        
        This source file is free software; you can redistribute it 
        and/or modify it under the terms of the GNU Lesser General 
        Public License as published by the Free Software Foundation; 
        either version 2.1 of the License, or (at your option) any 
        later version.
        
        This source is distributed in the hope that it will be 
        useful, but WITHOUT ANY WARRANTY; without even the implied 
        warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR 
        PURPOSE. See the GNU Lesser General Public License for more 
        details.
        
        You should have received a copy of the GNU Lesser General 
        Public License along with this source; if not, download it 
        from http://www.opencores.org/lgpl.shtml.
*/
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

package types is
	type byte is array(7 downto 0) of std_logic;
	type byte_vector is array(natural range <>) of byte;
	
	/* VHDL-2008 datatypes.
		Comment out for simulation. Questa/ModelSim already supports this.
	*/
	type boolean_vector is array(natural range <>) of boolean;
	type integer_vector is array(natural range <>) of integer;
	/* [end]: VHDL-2008 datatypes. */
end package types;

package body types is
end package body types;
