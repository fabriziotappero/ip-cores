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
-- Entity: EdgeDetector
-- Date:2011-11-25  
-- Author: Andrzej Paluch
--
-- Description ${cursor}
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.helperComponents.all;

entity EdgeDetector is
	generic (
		RISING : std_logic := '1';
		FALLING : std_logic := '0';
		PULSE_WIDTH : integer := 10
	);
	
	port (
		reset : in std_logic;
		clk : in std_logic;
		in_data : in std_logic;
		pulse : out std_logic
	);
end EdgeDetector;

architecture arch of EdgeDetector is

	signal t_i, t_o : std_logic;
	signal lastData : std_logic;

begin

	process(reset, clk, t_o, in_data) begin
		if reset = '1' then
			t_i <= t_o;
			lastData <= in_data;
		elsif rising_edge(clk) then
			if lastData /= in_data then
				if RISING='1' and lastData='0' and in_data='1' then
					t_i <= not t_o;
				end if;
				
				if FALLING='1' and lastData='1' and in_data='0' then
					t_i <= not t_o;
				end if;
			end if;
			lastData <= in_data;
		end if;
	end process;

	spg: SinglePulseGenerator generic map (WIDTH => PULSE_WIDTH) port map (
		reset => reset, clk => clk, t_in => t_i, t_out => t_o, pulse => pulse
	);

end arch;

