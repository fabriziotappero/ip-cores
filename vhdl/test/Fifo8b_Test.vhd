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
-- Author: Andrzej Paluch
-- Fifo8b test
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
use ieee.std_logic_arith.all;

use work.helperComponents.all;

ENTITY Fifo8b_Test_vhd IS
END Fifo8b_Test_vhd;

ARCHITECTURE behavior OF Fifo8b_Test_vhd IS 

	constant clk_period : time := 1us;
	

	SIGNAL reset :  std_logic := '0';
	SIGNAL clk :  std_logic := '0';
	-------------- fifo --------------------
	SIGNAL bytesAvailable : std_logic;
	SIGNAL availableBytesCount : std_logic_vector(10 downto 0);
	SIGNAL bufferFull : std_logic;
	SIGNAL resetFifo : std_logic := '0';
	----------------------------------------
	SIGNAL data_in : std_logic_vector(7 downto 0) := (others => '0');
	SIGNAL ready_to_write : std_logic;
	SIGNAL strobe_write : std_logic := '0';
		----------------------------------------
	SIGNAL data_out : std_logic_vector(7 downto 0);
	SIGNAL ready_to_read : std_logic;
	SIGNAL strobe_read : std_logic := '0';

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	fifo: Fifo8b port map (
		reset => reset,
		clk => clk,
		-------------- fifo --------------------
		bytesAvailable => bytesAvailable,
		availableBytesCount => availableBytesCount,
		bufferFull => bufferFull,
		resetFifo => resetFifo,
		----------------------------------------
		data_in => data_in,
		ready_to_write => ready_to_write,
		strobe_write => strobe_write,
		----------------------------------------
		data_out => data_out,
		ready_to_read => ready_to_read,
		strobe_read => strobe_read
	);

	-- Clock process definitions
	clk_process :process
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;

	stim_proc: PROCESS
	BEGIN

		reset <= '1';
		wait for clk_period*4;
		reset <= '0';
		wait for clk_period*4;
		
		data_in <= "00000010";
		wait for clk_period;
		strobe_write <= '1';
		wait for clk_period;
		strobe_write <= '0';
		
		wait for clk_period*4;
		
		data_in <= "00000011";
		wait for clk_period;
		strobe_write <= '1';
		wait for clk_period;
		strobe_write <= '0';
		
		wait for clk_period*4;
		
		strobe_read <= '1';
		wait for clk_period;
		strobe_read <= '0';
		
		wait for clk_period*4;
		
		strobe_read <= '1';
		wait for clk_period;
		strobe_read <= '0';
		
		wait for clk_period*4;
		
		data_in <= "00000100";
		wait for clk_period;
		strobe_write <= '1';
		wait for clk_period;
		strobe_write <= '0';
		
		wait for clk_period*4;
		
		strobe_read <= '1';
		wait for clk_period;
		strobe_read <= '0';
		
--		for i in 0 to 2**11-1 loop
--			data_in <= conv_std_logic_vector(i, 8);
--			wait for clk_period;
--			strobe_write <= '1';
--			wait until ready_to_write = '0';
--			strobe_write <= '0';
--			if i < 2**11-1 then
--				wait until ready_to_write = '1';
--			end if;
--		end loop; 
--		
--		wait for clk_period;
--		
--		strobe_read <= '1';
--		wait for clk_period;
--		strobe_read <= '0';
--		
--		wait for clk_period*3;
--		
--		for i in 0 to 1 loop
--			data_in <= conv_std_logic_vector(i, 8);
--			wait for clk_period;
--			strobe_write <= '1';
--			wait until ready_to_write = '0';
--			strobe_write <= '0';
--			wait until ready_to_write = '1';
--		end loop;
		
		wait; -- will wait forever
	END PROCESS;

END;
