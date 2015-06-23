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
-- Entity: gpibWriter
-- Date: 2011-11-01
-- Author: Andrzej Paluch
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

use work.utilPkg.all;


entity gpibWriter is
	port (
		-- clock
		clk : in std_logic;
		-- reset
		reset : std_logic;
		------------------------------------------------------------------------
		------ GPIB interface --------------------------------------------------
		------------------------------------------------------------------------
		-- output data
		data_out : out std_logic_vector (7 downto 0);
		-- wait for new cycle
		wnc : in std_logic;
		-- seriall poll active
		spa : in std_logic;
		-- new byte available
		nba : out std_logic;
		-- end of string
		endOf : out std_logic;
		-- talker active
		tac : in std_logic;
		-- controller write command
		cwrc : in std_logic;
		------------------------------------------------------------------------
		------ external interface ----------------------------------------------
		------------------------------------------------------------------------
		-- TE is extended
		isTE : in std_logic;
		-- current secondary address
		secAddr : in std_logic_vector (4 downto 0);
		-- secondary address of data
		dataSecAddr : in std_logic_vector (4 downto 0);
		-- buffer consumed
		buf_interrupt : out std_logic;
		-- indicates end of stream
		end_of_stream : in std_logic;
		-- resets writer
		reset_writer : in std_logic;
		-- enables writer
		writer_enable : in std_logic;
		---------------- fifo ---------------------------
		availableFifoBytesCount : in std_logic_vector(10 downto 0);
		-- fifo read strobe
		fifo_read_strobe : out std_logic;
		-- indicates fifo ready to read
		fifo_ready_to_read : in std_logic;
		-- input data
		fifo_data_in : in std_logic_vector (7 downto 0)
	);
end gpibWriter;

architecture arch of gpibWriter is

	-- writer states
	type WRITER_STATE is (
		ST_IDLE,
		ST_WAIT_WNC_1,
		ST_WAIT_WNC_0
	);


	signal current_state : WRITER_STATE;
	-- triggered by spa
	signal tr_by_spa : std_logic;
	signal readyToSend : boolean;
	signal at_least_one_byte_in_fifo : boolean;
	
begin

	buf_interrupt <= to_stdl(not at_least_one_byte_in_fifo);
	data_out <= fifo_data_in;
	at_least_one_byte_in_fifo <= availableFifoBytesCount /= "000000000000";

	readyToSend <=
		(
				writer_enable = '1'
			and
				at_least_one_byte_in_fifo
			and
			(
				(
					tac='1'
					and
					(
						(isTE='1' and dataSecAddr=secAddr)
						or
						isTE='0'
					)
				)
				or
				cwrc='1'
			)
			and
			fifo_ready_to_read='1'
		)
		or
		spa='1';

	process (clk, reset, reset_writer) begin
		if reset = '1' or reset_writer = '1' then
			nba <= '0';
			endOf <= '0';
			fifo_read_strobe <= '0';
			tr_by_spa <= '0';
			current_state <= ST_IDLE;
		elsif rising_edge(clk) then
			case current_state is
				when ST_IDLE =>
					if readyToSend then
						nba <= '1';
						
						tr_by_spa <= spa;
						
						if availableFifoBytesCount="000000000001" and
								end_of_stream='1' and spa='0' and tac='1' and
								cwrc='0' then
							endOf <= '1';
						end if;
						
						current_state <= ST_WAIT_WNC_1;
					end if;
				when ST_WAIT_WNC_1 =>
					if wnc='1' then
						nba <= '0';
						
						if tr_by_spa='0' then
							endOf <= '0';
							fifo_read_strobe <= '1';
						end if;
						
						current_state <= ST_WAIT_WNC_0;
					end if;
				when ST_WAIT_WNC_0 =>
					if wnc='0' then
						if tr_by_spa='0' then
							fifo_read_strobe <= '0';
						end if;
						
						current_state <= ST_IDLE;
					end if;
				when others =>
					current_state <= ST_IDLE;
			end case;
		end if;
	end process;

end arch;

