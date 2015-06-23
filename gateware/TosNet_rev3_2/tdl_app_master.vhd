----------------------------------------------------------------------------------
-- Company: 		University of Southern Denmark
-- Engineer: 		Simon Falsig
-- 
-- Create Date:    	11/5/2010 
-- Design Name		TosNet
-- Module Name:    	app_master - Behavioral 
-- File Name:		app_master.vhd
-- Project Name:	TosNet
-- Target Devices:	Spartan3/6
-- Tool versions:	Xilinx ISE 12.2
-- Description: 	The master discovery module performs master discovery and
--					setup during startup. The node with the lowest node_id is
--					designated as the master, and transmits this information to
--					all other nodes in the network.
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


entity tdl_app_master is
	Port (	app_enable				: in	STD_LOGIC;
			app_data_in				: in	STD_LOGIC_VECTOR(7 downto 0);
			app_data_in_strobe		: in	STD_LOGIC;
			app_data_out			: out	STD_LOGIC_VECTOR(7 downto 0);
			app_data_out_strobe		: out	STD_LOGIC;
			app_data_out_enable		: out	STD_LOGIC;
			app_buffer_full			: in	STD_LOGIC;
			app_packet_error		: in	STD_LOGIC;
			app_force_packet_error	: out	STD_LOGIC;
			app_cmd_valid			: in	STD_LOGIC;
			app_sync_strobe			: in	STD_LOGIC;
			app_is_master			: out	STD_LOGIC;
			app_dsc_done			: out	STD_LOGIC;
			app_node_id				: in	STD_LOGIC_VECTOR(3 downto 0);
			app_clk					: in	STD_LOGIC;
			app_reset				: in	STD_LOGIC);
end tdl_app_master;

architecture Behavioral of tdl_app_master is

	type STATES is (OFF, IDLE, DSC, CMP, SET, SET_RESPOND, WAIT_FOR_SET, DONE);
	
	signal state						: STATES := OFF;
	signal next_state					: STATES := OFF;
	
	signal last_data_in_strobe 			: STD_LOGIC;
	signal lowest_current_id			: STD_LOGIC_VECTOR(3 downto 0);

	signal counter						: STD_LOGIC_VECTOR(2 downto 0) := "000";

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
				counter <= "000";
			end if;

			case state is

				when OFF =>
					app_data_out_enable <= '0';
					app_data_out_strobe <= '0';
					app_data_out <= "00000000";
					app_force_packet_error <= 'Z';
					app_is_master <= '0';
					app_dsc_done <= '0';
					last_data_in_strobe <= '0';
					lowest_current_id <= app_node_id;

				when IDLE =>
					app_data_out_enable <= '0';
					app_data_out_strobe <= '0';
					app_dsc_done <= '0';
					app_is_master <= '0';

				when DSC =>							--Transmit discovery packet
					app_data_out_enable <= '1';
					app_data_out <= CMD_MASTER_DSC & lowest_current_id;
					app_data_out_strobe <= '1';

				when CMP =>							--Compare received packets to lowest known id
					app_data_out_enable <= '0';
					app_data_out_strobe <= '0';
					
					if(app_data_in_strobe = '1' and last_data_in_strobe = '0' and app_cmd_valid = '1') then
						if(app_data_in(7 downto 4) = CMD_MASTER_DSC) then
							if(app_data_in(3 downto 0) = app_node_id) then
								app_is_master <= '1';
							elsif(app_data_in(3 downto 0) < app_node_id) then
								lowest_current_id <= app_data_in(3 downto 0);
							end if;
						end if;
					end if;

				when SET =>							--Transmit set packet (master only)
					app_data_out_enable <= '1';
					app_data_out <= CMD_MASTER_SET & lowest_current_id;
					app_data_out_strobe <= '1';
					
				when SET_RESPOND =>					--Forward set packet (slave only)
					app_data_out_enable <= '1';
					app_data_out <= app_data_in(7 downto 0);
					app_data_out_strobe <= '1';

				when WAIT_FOR_SET =>				--Wait until set is received again (master only)
					app_data_out_enable <= '0';
					app_data_out_strobe <= '0';
					
				when DONE =>						--Done!
					app_dsc_done <= '1';
					app_data_out_enable <= '0';
					app_data_out_strobe <= '0';
					app_data_out <= "00000000";
					app_force_packet_error <= 'Z';
					
			end case;
			
			last_data_in_strobe <= app_data_in_strobe;
			
		end if;
	end process;
	

	process(state, app_enable, app_data_in, app_data_in_strobe, last_data_in_strobe, app_node_id, app_cmd_valid)
	begin
		case state is
			when OFF =>
				if(app_enable = '1') then
					next_state <= IDLE;
				else
					next_state <= OFF;
				end if;
			when IDLE =>
				next_state <= DSC;
			when DSC =>
				next_state <= CMP;
			when CMP =>
				next_state <= CMP;

				if(app_data_in_strobe = '1' and last_data_in_strobe = '0' and app_cmd_valid = '1') then
					if(app_data_in(7 downto 4) = CMD_MASTER_DSC) then
						if(app_data_in(3 downto 0) = app_node_id) then
							next_state <= SET;
						else
							next_state <= DSC;
						end if;
					elsif(app_data_in(7 downto 4) = CMD_MASTER_SET) then
						if(app_data_in(3 downto 0) > app_node_id) then		--Make a quick sanity check on the received master node id, if it is larger than the id of this node, then something is wrong...
							next_state <= IDLE;
						else
							next_state <= SET_RESPOND;
						end if;
					end if;
				end if;
			when SET =>
				next_state <= WAIT_FOR_SET;

			when SET_RESPOND =>
				next_state <= DONE;
				
			when WAIT_FOR_SET =>
				next_state <= WAIT_FOR_SET;
				
				if(app_data_in_strobe = '1' and last_data_in_strobe = '0' and app_cmd_valid = '1') then
					if(app_data_in(7 downto 4) = CMD_MASTER_SET) then
						next_state <= DONE;
					end if;
				end if;
			
			when DONE =>
				next_state <= DONE;
		end case;
	end process;
		

end Behavioral;

