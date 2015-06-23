----------------------------------------------------------------------------------
-- Company: 		University of Southern Denmark
-- Engineer: 		Simon Falsig
-- 
-- Create Date:    	10/3/2010 
-- Design Name		TosNet
-- Module Name:    	app_net - Behavioral 
-- File Name:		app_net.vhd
-- Project Name:	TosNet
-- Target Devices:	Spartan3/6
-- Tool versions:	Xilinx ISE 12.2
-- Description: 	The network discorvery module runs during startup, and 
--					performs network discovery. It is initiated by the master
--					node, and polls all attached nodes for their node_ids which
--					are stored together with the addresses of the nodes (that is,
--					their position in the ring, relative to the master) in the
--					network registers on all nodes.
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.commandpack.all;


entity tdl_app_net is
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
			app_node_count				: out	STD_LOGIC_VECTOR(3 downto 0);
			app_node_address			: out	STD_LOGIC_VECTOR(3 downto 0);
			app_node_id					: in	STD_LOGIC_VECTOR(3 downto 0);
			app_clk						: in	STD_LOGIC;
			app_reset					: in	STD_LOGIC);
end tdl_app_net;

architecture Behavioral of tdl_app_net is

	type STATES is (OFF, IDLE, CLEAR_NETWORKREG, DSC_SEND, DSC_RECEIVE, DSC_RESPOND, SET_SEND, SET_RECEIVE, SET_RESPOND, DONE);
	
	signal state						: STATES := OFF;
	signal next_state					: STATES := OFF;
	
	signal last_data_in_strobe 			: STD_LOGIC;
	signal node_count					: STD_LOGIC_VECTOR(3 downto 0) := "0000";
	signal node_address					: STD_LOGIC_VECTOR(3 downto 0) := "0000";
	signal nodes_received				: STD_LOGIC_VECTOR(4 downto 0) := "00000";
	
	signal cmd_received					: STD_LOGIC := '0';
	
	signal counter						: STD_LOGIC_VECTOR(8 downto 0) := "000000000";

begin

	process(app_clk)
	begin
		if(app_clk = '1' and app_clk'EVENT) then
			if(app_reset = '1') then
				state <= OFF;
			else
				state <= next_state;
			end if;

			if(app_buffer_full = '1') then
				counter <= counter;
			elsif(state = next_state) then
				counter <= counter + 1;
			else
				counter <= "000000000";
			end if;

			case state is

				when OFF =>
					app_data_out_enable <= '0';
					app_data_out_strobe <= '0';
					app_data_out <= "00000000";
					app_force_packet_error <= 'Z';
					app_dsc_done <= '0';
					app_network_reg_clk <= '0';
					app_network_reg_addr <= "000000";
					app_network_reg_data_out <= "00000000";
					app_network_reg_we <= "0";
					last_data_in_strobe <= '0';
					node_count <= "0000";
					nodes_received <= "00000";
					cmd_received <= '0';
					node_address <= "0000";

				when IDLE =>
					app_data_out_enable <= '0';
					app_data_out_strobe <= '0';
					app_dsc_done <= '0';
					app_network_reg_clk <= '0';
					app_network_reg_we <= "0";
				
				when CLEAR_NETWORKREG =>
					app_network_reg_we <= "1";
					if(counter(0) = '0') then
						app_network_reg_clk <= '0';
						app_network_reg_addr <= counter(6 downto 1);
						app_network_reg_data_out <= "00000000";
					else
						app_network_reg_clk <= '1';
					end if;
				
				when DSC_SEND =>						--Send discovery packet (master only)
					if(counter(8 downto 1) = 0) then
						app_data_out_enable <= '1';
						app_data_out <= CMD_NET_DSC & "0001";
						app_data_out_strobe <= '1';
					elsif(counter(8 downto 1) = 1) then
						app_data_out_strobe <= '0';
					elsif(counter(8 downto 1) = 2) then
						app_data_out <= "0000" & app_node_id;
						app_data_out_strobe <= '1';
					else
						app_data_out_enable <= '0';
						app_data_out_strobe <= '0';
					end if;

				when DSC_RECEIVE =>					--Receive discovery packet
					if(app_data_in_strobe = '1' and last_data_in_strobe = '0') then
						if(node_count = 0 and app_data_in(7 downto 4) = CMD_NET_DSC and cmd_received = '0') then
							node_count <= app_data_in(3 downto 0);
							node_address <= app_data_in(3 downto 0);
							nodes_received <= "00000";
							cmd_received <= '1';
						else
							app_network_reg_addr <= nodes_received(3 downto 0) & "00";
							app_network_reg_data_out <= app_data_in;
							app_network_reg_we <= "1";
							app_network_reg_clk <= '0';
							nodes_received <= nodes_received + 1;
						end if;
					elsif(app_data_in_strobe = '0' and last_data_in_strobe = '1' and app_network_reg_we = "1") then
						app_network_reg_clk <= '1';
					else
						app_network_reg_clk <= '0';
					end if;

				when DSC_RESPOND =>				--Forward discovery packet (slave only)
					app_network_reg_we <= "0";

					if(counter(8 downto 1) = 0) then
						app_network_reg_clk <= '0';
						app_network_reg_addr <= counter(5 downto 2) & "00";
						app_data_out_enable <= '1';
						app_data_out_strobe <= '1';
						app_data_out <= CMD_NET_DSC & (node_count + 1);
					elsif(counter(5 downto 1) = node_count & '1') then
						app_data_out_strobe <= '0';
					elsif(counter(5 downto 1) = (node_count + 1) & '0') then
						app_data_out_strobe <= '1';
						app_data_out <= node_count & app_node_id;
					elsif(counter(5 downto 1) = (node_count + 1) & '1') then
						app_data_out_strobe <= '0';
						app_data_out_enable <= '0';
						node_count <= "0000";				--Reset node_count and nodes_received, as the combinatorial part doesn't work otherwise
						nodes_received <= "00000";
						cmd_received <= '0';
					elsif(counter(1) = '1') then
						app_data_out_strobe <= '0';
						app_network_reg_clk <= '1';
					else
						app_data_out_strobe <= '1';
						app_data_out <= app_network_reg_data_in;
						app_network_reg_clk <= '0';
						app_network_reg_addr <= counter(5 downto 2) & "00";
					end if;
					
				when SET_SEND =>					--Transmit set packet (master only)
					app_network_reg_we <= "0";
					if(counter(8 downto 1) = 0) then
						app_network_reg_clk <= '0';
						app_network_reg_addr <= counter(5 downto 2) & "00";
						app_data_out_enable <= '1';
						app_data_out_strobe <= '1';
						app_data_out <= CMD_NET_SET & node_count;
					elsif(counter(5 downto 1) = node_count & '1') then
						app_network_reg_clk <= '0';
						app_data_out_strobe <= '0';
						app_data_out_enable <= '0';
						node_count <= "0000";				--Reset node_count and nodes_received, as the combinatorial part doesn't work otherwise
						nodes_received <= "00000";
						cmd_received <= '0';
					elsif(counter(1) = '1') then
						app_data_out_strobe <= '0';
						app_network_reg_clk <= '1';
					else
						app_data_out_strobe <= '1';
						app_data_out <= app_network_reg_data_in;
						app_network_reg_clk <= '0';
						app_network_reg_addr <= counter(5 downto 2) & "00";
					end if;

				when SET_RECEIVE =>				--Receive set packet
					if(app_data_in_strobe = '1' and last_data_in_strobe = '0') then
						if(node_count = 0 and app_data_in(7 downto 4) = CMD_NET_SET and cmd_received = '0') then
							node_count <= app_data_in(3 downto 0);
							nodes_received <= "00000";
							cmd_received <= '1';
						else
							app_network_reg_addr <= nodes_received(3 downto 0) & "00";
							app_network_reg_data_out <= app_data_in;
							app_network_reg_we <= "1";
							app_network_reg_clk <= '0';
							nodes_received <= nodes_received + 1;
						end if;
					elsif(app_data_in_strobe = '0' and last_data_in_strobe = '1' and app_network_reg_we = "1") then
						app_network_reg_clk <= '1';
					else
						app_network_reg_clk <= '0';
					end if;

				when SET_RESPOND =>				--Forward set packet (slave only)
					app_network_reg_we <= "0";
					if(counter(8 downto 1) = 0) then
						app_network_reg_clk <= '0';
						app_network_reg_addr <= counter(5 downto 2) & "00";
						app_data_out_enable <= '1';
						app_data_out_strobe <= '1';
						app_data_out <= CMD_NET_SET & node_count;
					elsif(counter(5 downto 1) = node_count & '1') then
						app_network_reg_clk <= '0';
						app_data_out_strobe <= '0';
						app_data_out_enable <= '0';
					elsif(counter(1) = '1') then
						app_data_out_strobe <= '0';
						app_network_reg_clk <= '1';
					else
						app_data_out_strobe <= '1';
						app_data_out <= app_network_reg_data_in;
						app_network_reg_clk <= '0';
						app_network_reg_addr <= counter(5 downto 2) & "00";
					end if;
	
				when DONE =>					--Done!
					app_network_reg_we <= "0";
					if(app_is_master = '1') then
						app_node_address <= "0000";
					else
						app_node_address <= node_address;
					end if;
					app_node_count <= node_count;
					app_network_reg_clk <= '0';
					app_network_reg_addr <= "000000";
					app_network_reg_data_out <= "00000000";
					app_dsc_done <= '1';
					app_data_out_enable <= '0';
					app_data_out_strobe <= '0';
					app_data_out <= "00000000";
					app_force_packet_error <= 'Z';
			end case;
			
			last_data_in_strobe <= app_data_in_strobe;
			
		end if;
	end process;
	

	process(state, app_enable, app_data_in_strobe, counter, node_count, nodes_received, app_is_master)
	begin
		case state is

			when OFF =>
				if(app_enable = '1') then
					next_state <= IDLE;
				else
					next_state <= OFF;
				end if;

			when IDLE =>
				next_state <= CLEAR_NETWORKREG;
			
			when CLEAR_NETWORKREG =>
				if(counter = 128) then
					if(app_is_master = '1') then
						next_state <= DSC_SEND;
					else
						next_state <= DSC_RECEIVE;
					end if;
				else
					next_state <= CLEAR_NETWORKREG;
				end if;					
			
			when DSC_SEND =>
				if(counter(8 downto 1) = 3) then
					next_state <= DSC_RECEIVE;
				else
					next_state <= DSC_SEND;
				end if;

			when DSC_RECEIVE =>
				next_state <= DSC_RECEIVE;
				
				if((nodes_received = node_count) and not (node_count = 0) and (app_data_in_strobe = '0')) then
					if(app_is_master = '0') then
						next_state <= DSC_RESPOND;
					else
						next_state <= SET_SEND;
					end if;
				end if;

			when DSC_RESPOND =>
				if(counter(5 downto 1) = (node_count + 1) & '1') then
					next_state <= SET_RECEIVE;
				else
					next_state <= DSC_RESPOND;
				end if;

			when SET_SEND =>
				if(counter(5 downto 1) = node_count & '1') then
					next_state <= SET_RECEIVE;
				else
					next_state <= SET_SEND;
				end if;

			when SET_RECEIVE =>
				next_state <= SET_RECEIVE;
				if((nodes_received = node_count) and not (node_count = 0) and (app_data_in_strobe = '0')) then
					if(app_is_master = '0') then
						next_state <= SET_RESPOND;
					else
						next_state <= DONE;
					end if;
				end if;

			when SET_RESPOND =>
				if(counter(5 downto 1) = node_count & '1') then
					next_state <= DONE;
				else
					next_state <= SET_RESPOND;
				end if;

			when DONE =>
				next_state <= DONE;

		end case;
	end process;
		

end Behavioral;

