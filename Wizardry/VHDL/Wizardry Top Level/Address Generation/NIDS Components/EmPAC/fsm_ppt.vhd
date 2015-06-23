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
-- Module Name: fsm_ppt - Behavioral 
-- Project Name: Wizardry
-- Target Devices: Virtex 4 ML401
-- Description: Keeps track of which ports have been encountered and 
-- Revision: 1.0
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.port_block_constants.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fsm_ppt is
    Port ( clock : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  frame_counters : in frame_counters_type;
           fifo_empty : in  STD_LOGIC;
           lut_info : in  lut_check;
			  lut_ptr : in integer range 0 to MAX_NUM_PORTS_2_FIND-1;
           fifo_data_out : in  STD_LOGIC_VECTOR (16 downto 0);
           ack_i : in  STD_LOGIC;
           dat_i : in  STD_LOGIC_VECTOR (31 downto 0);
           dat_o : out  STD_LOGIC_VECTOR (31 downto 0);
           adr_o : out  STD_LOGIC_VECTOR (21 downto 0);
           cyc_o : out  STD_LOGIC;
           stb_o : out  STD_LOGIC;
           we_o : out  STD_LOGIC;
           fifo_pop : out  STD_LOGIC;
           load_lut : out  STD_LOGIC;
           enable_lut_search : out  STD_LOGIC);
end fsm_ppt;

architecture Behavioral of fsm_ppt is

type statetype is (reset_state,idle_0_0,idle_0,idle,lut_search,read_lut,read_ddr,
						 load_lut_value,write_1_to_ddr,pop_fifo,pop_fifo_wait,
						 increment_ddr_read_data,write_inc_data_2_ddr,store_lut_2_ddr,
						 store_lut_2_ddr_0,update_counters_2_ddr,update_counters_2_ddr_0,
						 inc_counter_ptr,completed_update,store_lut_delim,store_lut_delim_0,
						 inc_counter_ptr_wait,check_counter_ptr,write_1_to_ddr_0,read_ddr_0,
						 check_fifo,write_inc_data_2_ddr_0,store_lut_delim_wait,
						 register_ddr_address,register_ddr_address_2,update_counters_2_ddr_1);
						 
signal currentstate,nextstate : statetype;signal increment_rd_data : std_logic;
signal frame_counters_reg : frame_counters_array_type;
signal dat_i_reg : std_logic_Vector(31 downto 0);signal counter_snapshot : std_logic;signal update_complete : std_logic;signal update_counters : std_logic;
signal increment_counter_ptr : std_logic;
signal dat_i_inc_reg : std_logic_vector(31 downto 0);signal counter_ptr : integer range 0 to 7;signal counter_address_reg : std_logic_vector(21 downto 0);
signal new_counter_address_reg : std_logic_Vector(21 downto 0);
signal lut_port_address_reg : std_logic_vector(21 downto 0);
signal lut_port_delim_address_Reg : std_logic_Vector(21 downto 0);
signal dat_o_reg : std_logic_vector(31 downto 0);
signal register_address : std_logic;
signal frame_counter_address_reg : std_logic_vector(21 downto 0);
signal lut_start_address : std_logic_vector(21 downto 0);

begin


lut_start_address <= SHARED_MEM_LUT_SRC_START & "0000000000000";

process(clock,reset,counter_snapshot,counter_ptr)
begin
	if rising_edge(clock) then
		if reset = '1' then
			frame_counter_address_reg <= (others => '0');
		elsif counter_snapshot = '1' then
			frame_counter_address_reg <= SHARED_MEM_COUNTER_START & conv_std_logic_vector(counter_ptr,13);
		else
			frame_counter_address_reg <= frame_counter_address_reg;
		end if;
	end if;
end process;

process(clock,register_address) 
begin
	if rising_edge(clock) then
		if register_address = '1' then
			dat_o_reg <= conv_std_logic_vector(lut_ptr-1,15) & fifo_data_out(16 downto 0);
		else
			dat_o_reg <= dat_o_reg;
		end if;
	end if;
end process;

process(clock,reset,register_address,lut_info)
begin
	if rising_Edge(clock) then
		if reset = '1' then
			counter_address_reg <= (others => '0');
		elsif (register_address = '1' and lut_info.in_lut = true )then
				counter_address_reg <= SHARED_MEM_PREFIX_SOURCE & conv_std_logic_vector(lut_info.lut_pointer,13);
		else
			counter_address_reg <= counter_address_reg;
		end if;
	end if;
end process;

process(clock,reset,register_address,lut_ptr)
begin
	if rising_edge(clock) then
		if reset = '1' then
			new_counter_address_reg <= (others => '0');
		elsif register_address = '1' then
			new_counter_address_reg <= SHARED_MEM_PREFIX_SOURCE & conv_std_logic_Vector(lut_ptr,13);
		else
			new_counter_address_reg <= new_counter_address_reg;
		end if;
	end if;
end process;

process(clock,reset,register_address,lut_ptr)
begin
	if rising_edge(clock) then
		if reset = '1' then
			lut_port_address_reg <= (others => '0');
		elsif register_address = '1' then
			lut_port_address_reg <= SHARED_MEM_LUT_SRC_START & conv_std_logic_vector(lut_ptr-1,13);
		else
			lut_port_address_reg <= lut_port_address_reg;
		end if;
	end if;
end process;

process(clock,reset,register_address,lut_ptr)
begin
	if rising_edge(clock) then
		if reset = '1' then
			lut_port_delim_address_reg <= (others => '0');
		elsif register_address = '1' then
			lut_port_delim_address_reg <= SHARED_MEM_LUT_SRC_START & conv_std_logic_Vector(lut_ptr, 13);
		else
			lut_port_delim_address_reg <= lut_port_delim_address_reg;
		end if;
	end if;
end process;

process(clock,ack_i)
begin
	if rising_edge(clock) then
		if ack_i = '1' then
			dat_i_reg <= dat_i;
		else
			dat_i_reg <= dat_i_reg;
		end if;
	end if;
end process;

process(clock,reset,increment_rd_data,dat_i_reg)
begin
	if rising_edge(clock) then
		if reset = '1' then
			dat_i_inc_reg <= (others => '0');
		else
			if increment_rd_data = '1' then
				dat_i_inc_reg <= dat_i_reg + 1;
			else
				dat_i_inc_reg <= dat_i_inc_reg;
			end if;
		end if;
	end if;
end process;

snapshot:process(clock,reset,counter_snapshot)
begin
	if rising_edge(clock) then
		if reset = '1' then
--			for i in 0 to 6 loop
				frame_counters_reg(0) <= (others => '0');
				frame_counters_reg(1) <= (others => '0');
				frame_counters_reg(2) <= (others => '0');
				frame_counters_reg(3) <= (others => '0');
				frame_counters_reg(4) <= (others => '0');
				frame_counters_reg(5) <= (others => '0');
				frame_counters_reg(6) <= (others => '0');
				frame_counters_reg(7) <= (others => '0');
--			end loop;
		elsif counter_snapshot = '1' then
--			for i in 0 to 6 loop
				frame_counters_reg(0) <= frame_counters.count0;
				frame_counters_reg(1) <= frame_counters.count1;
				frame_counters_reg(2) <= frame_counters.count2;
				frame_counters_reg(3) <= frame_counters.count3;
				frame_counters_reg(4) <= frame_counters.count4;
				frame_counters_reg(5) <= frame_counters.count5;
				frame_counters_reg(6) <= frame_counters.count6;
				frame_counters_reg(7) <= frame_counters.count7;
--			end loop;
		else
--			for i in 0 to 6 loop
				frame_counters_reg(0) <= frame_counters_reg(0);
				frame_counters_reg(1) <= frame_counters_reg(1);
				frame_counters_reg(2) <= frame_counters_reg(2);
				frame_counters_reg(3) <= frame_counters_reg(3);
				frame_counters_reg(4) <= frame_counters_reg(4);
				frame_counters_reg(5) <= frame_counters_reg(5);
				frame_counters_reg(6) <= frame_counters_reg(6);
				frame_counters_reg(7) <= frame_counters_reg(7);
--			end loop;
		end if;
	end if;			
end process;

update_timer:
process(clock,reset,update_complete)
variable counter : integer range 0 to 100000000;
begin
	if rising_edge(clock) then
		if reset = '1' then
			update_counters <= '1';
			counter := 100000000;
		else
			if update_complete = '1' then
				update_counters <= '0';
				counter := 0;
			elsif counter = 100000000 then
				update_counters <= '1';
				counter := 100000000;
			else
				update_counters <= '0';
				counter := counter + 1;
			end if;
		end if;
	end if;
end process;

process(clock,reset,increment_counter_ptr,update_complete)
begin
	if rising_Edge(clock) then
		if reset = '1' then
			counter_ptr <= 0;
		else
			if increment_counter_ptr = '1' then
				counter_ptr <= counter_ptr + 1;
			elsif update_complete = '1' then
				counter_ptr <= 0;
			else
				counter_ptr <= counter_ptr;
			end if;
		end if;
	end if;
end process;

nxtstate_log:process(currentstate,fifo_empty,ack_i,lut_info.in_lut,update_counters,counter_ptr,
							fifo_data_out,lut_ptr,lut_info.lut_pointer,dat_i_inc_reg,frame_counters_reg,
							dat_o_reg,lut_port_address_reg,lut_port_delim_address_reg,new_counter_address_reg,
							counter_address_reg,frame_counter_address_reg)
begin
	case currentstate is 
		
		when reset_state =>
				nextstate <= idle_0_0;
			cyc_o <= '0';
			stb_o <= '0';
			we_o <= '0';
			adr_o <= (others => '0');
			dat_o <= (others => '0');
			fifo_pop <= '0';
			load_lut <= '0';
			enable_lut_search <= '0';
			increment_rd_data <= '0';
			increment_counter_ptr <= '0';
			update_complete <= '0';
			counter_snapshot <= '0';
			register_address <= '0';
		
		when idle_0_0 =>
				nextstate <= idle_0;
			cyc_o <= '1';
			stb_o <= '1';
			we_o <= '1';
			adr_o <= lut_start_address;--SHARED_MEM_LUT_SRC_START & "0000000000000";
			dat_o <= X"12345678";
			fifo_pop <= '0';
			load_lut <= '0';
			enable_lut_search <= '0';
			increment_rd_data <= '0';
			increment_counter_ptr <= '0';
			update_complete <= '0';
			counter_snapshot <= '0';
			register_address <= '0';
		
		when idle_0 =>
				if ack_i = '1' then
					nextstate <= idle;
				else
					nextstate <= idle_0;
				end if;
			cyc_o <= '1';
			stb_o <= '1';
			we_o <= '1';
			adr_o <= lut_start_address;--SHARED_MEM_LUT_SRC_START & "0000000000000";--conv_std_logic_vector(active_ptr,13);
			dat_o <= X"12345678";
			fifo_pop <= '0';
			load_lut <= '0';
			enable_lut_search <= '0';
			increment_rd_data <= '0';
			increment_counter_ptr <= '0';
			update_complete <= '0';
			counter_snapshot <= '0';
			register_address <= '0';
		
		when idle =>
			if update_counters = '1' then
				nextstate <= update_counters_2_ddr;
			elsif fifo_empty = '0' then
				nextstate <= pop_fifo;--lut_search;
--			if fifo_empty = '0' then --and update_counters = '0' then
--				nextstate <= lut_search;
--			elsif update_counters = '1' then
--				nextstate <= update_counters_2_ddr;
			else
				nextstate <= idle;
			end if;
			cyc_o <= '0';
			stb_o <= '0';
			we_o <= '0';
			dat_o <= (others => '0');
			adr_o <= (others => '0');
			fifo_pop <= '0';
			load_lut <= '0';
			enable_lut_search <= '0';
			increment_rd_data <= '0';
			increment_counter_ptr <= '0';
			update_complete <= '0';
			counter_snapshot <= '0';
			register_address <= '0';
			
		when lut_search =>
				nextstate <= register_ddr_address;--read_lut;
			cyc_o <= '0';
			stb_o <= '0';
			we_o <= '0';
			dat_o <= (others => '0');
			adr_o <= (others => '0');
			fifo_pop <= '0';
			load_lut <= '0';
			enable_lut_search <= '1';
			increment_rd_data <= '0';
			increment_counter_ptr <= '0';
			update_complete <= '0';
			counter_snapshot <= '0';
			register_address <= '0';
		
		when register_ddr_address =>
				nextstate <= read_lut;
			cyc_o <= '0';
			stb_o <= '0';
			we_o <= '0';
			dat_o <= (others => '0');
			adr_o <= (others => '0');
			fifo_pop <= '0';
			load_lut <= '0';
			enable_lut_search <= '0';
			increment_rd_data <= '0';
			increment_counter_ptr <= '0';
			update_complete <= '0';
			counter_snapshot <= '0';
			register_address <= '1';
			
		when read_lut =>
				if lut_info.in_lut = true then
					nextstate <= read_ddr;
				else
					nextstate <= write_1_to_ddr;--load_lut_value;
				end if;
			cyc_o <= '0';
			stb_o <= '0';
			we_o <= '0';
			dat_o <= (others => '0');
			adr_o <= (others => '0');
			fifo_pop <= '0';
			load_lut <= '0';
			enable_lut_search <= '0';
			increment_rd_data <= '0';
			increment_counter_ptr <= '0';
			update_complete <= '0';
			counter_snapshot <= '0';
			register_address <= '0';
			
		when load_lut_value =>
				nextstate <= register_ddr_address_2;--store_lut_2_ddr;--pop_fifo;--write_1_to_ddr;
			cyc_o <= '0';
			stb_o <= '0';
			we_o <= '0';
			dat_o <= (others => '0');
			adr_o <= (others => '0');
			fifo_pop <= '0';
			load_lut <= '1';
			enable_lut_search <= '0';
			increment_rd_data <= '0';
			increment_counter_ptr <= '0';
			update_complete <= '0';
			counter_snapshot <= '0';
			register_address <= '0';
		
		when register_ddr_address_2 =>
				nextstate <= store_lut_2_ddr;
			cyc_o <= '0';
			stb_o <= '0';
			we_o <= '0';
			dat_o <= (others => '0');
			adr_o <= (others => '0');
			fifo_pop <= '0';
			load_lut <= '0';
			enable_lut_search <= '0';
			increment_rd_data <= '0';
			increment_counter_ptr <= '0';
			update_complete <= '0';
			counter_snapshot <= '0';
			register_address <= '1';
		
		when store_lut_2_ddr =>
--				if ack_i = '1' then
--					nextstate <= store_lut_delim;--pop_fifo;
--				else
					nextstate <= store_lut_2_ddr_0;
--				end if;
			cyc_o <= '1';
			stb_o <= '1';
			we_o <= '1';
			dat_o <= dat_o_reg;--conv_std_logic_vector(lut_ptr-1,15) & fifo_data_out(16 downto 0);
			adr_o <= lut_port_address_reg;--SHARED_MEM_LUT_SRC_START & conv_std_logic_vector((lut_ptr-1),13);
			fifo_pop <= '0';
			load_lut <= '0';
			enable_lut_search <= '0';
			increment_rd_data <= '0';
			increment_counter_ptr <= '0';
			update_complete <= '0';
			counter_snapshot <= '0';
			register_address <= '0';
		
		when store_lut_2_ddr_0 =>
				if ack_i = '1' then
					nextstate <= store_lut_delim_wait;--pop_fifo;
				else
					nextstate <= store_lut_2_ddr_0;
				end if;
			cyc_o <= '1';
			stb_o <= '1';
			we_o <= '1';
			dat_o <= dat_o_reg;--conv_std_logic_vector(lut_ptr-1,15) & fifo_data_out(16 downto 0);
			adr_o <= lut_port_address_reg;--SHARED_MEM_LUT_SRC_START & conv_std_logic_vector((lut_ptr-1),13);
			fifo_pop <= '0';
			load_lut <= '0';
			enable_lut_search <= '0';
			increment_rd_data <= '0';
			increment_counter_ptr <= '0';
			update_complete <= '0';
			counter_snapshot <= '0';
			register_address <= '0';
		
		when store_lut_delim_wait =>
				nextstate <= store_lut_delim;
			cyc_o <= '0';
			stb_o <= '0';
			we_o <= '0';
			dat_o <= (others => '0');
			adr_o <= (others => '0');
			fifo_pop <= '0';
			load_lut <= '0';
			enable_lut_search <= '0';
			increment_rd_data <= '0';
			increment_counter_ptr <= '0';
			update_complete <= '0';
			counter_snapshot <= '0';
			register_address <= '0';
		
		when store_lut_delim =>
--				if ack_i = '1' then
--					nextstate <= pop_fifo;
--				else
					nextstate <= store_lut_delim_0;
--				end if;
			cyc_o <= '1';
			stb_o <= '1';
			we_o <= '1';
			dat_o <= X"12345678";
			adr_o <= lut_port_delim_address_reg;--SHARED_MEM_LUT_SRC_START & conv_std_logic_vector((lut_ptr),13);
			fifo_pop <= '0';
			load_lut <= '0';
			enable_lut_search <= '0';
			increment_rd_data <= '0';
			increment_counter_ptr <= '0';
			update_complete <= '0';
			counter_snapshot <= '0';
			register_address <= '0';
		
		when store_lut_delim_0 =>
				if ack_i = '1' then
					nextstate <= idle;--pop_fifo;
				else
					nextstate <= store_lut_delim_0;
				end if;
			cyc_o <= '1';
			stb_o <= '1';
			we_o <= '1';
			dat_o <= X"12345678";
			adr_o <= lut_port_delim_address_reg;--SHARED_MEM_LUT_SRC_START & conv_std_logic_vector((lut_ptr),13);
			fifo_pop <= '0';
			load_lut <= '0';
			enable_lut_search <= '0';
			increment_rd_data <= '0';
			increment_counter_ptr <= '0';
			update_complete <= '0';
			counter_snapshot <= '0';
			register_address <= '0';
		
		when write_1_to_ddr =>
--				if ack_i = '1' then
--					nextstate <= load_lut_value;--pop_fifo;
--				else
					nextstate <= write_1_to_ddr_0;
--				end if;
			cyc_o <= '1';
			stb_o <= '1';
			we_o <= '1';
			dat_o <= X"00000001";
			adr_o <= new_counter_address_reg;--SHARED_MEM_PREFIX_SOURCE & conv_std_logic_vector(lut_ptr,13);
			fifo_pop <= '0';
			load_lut <= '0';
			enable_lut_search <= '0';
			increment_rd_data <= '0';
			increment_counter_ptr <= '0';
			update_complete <= '0';
			counter_snapshot <= '0';
			register_address <= '0';
		
		when write_1_to_ddr_0 =>
				if ack_i = '1' then
					nextstate <= load_lut_value;--pop_fifo;
				else
					nextstate <= write_1_to_ddr_0;
				end if;
			cyc_o <= '1';
			stb_o <= '1';
			we_o <= '1';
			dat_o <= X"00000001";
			adr_o <= new_counter_address_reg;--SHARED_MEM_PREFIX_SOURCE & conv_std_logic_vector(lut_ptr,13);
			fifo_pop <= '0';
			load_lut <= '0';
			enable_lut_search <= '0';
			increment_rd_data <= '0';
			increment_counter_ptr <= '0';
			update_complete <= '0';
			counter_snapshot <= '0';
			register_address <= '0';
		
		
		when pop_fifo =>
				nextstate <= pop_fifo_wait;--idle;
			cyc_o <= '0';
			stb_o <= '0';
			we_o <= '0';
			dat_o <= (others => '0');
			adr_o <= (others => '0');
			fifo_pop <= '1';
			load_lut <= '0';
			enable_lut_search <= '0';
			increment_rd_data <= '0';
			increment_counter_ptr <= '0';
			update_complete <= '0';
			counter_snapshot <= '0';
			register_address <= '0';
		
		when pop_fifo_wait =>
				nextstate <= lut_search;
			cyc_o <= '0';
			stb_o <= '0';
			we_o <= '0';
			dat_o <= (others => '0');
			adr_o <= (others => '0');
			fifo_pop <= '0';
			load_lut <= '0';
			enable_lut_search <= '0';
			increment_rd_data <= '0';
			increment_counter_ptr <= '0';
			update_complete <= '0';
			counter_snapshot <= '0';
			register_address <= '0';
		when read_ddr =>
--				if ack_i = '1' then
--					nextstate <= increment_ddr_read_data;
--				else
					nextstate <= read_ddr_0;
--				end if;
			cyc_o <= '1';
			stb_o <= '1';
			we_o <= '0';
			dat_o <= (others => '0');
			adr_o <= counter_address_reg;--SHARED_MEM_PREFIX_SOURCE & conv_std_logic_vector(lut_info.lut_pointer,13);
			fifo_pop <= '0';
			load_lut <= '0';
			enable_lut_search <= '0';
			increment_rd_data <= '0';
			increment_counter_ptr <= '0';
			update_complete <= '0';
			counter_snapshot <= '0';
			register_address <= '0';
		
		when read_ddr_0 =>
				if ack_i = '1' then
					nextstate <= increment_ddr_read_data;
				else
					nextstate <= read_ddr_0;
				end if;
			cyc_o <= '1';
			stb_o <= '1';
			we_o <= '0';
			dat_o <= (others => '0');
			adr_o <= counter_address_reg;--SHARED_MEM_PREFIX_SOURCE & conv_std_logic_vector(lut_info.lut_pointer,13);
			fifo_pop <= '0';
			load_lut <= '0';
			enable_lut_search <= '0';
			increment_rd_data <= '0';
			increment_counter_ptr <= '0';
			update_complete <= '0';
			counter_snapshot <= '0';
			register_address <= '0';
		
		when increment_ddr_read_data =>
				nextstate <= write_inc_data_2_ddr;
			cyc_o <= '0';
			stb_o <= '0';
			we_o <= '0';
			dat_o <= (others => '0');
			adr_o <= (others => '0');
			fifo_pop <= '0';
			load_lut <= '0';
			enable_lut_search <= '0';
			increment_rd_data <= '1';
			increment_counter_ptr <= '0';
			update_complete <= '0';
			counter_snapshot <= '0';
			register_address <= '0';
		
		when write_inc_data_2_ddr =>
--				if ack_i = '1' then
--					nextstate <= pop_fifo;
--				else
					nextstate <= write_inc_data_2_ddr_0;
--				end if;
			cyc_o <= '1';
			stb_o <= '1';
			we_o <= '1';
			dat_o <= dat_i_inc_reg;--dat_i_reg + 1;--counter_data;
			adr_o <= counter_address_reg;--SHARED_MEM_PREFIX_SOURCE & conv_std_logic_vector(lut_info.lut_pointer,13);
			fifo_pop <= '0';
			load_lut <= '0';
			enable_lut_search <= '0';
			increment_rd_data <= '0';
			increment_counter_ptr <= '0';
			update_complete <= '0';
			counter_snapshot <= '0';
			register_address <= '0';
		
		when write_inc_data_2_ddr_0 =>
				if ack_i = '1' then
					nextstate <= idle;--pop_fifo;
				else
					nextstate <= write_inc_data_2_ddr_0;
				end if;
			cyc_o <= '1';
			stb_o <= '1';
			we_o <= '1';
			dat_o <= dat_i_inc_reg;--dat_i_reg + 1;--counter_data;
			adr_o <= counter_address_reg;--SHARED_MEM_PREFIX_SOURCE & conv_std_logic_vector(lut_info.lut_pointer,13);
			fifo_pop <= '0';
			load_lut <= '0';
			enable_lut_search <= '0';
			increment_rd_data <= '0';
			increment_counter_ptr <= '0';
			update_complete <= '0';
			counter_snapshot <= '0';
			register_address <= '0';
		
		when update_counters_2_ddr =>
				nextstate <= update_counters_2_ddr_0;
			cyc_o <= '0';
			stb_o <= '0';
			we_o <= '0';
			dat_o <= (others => '0');
			adr_o <= (others => '0');
			fifo_pop <= '0';
			load_lut <= '0';
			enable_lut_search <= '0';
			increment_rd_data <= '0';
			increment_counter_ptr <= '0';
			update_complete <= '0';
			counter_snapshot <= '1';
			register_address <= '0';
		
		when update_counters_2_ddr_0 =>
--				if ack_i = '1' then
--					nextstate <= check_counter_ptr;--inc_counter_ptr;
--				else
					nextstate <= update_counters_2_ddr_1;
--				end if;
			cyc_o <= '1';
			stb_o <= '1';
			we_o <= '1';
			dat_o <= frame_counters_reg(counter_ptr);
			adr_o <= frame_counter_address_reg;--SHARED_MEM_COUNTER_START & conv_std_logic_vector(counter_ptr,13);
			fifo_pop <= '0';
			load_lut <= '0';
			enable_lut_search <= '0';
			increment_rd_data <= '0';
			increment_counter_ptr <= '0';
			update_complete <= '0';
			counter_snapshot <= '0';
			register_address <= '0';
		
		when update_counters_2_ddr_1 =>
				if ack_i = '1' then
					nextstate <= check_counter_ptr;--inc_counter_ptr;
				else
					nextstate <= update_counters_2_ddr_1;
				end if;
			cyc_o <= '1';
			stb_o <= '1';
			we_o <= '1';
			dat_o <= frame_counters_reg(counter_ptr);
			adr_o <= frame_counter_address_reg;--SHARED_MEM_COUNTER_START & conv_std_logic_vector(counter_ptr,13);
			fifo_pop <= '0';
			load_lut <= '0';
			enable_lut_search <= '0';
			increment_rd_data <= '0';
			increment_counter_ptr <= '0';
			update_complete <= '0';
			counter_snapshot <= '0';
			register_address <= '0';
		
		when check_counter_ptr =>
				if counter_ptr = MAX_NUM_FRAME_COUNTERS-1 then
					nextstate <= completed_update;
				else
					nextstate <= inc_counter_ptr;
				end if;
			cyc_o <= '0';
			stb_o <= '0';
			we_o <= '0';
			dat_o <= (others => '0');
			adr_o <= (others => '0');
			fifo_pop <= '0';
			load_lut <= '0';
			enable_lut_search <='0';
			increment_rd_data <= '0';
			increment_counter_ptr <= '0';
			update_complete <= '0';
			counter_snapshot <= '0';
			register_address <= '0';
		
		when inc_counter_ptr =>
--				if counter_ptr = 6 then
--					nextstate <= completed_update;
--				else
					nextstate <= inc_counter_ptr_wait;--update_counters_2_ddr;
--				end if;
			cyc_o <= '0';
			stb_o <= '0';
			we_o <= '0';
			dat_o <= (others => '0');
			adr_o <= (others => '0');
			fifo_pop <= '0';
			load_lut <= '0';
			enable_lut_search <= '0';
			increment_rd_data <= '0';
			increment_counter_ptr <= '1';
			update_complete <= '0';
			counter_snapshot <= '0';
			register_address <= '0';
		
		when inc_counter_ptr_wait =>
				nextstate <= update_counters_2_ddr;
			cyc_o <= '0';
			stb_o <= '0';
			we_o <= '0';
			dat_o <= (others => '0');
			adr_o <= (others => '0');
			fifo_pop <= '0';
			load_lut <= '0';
			enable_lut_search <= '0';
			increment_rd_data <= '0';
			increment_counter_ptr <= '0';
			update_complete <= '0';
			counter_snapshot <= '0';
			register_address <= '0';
		
		when completed_update =>
				nextstate <= idle;
			cyc_o <= '0';
			stb_o <= '0';
			we_o <= '0';
			dat_o <= (others => '0');
			adr_o <= (others => '0');
			fifo_pop <= '0';
			load_lut <= '0';
			enable_lut_search <= '0';
			increment_rd_data <= '0';
			increment_counter_ptr <= '0';
			update_complete <= '1';
			counter_snapshot <= '0';
			register_address <= '0';
		
		when others =>
				nextstate <= idle;
			cyc_o <= '0';
			stb_o <= '0';
			we_o <= '0';
			dat_o <= (others => '0');
			adr_o <= (others => '0');
			fifo_pop <= '0';
			load_lut <= '0';
			enable_lut_search <= '0';
			increment_rd_data <= '0';
			increment_counter_ptr <= '0';
			update_complete <= '0';
			counter_snapshot <= '0';
			register_address <= '0';
	end case;
end process;

curstate_log:process(clock,reset,nextstate)
begin
	if (clock'event AND clock = '1') then	
		if reset = '1' then
			currentstate <= reset_state;
		else
			currentstate <= nextstate;
		end if;
	
	end if;
end process;

end Behavioral;

