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
-- Entity: SerialPollCoordinator
-- Date:2011-11-03  
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

entity SerialPollCoordinator is
	port (
		-- clock
		clk : in std_logic;
		-- reset
		reset : in std_logic;
		-- data accepted
		DAC : in std_logic;
		-- receive status byte
		rec_stb : in std_logic;
		-- attention in
		ATN_in : in std_logic;
		-- attention out
		ATN_out : out std_logic;
		-- output valid in
		output_valid_in : in std_logic;
		-- output valid out
		output_valid_out : out std_logic;
		-- stb received
		stb_received : out std_logic
	);
end SerialPollCoordinator;

architecture arch of SerialPollCoordinator is

	-- serial poll coordinator states
	type SPC_STATE is (
		ST_IDLE,
		ST_WAIT_DAC,
		ST_WAIT_REC_STB_0
	);

	signal current_state : SPC_STATE;

begin

	ATN_out <= '0' when current_state = ST_WAIT_DAC else ATN_in;
	output_valid_out <= '0' when current_state = ST_WAIT_DAC else output_valid_in;
	stb_received <= '1' when current_state = ST_WAIT_REC_STB_0 else '0';

	process (clk, reset) begin
		if reset = '1' then
			current_state <= ST_IDLE;
		elsif rising_edge(clk) then
			case current_state is
				when ST_IDLE =>
					if rec_stb='1' then
						current_state <= ST_WAIT_DAC;
					end if;
				when ST_WAIT_DAC =>
					if DAC='1' then
						current_state <= ST_WAIT_REC_STB_0;
					elsif rec_stb='0' then
						current_state <= ST_IDLE;
					end if;
				when ST_WAIT_REC_STB_0 =>
					if rec_stb='0' then
						current_state <= ST_IDLE;
					end if;
				when others =>
					current_state <= ST_IDLE;
			end case;
		end if;
	end process;

end arch;

