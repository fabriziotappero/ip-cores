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
-- Entity: SettingsReg0
-- Date:2011-11-09  
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

entity SettingsReg1 is
	port (
		reset : in std_logic;
		strobe : in std_logic;
		data_in : in std_logic_vector (15 downto 0);
		data_out : out std_logic_vector (15 downto 0);
		-- gpib
		myAddr : out std_logic_vector (4 downto 0);
		T1 : out std_logic_vector (7 downto 0)
	);
end SettingsReg1;

architecture arch of SettingsReg1 is

	signal inner_buf : std_logic_vector (15 downto 0);

begin

	inner_buf(15 downto 13) <= "000";

	data_out <= inner_buf;

	myAddr <= inner_buf(4 downto 0);
	T1 <= inner_buf(12 downto 5);

	process (reset, strobe) begin
		if reset = '1' then
			-- default 132*Tclk = 2uS and addr=1
			inner_buf(12 downto 0) <= "1000010000001";
		elsif rising_edge(strobe) then
			inner_buf(12 downto 0) <= data_in(12 downto 0);
		end if;
	end process;

end arch;

