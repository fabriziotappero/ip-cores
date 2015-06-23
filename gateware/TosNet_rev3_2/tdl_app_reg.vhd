----------------------------------------------------------------------------------
-- Company: 		University of Southern Denmark
-- Engineer: 		Simon Falsig
-- 
-- Create Date:    	10/3/2010 
-- Design Name		TosNet
-- Module Name:    	app_reg - Behavioral 
-- File Name:		app_reg.vhd
-- Project Name:	TosNet
-- Target Devices:	Spartan3/6
-- Tool versions:	Xilinx ISE 12.2
-- Description: 	The registry discovery module runs during startup, and polls
--					all nodes in the network for their enabled registers. The
--					gathered data is then distributed back to the nodes, and
--					stored in their network registers.
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

entity tdl_app_reg is
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
end tdl_app_reg;

architecture Behavioral of tdl_app_reg is

	type STATES is (OFF, IDLE, DSC_SEND, DSC_RECEIVE, DSC_RESPOND, SET_SEND, SET_RECEIVE, SET_RESPOND, DONE);
	
	signal state						: STATES := OFF;
	signal next_state					: STATES := OFF;
	
	signal last_data_in_strobe 			: STD_LOGIC;
	signal bytes_received				: STD_LOGIC_VECTOR(5 downto 0) := "000000";
	signal cmd_received					: STD_LOGIC := '0';
	
	signal counter						: STD_LOGIC_VECTOR(8 downto 0) := "000000000";
	
	signal node_count					: STD_LOGIC_VECTOR(4 downto 0);
	signal node_address					: STD_LOGIC_VECTOR(4 downto 0);
begin

	node_count <= '0' & app_node_count;			--Add a leading 0, so we have an extra bit for eventual carrys
	node_address <= '0' & app_node_address;

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
					bytes_received <= "000000";
					cmd_received <= '0';

				when IDLE =>
					app_data_out_enable <= '0';
					app_data_out_strobe <= '0';
					app_dsc_done <= '0';
					app_network_reg_clk <= '0';
					app_network_reg_we <= "0";

				when DSC_SEND =>					--Transmit discovery packet (master only)
					if(counter(8 downto 1) = 0) then
						app_data_out_enable <= '1';
						app_data_out <= CMD_REG_DSC & "0000";
						app_data_out_strobe <= '1';
					elsif(counter(8 downto 1) = 1) then
						app_data_out_strobe <= '0';
					elsif(counter(8 downto 1) = 2) then
						app_data_out <= app_reg_enable;
						app_data_out_strobe <= '1';
					elsif(counter(8 downto 1) = 3) then
						app_data_out_strobe <= '0';
					elsif(counter(8 downto 1) = 4) then
						app_data_out <= app_reg_enable;
						app_data_out_strobe <= '1';
					else
						app_data_out_enable <= '0';
						app_data_out_strobe <= '0';
					end if;

				when DSC_RECEIVE =>				--Receive discovery packet
					if(app_data_in_strobe = '1' and last_data_in_strobe = '0') then
						if(bytes_received = 0 and app_data_in(7 downto 4) = CMD_REG_DSC and cmd_received = '0') then
							bytes_received <= "000000";
							cmd_received <= '1';
						else
							app_network_reg_addr <= bytes_received(4 downto 0) & not bytes_received(0);
							app_network_reg_data_out <= app_data_in;
							app_network_reg_we <= "1";
							app_network_reg_clk <= '0';
							bytes_received <= bytes_received + 1;
						end if;
					elsif(app_data_in_strobe = '0' and last_data_in_strobe = '1' and app_network_reg_we = "1") then
						app_network_reg_clk <= '1';
					else
						app_network_reg_clk <= '0';
					end if;

				when DSC_RESPOND =>				--Forward discovery packet (slave only)
					if(counter(8 downto 1) = 0) then
						app_network_reg_we <= "0";
						app_network_reg_clk <= '0';
						app_network_reg_addr <= counter(6 downto 2) & not counter(2);
						app_data_out_enable <= '1';
						app_data_out_strobe <= '1';
						app_data_out <= CMD_REG_DSC & "0000";
					elsif(counter(7 downto 1) = (node_address) & "01") then
						app_data_out_strobe <= '0';
					elsif(counter(7 downto 1) = (node_address) & "10") then
						app_data_out_strobe <= '1';
						app_data_out <= app_reg_enable;
					elsif(counter(7 downto 1) = (node_address) & "11") then
						app_data_out_strobe <= '0';
					elsif(counter(7 downto 1) = (node_address + 1) & "00") then
						app_data_out_strobe <= '1';
						app_data_out <= app_reg_enable;
					elsif(counter(7 downto 1) = (node_address + 1) & "01") then
						app_network_reg_we <= "0";
						app_network_reg_clk <= '0';
						app_data_out_strobe <= '0';
						app_data_out_enable <= '0';
						bytes_received <= "000000";		--Reset bytes_received, as the combinatorial part doesn't work otherwise
						cmd_received <= '0';
					elsif(counter(1) = '1') then
						app_data_out_strobe <= '0';
						app_network_reg_clk <= '1';
					else
						app_data_out_strobe <= '1';
						app_data_out <= app_network_reg_data_in;
						app_network_reg_clk <= '0';
						app_network_reg_addr <= counter(6 downto 2) & not counter(2);
					end if;
					
				when SET_SEND =>					--Transmit set packet (master only)
					if(counter(8 downto 1) = 0) then
						app_network_reg_we <= "0";
						app_network_reg_clk <= '0';
						app_network_reg_addr <= counter(6 downto 2) & not counter(2);
						app_data_out_enable <= '1';
						app_data_out_strobe <= '1';
						app_data_out <= CMD_REG_SET & "0000";
					elsif(counter(7 downto 1) = node_count & "01") then
						app_network_reg_we <= "0";
						app_network_reg_clk <= '0';
						app_data_out_strobe <= '0';
						app_data_out_enable <= '0';
						bytes_received <= "000000";				--Reset node_count and nodes_received, as the combinatorial part doesn't work otherwise
						cmd_received <= '0';
					elsif(counter(1) = '1') then
						app_data_out_strobe <= '0';
						app_network_reg_clk <= '1';
					else
						app_data_out_strobe <= '1';
						app_data_out <= app_network_reg_data_in;
						app_network_reg_clk <= '0';
						app_network_reg_addr <= counter(6 downto 2) & not counter(2);
					end if;

				when SET_RECEIVE =>				--Receive set packet
					if(app_data_in_strobe = '1' and last_data_in_strobe = '0') then
						if(bytes_received = 0 and app_data_in(7 downto 4) = CMD_REG_SET and cmd_received = '0') then
							bytes_received <= "000000";
							cmd_received <= '1';
						else
							app_network_reg_addr <= bytes_received(4 downto 0) & not bytes_received(0);
							app_network_reg_data_out <= app_data_in;
							app_network_reg_we <= "1";
							app_network_reg_clk <= '0';
							bytes_received <= bytes_received + 1;
						end if;
					elsif(app_data_in_strobe = '0' and last_data_in_strobe = '1' and app_network_reg_we = "1") then
						app_network_reg_clk <= '1';
					else
						app_network_reg_clk <= '0';
					end if;

				when SET_RESPOND =>				--Forward set packet (slave only)
					if(counter(8 downto 1) = 0) then
						app_network_reg_we <= "0";
						app_network_reg_clk <= '0';
						app_network_reg_addr <= counter(6 downto 2) & not counter(2);
						app_data_out_enable <= '1';
						app_data_out_strobe <= '1';
						app_data_out <= CMD_REG_SET & "0000";
					elsif(counter(7 downto 1) = node_count & "01") then
						app_network_reg_we <= "0";
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
						app_network_reg_addr <= counter(6 downto 2) & not counter(2);
					end if;

				when DONE =>						--Done!
					app_network_reg_clk <= '0';
					app_network_reg_addr <= "000000";
					app_network_reg_data_out <= "00000000";
					app_network_reg_we <= "0";
					app_dsc_done <= '1';
					app_data_out_enable <= '0';
					app_data_out_strobe <= '0';
					app_data_out <= "00000000";
					app_force_packet_error <= 'Z';
			end case;
			
			last_data_in_strobe <= app_data_in_strobe;
			
		end if;
	end process;
	

	process(state, app_enable, counter, node_count, node_address, bytes_received, app_is_master, app_data_in_strobe, app_node_count)
	begin
		case state is

			when OFF =>
				if(app_enable = '1') then
					next_state <= IDLE;
				else
					next_state <= OFF;
				end if;

			when IDLE =>
				if(app_is_master = '1') then
					next_state <= DSC_SEND;
				else
					next_state <= DSC_RECEIVE;
				end if;

			when DSC_SEND =>
				if(counter(8 downto 1) = 5) then
					next_state <= DSC_RECEIVE;
				else
					next_state <= DSC_SEND;
				end if;

			when DSC_RECEIVE =>
				next_state <= DSC_RECEIVE;
				
				if(app_is_master = '0') then
					if((bytes_received(5 downto 1) = node_address) and app_data_in_strobe = '0') then
						next_state <= DSC_RESPOND;
					end if;
				else
					if((bytes_received(5 downto 1) = node_count) and app_data_in_strobe = '0') then	
						next_state <= SET_SEND;
					end if;
				end if;

			when DSC_RESPOND =>
				if(counter(7 downto 1) = (node_address + 1) & "01") then
					next_state <= SET_RECEIVE;
				else
					next_state <= DSC_RESPOND;
				end if;

			when SET_SEND =>
				if(counter(7 downto 1) = node_count & "01") then
					next_state <= SET_RECEIVE;
				else
					next_state <= SET_SEND;
				end if;

			when SET_RECEIVE =>
				next_state <= SET_RECEIVE;
				if((bytes_received(5 downto 1) = node_count) and (app_data_in_strobe = '0')) then
					if(app_is_master = '0') then
						next_state <= SET_RESPOND;
					else
						next_state <= DONE;
					end if;
				end if;

			when SET_RESPOND =>
				if(counter(7 downto 1) = node_count & "01") then
					next_state <= DONE;
				else
					next_state <= SET_RESPOND;
				end if;

			when DONE =>
				next_state <= DONE;

		end case;
	end process;
		

end Behavioral;
