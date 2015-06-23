----------------------------------------------------------------------------------
-- Company: 		University of Southern Denmark
-- Engineer: 		Simon Falsig
-- 
-- Create Date:    	7/3/2010 
-- Design Name		TosNet
-- Module Name:    	app_sync - Behavioral 
-- File Name:		app_sync.vhd
-- Project Name:	TosNet
-- Target Devices:	Spartan3/6
-- Tool versions:	Xilinx ISE 12.2
-- Description: 	The synchronization module handles the synchronization strobes
--					that are emitted at the end of each cycle. The strobe is
--					delayed for a fixed interval, depending on the node address
--					(which specifies the position of the node in the network
--					relative to the master), which causes the strobe to be emitted
--					at the same time in all nodes.
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

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tdl_app_sync is
	Port (	app_enable				: in	STD_LOGIC;
			app_data_in				: in	STD_LOGIC_VECTOR(7 downto 0);
			app_data_in_strobe		: in	STD_LOGIC;
			app_data_in_enable		: in	STD_LOGIC;
			app_data_out			: out	STD_LOGIC_VECTOR(7 downto 0);
			app_data_out_strobe		: out	STD_LOGIC;
			app_data_out_enable		: out	STD_LOGIC;
			app_buffer_full			: in	STD_LOGIC;
			app_packet_error		: in	STD_LOGIC;
			app_force_packet_error	: out	STD_LOGIC;
			app_cmd_valid			: in	STD_LOGIC;
			app_sync_strobe			: out	STD_LOGIC;
			app_is_master			: in	STD_LOGIC;
			app_dsc_done			: out	STD_LOGIC;
			app_node_id				: in	STD_LOGIC_VECTOR(3 downto 0);
			app_node_count			: in	STD_LOGIC_VECTOR(3 downto 0);
			app_node_address		: in	STD_LOGIC_VECTOR(3 downto 0);
			app_clk					: in	STD_LOGIC;
			app_reset				: in	STD_LOGIC);
end tdl_app_sync;

architecture Behavioral of tdl_app_sync is

	type STATES is (OFF, CALC_SYNC_DELAY, SYNC_READY, SYNC_ONLINE, SYNC_RUNNING, SYNC_SET);
	
	signal state					: STATES := OFF;
	signal next_state				: STATES := OFF;
	
	signal last_data_in_enable		: STD_LOGIC;

	signal counter					: STD_LOGIC_VECTOR(4 downto 0) := "00000";
	
	signal delay_counter			: STD_LOGIC_VECTOR(11 downto 0) := "000000000000";
	signal delay_current_node		: STD_LOGIC_VECTOR(11 downto 0) := "000000000000";
	constant delay_pr_node			: STD_LOGIC_VECTOR(11 downto 0) := "000100101100";

begin

	process(app_clk)
	begin
		if(app_clk = '1' and app_clk'EVENT) then
			if(app_reset = '1') then
				state <= OFF;
			else
				state <= next_state;
			end if;
			
			if(state = next_state) then
				counter <= counter + 1;
			else
				counter <= "00000";
			end if;

			case state is

				when OFF =>
					delay_counter <= "000000000000";
					delay_current_node <= "000000000000";
					app_dsc_done <= '0';
					last_data_in_enable <= '0';
					app_sync_strobe <= '0';

				when CALC_SYNC_DELAY =>
					if(app_is_master = '1') then
						delay_current_node <= "000000000000";
					elsif(counter = 0) then
						delay_current_node <= delay_pr_node;
					else
						delay_current_node <= delay_current_node + delay_pr_node;
					end if;
				
				when SYNC_READY =>
					if(app_is_master = '1') then
						app_sync_strobe <= '1';			--If this is the master node, send out a single sync pulse to get the application started...
					end if;
					
				when SYNC_ONLINE =>
					app_dsc_done <= '1';
					app_sync_strobe <= '0';
					delay_counter <= "000000000000";
					
				when SYNC_RUNNING =>
					delay_counter <= delay_counter + 1;
				
				when SYNC_SET =>
					app_sync_strobe <= '1';
					
			end case;
			
			last_data_in_enable <= app_data_in_enable;
			
		end if;
	end process;
	
	process(state, app_enable, counter, app_node_count, app_node_address, delay_counter, delay_current_node, app_data_in_enable, last_data_in_enable)
	begin
		case state is
			when OFF =>
				if(app_enable = '1') then
					next_state <= CALC_SYNC_DELAY;
				else
					next_state <= OFF;
				end if;
			when CALC_SYNC_DELAY =>
				if(counter = app_node_count - app_node_address - 1) then
					next_state <= SYNC_READY;
				else
					next_state <= CALC_SYNC_DELAY;
				end if;
			when SYNC_READY =>									--Make sure that the current transmission is done before going online (if not the enable signal from the received sync_set will trigger the sync mechanism... which is kinda not what we want)
				if(app_data_in_enable = '0') then
					next_state <= SYNC_ONLINE;
				else
					next_state <= SYNC_READY;
				end if;
			when SYNC_ONLINE =>
				if(app_data_in_enable = '0' and last_data_in_enable = '1') then
					next_state <= SYNC_RUNNING;
				else
					next_state <= SYNC_ONLINE;
				end if;
			when SYNC_RUNNING =>
				if(app_data_in_enable = '1') then			--If app_data_in_enable goes high before the sync_strobe something bad is happening - but let's just make sure we don't make it worse by sending a sync_strobe in the middle of a (probably erroneous) transmission...
					next_state <= SYNC_ONLINE;
				elsif(delay_counter = delay_current_node) then
					next_state <= SYNC_SET;
				else
					next_state <= SYNC_RUNNING;
				end if;
			when SYNC_SET =>
				next_state <= SYNC_ONLINE;
		end case;
	end process;
		

end Behavioral;

