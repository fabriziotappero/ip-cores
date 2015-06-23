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
-- Entity: communication
-- Date:2011-11-27  
-- Author: Andrzej Paluch
--
-- Description ${cursor}
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

package communication is

	component Uart is
		port (
			reset : in std_logic;
			clk : in std_logic;
			---------- UART ---------------
			RX : in std_logic;
			TX : out std_logic;
			---------- gpib ---------------
			data_out : out std_logic_vector(7 downto 0);
			data_out_ready : out std_logic;
			data_in : in std_logic_vector(7 downto 0);
			data_in_ready : in std_logic;
			ready_to_send : out std_logic
		);
	end component;


end communication;

