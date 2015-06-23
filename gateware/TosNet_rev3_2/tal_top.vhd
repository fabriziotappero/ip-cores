----------------------------------------------------------------------------------
-- Company: 		University of Southern Denmark
-- Engineer: 		Simon Falsig
-- 
-- Create Date:    	17/3/2008 
-- Design Name		TosNet
-- Module Name:    	tal_top - Behavioral 
-- File Name:		tal_top.vhd
-- Project Name:	TosNet
-- Target Devices:	Spartan3/6
-- Tool versions:	Xilinx ISE 12.2
-- Description: 	The TosNet application layer handles the shared memory block,
--					and keeps it updated. It also handles the FIFO buffers used 
--					for the asynchronous communication.
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
use IEEE.NUMERIC_STD.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tal_top is
	Generic(disable_master			: in	STD_LOGIC := '0';
			disable_slave			: in	STD_LOGIC := '1';
			disable_async			: in	STD_LOGIC := '1');
	Port (	node_id					: in	STD_LOGIC_VECTOR(3 downto 0);
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
end tal_top;

architecture Behavioral of tal_top is
	constant ASYNC_M2S_VALID			: STD_LOGIC_VECTOR := "1001";
	constant ASYNC_S2M_VALID			: STD_LOGIC_VECTOR := "1010";
	constant ASYNC_M2S_INVALID			: STD_LOGIC_VECTOR := "0001";
	constant ASYNC_S2M_INVALID			: STD_LOGIC_VECTOR := "0010";

	type SLV_STATES is (IDLE, ADDR_1, ADDR_2, ADDR_3, DATA, ASYNC_CTL_HEAD, ASYNC, ASYNC_CTL_TAIL);
	type MST_TRN_STATES is (IDLE, ADDR_1, ADDR_2, ADDR_3, DATA, ASYNC_CTL_HEAD, ASYNC, ASYNC_CTL_TAIL, WAIT_STATE);
	type MST_REC_STATES is (IDLE, ADDR_1, ADDR_2, ADDR_3, DATA, ASYNC_CTL_HEAD, ASYNC, ASYNC_CTL_TAIL);
	
	signal slv_state					: SLV_STATES := IDLE;
	signal next_slv_state				: SLV_STATES := IDLE;
	
	signal mst_trn_state				: MST_TRN_STATES := IDLE;
	signal next_mst_trn_state			: MST_TRN_STATES := IDLE;

	signal mst_rec_state				: MST_REC_STATES := IDLE;
	signal next_mst_rec_state			: MST_REC_STATES := IDLE;
	
	signal slave_reset					: STD_LOGIC;
	signal master_reset					: STD_LOGIC;
	
	signal last_data_in_strobe 			: STD_LOGIC := '0';

	signal current_user_reg_write		: STD_LOGIC := '0';
	signal current_sys_reg_write		: STD_LOGIC := '1';

	signal current_user_reg_read		: STD_LOGIC := '0';
	signal current_sys_reg_read			: STD_LOGIC := '1';
	
	signal skip_counter_write			: STD_LOGIC_VECTOR(15 downto 0) := "0000000000000000";
	signal skip_counter_read			: STD_LOGIC_VECTOR(15 downto 0) := "0000000000000000";
	
	signal write_commited				: STD_LOGIC := '0';
	signal read_commited				: STD_LOGIC := '0';
	
	signal last_commit_write			: STD_LOGIC;
	signal last_commit_read				: STD_LOGIC;
	
	signal data_reg_addr_user			: STD_LOGIC_VECTOR(10 downto 0) := "00000000000";
	
	signal sync_ok						: STD_LOGIC := '1';
	signal last_sync_strobe				: STD_LOGIC := '0';

	signal slv_current_node				: STD_LOGIC_VECTOR(3 downto 0) := "0000";
	signal slv_current_reg				: STD_LOGIC_VECTOR(2 downto 0) := "000";
	signal slv_current_rw				: STD_LOGIC := '0';	--Read: '0', Write: '1'
	signal slv_current_var	 			: STD_LOGIC_VECTOR(3 downto 0) := "0000";
	
	signal slv_current_reg_ok			: STD_LOGIC;
	
	signal slv_current_node_address				: STD_LOGIC_VECTOR(3 downto 0);
	signal slv_current_node_id					: STD_LOGIC_VECTOR(3 downto 0);
	signal slv_current_node_read_reg_enable		: STD_LOGIC_VECTOR(7 downto 0);
	signal slv_current_node_write_reg_enable	: STD_LOGIC_VECTOR(7 downto 0);

	signal mst_trn_current_node			: STD_LOGIC_VECTOR(3 downto 0) := "0000";
	signal mst_trn_current_reg			: STD_LOGIC_VECTOR(2 downto 0) := "000";
	signal mst_trn_current_rw			: STD_LOGIC := '0';	--Read: '0', Write: '1'
	signal mst_trn_current_var	 		: STD_LOGIC_VECTOR(3 downto 0) := "0000";
	
	signal mst_trn_current_reg_ok		: STD_LOGIC;
	
	signal mst_trn_current_node_address			: STD_LOGIC_VECTOR(3 downto 0);
	signal mst_trn_current_node_id				: STD_LOGIC_VECTOR(3 downto 0);
	signal mst_trn_current_node_read_reg_enable	: STD_LOGIC_VECTOR(7 downto 0);
	signal mst_trn_current_node_write_reg_enable: STD_LOGIC_VECTOR(7 downto 0);

	signal mst_rec_current_node			: STD_LOGIC_VECTOR(3 downto 0) := "0000";
	signal mst_rec_current_reg			: STD_LOGIC_VECTOR(2 downto 0) := "000";
	signal mst_rec_current_rw			: STD_LOGIC := '0';	--Read: '0', Write: '1'
	signal mst_rec_current_var	 		: STD_LOGIC_VECTOR(3 downto 0) := "0000";
	
	signal mst_rec_current_reg_ok		: STD_LOGIC;
	
	signal mst_rec_current_node_address			: STD_LOGIC_VECTOR(3 downto 0);
	signal mst_rec_current_node_id				: STD_LOGIC_VECTOR(3 downto 0);
	signal mst_rec_current_node_read_reg_enable	: STD_LOGIC_VECTOR(7 downto 0);
	signal mst_rec_current_node_write_reg_enable: STD_LOGIC_VECTOR(7 downto 0);

	signal data_in_buffer				: STD_LOGIC_VECTOR(7 downto 0);
	signal waiting_for_trn				: STD_LOGIC;

	signal data_reg_internal_clk		: STD_LOGIC;
	signal data_reg_internal_data_in	: STD_LOGIC_VECTOR(7 downto 0);
	signal data_reg_internal_addr		: STD_LOGIC_VECTOR(12 downto 0);
	signal data_reg_internal_data_out	: STD_LOGIC_VECTOR(7 downto 0);
	signal data_reg_internal_we			: STD_LOGIC_VECTOR(0 downto 0);

	signal async_rd_en					: STD_LOGIC;
	signal async_wr_en					: STD_LOGIC;
	signal async_rd_data				: STD_LOGIC_VECTOR(37 downto 0);
	signal async_wr_data				: STD_LOGIC_VECTOR(37 downto 0);
	signal async_full					: STD_LOGIC;
	signal async_empty					: STD_LOGIC;
	signal async_valid					: STD_LOGIC;
	
	signal async_buffer					: STD_LOGIC_VECTOR(95 downto 0);
	signal async_trn_byte_count			: STD_LOGIC_VECTOR(3 downto 0);
	signal async_trn_valid_byte_count	: STD_LOGIC_VECTOR(3 downto 0);
	signal async_rec_byte_count			: STD_LOGIC_VECTOR(3 downto 0);
	signal async_rec_valid_byte_count	: STD_LOGIC_VECTOR(3 downto 0);
	signal async_trn_target				: STD_LOGIC_VECTOR(3 downto 0);
	signal async_rec_target				: STD_LOGIC_VECTOR(3 downto 0);
	signal async_trn_done				: STD_LOGIC;
	signal async_wr_be					: STD_LOGIC_VECTOR(1 downto 0);
	signal async_rec_valid				: STD_LOGIC;

	signal async_slv_buffer					: STD_LOGIC_VECTOR(95 downto 0);
	signal async_slv_trn_byte_count			: STD_LOGIC_VECTOR(3 downto 0);
	signal async_slv_trn_valid_byte_count	: STD_LOGIC_VECTOR(3 downto 0);
	signal async_slv_rec_byte_count			: STD_LOGIC_VECTOR(3 downto 0);
	signal async_slv_rec_valid_byte_count	: STD_LOGIC_VECTOR(3 downto 0);
	signal async_slv_trn_target				: STD_LOGIC_VECTOR(3 downto 0);
	signal async_slv_rec_target				: STD_LOGIC_VECTOR(3 downto 0);
	signal async_slv_trn_done				: STD_LOGIC;
	signal async_slv_wr_be					: STD_LOGIC_VECTOR(1 downto 0);
	signal async_slv_valid					: STD_LOGIC;
	signal async_slv_broadcast				: STD_LOGIC;


	signal read_done					: STD_LOGIC;
	signal read_progress				: STD_LOGIC_VECTOR(1 downto 0);
	signal write_done					: STD_LOGIC;
	signal write_progress				: STD_LOGIC_VECTOR(1 downto 0);
	signal slv_progress					: STD_LOGIC_VECTOR(1 downto 0);
	
	signal rw_arbiter					: STD_LOGIC;

	signal reset_counter_int			: STD_LOGIC_VECTOR(31 downto 0) := "00000000000000000000000000000000";
	signal packet_counter_int			: STD_LOGIC_VECTOR(31 downto 0) := "00000000000000000000000000000000";
	signal error_counter_int			: STD_LOGIC_VECTOR(31 downto 0) := "00000000000000000000000000000000";

	signal reset_counted				: STD_LOGIC := '0';

	component data_reg is
	Port (	clka				: in	STD_LOGIC;
			dina				: in	STD_LOGIC_VECTOR(7 downto 0);
			addra				: in	STD_LOGIC_VECTOR(12 downto 0);
			wea					: in	STD_LOGIC_VECTOR(0 downto 0);
			douta				: out	STD_LOGIC_VECTOR(7 downto 0);
			clkb				: in	STD_LOGIC;
			dinb				: in	STD_LOGIC_VECTOR(31 downto 0);
			addrb				: in	STD_LOGIC_VECTOR(10 downto 0);
			web					: in	STD_LOGIC_VECTOR(0 downto 0);
			doutb				: out	STD_LOGIC_VECTOR(31 downto 0));
	end component;

	component async_fifo is
	Port (	rst					: in	STD_LOGIC;
			wr_clk				: in	STD_LOGIC;
			rd_clk				: in	STD_LOGIC;
			din					: in	STD_LOGIC_VECTOR(37 downto 0);
			wr_en				: in	STD_LOGIC;
			rd_en				: in	STD_LOGIC;
			dout				: out	STD_LOGIC_VECTOR(37 downto 0);
			full				: out	STD_LOGIC;
			empty				: out	STD_LOGIC;
			valid				: out	STD_LOGIC);
	end component;

begin

	data_reg_inst : data_reg
	Port map ( 	clka => data_reg_internal_clk,
				dina => data_reg_internal_data_in,
				addra => data_reg_internal_addr,
				wea => data_reg_internal_we,
				douta => data_reg_internal_data_out,
				clkb => data_reg_clk,
				dinb => data_reg_data_in,
				addrb => data_reg_addr_user,
				web => data_reg_we,
				doutb => data_reg_data_out);
	
	async_enabled:
	if(disable_async = '0') generate
		in_fifo : async_fifo
		Port map (	rst => reset,
					wr_clk => async_in_clk,
					rd_clk => clk_50M,
					din => async_in_data,
					wr_en => async_in_wr_en,
					rd_en => async_rd_en,
					dout => async_rd_data,
					full => async_in_full,
					empty => async_empty,
					valid => async_valid);

		out_fifo : async_fifo
		Port map (	rst => reset,
					wr_clk => clk_50M,
					rd_clk => async_out_clk,
					din => async_wr_data,
					wr_en => async_wr_en,
					rd_en => async_out_rd_en,
					dout => async_out_data,
					full => async_full,
					empty => async_out_empty,
					valid => async_out_valid);
	end generate;

	async_disabled:
	if(disable_async = '1') generate
		async_rd_data <= (others => '0');
		async_in_full <= '1';
		async_empty <= '1';
		async_valid <= '0';
		async_out_data <= (others => '0');
		async_full <= '1';
		async_out_empty <= '1';
		async_out_valid <= '0';
	end generate;
	
	data_reg_addr_user <=	current_user_reg_write & data_reg_addr when 	--Create the address for the data register depending on the current buffer selection...
									(((data_reg_addr(9 downto 6) = node_id) and data_reg_addr(2) = '0') or
									(not(data_reg_addr(9 downto 6) = node_id) and data_reg_addr(2) = '1')) else
									current_user_reg_read & data_reg_addr;

	slave_reset <= (reset or is_master) or disable_slave;		--The disable switches work by simply making sure that the slave- or master-reset is '1' always
	master_reset <= (reset or not is_master) or disable_master;	--XST will thus be able to optimize most of the slave- or master-functionality away...:)

	error_counter <= error_counter_int;
	packet_counter <= packet_counter_int;
	reset_counter <= reset_counter_int;

	skip_count_write <= skip_counter_write;
	skip_count_read <= skip_counter_read;
	current_buffer_index <= current_user_reg_write & current_user_reg_read & current_sys_reg_write & current_sys_reg_read;

	force_packet_error <= (packet_error and not is_master) and not reset;	--If we are forwarding a packet (slave only), and the current packet has an error, make sure that the packet is poisoned...

	process(clk_50M)
	begin
		if(clk_50M = '1' and clk_50M'EVENT) then
			if(reset = '1') then
				write_commited <= '0';
				read_commited <= '0';
				skip_counter_write <= "0000000000000000";
				skip_counter_read <= "0000000000000000";
				system_halt <= '0';
				sync_ok <= '1';		--Make sure that the system starts automagically when it exits reset
				pause_ack <= '0';
				if(reset_counted = '0') then
					reset_counter_int <= reset_counter_int + 1;
					reset_counted <= '1';
				end if;
			else
				reset_counted <= '0';
			end if;
			
			if(data_reg_commit_write = '1' and last_commit_write = '0') then
				write_commited <= '1';
			end if;

			if(data_reg_commit_read = '1' and last_commit_read = '0') then
				read_commited <= '1';
			end if;

			if((sync_strobe = '1') and (last_sync_strobe = '0')) then
				if(write_commited = '1' and packet_error = '0') then		--Handle the doublebuffering for the write buffers
					if(current_user_reg_write = '1') then
						current_user_reg_write <= '0';
					else
						current_user_reg_write <= '1';
					end if;
					if(current_sys_reg_write = '1') then
						current_sys_reg_write <= '0';
					else
						current_sys_reg_write <= '1';
					end if;
					write_commited <= '0';
					skip_counter_write <= "0000000000000000";
				else
					skip_counter_write <= skip_counter_write + 1;
				end if;

				if(read_commited = '1' and packet_error = '0') then		--Handle the doublebuffering for the read buffers
					if(current_user_reg_read = '1') then
						current_user_reg_read <= '0';
					else
						current_user_reg_read <= '1';
					end if;
					if(current_sys_reg_read = '1') then
						current_sys_reg_read <= '0';
					else
						current_sys_reg_read <= '1';
					end if;
					read_commited <= '0';
					skip_counter_read <= "0000000000000000";
				else
					skip_counter_read <= skip_counter_read + 1;
				end if;
				
				sync_ok <= '1';
				
				packet_counter_int <= packet_counter_int + 1;
				
				if(packet_error = '1') then
					error_counter_int <= error_counter_int + 1;
				end if;

				if(pause = '1' and is_master = '1') then				--Handle pause functionality
					pause_ack <= '1';
				else
					pause_ack <= '0';
				end if;
			end if;
			
			if(((skip_counter_write > max_skipped_writes) and not(max_skipped_writes = 0)) or 	--The system only uses the skip counters if they're different from 0. If 0, an unlimited number of skips are allowed...
			   ((skip_counter_read > max_skipped_reads) and not (max_skipped_reads = 0))) then
				system_halt <= '1';
			end if;
			
			async_wr_en <= '0';
------------------------------------------------------------------------
-- Slave synchronous part
------------------------------------------------------------------------
			if(slave_reset = '1') then
				slv_state <= IDLE;
				slv_current_node <= "0000";
				slv_current_rw <= '0';
				slv_current_var <= "0000";
				async_slv_buffer <= (others => '0');
				async_slv_trn_byte_count <= (others => '0');
				async_slv_trn_valid_byte_count <= (others => '0');
				async_slv_rec_byte_count <= (others => '0');
				async_slv_rec_valid_byte_count <= (others => '0');
				async_slv_trn_target <= (others => '0');
				async_slv_rec_target <= (others => '0');
				async_slv_trn_done <= '0';
				async_slv_wr_be <= (others => '0');
				async_slv_valid <= '0';
				async_slv_broadcast <= '0';
				slv_progress <= "00";
			else
				slv_state <= next_slv_state;
			
				case slv_state is
					when IDLE =>
						slv_current_node <= "0000";
						slv_current_rw <= '0';
						slv_current_var <= "0000";
						data_out_strobe <= '0';
						data_out_enable <= '0';
						async_slv_buffer <= (others => '0');
						async_slv_trn_byte_count <= (others => '0');
						async_slv_trn_valid_byte_count <= (others => '0');
						async_slv_rec_byte_count <= (others => '0');
						async_slv_rec_valid_byte_count <= (others => '0');
						async_slv_trn_target <= (others => '0');
						async_slv_rec_target <= (others => '0');
						async_slv_trn_done <= '0';
						async_slv_wr_be <= (others => '0');
						async_slv_valid <= '0';
						async_slv_broadcast <= '0';
						slv_progress <= "00";
					when ADDR_1 =>										--Retreive network register entry for node
						network_reg_addr <= slv_current_node;
						network_reg_clk <= '0';
						sync_ok <= '0';
					when ADDR_2 =>
						network_reg_clk <= '1';
					when ADDR_3 =>
						network_reg_clk <= '0';
						slv_current_node_address <= network_reg_data(7 downto 4);
						slv_current_node_id <= network_reg_data(3 downto 0);
						slv_current_node_read_reg_enable <= network_reg_data(15 downto 8);
						slv_current_node_write_reg_enable <= network_reg_data(23 downto 16);
						slv_current_rw <= '0';
						slv_current_var <= "0000";
					when DATA =>										--Receive, store, and forward packet
						data_out_enable <= '1';
						
						if(slv_current_reg_ok = '0') then		--No more registers for this part
							if(slv_current_rw = '0') then			--If read registers are currently selected,
								slv_current_rw <= '1';				--then switch to write
							else											--else the node is done,
								slv_current_rw <= '0';
								slv_current_node <= slv_current_node + 1;	--so go to the next node...
								slv_current_var <= "0000";
							end if;
						else
							if(data_in_strobe = '1' and last_data_in_strobe = '0') then
								if(slv_current_node = node_address) then
									if(slv_current_rw = '1') then			--Ignore the Read registers from this node, we're only interested in the write registers...
										data_reg_internal_addr <= current_sys_reg_read & slv_current_node_id & slv_current_reg & '1' & slv_current_var;
										data_reg_internal_data_in <= data_in;
										data_reg_internal_we <= "1";
										data_reg_internal_clk <= '0';
										data_out <= data_reg_internal_data_out;
										data_out_strobe <= '1';
									else
										data_out <= data_in;
										data_out_strobe <= '1';
									end if;
								else
									data_reg_internal_addr <= current_sys_reg_read & slv_current_node_id & slv_current_reg & slv_current_rw & slv_current_var;
									data_reg_internal_data_in <= data_in;
									data_reg_internal_we <= "1";
									data_reg_internal_clk <= '0';
									data_out <= data_in;
									data_out_strobe <= '1';
								end if;
							elsif(data_in_strobe = '0' and last_data_in_strobe = '1') then
								if(not((slv_current_node = node_address) and (slv_current_rw = '0'))) then
									data_reg_internal_clk <= '1';
								end if;
	
								data_out_strobe <= '0';
		
								if(slv_current_var = "1111") then							--All vars for this register read, set the reg_enable bit for this register to 0 to go to the next register
									if(slv_current_rw = '0') then
										slv_current_node_read_reg_enable(conv_integer(slv_current_reg)) <= '0';
									else
										slv_current_node_write_reg_enable(conv_integer(slv_current_reg)) <= '0';
									end if;
								end if;
	
								slv_current_var <= slv_current_var + 1;
	
							elsif((data_reg_internal_clk = '1') and (data_reg_internal_we = "1") and (data_in_strobe = '0')) then
								data_reg_internal_clk <= '0';
								data_reg_internal_addr <= current_sys_reg_write & slv_current_node_id & slv_current_reg & '0' & slv_current_var;
								data_reg_internal_we <= "0";
							elsif((data_reg_internal_clk = '0') and (data_reg_internal_we = "0") and (data_in_strobe = '0')) then
								data_reg_internal_clk <= '1';
							else
								data_reg_internal_clk <= '0';
								data_reg_internal_we <= "1";
							end if;
						end if;
					when ASYNC_CTL_HEAD =>
						if(data_in_strobe = '1' and last_data_in_strobe = '0') then
							if(data_in = ASYNC_M2S_VALID & NODE_ID) then		--Data for this node only received
								async_slv_valid <= '1';
								if(async_valid = '1') then
									data_out <= ASYNC_S2M_VALID & NODE_ID;
								else
									data_out <= ASYNC_S2M_INVALID & NODE_ID;
								end if;
							elsif(data_in = ASYNC_M2S_VALID & "0000") then 		--Broadcast received
								data_out <= data_in;
								async_slv_valid <= '1';
								async_trn_done <= '1';
								async_slv_broadcast <= '1';
							else												--Nothing of interest for this node
								async_slv_valid <= '0';
								data_out <= data_in;
							end if;

							data_out_strobe <= '1';
						end if;
					when ASYNC =>
						data_out_strobe <= '0';
						if(data_in_strobe = '1' and last_data_in_strobe = '0') then
							if(async_slv_valid = '0') then
								data_out <= data_in;
								data_out_strobe <= '1';
							else
								async_slv_buffer <= async_slv_buffer(87 downto 0) & data_in;
								async_slv_rec_byte_count <= async_slv_rec_byte_count + 1;
								
								if(async_valid = '1') then
									if(async_slv_trn_byte_count = 0) then
										async_slv_trn_target <= async_rd_data(35 downto 32);
									end if;
								else
									async_slv_trn_done <= '1';
								end if;
								slv_progress <= "01";
							end if;
						elsif(slv_progress = "01") then			--We'll only increase slv_progress if async_slv_valid is true, thus no need for a (redundant) check for validity here...
							if(async_slv_trn_done = '0' and async_slv_trn_target = async_rd_data(35 downto 32)) then
								case async_slv_trn_byte_count(1 downto 0) is
									when "00" =>
										data_out <= async_rd_data(31 downto 24);
										if(async_rd_data(37 downto 36) = "00") then
											async_slv_trn_done <= '1';
										end if;
									when "01" =>
										data_out <= async_rd_data(23 downto 16);
										if(async_rd_data(37 downto 36) = "01") then
											async_slv_trn_done <= '1';
										end if;
									when "10" =>
										data_out <= async_rd_data(15 downto 8);
										if(async_rd_data(37 downto 36) = "10") then
											async_slv_trn_done <= '1';
										end if;
									when "11" =>
										data_out <= async_rd_data(7 downto 0);
									when others =>
								end case;
								async_slv_trn_valid_byte_count <= async_slv_trn_valid_byte_count + 1;
							else
								data_out <= data_in;
								async_slv_trn_done <= '1';
							end if;
							data_out_strobe <= '1';
							async_slv_trn_byte_count <= async_slv_trn_byte_count + 1;
							slv_progress <= "10";
						elsif(slv_progress = "10") then
							slv_progress <= "00";
						end if;
					when ASYNC_CTL_TAIL =>
						data_out_strobe <= '0';
						if(data_in_strobe = '1' and last_data_in_strobe = '0' and slv_progress = "00") then
							if(async_slv_broadcast = '1') then
								data_out <= data_in;
							else
								data_out <= async_slv_trn_valid_byte_count & NODE_ID;
							end if;
							data_out_strobe <= '1';
							async_slv_rec_valid_byte_count <= data_in(7 downto 4) - 4;
							async_slv_rec_target <= data_in(3 downto 0);
							slv_progress <= "01";
							if(data_in(7 downto 4) > 3) then
								async_slv_wr_be <= "11";
							else
								async_slv_wr_be <= data_in(5 downto 4) - 1;
							end if;
						elsif(slv_progress = "01") then
							data_out_strobe <= '0';
							if((async_slv_rec_valid_byte_count > 8) and (async_slv_rec_valid_byte_count < 13)) then
								slv_progress <= "11";			--Done
							else
								slv_progress <= "10";			--Delay one clock (we've got lots), to make sure we jump out if no data has been received (8 < async_rec_valid_byte_count < 13)
							end if;
							async_wr_en <= '0';
						elsif(slv_progress = "10") then
							async_wr_data <= async_slv_wr_be & async_slv_rec_target & async_slv_buffer(95 downto 64);
							async_wr_en <= '1';
							async_slv_buffer(95 downto 32) <= async_slv_buffer(63 downto 0);
							async_slv_rec_valid_byte_count <= async_slv_rec_valid_byte_count - 4;
							if(async_slv_rec_valid_byte_count > 3) then
								async_slv_wr_be <= "11";
							else
								async_slv_wr_be <= async_slv_rec_valid_byte_count(1 downto 0) - 1;
							end if;
							slv_progress <= "01";
						end if;
				end case;
			end if;
			
------------------------------------------------------------------------
-- Master TRN synchronous part
------------------------------------------------------------------------
			if(master_reset = '1') then
				mst_trn_state <= IDLE;
				mst_trn_current_node <= "0000";
				mst_trn_current_rw <= '0';
				mst_trn_current_var <= "0000";
				read_progress <= "00";
				read_done <= '1';
				async_trn_byte_count <= (others => '0');
				async_trn_valid_byte_count <= (others => '0');
				async_trn_done <= '0';
				async_trn_target <= (others => '0');
			else
				mst_trn_state <= next_mst_trn_state;
			
				case mst_trn_state is
					when IDLE =>
						mst_trn_current_node <= "0000";
						mst_trn_current_rw <= '0';
						mst_trn_current_var <= "0000";
						data_out_strobe <= '0';
						data_out_enable <= '0';
						read_progress <= "00";
						read_done <= '1';
						async_trn_byte_count <= (others => '0');
						async_trn_valid_byte_count <= (others => '0');
						async_trn_done <= '0';
						async_trn_target <= (others => '0');
					when ADDR_1 =>										--Retreive network register entry for node
						network_reg_addr <= mst_trn_current_node;
						network_reg_clk <= '0';
						sync_ok <= '0';
						pause_ack <= '0';
					when ADDR_2 =>
						network_reg_clk <= '1';
					when ADDR_3 =>
						network_reg_clk <= '0';
						mst_trn_current_node_address <= network_reg_data(7 downto 4);
						mst_trn_current_node_id <= network_reg_data(3 downto 0);
						mst_trn_current_node_read_reg_enable <= network_reg_data(15 downto 8);
						mst_trn_current_node_write_reg_enable <= network_reg_data(23 downto 16);
						mst_trn_current_rw <= '0';
						mst_trn_current_var <= "0000";
					when DATA =>										--Receive, store, and forward packet
						data_out_enable <= '1';
						
						if(mst_trn_current_reg_ok = '0') then		--No more registers for this part
							if(mst_trn_current_rw = '0') then		--If read registers are currently selected,
								mst_trn_current_rw <= '1';				--then switch to write
							else												--else the node is done,
								mst_trn_current_rw <= '0';
								mst_trn_current_node <= mst_trn_current_node + 1;	--so go to the next node...
								mst_trn_current_var <= "0000";
							end if;
						else
							if(read_progress = "00" and write_done = '1' and buffer_full = '0' and rw_arbiter = '0') then
								if(mst_trn_current_rw = '0' and not(mst_trn_current_node = node_address)) then
									data_reg_internal_addr <= current_sys_reg_read & mst_trn_current_node_id & mst_trn_current_reg & mst_trn_current_rw & mst_trn_current_var;
								else
									data_reg_internal_addr <= current_sys_reg_write & mst_trn_current_node_id & mst_trn_current_reg & mst_trn_current_rw & mst_trn_current_var;
								end if;
								data_reg_internal_we <= "0";
								data_reg_internal_clk <= '0';
								read_progress <= "01";
								read_done <= '0';
							elsif(read_progress = "01") then
								data_reg_internal_clk <= '1';
								read_progress <= "10";
							elsif(read_progress = "10") then
								data_reg_internal_clk <= '0';
								data_out <= data_reg_internal_data_out;
								data_out_strobe <= '1';
								read_progress <= "11";
								read_done <= '1';
							elsif(read_progress = "11") then
								data_out_strobe <= '0';
								read_progress <= "00";

								if(mst_trn_current_var = "1111") then							--All vars for this register read, set the reg_enable bit for this register to 0 to go to the next register
									if(mst_trn_current_rw = '0') then
										mst_trn_current_node_read_reg_enable(conv_integer(mst_trn_current_reg)) <= '0';
									else
										mst_trn_current_node_write_reg_enable(conv_integer(mst_trn_current_reg)) <= '0';
									end if;
								end if;
	
								mst_trn_current_var <= mst_trn_current_var + 1;
							end if;
						end if;
					when ASYNC_CTL_HEAD =>
						if(buffer_full = '0' and read_progress <= "00") then
							if(async_valid = '1') then
								async_trn_target <= async_rd_data(35 downto 32);
								data_out <= ASYNC_M2S_VALID & async_rd_data(35 downto 32);
							else
								data_out <= ASYNC_M2S_INVALID & "0000";
								async_trn_done <= '1';
							end if;
							data_out_strobe <= '1';
							read_progress <= "01";
						else
							data_out_strobe <= '0';
						end if;
					when ASYNC =>
						data_out_strobe <= '0';
						if(read_progress = "00") then
							read_progress <= "01";
						elsif(read_progress = "01" and buffer_full = '0') then
							if(async_valid = '0') then
								async_trn_done <= '1';
							end if;
							read_progress <= "10";
						elsif(read_progress = "10") then
							if(async_trn_done = '0' and async_trn_target = async_rd_data(35 downto 32)) then
								case async_trn_byte_count(1 downto 0) is
									when "00" =>
										data_out <= async_rd_data(31 downto 24);
										if(async_rd_data(37 downto 36) = "00") then
											async_trn_done <= '1';
										end if;
									when "01" =>
										data_out <= async_rd_data(23 downto 16);
										if(async_rd_data(37 downto 36) = "01") then
											async_trn_done <= '1';
										end if;
									when "10" =>
										data_out <= async_rd_data(15 downto 8);
										if(async_rd_data(37 downto 36) = "10") then
											async_trn_done <= '1';
										end if;
									when "11" =>
										data_out <= async_rd_data(7 downto 0);
									when others =>
								end case;
								async_trn_valid_byte_count <= async_trn_valid_byte_count + 1;
							else
								data_out <= (others => '0');
								async_trn_done <= '1';
							end if;
							data_out_strobe <= '1';
							async_trn_byte_count <= async_trn_byte_count + 1;
							read_progress <= "11";
						elsif(read_progress = "11") then
							data_out_strobe <= '0';
							read_progress <= "00";
						end if;
					when ASYNC_CTL_TAIL =>
						if(read_progress = "00" and buffer_full = '0') then
							data_out <= async_trn_valid_byte_count & async_trn_target;
							data_out_strobe <= '1';
							read_progress <= "01";
						elsif(read_progress = "01") then
							data_out_strobe <= '0';
							read_progress <= "00";
						end if;
					when WAIT_STATE =>
						--Just do nothing...
				end case;
			end if;

------------------------------------------------------------------------
-- Master REC synchronous part
------------------------------------------------------------------------
			if(master_reset = '1') then
				mst_rec_state <= IDLE;
				mst_rec_current_node <= "0000";
				mst_rec_current_rw <= '0';
				mst_rec_current_var <= "0000";
				write_progress <= "00";
				write_done <= '1';
				async_rec_byte_count <= (others => '0');
				async_rec_valid_byte_count <= (others => '0');
				async_rec_target <= (others => '0');
				async_wr_be <= "00";
				async_rec_valid <= '0';
			else
				mst_rec_state <= next_mst_rec_state;
			
				case mst_rec_state is
					when IDLE =>
						mst_rec_current_node <= "0000";
						mst_rec_current_rw <= '0';
						mst_rec_current_var <= "0000";
						write_progress <= "00";
						write_done <= '1';
						async_rec_byte_count <= (others => '0');
						async_rec_valid_byte_count <= (others => '0');
						async_rec_target <= (others => '0');
						async_wr_be <= "00";
						async_rec_valid <= '0';
					when ADDR_1 =>										--Retreive network register entry for node
						network_reg_addr <= mst_rec_current_node;
						network_reg_clk <= '0';
						sync_ok <= '0';
					when ADDR_2 =>
						network_reg_clk <= '1';
					when ADDR_3 =>
						network_reg_clk <= '0';
						mst_rec_current_node_address <= network_reg_data(7 downto 4);
						mst_rec_current_node_id <= network_reg_data(3 downto 0);
						mst_rec_current_node_read_reg_enable <= network_reg_data(15 downto 8);
						mst_rec_current_node_write_reg_enable <= network_reg_data(23 downto 16);
						mst_rec_current_rw <= '0';
						mst_rec_current_var <= "0000";
					when DATA =>										--Receive, store, and forward packet
						if(mst_rec_current_reg_ok = '0') then		--No more registers for this part
							if(waiting_for_trn = '0') then			
								if(mst_rec_current_rw = '0') then	--If read registers are currently selected,
									mst_rec_current_rw <= '1';			--then switch to write
								else											--else the node is done,
									mst_rec_current_rw <= '0';
									mst_rec_current_node <= mst_rec_current_node + 1;	--so go to the next node...
									mst_rec_current_var <= "0000";
								end if;
							end if;
						else
							if(data_in_strobe = '1' and last_data_in_strobe = '0') then
								if((mst_rec_current_rw = '1') and not(mst_rec_current_node = node_address)) then			--Ignore the Read registers for the nodes, we're only interested in the write registers, which hold the newest data...
									data_in_buffer <= data_in;
									write_progress <= "01";
								end if;
							elsif(data_in_strobe = '0' and last_data_in_strobe = '1') then
								if(mst_rec_current_var = "1111") then							--All vars for this register read, set the reg_enable bit for this register to 0 to go to the next register
									if(mst_rec_current_rw = '0') then
										mst_rec_current_node_read_reg_enable(conv_integer(mst_rec_current_reg)) <= '0';
									else
										mst_rec_current_node_write_reg_enable(conv_integer(mst_rec_current_reg)) <= '0';
									end if;
								end if;
								mst_rec_current_var <= mst_rec_current_var + 1;
							elsif(write_progress = "01" and write_done = '1' and read_done = '1' and rw_arbiter = '1') then
								data_reg_internal_addr <= current_sys_reg_read & mst_rec_current_node_id & mst_rec_current_reg & '0' & mst_rec_current_var;
								data_reg_internal_data_in <= data_in_buffer;
								data_reg_internal_we <= "1";
								data_reg_internal_clk <= '0';
								write_done <= '0';
								write_progress <= "10";
							elsif(write_progress = "10" and write_done = '0') then
								data_reg_internal_clk <= '1';
								write_progress <= "11";
							elsif(write_progress = "11" and write_done = '0') then
								data_reg_internal_clk <= '0';
								data_reg_internal_we <= "0";
								write_done <= '1';
								write_progress <= "00";
							end if;
						end if;
					when ASYNC_CTL_HEAD =>
						if(data_in_strobe = '1' and last_data_in_strobe = '0') then
							if(data_in(7 downto 4) = ASYNC_S2M_VALID) then
								async_rec_valid <= '1';
							else
								async_rec_valid <= '0';
							end if;
						end if;
					when ASYNC =>
						if(data_in_strobe = '1' and last_data_in_strobe = '0') then
							async_buffer <= async_buffer(87 downto 0) & data_in;
							async_rec_byte_count <= async_rec_byte_count + 1;
						end if;
					when ASYNC_CTL_TAIL =>
						if(data_in_strobe = '1' and last_data_in_strobe = '0' and write_progress = "00") then
							async_rec_valid_byte_count <= data_in(7 downto 4) - 4;
							async_rec_target <= data_in(3 downto 0);
							write_progress <= "01";
							if(data_in(7 downto 4) > 3) then
								async_wr_be <= "11";
							else
								async_wr_be <= data_in(5 downto 4) - 1;
							end if;
						elsif(write_progress = "01") then
							write_progress <= "10";			--Delay one clock (we've got lots), to make sure we jump out if no data has been received (async_rec_valid_byte_count > 8)
							async_wr_en <= '0';
						elsif(write_progress = "10") then
							async_wr_data <= async_wr_be & async_rec_target & async_buffer(95 downto 64);
							async_wr_en <= '1';
							async_buffer(95 downto 32) <= async_buffer(63 downto 0);
							async_rec_valid_byte_count <= async_rec_valid_byte_count - 4;
							if(async_rec_valid_byte_count > 3) then
								async_wr_be <= "11";
							else
								async_wr_be <= async_rec_valid_byte_count(1 downto 0) - 1;
							end if;
							write_progress <= "01";
						end if;
				end case;
			end if;

------------------------------------------------------------------------
			
			last_data_in_strobe <= data_in_strobe;
			last_sync_strobe <= sync_strobe;
			last_commit_write <= data_reg_commit_write;
			last_commit_read <= data_reg_commit_read;
			
			if(rw_arbiter = '0') then
				rw_arbiter <= '1';
			else
				rw_arbiter <= '0';
			end if;
			
		end if;
	end process;
	

------------------------------------------------------------------------
-- Slave combinatorial next-state logic
------------------------------------------------------------------------
	process(slv_state, data_in_enable, slv_current_reg_ok, slv_current_rw, slv_current_node, network_reg_data(7 downto 4), slv_progress, async_slv_trn_byte_count, async_slv_rec_valid_byte_count, data_in_strobe, last_data_in_strobe)
	begin
		case slv_state is
			when IDLE =>
				if(data_in_enable = '1') then
					next_slv_state <= ADDR_1;
				else
					next_slv_state <= IDLE;
				end if;
			when ADDR_1 =>
				next_slv_state <= ADDR_2;
			when ADDR_2 =>
				next_slv_state <= ADDR_3;
			when ADDR_3 =>
				if(slv_current_node = network_reg_data(7 downto 4)) then
					next_slv_state <= DATA;
				else
					next_slv_state <= ASYNC_CTL_HEAD;
				end if;
			when DATA =>
				if(data_in_enable = '0') then
					next_slv_state <= IDLE;
				elsif(slv_current_reg_ok = '0' and slv_current_rw = '1') then
					next_slv_state <= ADDR_1;
				else
					next_slv_state <= DATA;
				end if;
			when ASYNC_CTL_HEAD =>
				if(data_in_strobe = '1' and last_data_in_strobe = '0') then
					next_slv_state <= ASYNC;
				else
					next_slv_state <= ASYNC_CTL_HEAD;
				end if;
			when ASYNC =>
				if(data_in_enable = '0') then
					next_slv_state <= IDLE;
				elsif(slv_progress = "00" and async_slv_trn_byte_count = 12) then
					next_slv_state <= ASYNC_CTL_TAIL;
				else
					next_slv_state <= ASYNC;
				end if;
			when ASYNC_CTL_TAIL =>
				if(data_in_enable = '0') then
					next_slv_state <= IDLE;
				else
					next_slv_state <= ASYNC_CTL_TAIL;
				end if;
		end case;
	end process;
	

------------------------------------------------------------------------
-- Master TRN combinatorial next-state logic
------------------------------------------------------------------------
	process(mst_trn_state, mst_rec_state, sync_ok, data_in_enable, mst_trn_current_reg_ok, mst_trn_current_rw, mst_trn_current_node, network_reg_data(7 downto 4), pause, read_progress, async_trn_byte_count)
	begin
		case mst_trn_state is
			when IDLE =>
				if(mst_rec_state = IDLE and sync_ok = '1' and pause = '0') then				--Make sure that we're done receiving and sync'ing before sending out the next packet (for synchronization, buffering and a couple of other reasons...)
					next_mst_trn_state <= WAIT_STATE;
				else
					next_mst_trn_state <= IDLE;
				end if;
			when ADDR_1 =>
				next_mst_trn_state <= ADDR_2;
			when ADDR_2 =>
				next_mst_trn_state <= ADDR_3;
			when ADDR_3 =>
				if(mst_trn_current_node = network_reg_data(7 downto 4)) then
					next_mst_trn_state <= DATA;
				else
					next_mst_trn_state <= ASYNC_CTL_HEAD;
				end if;
			when DATA =>
				if(mst_trn_current_reg_ok = '0' and mst_trn_current_rw = '1') then
					next_mst_trn_state <= WAIT_STATE;
				else
					next_mst_trn_state <= DATA;
				end if;
			when ASYNC_CTL_HEAD =>
				if(read_progress = "01") then
					next_mst_trn_state <= ASYNC;
				else
					next_mst_trn_state <= ASYNC_CTL_HEAD;
				end if;
			when ASYNC =>
				if(read_progress = "11" and async_trn_byte_count = 12) then
					next_mst_trn_state <= ASYNC_CTL_TAIL;
				else
					next_mst_trn_state <= ASYNC;
				end if;
			when ASYNC_CTL_TAIL =>
				if(read_progress = "01") then
					next_mst_trn_state <= IDLE;
				else
					next_mst_trn_state <= ASYNC_CTL_TAIL;
				end if;				
			when WAIT_STATE =>
				if(mst_rec_state = DATA or mst_rec_state = IDLE) then
					next_mst_trn_state <= ADDR_1;
				else
					next_mst_trn_state <= WAIT_STATE;
				end if;
		end case;
	end process;
	
	
------------------------------------------------------------------------
-- Master REC combinatorial next-state logic
------------------------------------------------------------------------
	process(mst_rec_state, mst_trn_state, data_in_enable, mst_rec_current_reg_ok, mst_rec_current_rw, mst_rec_current_node, network_reg_data(7 downto 4), async_rec_byte_count, async_rec_valid_byte_count, async_rec_valid, data_in_strobe, last_data_in_strobe)
	begin
		waiting_for_trn <= '0';
		
		case mst_rec_state is
			when IDLE =>
				if(data_in_enable = '1' and (mst_trn_state = DATA or mst_trn_state = IDLE or mst_trn_state = ASYNC_CTL_HEAD or mst_trn_state = ASYNC or mst_trn_state = ASYNC_CTL_TAIL)) then
					next_mst_rec_state <= ADDR_1;
				else
					next_mst_rec_state <= IDLE;
				end if;
			when ADDR_1 =>
				next_mst_rec_state <= ADDR_2;
			when ADDR_2 =>
				next_mst_rec_state <= ADDR_3;
			when ADDR_3 =>
				if(mst_rec_current_node = network_reg_data(7 downto 4)) then
					next_mst_rec_state <= DATA;
				else
					next_mst_rec_state <= ASYNC_CTL_HEAD;
				end if;
			when DATA =>
				if(data_in_enable = '0') then
					next_mst_rec_state <= IDLE;
				elsif(mst_rec_current_reg_ok = '0' and mst_rec_current_rw = '1' and (mst_trn_state = DATA or mst_trn_state = IDLE or mst_trn_state = ASYNC_CTL_HEAD or mst_trn_state = ASYNC or mst_trn_state = ASYNC_CTL_TAIL)) then
					next_mst_rec_state <= ADDR_1;
				elsif(mst_rec_current_reg_ok = '0' and mst_rec_current_rw = '1') then
					waiting_for_trn <= '1';
					next_mst_rec_state <= DATA;
				else
					next_mst_rec_state <= DATA;
				end if;
			when ASYNC_CTL_HEAD =>
				if(data_in_strobe = '1' and last_data_in_strobe = '0') then
					next_mst_rec_state <= ASYNC;
				else
					next_mst_rec_state <= ASYNC_CTL_HEAD;
				end if;
			when ASYNC =>
				if(async_rec_byte_count = 12) then
					next_mst_rec_state <= ASYNC_CTL_TAIL;
				else
					next_mst_rec_state <= ASYNC;
				end if;
			when ASYNC_CTL_TAIL =>
				if(((async_rec_valid_byte_count > 8) and (async_rec_valid_byte_count < 13)) or async_rec_valid <= '0') then
					next_mst_rec_state <= IDLE;
				else
					next_mst_rec_state <= ASYNC_CTL_TAIL;
				end if;
		end case;
	end process;
	
	
------------------------------------------------------------------------
-- Combinatorial logic for address generation
------------------------------------------------------------------------
	
	async_rd_en <= '1' when (((mst_trn_state = ASYNC) and (read_progress = "11") and (async_trn_done = '0') and (async_trn_byte_count(1 downto 0) = "00")) or
							 ((mst_trn_state = ASYNC_CTL_TAIL) and (read_progress = "01") and not (async_trn_valid_byte_count(1 downto 0) = "00")) or
							 ((slv_state = ASYNC) and (slv_progress = "10") and (async_slv_trn_done = '0') and (async_slv_trn_byte_count(1 downto 0) = "00")) or
							 ((slv_state = ASYNC_CTL_TAIL) and (data_in_strobe = '1') and (last_data_in_strobe = '0') and (slv_progress = "00") and not (async_slv_trn_valid_byte_count(1 downto 0) = "00"))) else '0';

	
	
	
	
	
	slv_current_reg <= "111" when (slv_current_node_read_reg_enable(7) = '1' and slv_current_rw = '0') or 
											(slv_current_node_write_reg_enable(7) = '1' and slv_current_rw = '1') else
							"110" when 	(slv_current_node_read_reg_enable(6) = '1' and slv_current_rw = '0') or
											(slv_current_node_write_reg_enable(6) = '1' and slv_current_rw = '1') else
							"101" when 	(slv_current_node_read_reg_enable(5) = '1' and slv_current_rw = '0') or
											(slv_current_node_write_reg_enable(5) = '1' and slv_current_rw = '1') else
							"100" when 	(slv_current_node_read_reg_enable(4) = '1' and slv_current_rw = '0') or
											(slv_current_node_write_reg_enable(4) = '1' and slv_current_rw = '1') else
							"011" when 	(slv_current_node_read_reg_enable(3) = '1' and slv_current_rw = '0') or
											(slv_current_node_write_reg_enable(3) = '1' and slv_current_rw = '1') else
							"010" when 	(slv_current_node_read_reg_enable(2) = '1' and slv_current_rw = '0') or
											(slv_current_node_write_reg_enable(2) = '1' and slv_current_rw = '1') else
							"001" when 	(slv_current_node_read_reg_enable(1) = '1' and slv_current_rw = '0') or
											(slv_current_node_write_reg_enable(1) = '1' and slv_current_rw = '1') else
							"000";
					
	slv_current_reg_ok <= '0' when slv_current_reg = "000" and not ((slv_current_node_read_reg_enable(0) = '1' and slv_current_rw = '0') or
																						(slv_current_node_write_reg_enable(0) = '1' and slv_current_rw = '1')) else
							'1';


	mst_trn_current_reg <= "111" when 	(mst_trn_current_node_read_reg_enable(7) = '1' and mst_trn_current_rw = '0') or 
													(mst_trn_current_node_write_reg_enable(7) = '1' and mst_trn_current_rw = '1') else
									"110" when 	(mst_trn_current_node_read_reg_enable(6) = '1' and mst_trn_current_rw = '0') or
													(mst_trn_current_node_write_reg_enable(6) = '1' and mst_trn_current_rw = '1') else
									"101" when 	(mst_trn_current_node_read_reg_enable(5) = '1' and mst_trn_current_rw = '0') or
													(mst_trn_current_node_write_reg_enable(5) = '1' and mst_trn_current_rw = '1') else
									"100" when 	(mst_trn_current_node_read_reg_enable(4) = '1' and mst_trn_current_rw = '0') or
													(mst_trn_current_node_write_reg_enable(4) = '1' and mst_trn_current_rw = '1') else
									"011" when 	(mst_trn_current_node_read_reg_enable(3) = '1' and mst_trn_current_rw = '0') or
													(mst_trn_current_node_write_reg_enable(3) = '1' and mst_trn_current_rw = '1') else
									"010" when 	(mst_trn_current_node_read_reg_enable(2) = '1' and mst_trn_current_rw = '0') or
													(mst_trn_current_node_write_reg_enable(2) = '1' and mst_trn_current_rw = '1') else
									"001" when 	(mst_trn_current_node_read_reg_enable(1) = '1' and mst_trn_current_rw = '0') or
													(mst_trn_current_node_write_reg_enable(1) = '1' and mst_trn_current_rw = '1') else
									"000";
					
	mst_trn_current_reg_ok <= '0' when mst_trn_current_reg = "000" and not ((mst_trn_current_node_read_reg_enable(0) = '1' and mst_trn_current_rw = '0') or
																									(mst_trn_current_node_write_reg_enable(0) = '1' and mst_trn_current_rw = '1')) else
							'1';


	mst_rec_current_reg <= "111" when 	(mst_rec_current_node_read_reg_enable(7) = '1' and mst_rec_current_rw = '0') or 
													(mst_rec_current_node_write_reg_enable(7) = '1' and mst_rec_current_rw = '1') else
									"110" when 	(mst_rec_current_node_read_reg_enable(6) = '1' and mst_rec_current_rw = '0') or
													(mst_rec_current_node_write_reg_enable(6) = '1' and mst_rec_current_rw = '1') else
									"101" when 	(mst_rec_current_node_read_reg_enable(5) = '1' and mst_rec_current_rw = '0') or
													(mst_rec_current_node_write_reg_enable(5) = '1' and mst_rec_current_rw = '1') else
									"100" when 	(mst_rec_current_node_read_reg_enable(4) = '1' and mst_rec_current_rw = '0') or
													(mst_rec_current_node_write_reg_enable(4) = '1' and mst_rec_current_rw = '1') else
									"011" when 	(mst_rec_current_node_read_reg_enable(3) = '1' and mst_rec_current_rw = '0') or
													(mst_rec_current_node_write_reg_enable(3) = '1' and mst_rec_current_rw = '1') else
									"010" when 	(mst_rec_current_node_read_reg_enable(2) = '1' and mst_rec_current_rw = '0') or
													(mst_rec_current_node_write_reg_enable(2) = '1' and mst_rec_current_rw = '1') else
									"001" when 	(mst_rec_current_node_read_reg_enable(1) = '1' and mst_rec_current_rw = '0') or
													(mst_rec_current_node_write_reg_enable(1) = '1' and mst_rec_current_rw = '1') else
									"000";
					
	mst_rec_current_reg_ok <= '0' when mst_rec_current_reg = "000" and not ((mst_rec_current_node_read_reg_enable(0) = '1' and mst_rec_current_rw = '0') or
																									(mst_rec_current_node_write_reg_enable(0) = '1' and mst_rec_current_rw = '1')) else
							'1';
							
end Behavioral;

