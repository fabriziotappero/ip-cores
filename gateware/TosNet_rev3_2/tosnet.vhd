----------------------------------------------------------------------------------
-- Company: 		University of Southern Denmark
-- Engineer: 		Simon Falsig
-- 
-- Create Date:    	30/7/2010 
-- Design Name: 	TosNet
-- Module Name:    	tosnet - Behavioral 
-- File Name:		tosnet.vhd
-- Project Name:	TosNet
-- Target Devices:	Spartan3/6
-- Tool versions:	Xilinx ISE 12.2
-- Description: 	TosNet is a fully FPGA-based isochronous network targeted for
--					use in prototype, modular, distributed robot controllers. Full
--					specification can be seen in the documentation.
--					This is the top-level wrapper, containing the application
--					and data-link/physical layer modules.
--
-- Revision: 
-- Revision 3.2 - 	Initial release
--
-- Copyright 2010
--
-- This module is free software: you can redistribute it and/or modify
-- it under the terms of the GNU Lesser General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This module is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU Lesser General Public License for more details.
--
-- You should have received a copy of the GNU Lesser General Public License
-- along with this module.  If not, see <http://www.gnu.org/licenses/>.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.vcomponents.all;

entity tosnet is															-- Ports marked with * are required
Generic (	disable_slave			: STD_LOGIC := '0';						-- Disable the slave functionality
			disable_master			: STD_LOGIC := '0';						-- Disable the master functionality (can drastically reduce the amount of logic required for slave-only nodes)
			disable_async			: STD_LOGIC := '0');					-- Disable async functionality (async will still work for other nodes in the network, communication to a node with async disabled will be silently discarded)
Port (		sig_in					: in	STD_LOGIC;						--*The serial input signal
			sig_out					: out	STD_LOGIC;						--*The serial output signal
			clk_50M					: in	STD_LOGIC;						--*The 50 MHz input clock
			reset					: in	STD_LOGIC;						-- Active high reset
			sync_strobe				: out	STD_LOGIC;						-- Active high synchronization strobe (asserted for one clock cycle during synchronication)
			online					: out	STD_LOGIC;						-- Active high online indicator (asserted when network is configured and running)
			is_master				: out	STD_LOGIC;						-- Active high is_master indicator (asserted when current node is master)
			packet_error			: out	STD_LOGIC;						-- Active high packet error indicator (asserted whenever the previously received packet was erroneous)
			system_halt				: out	STD_LOGIC;						-- Active high system halt signal (asserted when the max_skipped thresholds are exceeded)
			node_id					: in	STD_LOGIC_VECTOR(3 downto 0);	--*The id of the current node
			reg_enable				: in	STD_LOGIC_VECTOR(7 downto 0);	--*Bit-vector describing which registers are enabled (a '1' indicates that the corresponding register is enabled, '0' that it is disabled)
			watchdog_threshold		: in	STD_LOGIC_VECTOR(17 downto 0);	--*The threshold of the watchdog in 1.25 MHz clock cycles
			max_skipped_writes		: in	STD_LOGIC_VECTOR(15 downto 0);	--*The maximum amount of consecutive clock cycles without a write to the shared memory block (set to 0 to disable)
			max_skipped_reads		: in	STD_LOGIC_VECTOR(15 downto 0);	--*The maximum amount of consecutive clock cycles without a read from the shared memory block (set to 0 to disable)
			data_reg_addr			: in	STD_LOGIC_VECTOR(9 downto 0);	-- The address bus of the shared memory block
			data_reg_data_in		: in	STD_LOGIC_VECTOR(31 downto 0);	-- The input data bus to the shared memory block
			data_reg_data_out		: out	STD_LOGIC_VECTOR(31 downto 0);	-- The output data bus from the shared memory block
			data_reg_clk			: in	STD_LOGIC;						-- The clock for the shared memory block
			data_reg_we				: in	STD_LOGIC_VECTOR(0 downto 0);	-- Active high write enable for the shared memory block
			commit_write 			: in	STD_LOGIC;						-- Active high signal to commit the out registers
			commit_read				: in	STD_LOGIC;						-- Active high signal to commit the in registers
			reset_counter			: out	STD_LOGIC_VECTOR(31 downto 0);	-- The number of resets since last configuration
			packet_counter			: out	STD_LOGIC_VECTOR(31 downto 0);	-- The number of data packets transmitted since last configuration
			error_counter			: out	STD_LOGIC_VECTOR(31 downto 0);	-- The number of erroneous packets received since last configuration
			async_in_data			: in	STD_LOGIC_VECTOR(37 downto 0);	-- The async input data bus
			async_out_data			: out	STD_LOGIC_VECTOR(37 downto 0);	-- The async output data bus
			async_in_clk			: in	STD_LOGIC;						-- The async input clock
			async_out_clk			: in	STD_LOGIC;						-- The async output clock
			async_in_full			: out	STD_LOGIC;						-- Active high async input full indicator (asserted when async input buffer is full)
			async_out_empty			: out	STD_LOGIC;						-- Active high async output empty indicator (asserted when async output buffer is empty)
			async_in_wr_en			: in	STD_LOGIC;						-- Active high async input write enable
			async_out_rd_en			: in	STD_LOGIC;						-- Active high async output read enable
			async_out_valid			: out	STD_LOGIC);						-- Active high async output valid indicator (asserted when valid data is present on the async output data bus)
end tosnet;

architecture Behavioral of tosnet is
	
	component tdl_top is
	Port (	node_id					: in	STD_LOGIC_VECTOR(3 downto 0);
			reg_enable				: in	STD_LOGIC_VECTOR(7 downto 0);
			watchdog_threshold		: in	STD_LOGIC_VECTOR(17 downto 0);
			data_out_ext			: out	STD_LOGIC_VECTOR(7 downto 0);
			data_out_strobe_ext		: out	STD_LOGIC;
			data_out_enable_ext		: out	STD_LOGIC;
			data_in_ext				: in	STD_LOGIC_VECTOR(7 downto 0);
			data_in_strobe_ext		: in	STD_LOGIC;
			data_in_enable_ext		: in	STD_LOGIC;
			buffer_full				: inout	STD_LOGIC;
			packet_error			: inout	STD_LOGIC;
			force_packet_error		: inout	STD_LOGIC;
			sync_strobe				: inout	STD_LOGIC;
			online					: out	STD_LOGIC;
			network_reg_addr		: in	STD_LOGIC_VECTOR(3 downto 0);
			network_reg_data		: out	STD_LOGIC_VECTOR(31 downto 0);
			network_reg_clk			: in	STD_LOGIC;
			node_is_master			: out	STD_LOGIC;
			node_address			: out	STD_LOGIC_VECTOR(3 downto 0);
			clk_50M					: in	STD_LOGIC;
			reset					: in	STD_LOGIC;
			sig_in					: in	STD_LOGIC;
			sig_out					: inout	STD_LOGIC);
	end component;
	
	component tal_top is
	Generic (	disable_slave			: STD_LOGIC;
				disable_master			: STD_LOGIC;
				disable_async			: STD_LOGIC);
	Port (		node_id					: in	STD_LOGIC_VECTOR(3 downto 0);
				max_skipped_writes		: in	STD_LOGIC_VECTOR(15 downto 0);
				max_skipped_reads		: in	STD_LOGIC_VECTOR(15 downto 0);
				data_in					: in	STD_LOGIC_VECTOR(7 downto 0);
				data_in_strobe			: in	STD_LOGIC;
				data_in_enable			: in	STD_LOGIC;
				data_out				: out	STD_LOGIC_VECTOR(7 downto 0);
				data_out_strobe			: out	STD_LOGIC;
				data_out_enable			: out	STD_LOGIC;
				buffer_full				: in	STD_LOGIC;
				packet_error			: in	STD_LOGIC;
				force_packet_error		: out	STD_LOGIC;
				sync_strobe				: in	STD_LOGIC;
				network_reg_addr		: out	STD_LOGIC_VECTOR(3 downto 0);
				network_reg_data		: in	STD_LOGIC_VECTOR(31 downto 0);
				network_reg_clk			: out	STD_LOGIC;
				data_reg_addr			: in	STD_LOGIC_VECTOR(9 downto 0);
				data_reg_data_in		: in	STD_LOGIC_VECTOR(31 downto 0);
				data_reg_data_out		: out	STD_LOGIC_VECTOR(31 downto 0);
				data_reg_clk			: in	STD_LOGIC;
				data_reg_we				: in	STD_LOGIC_VECTOR(0 downto 0);
				data_reg_commit_write 	: in	STD_LOGIC;
				data_reg_commit_read	: in	STD_LOGIC;
				skip_count_write		: out	STD_LOGIC_VECTOR(15 downto 0);
				skip_count_read			: out	STD_LOGIC_VECTOR(15 downto 0);
				current_buffer_index	: out	STD_LOGIC_VECTOR(3 downto 0);
				node_address			: in	STD_LOGIC_VECTOR(3 downto 0);
				is_master				: in	STD_LOGIC;
				clk_50M					: in	STD_LOGIC;
				pause					: in	STD_LOGIC;
				pause_ack				: out	STD_LOGIC;
				reset					: in	STD_LOGIC;
				system_halt				: out	STD_LOGIC;
				reset_counter			: out	STD_LOGIC_VECTOR(31 downto 0);
				packet_counter			: out	STD_LOGIC_VECTOR(31 downto 0);
				error_counter			: out	STD_LOGIC_VECTOR(31 downto 0);
				async_in_data			: in	STD_LOGIC_VECTOR(37 downto 0);
				async_out_data			: out	STD_LOGIC_VECTOR(37 downto 0);
				async_in_clk			: in	STD_LOGIC;
				async_out_clk			: in	STD_LOGIC;
				async_in_full			: out	STD_LOGIC;
				async_out_empty			: out	STD_LOGIC;
				async_in_wr_en			: in	STD_LOGIC;
				async_out_rd_en			: in	STD_LOGIC;
				async_out_valid			: out	STD_LOGIC);
	end component;
	
	

	signal sig_out_int			: STD_LOGIC;
	signal data_up				: STD_LOGIC_VECTOR(7 downto 0);
	signal data_up_strobe		: STD_LOGIC;
	signal data_up_enable		: STD_LOGIC;
	signal data_down			: STD_LOGIC_VECTOR(7 downto 0);
	signal data_down_strobe		: STD_LOGIC;
	signal data_down_enable		: STD_LOGIC;
	signal buffer_full			: STD_LOGIC;
	signal sync_strobe_int		: STD_LOGIC;
	signal network_reg_addr		: STD_LOGIC_VECTOR(3 downto 0);
	signal network_reg_data		: STD_LOGIC_VECTOR(31 downto 0);
	signal network_reg_clk		: STD_LOGIC;
	signal node_address			: STD_LOGIC_VECTOR(3 downto 0);
	signal is_master_int		: STD_LOGIC;
	signal packet_error_int		: STD_LOGIC;
	signal online_int			: STD_LOGIC;
	signal app_reset			: STD_LOGIC;
	signal force_packet_error	: STD_LOGIC;

begin


	tdl_top_inst : tdl_top
	Port map ( 	node_id => node_id,
				reg_enable => reg_enable,
				watchdog_threshold => watchdog_threshold,
				sig_in => sig_in,
				sig_out => sig_out_int,
				reset => reset,
				clk_50M => clk_50M,
				data_in_ext => data_down,
				data_in_enable_ext => data_down_enable,
				data_in_strobe_ext => data_down_strobe,
				data_out_ext => data_up,
				data_out_enable_ext => data_up_enable,
				data_out_strobe_ext => data_up_strobe,
				buffer_full => buffer_full,
				packet_error => packet_error_int,
				force_packet_error => force_packet_error,
				sync_strobe => sync_strobe_int,
				online => online_int,
				network_reg_addr => network_reg_addr,
				network_reg_data => network_reg_data,
				network_reg_clk => network_reg_clk,
				node_address => node_address,
				node_is_master => is_master_int);

	application_inst : tal_top
	Generic map(disable_slave => disable_slave,
				disable_master => disable_master,
				disable_async => disable_async)
	Port map ( 	node_id => node_id,
				max_skipped_writes => max_skipped_writes,
				max_skipped_reads => max_skipped_reads,
				data_in => data_up,
				data_in_strobe => data_up_strobe,
				data_in_enable => data_up_enable,
				data_out => data_down,
				data_out_strobe => data_down_strobe,
				data_out_enable => data_down_enable,
				buffer_full => buffer_full,
				packet_error => packet_error_int,
				force_packet_error => force_packet_error,
				sync_strobe => sync_strobe_int,
				network_reg_addr => network_reg_addr,
				network_reg_data => network_reg_data,
				network_reg_clk => network_reg_clk,
				node_address => node_address,
				is_master => is_master_int,
				data_reg_addr => data_reg_addr,
				data_reg_data_in => data_reg_data_in,
				data_reg_data_out => data_reg_data_out,
				data_reg_clk => data_reg_clk,
				data_reg_we => data_reg_we,
				data_reg_commit_write => commit_write,
				data_reg_commit_read => commit_read,
				clk_50M => clk_50M,
				pause => '0',
				reset => app_reset,
				system_halt => system_halt,
				packet_counter => packet_counter,
				error_counter => error_counter,
				reset_counter => reset_counter,
				async_in_data => async_in_data,
				async_out_data => async_out_data,
				async_in_clk => async_in_clk,
				async_out_clk => async_out_clk,
				async_in_full => async_in_full,
				async_out_empty => async_out_empty,
				async_in_wr_en => async_in_wr_en,
				async_out_rd_en => async_out_rd_en,
				async_out_valid => async_out_valid);


	sig_out <= sig_out_int;

	app_reset <= not online_int;
	
	sync_strobe <= sync_strobe_int;
	online <= online_int;
	is_master <= is_master_int;
	packet_error <= packet_error_int;
	
end Behavioral;
