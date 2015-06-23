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
-- Entity: EventMem
-- Date:2011-11-11  
-- Author: Andrzej Paluch
--
-- Description ${cursor}
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity EventMem is
	port (
		reset : std_logic;
		-- event occured
		occured : in std_logic;
		-- event approved
		approved : in std_logic;
		-- output
		output : out std_logic
	);
end EventMem;

architecture arch of EventMem is

begin

	process(reset, occured, approved) begin
		if reset = '1' or approved = '1' then
			output <= '0';
		elsif rising_edge(occured) then
			output <= '1';
		end if;
	end process;

end arch;

