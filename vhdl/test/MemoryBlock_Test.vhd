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
--
-- Create Date:   23:50:53 11/16/2011
-- Design Name:   MemoryBlock
-- Module Name:   J:/projekty/elektronika/USB_to_HPIB/usbToHpib/src/test/MemoryBlock_Test.vhd
-- Project Name:  usbToGpib
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: MemoryBlock
--
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends 
-- that these types always be used for the top-level I/O of a design in order 
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;

use work.helperComponents.all;

ENTITY MemoryBlock_Test_vhd IS
END MemoryBlock_Test_vhd;

ARCHITECTURE behavior OF MemoryBlock_Test_vhd IS 

	constant clk_period : time := 1us;
	

	SIGNAL reset :  std_logic := '0';
	SIGNAL clk :  std_logic := '0';
	-------------------------------------------------
	SIGNAL p1_addr : std_logic_vector(10 downto 0) := (others => '0');
	SIGNAL p1_data_in : std_logic_vector(7 downto 0) := (others => '0');
	SIGNAL p1_data_out : std_logic_vector(7 downto 0);
	SIGNAL p1_strobe : std_logic := '0';
	-------------------------------------------------
	SIGNAL p2_addr : std_logic_vector(10 downto 0) := (others => '0');
	SIGNAL p2_data_in : std_logic_vector(7 downto 0) := (others => '0');
	SIGNAL p2_data_out : std_logic_vector(7 downto 0);
	SIGNAL p2_strobe : std_logic := '0';
	
BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut: MemoryBlock port map (
		reset => reset,
		clk => clk,
		-------------------------------------------------
		p1_addr => p1_addr,
		p1_data_in => p1_data_in,
		p1_strobe => p1_strobe,
		p1_data_out => p1_data_out,
		-------------------------------------------------
		p2_addr => p2_addr,
		p2_data_in => p2_data_in,
		p2_strobe => p2_strobe,
		p2_data_out => p2_data_out
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
		wait for clk_period*20;

		p1_addr <= "00000000000";
		p2_addr <= "00000000000";
		p1_data_in <= "10101010";
		
		wait for clk_period/2;
		
		p1_strobe <= '1';
		wait for clk_period;
		p1_strobe <= '0';

		wait for clk_period*4;
		
		p2_addr <= "00000000101";
		p2_data_in <= "11010101";
		
		wait for clk_period;
		
		p2_strobe <= '1';
		wait for clk_period;
		p2_strobe <= '0';
		
		wait for clk_period*4;
		
		p1_addr <= "00000000101";
		
		wait; -- will wait forever
	END PROCESS;

END;
