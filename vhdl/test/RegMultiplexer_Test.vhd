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
-- Create Date:   20:43:38 11/14/2011
-- Design Name:   RegMultiplexer
-- Module Name:   J:/projekty/elektronika/USB_to_HPIB/usbToHpib/src/test/RegMultiplexer_Test.vhd
-- Project Name:  usbToGpib
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: RegMultiplexer
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

use work.wrapperComponents.all;

ENTITY RegMultiplexer_Test_vhd IS
END RegMultiplexer_Test_vhd;

ARCHITECTURE behavior OF RegMultiplexer_Test_vhd IS 

	-- clock definitions
	constant clk_period : time := 2ps;
	signal clk : std_logic := '0';


	--Inputs
	SIGNAL strobe :  std_logic := '0';
	SIGNAL data_in :  std_logic_vector(15 downto 0) := (others=>'0');
	SIGNAL reg_addr :  std_logic_vector(14 downto 0) := (others=>'0');
	SIGNAL reg_out_0 :  std_logic_vector(15 downto 0) := "0000000000000001";
	SIGNAL reg_out_1 :  std_logic_vector(15 downto 0) := "0000000000000010";
	SIGNAL reg_out_2 :  std_logic_vector(15 downto 0) := "0000000000000011";
	SIGNAL reg_out_3 :  std_logic_vector(15 downto 0) := "0000000000000100";
	SIGNAL reg_out_4 :  std_logic_vector(15 downto 0) := "0000000000000101";
	SIGNAL reg_out_5 :  std_logic_vector(15 downto 0) := "0000000000000110";
	SIGNAL reg_out_6 :  std_logic_vector(15 downto 0) := "0000000000000111";
	SIGNAL reg_out_7 :  std_logic_vector(15 downto 0) := "0000000000001000";
	SIGNAL reg_out_8 :  std_logic_vector(15 downto 0) := "0000000000001001";
	SIGNAL reg_out_9 :  std_logic_vector(15 downto 0) := "0000000000001010";
	SIGNAL reg_out_10 :  std_logic_vector(15 downto 0) := "0000000000001011";
	SIGNAL reg_out_11 :  std_logic_vector(15 downto 0) := "0000000000001100";
	SIGNAL reg_out_writer :  std_logic_vector(15 downto 0) := "0000000000001101";
	SIGNAL reg_out_reader :  std_logic_vector(15 downto 0) := "0000000000001110";

	--Outputs
	SIGNAL data_out :  std_logic_vector(15 downto 0);
	SIGNAL reg_strobe_0 :  std_logic;
	SIGNAL reg_in_0 :  std_logic_vector(15 downto 0);
	SIGNAL reg_strobe_1 :  std_logic;
	SIGNAL reg_in_1 :  std_logic_vector(15 downto 0);
	SIGNAL reg_strobe_2 :  std_logic;
	SIGNAL reg_in_2 :  std_logic_vector(15 downto 0);
	SIGNAL reg_strobe_3 :  std_logic;
	SIGNAL reg_in_3 :  std_logic_vector(15 downto 0);
	SIGNAL reg_strobe_4 :  std_logic;
	SIGNAL reg_in_4 :  std_logic_vector(15 downto 0);
	SIGNAL reg_strobe_5 :  std_logic;
	SIGNAL reg_in_5 :  std_logic_vector(15 downto 0);
	SIGNAL reg_strobe_6 :  std_logic;
	SIGNAL reg_in_6 :  std_logic_vector(15 downto 0);
	SIGNAL reg_strobe_7 :  std_logic;
	SIGNAL reg_in_7 :  std_logic_vector(15 downto 0);
	SIGNAL reg_strobe_8 :  std_logic;
	SIGNAL reg_in_8 :  std_logic_vector(15 downto 0);
	SIGNAL reg_strobe_9 :  std_logic;
	SIGNAL reg_in_9 :  std_logic_vector(15 downto 0);
	SIGNAL reg_strobe_10 :  std_logic;
	SIGNAL reg_in_10 :  std_logic_vector(15 downto 0);
	SIGNAL reg_strobe_11 :  std_logic;
	SIGNAL reg_in_11 :  std_logic_vector(15 downto 0);
	SIGNAL reg_strobe_writer :  std_logic;
	SIGNAL reg_in_writer :  std_logic_vector(15 downto 0);
	SIGNAL reg_strobe_reader :  std_logic;
	SIGNAL reg_in_reader :  std_logic_vector(15 downto 0);

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut: RegMultiplexer generic map(READER_WRITER_BUF_LEN => 16) PORT MAP(
		strobe => strobe,
		data_in => data_in,
		data_out => data_out,
		reg_addr => reg_addr,
		reg_strobe_0 => reg_strobe_0,
		reg_in_0 => reg_in_0,
		reg_out_0 => reg_out_0,
		reg_strobe_1 => reg_strobe_1,
		reg_in_1 => reg_in_1,
		reg_out_1 => reg_out_1,
		reg_strobe_2 => reg_strobe_2,
		reg_in_2 => reg_in_2,
		reg_out_2 => reg_out_2,
		reg_strobe_3 => reg_strobe_3,
		reg_in_3 => reg_in_3,
		reg_out_3 => reg_out_3,
		reg_strobe_4 => reg_strobe_4,
		reg_in_4 => reg_in_4,
		reg_out_4 => reg_out_4,
		reg_strobe_5 => reg_strobe_5,
		reg_in_5 => reg_in_5,
		reg_out_5 => reg_out_5,
		reg_strobe_6 => reg_strobe_6,
		reg_in_6 => reg_in_6,
		reg_out_6 => reg_out_6,
		reg_strobe_7 => reg_strobe_7,
		reg_in_7 => reg_in_7,
		reg_out_7 => reg_out_7,
		reg_strobe_8 => reg_strobe_8,
		reg_in_8 => reg_in_8,
		reg_out_8 => reg_out_8,
		reg_strobe_9 => reg_strobe_9,
		reg_in_9 => reg_in_9,
		reg_out_9 => reg_out_9,
		reg_strobe_10 => reg_strobe_10,
		reg_in_10 => reg_in_10,
		reg_out_10 => reg_out_10,
		reg_strobe_11 => reg_strobe_11,
		reg_in_11 => reg_in_11,
		reg_out_11 => reg_out_11,
		reg_strobe_other0 => reg_strobe_writer,
		reg_in_other0 => reg_in_writer,
		reg_out_other0 => reg_out_writer,
		reg_strobe_other1 => reg_strobe_reader,
		reg_in_other1 => reg_in_reader,
		reg_out_other1 => reg_out_reader
	);

	-- Clock process definitions
	clk_process :process
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;

	strobe <= clk;

	stim_proc : PROCESS
	BEGIN

		data_in <= "1010101010101010";

		wait for clk_period * 10;
		
		report "$$$ begin RegMultiplexer test $$$";

		reg_addr <= "000000000000000";
		wait for clk_period * 10;
		reg_addr <= "000000000000001";
		wait for clk_period * 10;
		reg_addr <= "000000000000010";
		wait for clk_period * 10;
		reg_addr <= "000000000000011";
		wait for clk_period * 10;
		reg_addr <= "000000000000100";
		wait for clk_period * 10;
		reg_addr <= "000000000000101";
		wait for clk_period * 10;
		reg_addr <= "000000000000110";
		wait for clk_period * 10;
		reg_addr <= "000000000000111";
		wait for clk_period * 10;
		reg_addr <= "000000000001000";
		wait for clk_period * 10;
		reg_addr <= "000000000001001";
		wait for clk_period * 10;
		reg_addr <= "000000000001010";
		wait for clk_period * 10;
		reg_addr <= "000000000001011";
		wait for clk_period * 10;
		reg_addr <= "000000000001100";
		wait for clk_period * 10;
		reg_addr <= "000000000011100";
		wait for clk_period * 10;
		
		report "$$$ end RegMultiplexer test $$$";
		
		wait; -- will wait forever
	END PROCESS;

END;
