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
-- Entity: SecondaryAddressDecoder
-- Date:2011-11-07  
-- Author: Andrzej Paluch
--
-- Description ${cursor}
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity SecondaryAddressDecoder is
	port (
		-- secondary address mask
		secAddrMask : in std_logic_vector (31 downto 0);
		-- data input
		DI : in std_logic_vector (4 downto 0);
		-- secondary address detected
		secAddrDetected : out std_logic
	);
end SecondaryAddressDecoder;

architecture arch of SecondaryAddressDecoder is

begin

	secAddrDetected <= secAddrMask(conv_integer(DI));

end arch;

