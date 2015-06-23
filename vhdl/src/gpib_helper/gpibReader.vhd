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
-- Entity: gpibReader
-- Date: 2011-10-30  
-- Author: Andrzej Paluch
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

use work.utilPkg.all;


entity gpibReader is
	port (
		-- clock
		clk : in std_logic;
		-- reset
		reset : std_logic;
		------------------------------------------------------------------------
		------ GPIB interface --------------------------------------------------
		------------------------------------------------------------------------
		-- input data
		data_in : in std_logic_vector (7 downto 0);
		-- data valid
		dvd : in std_logic;
		-- listener active
		lac : in std_logic;
		-- last byte
		lsb : in std_logic;
		-- ready to next byte
		rdy : out std_logic;
		------------------------------------------------------------------------
		------ external interface ----------------------------------------------
		------------------------------------------------------------------------
		-- is LE function active
		isLE : in std_logic;
		-- current secondary address
		secAddr : in std_logic_vector (4 downto 0);
		-- secondary address of data
		dataSecAddr : out std_logic_vector (4 downto 0);
		-- buffer ready interrupt
		buf_interrupt : out std_logic;
		-- indicates end of stream
		end_of_stream : out std_logic;
		-- resets reader
		reset_reader : in std_logic;
		------------------ fifo --------------------------------------
		-- indicates fifo full
		fifo_full : in std_logic;
		-- indicates fifo ready to write
		fifo_ready_to_write : in std_logic;
		-- indicates at least one byte in fifo
		at_least_one_byte_in_fifo : in std_logic;
		-- output data
		data_out : out std_logic_vector (7 downto 0);
		-- fifo strobe
		fifo_strobe : out std_logic
	);
end gpibReader;

architecture arch of gpibReader is

	-- reader states
	type READER_STATE is (
		ST_IDLE,
		ST_WAIT_DVD_1,
		ST_WAIT_DVD_0
	);

	signal current_state : READER_STATE;
	signal buf_ready_to_write : boolean;
	
begin

	buf_interrupt <= not to_stdl(buf_ready_to_write);
	

	process (clk, reset, reset_reader) begin
		if reset = '1' then
			current_state <= ST_IDLE;
			rdy <= '1';
			buf_ready_to_write <= TRUE;
			end_of_stream <= '0';
			fifo_strobe <= '0';
			dataSecAddr <= "00000";
		elsif reset_reader='1' then
			buf_ready_to_write <= TRUE;
			end_of_stream <= '0';
			fifo_strobe <= '0';
			dataSecAddr <= "00000";
		elsif rising_edge(clk) then
			case current_state is
				when ST_IDLE =>
					if lac='1' and buf_ready_to_write then
						
						if isLE = '1' then
							dataSecAddr <= secAddr;
						end if;
						
						rdy <= '1';
						current_state <= ST_WAIT_DVD_1;
					elsif lac='0' and at_least_one_byte_in_fifo='1' then
						buf_ready_to_write <= FALSE;
					end if;
				when ST_WAIT_DVD_1 =>
					if dvd='1' and fifo_ready_to_write='1' then
						fifo_strobe <= '1';
						
						data_out <= data_in;
						
						if lsb='1'or fifo_full='1' then
							buf_ready_to_write <= FALSE;
							end_of_stream <= lsb;
						end if;
						
						rdy <= '0';
						current_state <= ST_WAIT_DVD_0;
					elsif lac='0' then
						current_state <= ST_IDLE;
					end if;
				when ST_WAIT_DVD_0 =>
					if dvd='0' then
						fifo_strobe <= '0';
						current_state <= ST_IDLE;
					end if;
				when others =>
					current_state <= ST_IDLE;
			end case;
		end if;
	end process;

end arch;

