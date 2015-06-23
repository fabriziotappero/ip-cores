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
-- Entity: SecAddrReg
-- Date:2011-11-09  
-- Author: Andrzej Paluch
--
-- Description ${cursor}
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity SecAddrReg is
	port (
		reset : in std_logic;
		strobe : in std_logic;
		data_in : in std_logic_vector (15 downto 0);
		data_out : out std_logic_vector (15 downto 0);
		-- gpib
		secAddrMask : out std_logic_vector (15 downto 0)
	);
end SecAddrReg;

architecture arch of SecAddrReg is

	signal inner_buf : std_logic_vector (15 downto 0);

begin

	data_out <= inner_buf;
	secAddrMask <= inner_buf;

	process (reset, strobe) begin
		if reset = '1' then
			inner_buf <= "0000000000000000";
		elsif rising_edge(strobe) then
			inner_buf <= data_in;
		end if;
	end process;

end arch;

