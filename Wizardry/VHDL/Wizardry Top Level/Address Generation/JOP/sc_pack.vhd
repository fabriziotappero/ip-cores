--
--
--  This file is a part of JOP, the Java Optimized Processor
--
--  Copyright (C) 2001-2008, Martin Schoeberl (martin@jopdesign.com)
--
--  This program is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program.  If not, see <http://www.gnu.org/licenses/>.
--


--
--	sc_pack.vhd
--
--	Package for SimpCon defines
--
--	Author: Martin Schoeberl (martin@jopdesign.com)
--	
--
--	2007-03-16  first version
--
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package sc_pack is

	-- two more bits than needed for the main memory
	--    one to distinguishe between memory and IO access
	--    one more to allow memory mirroring for size auto
	--        detection at boot time
	constant SC_ADDR_SIZE : integer := 23;
	constant RDY_CNT_SIZE : integer := 2;

	type sc_out_type is record
		address		: std_logic_vector(SC_ADDR_SIZE-1 downto 0);
		wr_data		: std_logic_vector(31 downto 0);
		rd			: std_logic;
		wr			: std_logic;
		atomic	: std_logic;
	end record;

	type sc_in_type is record
		rd_data		: std_logic_vector(31 downto 0);
		rdy_cnt		: unsigned(RDY_CNT_SIZE-1 downto 0);
	end record;
	
	type sc_out_array_type is array (integer range <>) of sc_out_type;
	type sc_in_array_type is array (integer range <>) of sc_in_type;
	
end sc_pack;
