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
-- Entity: WriterControlReg0
-- Date:2011-11-10  
-- Author: Andrzej Paluch
--
-- Description ${cursor}
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.utilPkg.all;
use work.helperComponents.all;

entity WriterControlReg0 is
	port (
		clk : in std_logic;
		reset : in std_logic;
		strobe : in std_logic;
		data_in : in std_logic_vector (15 downto 0);
		data_out : out std_logic_vector (15 downto 0);
		------------------- gpib -------------------------
		-- buffer consumed
		buf_interrupt : in std_logic;
		-- data avilable - at least one byte in buffer
		data_available : out std_logic;
		-- indicates end of stream
		end_of_stream : out std_logic;
		-- resets buffer
		reset_buffer : out std_logic;
		-- secondary address of data
		dataSecAddr : out std_logic_vector (4 downto 0);
		-- serial poll status byte
		status_byte : out std_logic_vector (6 downto 0)
	);
end WriterControlReg0;

architecture arch of WriterControlReg0 is

	signal i_data_available : std_logic;
	signal i_end_of_stream : std_logic;
	signal i_reset_buffer : std_logic;
	signal i_dataSecAddr : std_logic_vector (4 downto 0);
	signal i_status_byte : std_logic_vector (6 downto 0);
	
	signal t_in, t_out : std_logic;

begin

	data_out(0) <= buf_interrupt;
	data_out(1) <= i_data_available;
	data_out(2) <= i_end_of_stream;
	data_out(3) <= i_reset_buffer;
	data_out(8 downto 4) <= i_dataSecAddr;
	data_out(15 downto 9) <= i_status_byte;
	
	data_available <= i_data_available;
	end_of_stream <= i_end_of_stream;
	reset_buffer <= i_reset_buffer;
	dataSecAddr <= i_dataSecAddr;
	status_byte <= i_status_byte;

	process (reset, strobe) begin
		if reset = '1' then
			t_in <= '0';
			i_data_available <= '1';
		elsif rising_edge(strobe) then
			
			i_data_available <= data_in(1);
			i_end_of_stream <= data_in(2);
			
			if data_in(3) = '1' then
				t_in <= not t_out;
			end if;
			
			i_dataSecAddr <= data_in(8 downto 4);
			i_status_byte <= data_in(15 downto 9);
			
		end if;
	end process;

	spg: SinglePulseGenerator generic map (WIDTH => 3) port map(
		reset => reset, clk => clk,
		t_in => t_in, t_out => t_out,
		pulse => i_reset_buffer
	);

end arch;

