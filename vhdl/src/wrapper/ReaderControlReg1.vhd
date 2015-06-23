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
-- Entity: ReaderControlReg0
-- Date:2011-11-10  
-- Author: Andrzej Paluch
--
-- Description ${cursor}
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity ReaderControlReg1 is
	port (
		data_out : out std_logic_vector (15 downto 0);
		------------------ gpib --------------------
		-- num of bytes available in fifo
		bytes_available_in_fifo : in std_logic_vector (10 downto 0)
	);
end ReaderControlReg1;

architecture arch of ReaderControlReg1 is

begin

	data_out(10 downto 0) <= bytes_available_in_fifo(10 downto 0);
	data_out(15 downto 11) <= "00000";

end arch;

