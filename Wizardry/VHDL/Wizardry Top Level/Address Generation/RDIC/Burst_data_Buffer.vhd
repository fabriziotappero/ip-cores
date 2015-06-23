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
-- Module Name: Burst_data_Buffer - Behavioral 
-- Project Name: Wizardry
-- Target Devices: Virtex 4 ML401
-- Description: Behavioral description for burst data buffer.
-- Revision: 1.0
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.MAC_Constants.all;

entity Burst_data_Buffer is
    Port (clock : in  STD_LOGIC;
			device_clock : in  STD_LOGIC;
			reset : in std_logic;
			we_i : in std_logic;
			data_in : in std_logic_vector(data_width -1 downto 0);
			address_in : in std_logic_vector(virtual_address_width -1 downto 0);
			data_out : out std_logic_vector((data_width + virtual_address_width)-1 downto 0);
			read_address : out std_logic_vector(virtual_address_width -1 downto 0);
			pop : in std_logic;
			cyc_i : in std_logic;
			stb_i : in std_logic;
			lock_i : in std_logic;
			read_err_i : in std_logic;
			write_err_i : in std_logic;
			err_o : out std_logic;
			read_buffer_full : in std_logic;
			read_serviced : in std_logic;
			read_acknowledge : in std_logic;
			reset_pop_count_in : in std_logic;
			buffer_full : out std_logic; 
			buffer_empty : out std_logic;
			write_enable_out : out std_logic;
			read_enable_out : out std_logic;
			acknowledge : out std_logic;
			reset_buffer : out std_logic; 
			acknowledge_read_data : out std_logic 
			);
end Burst_data_Buffer;

architecture Behavioral of Burst_data_Buffer is

--type Burst_Data_Array is
--	array (0 to burst_length -1) of std_logic_vector((data_width + virtual_address_width) -1 downto 0);
signal full_s,empty_s,push_s,clear_push_count: std_logic;
signal address_in_s, read_address_s : std_logic_vector(virtual_address_width -1 downto 0);
signal buffer_input_data_s : std_logic_vector((data_width + virtual_address_width) -1 downto 0);
type StateType is (idle,pull_data,check_lock,check_buff_status,send_data,check_full,acknowledge_data,
	send_data_0,check_buff_status_0,send_acknowledge,send_acknowledge_wait,single_write,write_error_0);
     signal CurrentState,NextState: StateType;
	  
type StateType_read is (reset_idle,assert_read_enable,check_lock_and_bits,check_lock_and_bits_1,clear_buffer,
	wait_buffer_full,acknowledge_single_read,acknowledge_block_read,error_state,acknowledge_single_read_0);
     signal CurrentState_read,NextState_read: StateType_read;	  
	  
signal var_a, var_b : integer range 0 to burst_length -1 := 0;
signal Data_array_v : burst_data_array;
signal push_count,pop_count : std_logic_vector(2 downto 0) := "000";

begin
buffer_input_data : process(clock, reset,cyc_i, stb_i,data_in,address_in,read_acknowledge,read_address_s)
variable buffer_input_data_v : std_logic_vector((data_width + virtual_address_width) -1 downto 0);
variable address_in_v : std_logic_vector(virtual_address_width -1 downto 0);
begin
if clock='1' and clock'event then
	if(reset = '1' OR read_acknowledge = '1') then
		address_in_v := "0000000000000000000000";
		read_address_s <= (others => '0');
	elsif(cyc_i = '1' AND stb_i = '1') then
		if(we_i = '1') then
--			buffer_input_data_v := data_in & address_in;
			buffer_input_data_s <= data_in & address_in;
			address_in_v := address_in;
			read_address_s <= read_address_s;
		elsif(we_i = '0')then
			buffer_input_data_s <= (others => '0');
			address_in_v := address_in;
			read_address_s <= address_in;
		end if;
	else
		buffer_input_data_s <= buffer_input_data_s;
		address_in_v := address_in_v;
		read_address_s <= read_address_s;
	end if;

end if;
--buffer_input_data_s <= buffer_input_data_v;
address_in_s <= address_in_v;
read_address <= read_address_s;
end process buffer_input_data;


process(clock,read_err_i,write_err_i)
begin
if clock='1' and clock'event then
	for i in 0 to num_of_ports loop
		if(read_err_i = '1') then
			err_o <= '1';
		elsif(write_err_i = '1') then
			err_o <= '1';
		else
			err_o <= '0';
		end if;
	end loop;
end if;
end process;


read_communication: process(CurrentState_read, lock_i, cyc_i, stb_i, read_buffer_full,read_serviced,read_address_s,we_i,read_err_i)
   
   begin
	
		case (CurrentState_read) is			
			when reset_idle =>
				if (we_i = '0' AND cyc_i = '1' AND stb_i = '1') then
					NextState_read <= assert_read_enable;
				else
					NextState_read <= reset_idle;
				end if;			
			
			reset_buffer <= '1';
			acknowledge_read_data <= '0';
			read_enable_out <= '0';
--			err_o	<= '0';
--			read_address <= (others => '0');
			
			when assert_read_enable =>
				if (read_serviced = '1') then
					NextState_read <= wait_buffer_full;
				else
					NextState_read <= assert_read_enable;
				end if;
			
			reset_buffer <= '0';
			acknowledge_read_data <= '0';
			read_enable_out <= '1';
--			err_o	<= '0';
--			read_address <= read_address_s;


			when wait_buffer_full =>				
				if (read_buffer_full = '1') then
					NextState_read <= check_lock_and_bits;
				elsif(read_err_i = '1') then
					NextState_read <= error_state;
				else
					NextState_read <= wait_buffer_full;
				end if;				
			
			reset_buffer <= '0';
			acknowledge_read_data <= '0';
			read_enable_out <= '0';
--			err_o	<= '0';
--			read_address <= read_address_s;
			
			when check_lock_and_bits =>				
				if (lock_i = '0') then
					NextState_read <= acknowledge_single_read;
				elsif(read_address_s(1 downto 0) = "11") then
					NextState_read <= acknowledge_single_read;
				else
					NextState_read <= acknowledge_block_read;
				end if;			
			
			reset_buffer <= '0';
			acknowledge_read_data <= '0';
			read_enable_out <= '0';
--			err_o	<= '0';
--			read_address <= (others => '0');
			
			when acknowledge_single_read =>				
					NextState_read <= acknowledge_single_read_0;	
			
			reset_buffer <= '0';
			acknowledge_read_data <= '1';
			read_enable_out <= '0';
--			err_o	<= '0';
--			read_address <= (others => '0');
			
			when acknowledge_single_read_0 =>				
					NextState_read <= reset_idle;	
			
			reset_buffer <= '0';
			acknowledge_read_data <= '0';
			read_enable_out <= '0';
--			err_o	<= '0';
--			read_address <= (others => '0');
			
			when acknowledge_block_read =>				
					NextState_read <= check_lock_and_bits_1;	
			
			reset_buffer <= '0';
			acknowledge_read_data <= '1';
			read_enable_out <= '0';
--			err_o	<= '0';
--			read_address <= (others => '0');
			
			when check_lock_and_bits_1 =>			
				if (we_i = '0' AND cyc_i = '1' AND stb_i = '1' AND lock_i = '1') then
					NextState_read <= check_lock_and_bits;
				elsif (we_i = '0' AND cyc_i = '0' AND stb_i = '0' AND lock_i = '1') then
					NextState_read <= check_lock_and_bits_1;
				elsif (we_i = '0' AND cyc_i = '1' AND stb_i = '1' AND lock_i = '0') then
					NextState_read <= clear_buffer;
				else 
					NextState_read <= reset_idle;
				end if;
			
			reset_buffer <= '0';
			acknowledge_read_data <= '0';
			read_enable_out <= '0';
--			err_o	<= '0';
--			read_address <= (others => '0');
			
			when error_state =>			
					NextState_read <= reset_idle;
			
			reset_buffer <= '0';
			acknowledge_read_data <= '0';
			read_enable_out <= '0';
--			err_o	<= '1';
--			read_address <= (others => '0');
			
			when clear_buffer =>			
					NextState_read <= assert_read_enable;
			
			reset_buffer <= '1';
			acknowledge_read_data <= '0';
			read_enable_out <= '0';
--			err_o	<= '0';
--			read_address <= (others => '0');
			
			when others =>
					NextState_read <= reset_idle;		
			reset_buffer <= '0';
			acknowledge_read_data <= '0';
			read_enable_out <= '0';
--			err_o	<= '0';
--			read_address <= (others => '0');
		
	end case;
	
end process read_communication;

nextstatelogic_read: process
--(clock,reset)
	begin
			wait until device_clock'EVENT and device_clock = '1'; --WAIT FOR RISING EDGE
--	if(rising_edge(clock)) then
		-- INITIALIZATION
		if (Reset = '1') then
			CurrentState_read <= reset_idle;
		else
					CurrentState_read <= NextState_read;
		end if;
--	end if;
end process nextstatelogic_read;

	
buffer_communication: process(CurrentState, lock_i, cyc_i, stb_i, empty_s, we_i,full_s,write_err_i)
   
   begin
	
		case (CurrentState) is			
			when idle=>
				if (we_i = '1' AND lock_i = '1' AND cyc_i = '1' AND stb_i = '1') then
					NextState <= pull_data;
				elsif (we_i = '1' AND cyc_i = '1' AND stb_i = '1') then
					NextState <= single_write;
				else
					NextState <= idle;
				end if;			
			
			push_s <= '0';
			acknowledge <= '0';
			write_enable_out <= '0';
			clear_push_count <= '0';
--			clear_pop_count <= '0';
			
			when pull_data =>
					NextState <= check_full;	
			
			push_s <= '1';
			acknowledge <= '0';
			write_enable_out <= '0';
			clear_push_count <= '0';
--			clear_pop_count <= '0';
			
			when check_full =>
				if(full_s = '1') then
					NextState <= send_data_0;	
				else
					NextState <= acknowledge_data;	
				end if;
			push_s <= '0';
			acknowledge <= '0';
			write_enable_out <= '0';
			clear_push_count <= '0';
--			clear_pop_count <= '0';
		
			when acknowledge_data =>
					NextState <= check_lock;	
			push_s <= '0';
			acknowledge <= '1';
			write_enable_out <= '0';
			clear_push_count <= '0';
--			clear_pop_count <= '0';
			
			when check_lock =>
				if (lock_i = '0') then
					NextState <= send_data;
				else
					NextState <= idle;
				end if;			
			
			push_s <= '0';
			acknowledge <= '0';
			write_enable_out <= '0';
			clear_push_count <= '0';
--			clear_pop_count <= '0';
			
			
			when send_data =>
					NextState <= check_buff_status;
			
			push_s <= '0';
			acknowledge <= '0';
			write_enable_out <= '1';
			clear_push_count <= '0';
--			clear_pop_count <= '0';
			
			when send_data_0 =>
					NextState <= check_buff_status_0;
			
			push_s <= '0';
			acknowledge <= '0';
			write_enable_out <= '1';
			clear_push_count <= '0';
--			clear_pop_count <= '0';
			
			when check_buff_status =>
				if (empty_s = '1') then
					NextState <= idle;
				else
					NextState <= check_buff_status;
				end if;			
			
			push_s <= '0';
			acknowledge <= '0';
			write_enable_out <= '1';
			clear_push_count <= '0';
--			clear_pop_count <= '0';
			
			when check_buff_status_0 =>
				if (empty_s = '1') then
					NextState <= send_acknowledge;
				elsif (write_err_i = '1') then
					NextState <= write_error_0;
				else
					NextState <= check_buff_status_0;
				end if;			
			
			push_s <= '0';
			acknowledge <= '0';
			write_enable_out <= '1';
			clear_push_count <= '0';
--			clear_pop_count <= '0';
			
			when write_error_0 =>
					NextState <= send_acknowledge_wait;
					
			push_s <= '0';
			acknowledge <= '0';
			write_enable_out <= '0';
			clear_push_count <= '1';
			
			when send_acknowledge =>
					NextState <= send_acknowledge_wait;
					
			push_s <= '0';
			acknowledge <= '1';
			write_enable_out <= '0';
			clear_push_count <= '1';
--			clear_pop_count <= '1';

			when send_acknowledge_wait =>
					NextState <= idle;
					
			push_s <= '0';
			acknowledge <= '0';
			write_enable_out <= '0';
			clear_push_count <= '0';
--			clear_pop_count <= '1';
			
			when single_write =>
					NextState <= send_data_0;
					
			push_s <= '1';
			acknowledge <= '0';
			write_enable_out <= '0';
			clear_push_count <= '0';
--			clear_pop_count <= '0';
			
			when others =>
					NextState <= idle;		
			push_s <= '0';
			acknowledge <= '0';
			write_enable_out <= '0';
			clear_push_count <= '0';
--			clear_pop_count <= '0';
		
	end case;
	
end process buffer_communication;

nextstatelogic: process
--(clock,reset)
	begin
			wait until device_clock'EVENT and device_clock = '1'; --WAIT FOR RISING EDGE
--	if(rising_edge(clock)) then
		-- INITIALIZATION
		if (Reset = '1') then
			CurrentState <= idle;
		else
					CurrentState <= NextState;
		end if;
--	end if;
end process nextstatelogic;
			
pop_buffer_burst_data : process(clock,reset,pop,push_s,address_in,pop_count,data_array_v,reset_pop_count_in)
--variable Data_array_v : burst_data_array;
--variable var_a, var_b : integer range 0 to burst_length -1;
--variable count_v : std_logic_vector(2 downto 0);
begin
if (clock='1' and clock'event) then

      if reset='1' then 
--			var_a <= 0;
--			var_b <= 0;
--			count_v <= "000";
--			for i in 0 to (burst_length -1) loop
--				data_array_v(i) <= (others => '0');
--			end loop;
		else			
		
--			if(push_s = '1') then -- AND full_s = '0') then
--				if(count_v < "100") then
--					Data_array_v(var_a) <= buffer_input_data_s;
--					count_v <= count_v +1;
--					if(var_a = burst_length -1) then
--						var_a <= 0;
--					else
--						var_a <= var_a +1;
--					end if;
--				end if;
			
--			els
			if(reset_pop_count_in = '1') then
				pop_count <= "000";
				
			elsif(pop = '1' AND push_s = '0') then -- AND empty_s = '0') then
				if(empty_s = '0') then
--					if(pop_count = "011") then
--						pop_count <= "000";
--					else
						pop_count <= pop_count +1;
--					end if;
					if(var_b = burst_length -1) then
						var_b <= 0;
					else
						var_b <= var_b +1;
					end if;
				end if;
			else
				pop_count <= pop_count;
--				var_a <= var_a;
				var_b <= var_b;
			end if;	
		end if;
end if;

data_out <= Data_array_v(var_b); 

end process pop_buffer_burst_data;






push_buffer_burst_data : process(device_clock,reset,push_s,address_in,push_count,buffer_input_data_s,clear_push_count)
--variable Data_array_v : burst_data_array;
--variable var_a, var_b : integer range 0 to burst_length -1;
--variable count_v : std_logic_vector(2 downto 0);
begin
if (device_clock='1' and device_clock'event) then

      if reset='1' then 
--			var_a <= 0;
--			var_b <= 0;
--			count_v <= "000";
--			for i in 0 to (burst_length -1) loop
--				data_array_v(i) <= (others => '0');
--			end loop;
		else			
--			if(pop = '1') then
			
--			if(push_count = "100") then
--				push_count <= "000";
--			els
			if(clear_push_count = '1') then
				push_count <= "000";
				
			elsif(push_s = '1' and pop = '0') then -- AND full_s = '0') then
--				if(count_v < "100") then
				if(push_count = "100") then
					push_count <= "000";
				else
					push_count <= push_count +1;
				end if;
				Data_array_v(var_a) <= buffer_input_data_s;
					if(var_a = burst_length -1) then
						var_a <= 0;
					else
						var_a <= var_a +1;
--					end if;
				end if;
			
--			elsif(pop = '1') then -- AND empty_s = '0') then
--				if(empty_s = '0') then
--					count_v <= count_v -1;
--					if(var_b = burst_length -1) then
--						var_b <= 0;
--					else
--						var_b <= var_b +1;
--					end if;
--				end if;
			else
				push_count <= push_count;
				var_a <= var_a;
--				var_b <= var_b;
			end if;	
		end if;
end if;

--count_v_s <= count_v;
--data_out <= Data_array_v(var_b); 
--
end process push_buffer_burst_data;





FULL_s      <=  '1' when ((conv_integer(push_count) = 1) OR (Data_array_v(var_b)(1 downto 0) = "11") 
						OR (address_in_s(1 downto 0) = "11" AND empty_s = '0')) else '0';
EMPTY_s     <=  '1' when (pop_count = "100" OR pop_count = push_count) else '0';

--FULL_s      <=  '1' when ((conv_integer(push_count) = stack_depth) OR (Data_array_v(var_b)(1 downto 0) = "11") 
--						OR (address_in_s(1 downto 0) = "11" AND empty_s = '0')) else '0';
--EMPTY_s     <=  '1' when (pop_count = "100" OR pop_count = push_count) else '0';


buffer_full <= full_s;
buffer_empty <= empty_s;	

			

end Behavioral;

