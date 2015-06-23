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
-- Entity: gpibBusReg
-- Date:2011-11-13  
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

entity gpibBusReg is
	port (
		data_out : out std_logic_vector (15 downto 0);
		------------------------------------------------
		-- interface signals
		DIO : in std_logic_vector (7 downto 0);
		-- attention
		ATN : in std_logic;
		-- data valid
		DAV : in std_logic;
		-- not ready for data
		NRFD : in std_logic;
		-- no data accepted
		NDAC : in std_logic;
		-- end or identify
		EOI : in std_logic;
		-- service request
		SRQ : in std_logic;
		-- interface clear
		IFC : in std_logic;
		-- remote enable
		REN : in std_logic
	);
end gpibBusReg;

architecture arch of gpibBusReg is

begin

	data_out(7 downto 0) <= DIO;
	data_out(8) <= ATN;
	data_out(9) <= DAV;
	data_out(10) <= NRFD;
	data_out(11) <= NDAC;
	data_out(12) <= EOI;
	data_out(13) <= SRQ;
	data_out(14) <= IFC;
	data_out(15) <= REN;

end arch;

