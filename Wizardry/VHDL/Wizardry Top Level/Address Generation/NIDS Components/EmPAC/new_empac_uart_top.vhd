----------------------------------------------------------------------------------
--
--  This file is a part of Technica Corporation Wizardry Project
--
--  Copyright (C) 2004-2009, Technica Corporation  
--
--  This program is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Create Date:    12:44:51 03/31/2008 
-- Design Name: Marlon Winder
-- Module Name: new_empac_uart_top - Behavioral 
-- Project Name: Wizardry
-- Target Devices: Virtex 4 ML401
-- Tool versions: 
-- Description: Top-level structural description for EmPAC Component.
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.port_block_constants.all;

entity new_empac_uart_top is
port(	  
	  clock : in std_logic; -- FPGA clock input (100 Mhz)
	  phy_clock : in std_logic; --  Used to syncoronize EmPAC with the PHY interface
	  reset12_5_out : out std_logic;
	  reset_n : in std_logic; -- Active low reset
	  phy_data_in : in std_logic_vector(3 downto 0); -- 4-bit phy interface
	  phy_data_valid_in : in std_logic;
	  phy_reset : out std_logic; -- ethernet must be reset before it "wakes up"
	  field_data : out std_logic_vector(31 downto 0); -- 32 bit parsed data from packet
	  field_type : out std_logic_vector(7 downto 0);  -- Indicates which parsed portion of the packet is
	  data_ready : out std_logic;							  -- output from "field_data" when "data_ready" is asserted
	  empac_12_5_clock : out std_logic;					  -- 12.5 Mhz output
	  end_of_frame : out std_logic;				        -- Indicates the end of a packet
	  
	  -- Wishbone compliant DDR SDRAM interface ports.  These signals interface directly with
	  -- RDIC, the memory interface component.  See Wishbone spec for details on signal 
	  ack_i : in std_logic;									  -- acknowledge
     dat_i : in std_logic_Vector(31 downto 0);       -- data in
     dat_o : out std_logic_Vector(31 downto 0);		  -- etc.
     adr_o : out std_logic_Vector(21 downto 0);
     we_o  : out std_logic;
     cyc_o : out std_logic;
     stb_o : out std_logic;
	  lock_o : out std_logic;
	  priority_o : out std_logic_vector(7 downto 0);  -- NOT PART OF SPEC!!!!
																	  -- Indicates the access priority 
	  
	  id_o : out std_logic_Vector(4 downto 0);        -- NOT PART OF SPEC!!!!
																	  -- Enables other components to refer to EmPAC's
																	  -- shared memory resources by ID.
	  -- End of memory interface ports
	  
	  
	  -- Debug Outputs --
	  -- These signals can be used to see how fast the FIFO is being 
	  fifo_empty_out : out std_logic;  -- Signals used for debugging
	  fifo_full_out : out std_logic;   -- Signals used for debugging
	  fifo_push_count : out std_logic_vector(11 downto 0));  -- Signals used for debugging
	  
	  
end new_empac_uart_top;

architecture Behavioral of new_empac_uart_top is

-- Various signal for connecting the structural components of EmPAC
signal leds : std_logic_vector(8 downto 0);

signal field_data_s : std_logic_vector(31 downto 0);
signal field_type_s : std_logic_vector(7 downto 0);
signal data_ready_s : std_logic;
signal empac_load : std_logic;
signal empac_load_data : std_logic_vector(15 downto 0);

signal clk_div : std_logic;
signal phy_data : std_logic_Vector(7 downto 0);
signal phy_data_valid : std_logic;
signal reset : std_logic;
signal known_packet_count : std_logic_vector(31 downto 0);
signal unknown_packet_count : std_logic_vector(31 downto 0);
signal total_frame_count : std_logic_vector(31 downto 0);
signal tcp_frame_count : std_logic_vector(31 downto 0);
signal udp_frame_count : std_logic_vector(31 downto 0);
signal IPv4_frame_count : std_logic_vector(31 downto 0);
signal IPv6_frame_count : std_logic_vector(31 downto 0);
signal ARP_frame_count : std_logic_vector(31 downto 0);
signal src_port_found_count : std_logic_vector(31 downto 0);
signal dst_port_found_count : std_logic_vector(31 downto 0);
signal EmPAC_leds : std_logic_vector(8 downto 0);
signal Uart_leds : std_logic_vector(8 downto 0);

signal phy_clock_test : std_logic;
signal uart_data_ready : std_logic;
signal src_port_found : STD_LOGIC;
signal src_port_value : STD_LOGIC_VECTOR (15 downto 0);
signal dst_port_found : STD_LOGIC;
signal dst_port_value : STD_LOGIC_VECTOR (15 downto 0);

		
component reset_internal is  -- Component used to generate reset signals for different clock domains
    Port ( clock100 : in  STD_LOGIC;
			  clock25 : in std_logic;
			  clock12_5 : in std_logic;
           reset : in  STD_LOGIC;
           reset100 : out  STD_LOGIC;
           reset25 : out  STD_LOGIC;
           reset12_5 : out  STD_LOGIC);
end component;

-- This component takes 4 bit nibbles received from the PHY interface concattonates every other nibble into a byte.
-- However, since a byte is only received every other clock cycle (at 25 Mhz), a new 12.5 Mhz clock is generate
-- to resynchronize the PHY data.
 
component clk_divide is 
port(clock : in std_logic;
	  reset : in std_logic;
	  clk_div : out std_logic;
	  phy_data : out std_logic_Vector(7 downto 0);
	  phy_data_valid : out std_logic;
	  phy_data_in : in std_logic_vector(3 downto 0);
	  phy_data_valid_in : in std_logic);
end component;


-- Actual EmPAC component
component new_empac_top is
port(
		sys_clock : in std_logic;
		clock : in std_logic;
		reset : in std_logic;
		reset_100 : in std_logic;
		EmPAC_leds : out std_logic_vector(8 downto 0);
		phy_data : in std_logic_vector(7 downto 0);
		phy_data_valid : in std_logic;
		field_data : out std_logic_vector(31 downto 0);
		field_type : out std_logic_vector(7 downto 0);
		data_ready : out std_logic;
		ack_i : in  STD_LOGIC;
      dat_i : in  STD_LOGIC_vector(31 downto 0);
      dat_o : out  STD_LOGIC_VECTOR (31 downto 0);
      adr_o : out  STD_LOGIC_VECTOR (21 downto 0);
      we_o : out  STD_LOGIC;
      cyc_o : out  STD_LOGIC;
      stb_o : out  STD_LOGIC;
		lock_o : out std_logic;
		priority_o : out std_logic_vector(7 downto 0);
		id_o : out std_logic_Vector(4 downto 0);
		fifo_empty_out : out std_logic;
		fifo_full_out : out std_logic;
		fifo_push_count : out std_logic_vector(11 downto 0);
		end_of_frame : out std_logic
		);
end component;

signal reset100,reset25,reset12_5 : std_logic;
signal frame_counters : frame_counters_type;

begin
phy_reset <= not reset_n;

field_data <= field_data_s;
field_type <= field_type_s;
data_ready <= data_ready_s;
reset12_5_out <= reset12_5;
empac_12_5_clock <= clk_div;

rst_cmp: reset_internal
    Port map( clock100 => clock,
			  clock25 => phy_clock,
			  clock12_5 => clk_div,
           reset => reset_n,
           reset100 => reset100,
           reset25 => reset25,
           reset12_5 => reset12_5);

clkdiv : clk_divide 
port map(clock => phy_clock,
	  reset => reset,
	  clk_div => clk_div,
	  phy_data => phy_data,
	  phy_data_valid => phy_data_valid,
	  phy_data_in => phy_data_in,
	  phy_data_valid_in => phy_data_valid_in);

empac: new_empac_top
port map(
		sys_clock => clock,
		clock => clk_div,
		reset => reset12_5,
		reset_100 => reset100,
		EmPAC_leds => EmPAC_leds,
		phy_data => phy_data,
		phy_data_valid => phy_data_valid,
		field_data => field_data_s,
		field_type => field_type_s,
		data_ready => data_ready_s,
		ack_i => ack_i,
      dat_i => dat_i,
      dat_o => dat_o,
      adr_o => adr_o,
      we_o => we_o,
      cyc_o => cyc_o,
      stb_o => stb_o,
		lock_o => lock_o,
		priority_o => priority_o,
		id_o => id_o,
		fifo_empty_out => fifo_empty_out,
		fifo_full_out => fifo_full_out,
		fifo_push_count => fifo_push_count,
		end_of_frame => end_of_frame
		);

end Behavioral;