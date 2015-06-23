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
-- Create Date:   16:22:23 02/04/2012
-- Design Name:   
-- Module Name:   RegsGpibFasade_test.vhd
-- Project Name:  proto1
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: RegsGpibFasade
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
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
use work.wrapperComponents.ALL;
 
ENTITY RegsGpibFasade_test IS
END RegsGpibFasade_test;
 
ARCHITECTURE behavior OF RegsGpibFasade_test IS 

	component gpibCableEmulator is port (
		-- interface signals
		DIO_1 : in std_logic_vector (7 downto 0);
		output_valid_1 : in std_logic;
		DIO_2 : in std_logic_vector (7 downto 0);
		output_valid_2 : in std_logic;
		DIO : out std_logic_vector (7 downto 0);
		-- attention
		ATN_1 : in std_logic;
		ATN_2 : in std_logic;
		ATN : out std_logic;
		-- data valid
		DAV_1 : in std_logic;
		DAV_2 : in std_logic;
		DAV : out std_logic;
		-- not ready for data
		NRFD_1 : in std_logic;
		NRFD_2 : in std_logic;
		NRFD : out std_logic;
		-- no data accepted
		NDAC_1 : in std_logic;
		NDAC_2 : in std_logic;
		NDAC : out std_logic;
		-- end or identify
		EOI_1 : in std_logic;
		EOI_2 : in std_logic;
		EOI : out std_logic;
		-- service request
		SRQ_1 : in std_logic;
		SRQ_2 : in std_logic;
		SRQ : out std_logic;
		-- interface clear
		IFC_1 : in std_logic;
		IFC_2 : in std_logic;
		IFC : out std_logic;
		-- remote enable
		REN_1 : in std_logic;
		REN_2 : in std_logic;
		REN : out std_logic
	);
	end component;

   --Inputs
   signal reset : std_logic := '0';
   signal clk : std_logic := '0';
   signal DI : std_logic_vector(7 downto 0) := (others => '0');
   signal ATN_in : std_logic := '0';
   signal DAV_in : std_logic := '0';
   signal NRFD_in : std_logic := '0';
   signal NDAC_in : std_logic := '0';
   signal EOI_in : std_logic := '0';
   signal SRQ_in : std_logic := '0';
   signal IFC_in : std_logic := '0';
   signal REN_in : std_logic := '0';
   signal data_in : std_logic_vector(15 downto 0) := (others => '0');
   signal reg_addr : std_logic_vector(14 downto 0) := (others => '0');
   signal strobe_read : std_logic := '0';
   signal strobe_write : std_logic := '0';

 	--Outputs
   signal DO : std_logic_vector(7 downto 0);
   signal output_valid : std_logic;
   signal ATN_out : std_logic;
   signal DAV_out : std_logic;
   signal NRFD_out : std_logic;
   signal NDAC_out : std_logic;
   signal EOI_out : std_logic;
   signal SRQ_out : std_logic;
   signal IFC_out : std_logic;
   signal REN_out : std_logic;
   signal data_out : std_logic_vector(15 downto 0);
   signal interrupt_line : std_logic;
   signal debug1 : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
	uut: RegsGpibFasade PORT MAP (
		reset => reset,
		clk => clk,
		DI => DI,
		DO => DO,
		output_valid => output_valid,
		ATN_in => ATN_in,
		ATN_out => ATN_out,
		DAV_in => DAV_in,
		DAV_out => DAV_out,
		NRFD_in => NRFD_in,
		NRFD_out => NRFD_out,
		NDAC_in => NDAC_in,
		NDAC_out => NDAC_out,
		EOI_in => EOI_in,
		EOI_out => EOI_out,
		SRQ_in => SRQ_in,
		SRQ_out => SRQ_out,
		IFC_in => IFC_in,
		IFC_out => IFC_out,
		REN_in => REN_in,
		REN_out => REN_out,
		data_in => data_in,
		data_out => data_out,
		reg_addr => reg_addr,
		strobe_read => strobe_read,
		strobe_write => strobe_write,
		interrupt_line => interrupt_line,
		debug1 => debug1
	);

	gce: gpibCableEmulator port map (
		-- interface signals
		DIO_1 => DO,
		output_valid_1 => output_valid,
		DIO_2 => "00000000",
		output_valid_2 => '0',
		DIO => DI,
		-- attention
		ATN_1 => ATN_out,
		ATN_2 => '0',
		ATN => ATN_in,
		-- data valid
		DAV_1 => DAV_out,
		DAV_2 => '0',
		DAV => DAV_in,
		-- not ready for data
		NRFD_1 => NRFD_out,
		NRFD_2 => '0',
		NRFD => NRFD_in,
		-- no data accepted
		NDAC_1 => NDAC_out,
		NDAC_2 => '0',
		NDAC => NDAC_in,
		-- end or identify
		EOI_1 => EOI_out,
		EOI_2 => '0',
		EOI => EOI_in,
		-- service request
		SRQ_1 => SRQ_out,
		SRQ_2 => '0',
		SRQ => SRQ_in,
		-- interface clear
		IFC_1 => IFC_out,
		IFC_2 => '0',
		IFC => IFC_in,
		-- remote enable
		REN_1 => REN_out,
		REN_2 => '0',
		REN => REN_in
	);

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
	stim_proc: process begin
	
		-- hold reset state for 10 clock cycles
		reset <= '1';
		wait for clk_period*10;	
		reset <= '0';
		wait for clk_period*10;
		
		-- set rsc
		reg_addr <= "000000000000111";
		data_in <= "0000000001000000";
		
		wait for clk_period*2;
		strobe_write <= '1';
		wait for clk_period*2;
		strobe_write <= '0';
		
		wait for clk_period*20;
		
		-- set sic
		data_in <= "0000000011000000";
		wait for clk_period*2;
		strobe_write <= '1';
		wait for clk_period*2;
		strobe_write <= '0';
		
		wait for clk_period*20;
		
		-- reset sic
		data_in <= "0000000001000000";
		wait for clk_period*2;
		strobe_write <= '1';
		wait for clk_period*2;
		strobe_write <= '0';

		wait for clk_period*20;

		-- enable writer
		reg_addr <= "000000000001010";
		data_in <= "0000000000000010";
		wait for clk_period*2;
		strobe_write <= '1';
		wait for clk_period*2;
		strobe_write <= '0';

		-- self address to listen
		reg_addr <= "000000000001101";
		data_in <= "0000000000100001";
		wait for clk_period*2;
		strobe_write <= '1';
		wait for clk_period*2;
		strobe_write <= '0';

		-- self address to listen again
		reg_addr <= "000000000001101";
		data_in <= "0000000000100011";
		wait for clk_period*2;
		strobe_write <= '1';
		wait for clk_period*2;
		strobe_write <= '0';

		wait for clk_period*10;

		wait;
	end process;

END;
