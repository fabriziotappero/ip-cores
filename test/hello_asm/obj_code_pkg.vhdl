--------------------------------------------------------------------------------
-- obj_code_pkg.vhdl -- Application object code in vhdl constant string format.
--------------------------------------------------------------------------------
-- Written by build_rom.py for project 'hello_asm'.
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
use work.light52_pkg.all;

package obj_code_pkg is

-- Size of XCODE memory in bytes.
constant XCODE_SIZE : natural := 2048;
-- Size of XDATA memory in bytes.
constant XDATA_SIZE : natural := 0;

-- Object code initialization constant.
constant object_code : t_obj_code(0 to 149) := (
    X"02", X"00", X"30", X"02", X"00", X"6c", X"00", X"00", 
    X"00", X"00", X"00", X"02", X"00", X"6e", X"00", X"00", 
    X"00", X"00", X"00", X"02", X"00", X"6c", X"00", X"00", 
    X"00", X"00", X"00", X"02", X"00", X"6c", X"00", X"00", 
    X"00", X"00", X"00", X"02", X"00", X"6d", X"00", X"00", 
    X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
    X"75", X"81", X"40", X"75", X"80", X"00", X"75", X"90", 
    X"00", X"90", X"00", X"7e", X"12", X"00", X"59", X"75", 
    X"a8", X"00", X"75", X"88", X"00", X"75", X"8f", X"fc", 
    X"75", X"8e", X"50", X"75", X"a8", X"82", X"75", X"88", 
    X"30", X"01", X"51", X"f5", X"99", X"30", X"9c", X"fd", 
    X"22", X"c0", X"30", X"75", X"30", X"00", X"e5", X"30", 
    X"05", X"30", X"93", X"60", X"04", X"11", X"53", X"80", 
    X"f5", X"d0", X"30", X"22", X"32", X"32", X"d2", X"88", 
    X"c0", X"83", X"c0", X"82", X"90", X"00", X"8e", X"11", 
    X"59", X"d0", X"82", X"d0", X"83", X"32", X"48", X"65", 
    X"6c", X"6c", X"6f", X"20", X"57", X"6f", X"72", X"6c", 
    X"64", X"21", X"0d", X"0a", X"00", X"00", X"54", X"69", 
    X"63", X"6b", X"21", X"0d", X"0a", X"00" 
);


end package obj_code_pkg;
