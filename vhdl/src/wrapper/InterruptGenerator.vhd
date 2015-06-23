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
-- Entity: InterruptGenerator
-- Date:2011-11-25  
-- Author: Andrzej Paluch
--
-- Description ${cursor}
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.helperComponents.all;


entity InterruptGenerator is
	port (
		reset : std_logic;
		clk : in std_logic;
		interrupt : out std_logic;
		-------------------- gpib device ---------------------
		-- device is local controlled
		isLocal : in std_logic;
		-- input buffer ready
		in_buf_ready : in std_logic;
		-- output buffer ready
		out_buf_ready : in std_logic;
		-- clear device (DC)
		clr : in std_logic;
		-- trigger device (DT)
		trg : in std_logic;
		-- addressed to talk(L or LE)
		att : in std_logic;
		-- addressed to listen (T or TE)
		atl : in std_logic;
		-- seriall poll active
		spa : in std_logic;
		-------------------- gpib controller ---------------------
		-- controller write commands
		cwrc : in std_logic;
		-- controller write data
		cwrd : in std_logic;
		-- service requested
		srq : in std_logic;
		-- parallel poll ready
		ppr : in std_logic;
		-- stb received
		stb_received : in std_logic;
		REN : in std_logic;
		ATN : in std_logic;
		IFC : in std_logic
	);
end InterruptGenerator;

architecture arch of InterruptGenerator is

	constant PULSE_WIDTH : integer := 10;
	
	signal p0, p1, p2, p3, p4, p5, p6, p7 : std_logic;

begin

	interrupt <= p0 or p1 or p2 or p3 or p4 or p5 or p6 or p7;
	
	
	ed0: EdgeDetector generic map (RISING => '1', FALLING => '0',
		PULSE_WIDTH => PULSE_WIDTH) port map (
		reset => reset, clk => clk, in_data => in_buf_ready, pulse => p0
	);

	ed1: EdgeDetector generic map (RISING => '1', FALLING => '0',
		PULSE_WIDTH => PULSE_WIDTH) port map (
		reset => reset, clk => clk, in_data => out_buf_ready, pulse => p1
	);
	
	ed2: EdgeDetector generic map (RISING => '1', FALLING => '0',
		PULSE_WIDTH => PULSE_WIDTH) port map (
		reset => reset, clk => clk, in_data => clr, pulse => p2
	);

	ed3: EdgeDetector generic map (RISING => '1', FALLING => '0',
		PULSE_WIDTH => PULSE_WIDTH) port map (
		reset => reset, clk => clk, in_data => trg, pulse => p3
	);
	
	ed4: EdgeDetector generic map (RISING => '1', FALLING => '0',
		PULSE_WIDTH => PULSE_WIDTH) port map (
		reset => reset, clk => clk, in_data => srq, pulse => p4
	);
	
	ed5: EdgeDetector generic map (RISING => '1', FALLING => '0',
		PULSE_WIDTH => PULSE_WIDTH) port map (
		reset => reset, clk => clk, in_data => ppr, pulse => p5
	);

	ed6: EdgeDetector generic map (RISING => '1', FALLING => '0',
		PULSE_WIDTH => PULSE_WIDTH) port map (
		reset => reset, clk => clk, in_data => stb_received, pulse => p6
	);
	
	ed7: EdgeDetector generic map (RISING => '1', FALLING => '1',
		PULSE_WIDTH => PULSE_WIDTH) port map (
		reset => reset, clk => clk, in_data => isLocal, pulse => p7
	);

end arch;

