----------------------------------------------------------------------------------
-- Company: 		University of Southern Denmark
-- Engineer: 		Simon Falsig
-- 
-- Create Date:    	7/3/2010 
-- Design Name: 	TosNet
-- Module Name:    	tdl_top - Behavioral 
-- File Name:		tdl_top.vhd
-- Project Name:	TosNet
-- Target Devices:	Spartan3/6
-- Tool versions:	Xilinx ISE 12.2
-- Description: 	The datalink layer implementation and physical layer wrapper
--					for the TosNet stack.
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
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.crcpack.all;
use work.commandpack.all;

entity tdl_top is
	Port( 	node_id					: in	STD_LOGIC_VECTOR(3 downto 0);
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
end tdl_top;

architecture Behavioral of tdl_top is
	attribute buffer_type: string;
	attribute buffer_type of network_reg_clk: signal is "none";	--Make sure that the network register clock doesn't use a GCLK

	type MAIN_STATES is (IDLE, MASTER_DSC, NET_DSC, REG_DSC, SYNC_DSC, DATA, ERROR);
	type TX_STATES is (IDLE, DATA_CMD, DATA, CRC, ERROR);
	type RX_STATES is (IDLE, CMD, DATA, CRC, ERROR);

	signal main_state			: MAIN_STATES := IDLE;
	signal next_main_state		: MAIN_STATES := IDLE;
	signal tx_state				: TX_STATES := IDLE;
	signal next_tx_state		: TX_STATES := IDLE;
	signal rx_state				: RX_STATES := IDLE;
	signal next_rx_state		: RX_STATES := IDLE;
	
	signal tx_data 				: STD_LOGIC_VECTOR(7 downto 0);
	signal tx_clk_en	 		: STD_LOGIC;
	signal tx_enable 			: STD_LOGIC;
	signal tx_clk_div_reset		: STD_LOGIC;
	signal tx_clk_div_reset_ack	: STD_LOGIC;
	
	signal rx_data 				: STD_LOGIC_VECTOR(7 downto 0);
	signal rx_error 			: STD_LOGIC;
	signal rx_valid 			: STD_LOGIC;
	signal rx_clk		 		: STD_LOGIC;
	
	signal rx_cmd_valid			: STD_LOGIC;
	signal rx_cmd_valid_buffer_1: STD_LOGIC;
	signal rx_cmd_valid_buffer_2: STD_LOGIC;

	signal main_counter			: STD_LOGIC_VECTOR(7 downto 0) := "00000000";
	signal last_tx_clk_en		: STD_LOGIC;
	signal last_rx_clk			: STD_LOGIC;
	signal last_data_in_strobe	: STD_LOGIC;
		
	signal input_buffer			: STD_LOGIC_VECTOR(7 downto 0);
	signal data_buffer			: STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
	
	signal data_out_buffer_1			: STD_LOGIC_VECTOR(7 downto 0);
	signal data_out_buffer_2			: STD_LOGIC_VECTOR(7 downto 0);
	signal data_out_enable_buffer_1		: STD_LOGIC;
	signal data_out_enable_buffer_2		: STD_LOGIC;
	
	signal crcgen_rx_output_buffer		: STD_LOGIC_VECTOR(7 downto 0);
	
	signal data_buffer_counter 			: STD_LOGIC := '0';
	signal input_available				: STD_LOGIC;
	
	signal internal_reset 		: STD_LOGIC := '0';
	signal do_internal_reset	: STD_LOGIC := '0';
	
	signal watchdog_counter		: STD_LOGIC_VECTOR(17 downto 0) := "000000000000000000";
	
	signal master_dsc_enable 	: STD_LOGIC;
	signal master_dsc_done		: STD_LOGIC;
	signal master_dsc_reset		: STD_LOGIC;
	signal is_master			: STD_LOGIC;
	
	signal net_dsc_enable		: STD_LOGIC;
	signal net_dsc_done			: STD_LOGIC;
	signal net_dsc_reset		: STD_LOGIC;
	signal node_count			: STD_LOGIC_VECTOR(3 downto 0);
	signal address				: STD_LOGIC_VECTOR(3 downto 0);
	
	signal reg_dsc_enable		: STD_LOGIC;
	signal reg_dsc_done			: STD_LOGIC;
	signal reg_dsc_reset		: STD_LOGIC;
	
	signal sync_dsc_enable		: STD_LOGIC;
	signal sync_dsc_done		: STD_LOGIC;
	signal sync_dsc_reset		: STD_LOGIC;
	
	signal data_enable			: STD_LOGIC;
	
	signal network_reg_internal_clk				: STD_LOGIC;
	signal network_reg_internal_write_data		: STD_LOGIC_VECTOR(7 downto 0);
	signal network_reg_internal_addr			: STD_LOGIC_VECTOR(5 downto 0);
	signal network_reg_internal_we				: STD_LOGIC_VECTOR(0 downto 0);
	signal network_reg_internal_read_data		: STD_LOGIC_VECTOR(7 downto 0);

	signal network_reg_internal_clk_net			: STD_LOGIC;
	signal network_reg_internal_write_data_net	: STD_LOGIC_VECTOR(7 downto 0);
	signal network_reg_internal_addr_net		: STD_LOGIC_VECTOR(5 downto 0);
	signal network_reg_internal_we_net			: STD_LOGIC_VECTOR(0 downto 0);

	signal network_reg_internal_clk_reg			: STD_LOGIC;
	signal network_reg_internal_write_data_reg	: STD_LOGIC_VECTOR(7 downto 0);
	signal network_reg_internal_addr_reg		: STD_LOGIC_VECTOR(5 downto 0);
	signal network_reg_internal_we_reg			: STD_LOGIC_VECTOR(0 downto 0);

	signal data_out					: STD_LOGIC_VECTOR(7 downto 0);
	signal data_out_strobe			: STD_LOGIC;
	signal data_out_enable			: STD_LOGIC;
	
	signal data_in					: STD_LOGIC_VECTOR(7 downto 0);
	signal data_in_master			: STD_LOGIC_VECTOR(7 downto 0);
	signal data_in_net				: STD_LOGIC_VECTOR(7 downto 0);
	signal data_in_reg				: STD_LOGIC_VECTOR(7 downto 0);
	signal data_in_sync				: STD_LOGIC_VECTOR(7 downto 0);
	
	signal data_in_strobe			: STD_LOGIC;
	signal data_in_strobe_master	: STD_LOGIC;
	signal data_in_strobe_net		: STD_LOGIC;
	signal data_in_strobe_reg		: STD_LOGIC;
	signal data_in_strobe_sync		: STD_LOGIC;

	signal data_in_enable			: STD_LOGIC;
	signal data_in_enable_master	: STD_LOGIC;
	signal data_in_enable_net		: STD_LOGIC;
	signal data_in_enable_reg		: STD_LOGIC;
	signal data_in_enable_sync		: STD_LOGIC;

	signal crcgen_tx_input			: STD_LOGIC_VECTOR(7 downto 0);
	signal crcgen_tx_output			: STD_LOGIC_VECTOR(7 downto 0);
	signal crcgen_tx_reset			: STD_LOGIC;
	signal crcgen_tx_clk			: STD_LOGIC := '0';
	signal crcgen_tx_clk_en			: STD_LOGIC := '0';
	signal crcgen_tx_clk_en_buffer	: STD_LOGIC := '0';
	
	signal crc_tx_done				: STD_LOGIC := '0';

	signal crcgen_rx_input			: STD_LOGIC_VECTOR(7 downto 0);
	signal crcgen_rx_output			: STD_LOGIC_VECTOR(7 downto 0);
	signal crcgen_rx_reset			: STD_LOGIC;
	signal crcgen_rx_clk			: STD_LOGIC;
	signal crcgen_rx_clk_en			: STD_LOGIC;
	
	
	signal tpl_reset				: STD_LOGIC;
		
	component tpl_tx is
		Port ( 	data				: in	STD_LOGIC_VECTOR(7 downto 0);
				clk_50M				: in	STD_LOGIC;
				clk_data_en			: out	STD_LOGIC;
				enable				: in	STD_LOGIC;
				reset				: in	STD_LOGIC;
				sig_out				: out	STD_LOGIC;
				clk_div_reset		: in	STD_LOGIC;
				clk_div_reset_ack	: out	STD_LOGIC);
	end component;

	component tpl_rx is
		Port (	data				: out	STD_LOGIC_VECTOR(7 downto 0);
				valid				: out	STD_LOGIC;
				error				: out	STD_LOGIC;
				clk_data			: out	STD_LOGIC;
				clk_50M				: in	STD_LOGIC;
				reset				: in	STD_LOGIC;
				sig_in				: in	STD_LOGIC);
	end component;

	component tdl_app_master is
		Port (	app_enable					: in	STD_LOGIC;
				app_data_in					: in	STD_LOGIC_VECTOR(7 downto 0);
				app_data_in_strobe			: in	STD_LOGIC;
				app_data_out				: out	STD_LOGIC_VECTOR(7 downto 0);
				app_data_out_strobe			: out	STD_LOGIC;
				app_data_out_enable			: out	STD_LOGIC;
				app_buffer_full				: in	STD_LOGIC;
				app_packet_error			: in	STD_LOGIC;
				app_force_packet_error		: out	STD_LOGIC;
				app_cmd_valid				: in	STD_LOGIC;
				app_sync_strobe				: in	STD_LOGIC;
				app_is_master				: out	STD_LOGIC;
				app_dsc_done				: out	STD_LOGIC;
				app_node_id					: in	STD_LOGIC_VECTOR(3 downto 0);
				app_clk						: in	STD_LOGIC;
				app_reset					: in	STD_LOGIC);
	end component;
	
	component tdl_app_net is
		Port (	app_enable					: in	STD_LOGIC;
				app_data_in					: in	STD_LOGIC_VECTOR(7 downto 0);
				app_data_in_strobe			: in	STD_LOGIC;
				app_data_out				: out	STD_LOGIC_VECTOR(7 downto 0);
				app_data_out_strobe			: out	STD_LOGIC;
				app_data_out_enable			: out	STD_LOGIC;
				app_buffer_full				: in	STD_LOGIC;
				app_packet_error			: in	STD_LOGIC;
				app_force_packet_error		: out	STD_LOGIC;
				app_cmd_valid				: in	STD_LOGIC;
				app_sync_strobe				: in	STD_LOGIC;
				app_is_master				: in	STD_LOGIC;
				app_dsc_done				: out	STD_LOGIC;
				app_network_reg_clk			: out	STD_LOGIC;
				app_network_reg_addr 		: out	STD_LOGIC_VECTOR(5 downto 0);
				app_network_reg_data_in 	: in	STD_LOGIC_VECTOR(7 downto 0);
				app_network_reg_data_out 	: out	STD_LOGIC_VECTOR(7 downto 0);
				app_network_reg_we	 		: inout	STD_LOGIC_VECTOR(0 downto 0);
				app_node_count				: out	STD_LOGIC_VECTOR(3 downto 0);
				app_node_address			: out	STD_LOGIC_VECTOR(3 downto 0);
				app_node_id					: in	STD_LOGIC_VECTOR(3 downto 0);
				app_clk						: in	STD_LOGIC;
				app_reset					: in	STD_LOGIC);
	end component;
	
	component tdl_app_reg is
		Port (	app_enable					: in	STD_LOGIC;
				app_data_in					: in	STD_LOGIC_VECTOR(7 downto 0);
				app_data_in_strobe			: in	STD_LOGIC;
				app_data_out				: out	STD_LOGIC_VECTOR(7 downto 0);
				app_data_out_strobe			: out	STD_LOGIC;
				app_data_out_enable			: out	STD_LOGIC;
				app_buffer_full				: in	STD_LOGIC;
				app_packet_error			: in	STD_LOGIC;
				app_force_packet_error		: out	STD_LOGIC;
				app_cmd_valid				: in	STD_LOGIC;
				app_sync_strobe				: in	STD_LOGIC;
				app_is_master				: in	STD_LOGIC;
				app_dsc_done				: out	STD_LOGIC;
				app_network_reg_clk			: out	STD_LOGIC;
				app_network_reg_addr 		: out	STD_LOGIC_VECTOR(5 downto 0);
				app_network_reg_data_in 	: in	STD_LOGIC_VECTOR(7 downto 0);
				app_network_reg_data_out 	: out	STD_LOGIC_VECTOR(7 downto 0);
				app_network_reg_we 			: inout STD_LOGIC_VECTOR(0 downto 0);
				app_node_count				: in	STD_LOGIC_VECTOR(3 downto 0);
				app_node_address			: in	STD_LOGIC_VECTOR(3 downto 0);
				app_node_id					: in	STD_LOGIC_VECTOR(3 downto 0);
				app_reg_enable				: in	STD_LOGIC_VECTOR(7 downto 0);
				app_clk						: in	STD_LOGIC;
				app_reset					: in	STD_LOGIC);
	end component;
	
	component tdl_app_sync is
		Port (	app_enable					: in	STD_LOGIC;
				app_data_in					: in	STD_LOGIC_VECTOR(7 downto 0);
				app_data_in_strobe			: in	STD_LOGIC;
				app_data_in_enable			: in	STD_LOGIC;
				app_data_out				: out	STD_LOGIC_VECTOR(7 downto 0);
				app_data_out_strobe			: out	STD_LOGIC;
				app_data_out_enable			: out	STD_LOGIC;
				app_buffer_full				: in	STD_LOGIC;
				app_packet_error			: in	STD_LOGIC;
				app_force_packet_error		: out	STD_LOGIC;
				app_cmd_valid				: in	STD_LOGIC;
				app_sync_strobe				: out	STD_LOGIC;
				app_is_master				: in	STD_LOGIC;
				app_dsc_done				: out	STD_LOGIC;
				app_node_id					: in	STD_LOGIC_VECTOR(3 downto 0);
				app_node_count				: in	STD_LOGIC_VECTOR(3 downto 0);
				app_node_address			: in	STD_LOGIC_VECTOR(3 downto 0);
				app_clk						: in	STD_LOGIC;
				app_reset					: in	STD_LOGIC);
	end component;
	
	component crcgen is
		Port(	reset						: in	STD_LOGIC;
				clk 						: in	STD_LOGIC;
				clk_en						: in	STD_LOGIC;
				Din 						: in	STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
				Xout 						: out	STD_LOGIC_VECTOR(CRCDIM - 1 downto 0));
	end component;

	component network_register is
		Port (	clka						: in	STD_LOGIC;
				dina						: in	STD_LOGIC_VECTOR(7 downto 0);
				addra						: in	STD_LOGIC_VECTOR(5 downto 0);
				douta						: out	STD_LOGIC_VECTOR(7 downto 0);
				wea							: in	STD_LOGIC_VECTOR(0 downto 0);
				clkb						: in	STD_LOGIC;
				dinb						: in	STD_LOGIC_VECTOR(31 downto 0);
				addrb						: in	STD_LOGIC_VECTOR(3 downto 0);
				web							: in	STD_LOGIC_VECTOR(0 downto 0);
				doutb						: out	STD_LOGIC_VECTOR(31 downto 0));
	end component;

begin
	
	tpl_tx_inst : tpl_tx
	Port map (	data => tx_data,
				enable => tx_enable,
				clk_50M => clk_50M,
				clk_data_en => tx_clk_en,
				reset => tpl_reset,
				sig_out => sig_out,
				clk_div_reset => tx_clk_div_reset,
				clk_div_reset_ack => tx_clk_div_reset_ack);
					
	tpl_rx_inst : tpl_rx
	Port map (	data => rx_data,
				valid => rx_valid,
				error => rx_error,
				clk_data => rx_clk,
				clk_50M => clk_50M,
				reset => tpl_reset,
				sig_in => sig_in);
					
	
	app_master_inst : tdl_app_master
	Port map (	app_enable => master_dsc_enable,
				app_data_in => data_out,
				app_data_in_strobe => data_out_strobe,
				app_data_out => data_in_master,
				app_data_out_strobe => data_in_strobe_master,
				app_data_out_enable => data_in_enable_master,
				app_buffer_full => buffer_full,
				app_packet_error => packet_error,
				app_cmd_valid => rx_cmd_valid,
				app_sync_strobe => sync_strobe,
				app_is_master => is_master,
				app_dsc_done => master_dsc_done,
				app_node_id => node_id,
				app_clk => clk_50M,
				app_reset => master_dsc_reset);

	app_net_inst : tdl_app_net
	Port map (	app_enable => net_dsc_enable,
				app_data_in => data_out,
				app_data_in_strobe => data_out_strobe,
				app_data_out => data_in_net,
				app_data_out_strobe => data_in_strobe_net,
				app_data_out_enable => data_in_enable_net,
				app_buffer_full => buffer_full,
				app_packet_error => packet_error,
				app_cmd_valid => rx_cmd_valid,
				app_sync_strobe => sync_strobe,
				app_is_master => is_master,
				app_dsc_done => net_dsc_done,
				app_network_reg_clk => network_reg_internal_clk_net,
				app_network_reg_data_in => network_reg_internal_read_data,
				app_network_reg_data_out => network_reg_internal_write_data_net,
				app_network_reg_addr => network_reg_internal_addr_net,
				app_network_reg_we => network_reg_internal_we_net,
				app_node_count => node_count,
				app_node_address => address,
				app_node_id => node_id,
				app_clk => clk_50M,
				app_reset => net_dsc_reset);

	app_reg_inst : tdl_app_reg
	Port map (	app_enable => reg_dsc_enable,
				app_data_in => data_out,
				app_data_in_strobe => data_out_strobe,
				app_data_out => data_in_reg,
				app_data_out_strobe => data_in_strobe_reg,
				app_data_out_enable => data_in_enable_reg,
				app_buffer_full => buffer_full,
				app_packet_error => packet_error,
				app_cmd_valid => rx_cmd_valid,
				app_sync_strobe => sync_strobe,
				app_is_master => is_master,
				app_dsc_done => reg_dsc_done,
				app_network_reg_clk => network_reg_internal_clk_reg,
				app_network_reg_data_in => network_reg_internal_read_data,
				app_network_reg_data_out => network_reg_internal_write_data_reg,
				app_network_reg_addr => network_reg_internal_addr_reg,
				app_network_reg_we => network_reg_internal_we_reg,
				app_node_count => node_count,
				app_node_address => address,
				app_node_id => node_id,
				app_reg_enable => reg_enable,
				app_clk => clk_50M,
				app_reset => reg_dsc_reset);

	app_sync_inst : tdl_app_sync
	Port map(	app_enable => sync_dsc_enable,
				app_data_in => data_out,
				app_data_in_strobe => data_out_strobe,
				app_data_in_enable => data_out_enable,
				app_data_out => data_in_sync,
				app_data_out_strobe => data_in_strobe_sync,
				app_data_out_enable => data_in_enable_sync,
				app_buffer_full => buffer_full,
				app_packet_error => packet_error,
				app_cmd_valid => rx_cmd_valid,
				app_sync_strobe => sync_strobe,
				app_is_master => is_master,
				app_dsc_done => sync_dsc_done,
				app_node_id => node_id,
				app_node_count => node_count,
				app_node_address => address,
				app_clk => clk_50M,
				app_reset => sync_dsc_reset);
					
	crcgen_tx_inst : crcgen
	Port map (	reset => crcgen_tx_reset,
				clk => crcgen_tx_clk,
				clk_en => crcgen_tx_clk_en,
				Din => crcgen_tx_input,
				Xout => crcgen_tx_output);

	crcgen_rx_inst : crcgen
	Port map (	reset => crcgen_rx_reset,
				clk => crcgen_rx_clk,
				clk_en => crcgen_rx_clk_en,
				Din => crcgen_rx_input,
				Xout => crcgen_rx_output);

	crcgen_rx_clk <= clk_50M;
	crcgen_rx_clk_en <= '1' when ((rx_clk = '1') and (last_rx_clk = '0')) else '0';
	crcgen_rx_reset <= not rx_valid;
	crcgen_rx_input <= rx_data;

	crcgen_tx_clk <= clk_50M;

	network_register_inst : network_register
	Port map (	clka => network_reg_internal_clk,
				dina => network_reg_internal_write_data,
				addra => network_reg_internal_addr,
				wea => network_reg_internal_we,
				douta => network_reg_internal_read_data,
				clkb => network_reg_clk,
				dinb => "00000000000000000000000000000000",
				addrb => network_reg_addr,
				web => "0",
				doutb => network_reg_data);

	node_is_master <= is_master;
	node_address <= address;
	online <= data_enable;
	
	process(clk_50M)
	begin
		if(clk_50M = '1' and clk_50M'EVENT) then
			if(reset = '1') then
				main_state <= IDLE;
				tx_state <= IDLE;
				rx_state <= IDLE;
				watchdog_counter <= (others => '0');
			else
				main_state <= next_main_state;
				
				if(data_in_strobe = '1' and last_data_in_strobe = '0' and data_in_enable = '1') then		--The initial 8 bit input buffer
					input_buffer <= data_in;
					input_available <= '1';
				end if;
	
				if(tx_clk_en = '0' and input_available = '1') then			--The main 8 bit input data buffer
					if(data_buffer_counter = '0') then
						data_buffer <= input_buffer;
						data_buffer_counter <= '1';
						input_available <= '0';
					end if;
				end if;

				last_tx_clk_en <= tx_clk_en;
				last_rx_clk <= rx_clk;
				last_data_in_strobe <= data_in_strobe;
			end if;

			if(main_state = next_main_state) then
				main_counter <= main_counter + 1;
			else
				main_counter <= "00000000";
			end if;

			case main_state is					--Main state machine
				when IDLE =>
					master_dsc_enable <= '0';
					net_dsc_enable <= '0';
					reg_dsc_enable <= '0';
					sync_dsc_enable <= '0';
					data_enable <= '0';
					master_dsc_reset <= '1';
					net_dsc_reset <= '1';
					reg_dsc_reset <= '1';
					sync_dsc_reset <= '1';
					input_buffer <= "00000000";
					input_available <= '0';
					data_buffer <= (others => '0');
					data_buffer_counter <= '0';
					watchdog_counter <= (others => '0');
					internal_reset <= '0';
					do_internal_reset <= '0';
					if(main_counter < 42) then
						tpl_reset <= '1';
					else
						tpl_reset <= '0';
					end if;
				when MASTER_DSC =>
					master_dsc_enable <= '1';
					net_dsc_enable <= '0';
					reg_dsc_enable <= '0';
					sync_dsc_enable <= '0';
					data_enable <= '0';
					master_dsc_reset <= '0';
					net_dsc_reset <= '0';
					reg_dsc_reset <= '0';
					sync_dsc_reset <= '0';
					internal_reset <= '0';
					do_internal_reset <= '0';
				when NET_DSC =>
					master_dsc_enable <= '0';
					net_dsc_enable <= '1';
					reg_dsc_enable <= '0';
					sync_dsc_enable <= '0';
					data_enable <= '0';
				when REG_DSC =>
					master_dsc_enable <= '0';
					net_dsc_enable <= '0';
					reg_dsc_enable <= '1';
					sync_dsc_enable <= '0';
					data_enable <= '0';
				when SYNC_DSC =>
					master_dsc_enable <= '0';
					net_dsc_enable <= '0';
					reg_dsc_enable <= '0';
					sync_dsc_enable <= '1';
					data_enable <= '0';
				when DATA =>
					master_dsc_enable <= '0';
					net_dsc_enable <= '0';
					reg_dsc_enable <= '0';
					sync_dsc_enable <= '1';		--Keep app_sync enabled to maintain the sync signal during operation
					data_enable <= '1';
				when ERROR =>
			end case;

			if(do_internal_reset = '1') then		--Perform reset if requested internally...
				internal_reset <= '1';
			end if;

			if(reset = '1' or internal_reset = '1') then
				tx_state <= IDLE;
				rx_state <= IDLE;
			else
				tx_state <= next_tx_state;
				rx_state <= next_rx_state;
			end if;

			crcgen_tx_clk_en_buffer <= tx_clk_en;
			crcgen_tx_clk_en <= crcgen_tx_clk_en_buffer;

			if(tx_state = IDLE) then		--This is used to optimize the jitter performance, by restarting the clock enable generation of the physical transmission layer, thus creating a better synchronization with the upper layers. Without, you risk waiting for tx_clk_en for a full 1.25 MHz clock cycle (800 ns) - by resetting the clock generation you wait 0 to 4 50 MHz clock cycles (max 80 ns) instead.
				tx_clk_div_reset <= '0';
			else
				tx_clk_div_reset <= '1';
			end if;

			case tx_state is				--Transmission state machine, this part needs to run on clk_50M to avoid multisourcing data_buffer
				when IDLE =>
					tx_data <= "00000000";
					tx_enable <= '0';
					crcgen_tx_reset <= '1';
					crc_tx_done <= '0';
				when DATA_CMD =>			--Transmit first nibble of DATA command
					if(tx_clk_en = '1' and tx_clk_div_reset_ack = '1') then
						tx_data <= CMD_DATA & "0000";
						tx_enable <= '1';
						crcgen_tx_reset <= '0';
						crcgen_tx_input <= CMD_DATA & "0000";
					end if;
				when DATA =>				--Transmit contents of data buffer
					if(tx_clk_en = '1' and tx_clk_div_reset_ack = '1') then
						if(not(data_buffer_counter = '0')) then
							tx_data <= data_buffer;
							data_buffer_counter <= '0';
							tx_enable <= '1';

							crcgen_tx_reset <= '0';									--Load the transmitted byte into the CRC module
							crcgen_tx_input <= data_buffer;
						else						--AARRG... Buffer underrun... do.. erm... something...
							tx_enable <= '0';
						end if;
					elsif((data_in_enable = '0') and (data_buffer_counter = '0') and (crcgen_tx_clk_en = '1')) then	--When data has been transmitted, load a byte containing all zeros into the CRC module
						crcgen_tx_input <= "00000000";
						crcgen_tx_clk_en_buffer <= '1';
						crc_tx_done <= '1';
					end if;
						
				when CRC =>						--Transmit CRC checksum
					if(tx_clk_en = '1') then
						if(force_packet_error = '1') then
							tx_data <= not crcgen_tx_output(7 downto 0); --Flip the CRC byte to make sure this packet produces a CRC error at the receiver... Of course you can neven be completely sure with a CRC check, but the probability is quite good;)
						else
							tx_data <= crcgen_tx_output(7 downto 0);	
						end if;
						
						tx_enable <= '1';
					end if;
				when ERROR =>
			end case;


			if(rx_clk = '0' and last_rx_clk = '1') then
				data_out <= data_out_buffer_2;
				data_out_buffer_2 <= data_out_buffer_1;
				data_out_enable <= data_out_enable_buffer_2;
				data_out_enable_buffer_2 <= data_out_enable_buffer_1;
				rx_cmd_valid <= rx_cmd_valid_buffer_2;
				rx_cmd_valid_buffer_2 <= rx_cmd_valid_buffer_1;
			end if;

			case rx_state is
				when IDLE =>
					data_out_buffer_1 <= (others => '0');
					data_out_buffer_2 <= (others => '0');
					data_out_enable_buffer_1 <= '0';
					data_out_enable_buffer_2 <= '0';
					rx_cmd_valid_buffer_1 <= '0';
					rx_cmd_valid_buffer_2 <= '0';
				when CMD =>
					watchdog_counter <= (others => '0');				--We are receiving something => The network is alive (in some way at least) => Reset the watchdog
					if(rx_clk = '1' and last_rx_clk = '0') then
						data_out_buffer_1 <= rx_data;

						rx_cmd_valid_buffer_1 <= '0';
						case main_state is
							when IDLE =>
							when MASTER_DSC =>
								data_out_enable_buffer_1 <= '1';
								
								case rx_data(7 downto 4) is				--Check for a valid command
									when CMD_MASTER_DSC =>
										rx_cmd_valid_buffer_1 <= '1';
									when CMD_MASTER_SET =>
										rx_cmd_valid_buffer_1 <= '1';
									when others =>
								end case;

							when NET_DSC =>
								data_out_enable_buffer_1 <= '1';

								case rx_data(7 downto 4) is				--Check for a valid command
									when CMD_MASTER_DSC =>				--If we receive master discovery packets, the network is being reset, so do the same here
										do_internal_reset <= '1';
									when CMD_NET_DSC =>
										rx_cmd_valid_buffer_1 <= '1';
									when CMD_NET_SET =>
										rx_cmd_valid_buffer_1 <= '1';
									when others =>
								end case;

							when REG_DSC =>
								data_out_enable_buffer_1 <= '1';

								case rx_data(7 downto 4) is				--As above
									when CMD_MASTER_DSC =>
										do_internal_reset <= '1';
									when CMD_REG_DSC =>
										rx_cmd_valid_buffer_1 <= '1';
									when CMD_REG_SET =>
										rx_cmd_valid_buffer_1 <= '1';
									when others =>
								end case;

							when SYNC_DSC =>
								data_out_enable_buffer_1 <= '1';

								case rx_data(7 downto 4) is				--As above (this is actually a leftover from an early sync_dsc implementation, where the delay was measured at startup - currently a fixed delay is used instead, but it's nice to keep this around (also to be able to react to network resets during the sync_dsc state quickly))
									when CMD_MASTER_DSC =>
										do_internal_reset <= '1';
									when CMD_SYNC_DSC =>
										rx_cmd_valid_buffer_1 <= '1';
									when CMD_SYNC_SET =>
										rx_cmd_valid_buffer_1 <= '1';
									when others =>
								end case;

							when DATA =>
								data_out_enable_buffer_1 <= '0';

								case rx_data(7 downto 4) is				--As above
									when CMD_MASTER_DSC =>
										do_internal_reset <= '1';
									when CMD_DATA =>
										rx_cmd_valid_buffer_1 <= '1';
									when others =>
								end case;

							when ERROR =>
						end case;
					end if;
				when DATA =>
					watchdog_counter <= (others => '0');
					if(rx_clk = '1' and last_rx_clk = '0') then
						data_out_enable_buffer_1 <= '1';
						data_out_buffer_1 <= rx_data;
					end if;
					crcgen_rx_output_buffer <= crcgen_rx_output;
				when CRC =>
					data_out_enable_buffer_1 <= '0';
					data_out_enable_buffer_2 <= '0';
					if(crcgen_rx_output_buffer = "00000000") then
						packet_error <= '0';
					else
						packet_error <= '1';
					end if;
				when ERROR =>
			end case;

			if(tx_clk_en = '0' and last_tx_clk_en = '1') then
				watchdog_counter <= watchdog_counter + 1;		--Increment the watchdog
			
				if(watchdog_counter = watchdog_threshold) then	--If the watchdog timer crosses the threshold, perform an internal reset
					do_internal_reset <= '1';
				end if;
			end if;
		
		end if;
	end process;
	
	data_out_strobe <= rx_clk and data_out_enable;
	
	process(main_state, main_counter, master_dsc_done, net_dsc_done, reg_dsc_done, sync_dsc_done, data_buffer_counter, internal_reset)
	begin
		case main_state is
			when IDLE =>
				if(main_counter = 100 and data_buffer_counter = '0') then
					next_main_state <= MASTER_DSC;
				else
					next_main_state <= IDLE;
				end if;
			when MASTER_DSC =>
				if(internal_reset = '1') then
					next_main_state <= IDLE;
				elsif(master_dsc_done = '1' and data_buffer_counter = '0') then
					next_main_state <= NET_DSC;
				else
					next_main_state <= MASTER_DSC;
				end if;
			when NET_DSC =>
				if(internal_reset = '1') then
					next_main_state <= IDLE;
				elsif(net_dsc_done = '1' and data_buffer_counter = '0') then
					next_main_state <= REG_DSC;
				else
					next_main_state <= NET_DSC;
				end if;
			when REG_DSC =>
				if(internal_reset = '1') then
					next_main_state <= IDLE;
				elsif(reg_dsc_done = '1' and data_buffer_counter = '0') then
					next_main_state <= SYNC_DSC;
				else
					next_main_state <= REG_DSC;
				end if;
			when SYNC_DSC =>
				if(internal_reset = '1') then
					next_main_state <= IDLE;
				elsif(sync_dsc_done = '1' and data_buffer_counter = '0') then
					next_main_state <= DATA;
				else
					next_main_state <= SYNC_DSC;
				end if;
			when DATA =>
				if(internal_reset = '1') then
					next_main_state <= IDLE;
				else
					next_main_state <= DATA;
				end if;
			when ERROR =>
				if(internal_reset = '1') then
					next_main_state <= IDLE;
				else
					next_main_state <= ERROR;
				end if;
			when others =>
				next_main_state <= ERROR;
		end case;
	end process;
	

	process(tx_state, data_in_enable, data_buffer_counter, main_state, crc_tx_done, tx_clk_en, tx_enable)
	begin
		case tx_state is
			when IDLE =>
				if(data_buffer_counter = '0') then
					next_tx_state <= IDLE;
				else
					if(main_state = DATA) then
						next_tx_state <= DATA_CMD;
					else
						next_tx_state <= DATA;
					end if;
				end if;
			when DATA_CMD =>
				if(tx_enable = '1') then
					next_tx_state <= DATA;
				else
					next_tx_state <= DATA_CMD;
				end if;
			when DATA =>
				if(crc_tx_done = '1') then
					next_tx_state <= CRC;
				else
					next_tx_state <= DATA;
				end if;
			when CRC =>
				if(crc_tx_done = '1' and tx_clk_en = '1') then
					next_tx_state <= IDLE;
				else
					next_tx_state <= CRC;
				end if;
			when ERROR =>
				next_tx_state <= IDLE;
		end case;
	end process;


	process(rx_state, rx_valid, rx_data, rx_error, rx_clk, last_rx_clk)	--Receive state machine
	begin
		case rx_state is
			when IDLE =>
				if(rx_valid = '1') then
					if(rx_error = '1') then
						next_rx_state <= ERROR;
					else
						next_rx_state <= CMD;
					end if;
				else
					next_rx_state <= IDLE;
				end if;
			when CMD =>
			if(rx_clk = '1' and last_rx_clk = '0') then
				if(rx_valid = '1') then
					if(rx_error = '1') then
						next_rx_state <= ERROR;
					else
						next_rx_state <= DATA;
					end if;
				else
					next_rx_state <= CRC;
				end if;
			else
				next_rx_state <= CMD;
			end if;
			when DATA =>
			if(rx_clk = '1' and last_rx_clk = '0') then
				if(rx_valid = '1') then
					if(rx_error = '1') then
						next_rx_state <= ERROR;
					else
						next_rx_state <= DATA;
					end if;
				else
					next_rx_state <= CRC;
				end if;
			else
				next_rx_state <= DATA;
			end if;
			when CRC =>
				next_rx_state <= IDLE;
			when ERROR =>
				next_rx_state <= IDLE;
		end case;
	end process;



	buffer_full <= '1' when (data_buffer_counter = '1') or (input_available = '1') else '0';

	--TosNet protocol interface input multiplexing
	data_in <= 			data_in_master when master_dsc_enable = '1' else
						data_in_net when net_dsc_enable = '1' else
						data_in_reg when reg_dsc_enable = '1' else
						data_in_ext when data_enable = '1' else
						data_in_sync when sync_dsc_enable = '1' else							--Sync needs to be last (or at least just after ext), as it will be kept enabled during operation... Same goes for the other two signals...
						"00000000";
	data_in_strobe <=	data_in_strobe_master when master_dsc_enable = '1' else
						data_in_strobe_net when net_dsc_enable = '1' else
						data_in_strobe_reg when reg_dsc_enable = '1' else
						data_in_strobe_ext when data_enable = '1' else
						data_in_strobe_sync when sync_dsc_enable = '1' else
						'0';
	data_in_enable <=	data_in_enable_master when master_dsc_enable = '1' else
						data_in_enable_net when net_dsc_enable = '1' else
						data_in_enable_reg when reg_dsc_enable = '1' else
						data_in_enable_ext when data_enable = '1' else
						data_in_enable_sync when sync_dsc_enable = '1' else
						'0';

	--Network register interface multiplexing
	network_reg_internal_clk <= 	network_reg_internal_clk_net when net_dsc_enable = '1' else
									network_reg_internal_clk_reg when reg_dsc_enable = '1' else
									'0';
	network_reg_internal_write_data <= 	network_reg_internal_write_data_net when net_dsc_enable = '1' else
										network_reg_internal_write_data_reg when reg_dsc_enable = '1' else
										"00000000";
	network_reg_internal_addr <= 	network_reg_internal_addr_net when net_dsc_enable = '1' else
									network_reg_internal_addr_reg when reg_dsc_enable = '1' else
									"000000";
	network_reg_internal_we <= 	network_reg_internal_we_net when net_dsc_enable = '1' else
								network_reg_internal_we_reg when reg_dsc_enable = '1' else
								"0";

	--TosNet protocol interface output gating
	data_out_ext <= data_out when data_enable = '1' else "00000000";
	data_out_enable_ext <= data_out_enable when data_enable = '1' else '0';
	data_out_strobe_ext <= data_out_strobe when data_enable = '1' else '0';
	
end Behavioral;

