--------------------------------------------------------------------------------
--This file is part of fpga_gpib_controller.
--
-- Fpga_gpib_controller is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- Fpga_gpib_controller is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with Fpga_gpib_controller.  If not, see <http://www.gnu.org/licenses/>.
--------------------------------------------------------------------------------
-- Entity: 	utilPkg
-- Date:	2011-10-09  
-- Author: Andrzej Paluch
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package utilPkg is

	-- converts boolean to std_logic '0' or '1'
	function to_stdl(b : boolean) return std_logic;
	
	-- converts std_logic to boolean
	function is_1(v : std_logic) return boolean;

end;

package body utilPkg is

	function to_stdl(b : boolean) return std_logic is begin
		if b then
			return '1';
		else
			return '0';
		end if;
	end function;

	function is_1(v : std_logic) return boolean is begin
		if v = '1' then
			return true;
		else
			return false;
		end if;
	end function;

end package body;