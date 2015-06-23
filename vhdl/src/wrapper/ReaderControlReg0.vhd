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
-- Entity: ReaderControlReg0
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

entity ReaderControlReg0 is
	port (
		clk : in std_logic;
		reset : in std_logic;
		strobe : in std_logic;
		data_in : in std_logic_vector (15 downto 0);
		data_out : out std_logic_vector (15 downto 0);
		------------------- gpib -------------------------
		-- buffer ready interrupt
		buf_interrupt : in std_logic;
		-- at least one byte available
		data_available : in std_logic;
		-- indicates end of stream
		end_of_stream : in std_logic;
		-- resets buffer
		reset_buffer : out std_logic;
		-- secondary address of data
		dataSecAddr : in std_logic_vector (4 downto 0)
	);
end ReaderControlReg0;

architecture arch of ReaderControlReg0 is

	signal i_reset_buffer : std_logic;
	
	signal t_in, t_out : std_logic;

begin

	data_out(0) <= buf_interrupt;
	data_out(1) <= data_available;
	data_out(2) <= end_of_stream;
	data_out(3) <= i_reset_buffer;
	data_out(8 downto 4) <= dataSecAddr;
	data_out(15 downto 9) <= "0000000";
	
	reset_buffer <= i_reset_buffer;

	process (reset, strobe) begin
		if reset = '1' then
			t_in <= '0';
		elsif rising_edge(strobe) then
			
			if data_in(3) = '1' then
				t_in <= not t_out;
			end if;
		end if;
	end process;

	spg: SinglePulseGenerator generic map (WIDTH => 3) port map(
		reset => reset, clk => clk,
		t_in => t_in, t_out => t_out,
		pulse => i_reset_buffer
	);

end arch;

