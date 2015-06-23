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
-- Module Name: Arbitration_Path - Behavioral 
-- Project Name: Wizardry
-- Target Devices: Virtex 4 ML401
-- Description: Behavioral description for memory access arbitration scheme.
-- Revision: 1.0
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.MAC_Constants.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Arbitration_Path is
    Port ( clock : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  FIFO_full : in  STD_LOGIC;
			  FIFO_empty : in std_logic;
--			  burst_full : in std_logic_vector(num_of_ports downto 0);
			  read_request : in std_logic_vector(num_of_ports downto 0);
			  write_request : in std_logic_vector(num_of_ports downto 0);
--			  burst_empty : in std_logic_vector(num_of_ports downto 0);
			  priority_signals : in priority_type;
--           Memory_Access_out : out  Memory_Access_Port_out;
			  read_acknowledge : in std_logic_vector(num_of_ports downto 0);
			  read_enable_in : out  std_logic_vector(num_of_ports downto 0);
			  write_enable_in : out  std_logic_vector(num_of_ports downto 0)
			  );
end Arbitration_Path;

architecture Behavioral of Arbitration_Path is


type StateType is (reset_state, idle_0, idle_1, idle_2, idle_3,
		access_requested, access_requested_check,
		inc_counter, increment_index_i, check_request_vector,
		increment_index_j,check_priority, check_access_type,
		check_access_type_1,check_access_type_2,check_access_type_3,
		grant_write_access_1,
		pre_inc_index_j, check_request_vector_0, 
		grant_write_access, grant_read_access,
		check_index_j, pre_clear_index_j,
		increment_index_i_0, increment_access_count, check_i_j,
		clear_j, increment_req_index_i
			
			
			);
signal CurrentState,NextState: StateType;
signal request, read_flag_a : std_logic_vector(num_of_ports downto 0);
signal access_count : std_logic_vector(7 downto 0);
signal index_i : integer range 0 to 7;
signal index_j : integer range 0 to num_of_ports;
signal read_access_out,write_access_out : std_logic_vector(num_of_ports downto 0);
signal inc_count, inc_index_i, inc_index_j, read_enable,write_enable,
clear_index_i,clear_index_j : std_logic;
	  
begin

Generate_Access_Signals : process(clock,write_request,read_request)--,read_flag_a)
--variable : integer range (0 to num_of_ports-1);
begin
	for i in 0 to (num_of_ports) loop
		request(i) <= write_request(i) OR (read_request(i));-- AND ( read_flag_a(i)) );
	end loop;
end process;

--toggle_read : process(clock,reset)
--variable flag : std_logic;
--begin
--	if clock='1' and clock'event then
--      if reset='1' then 
--			read_flag_a <= "111111111";
--		else
--			for i in 0 to (num_of_ports) loop
--			flag := read_acknowledge(i) XOR read_access_out(i);
--				if(flag = '1') then
--					read_flag_a(i) <= not read_flag_a(i);
--				else
--					read_flag_a(i) <= read_flag_a(i);
--				end if;
--			end loop;
--		end if;
--	end if;
--end process;


access_counter : process (clock) 
begin
   if clock='1' and clock'event then
      if reset='1' then 
         access_count <= (others => '0');
      elsif inc_count = '1' then
         access_count <= access_count + 1;
      end if;
   end if;
end process;

Index_i_counter : process (clock) 
begin
   if clock='1' and clock'event then
      if reset='1' then 
         index_i <= 0;
      elsif inc_index_i = '1' then
         index_i <= index_i + 1;
		elsif clear_index_i = '1' then
			index_i <= 0;
      end if;
   end if;
end process;

Index_j_counter : process (clock) 
begin
   if clock='1' and clock'event then
      if reset='1' then 
         index_j <= 0;
      elsif inc_index_j = '1' then
         index_j <= index_j + 1;
		elsif clear_index_j = '1' then
			index_j <= 0;
      end if;
   end if;
end process;

set_access_outputs : process (clock,reset,read_enable,write_enable,read_access_out,write_access_out) 
--variable read_access_out,write_access_out : std_logic_vector(num_of_ports -1 downto 0);
begin
   if clock='1' and clock'event then
      if reset='1' then 
         read_access_out <= "000000000";
			write_access_out <= "000000000";
      elsif read_enable = '1' then
         read_access_out(index_j) <=  '1';
			write_access_out <= "000000000";
		elsif write_enable = '1' then
         write_access_out(index_j) <=  '1';
			read_access_out <= "000000000";
		else
			read_access_out <= "000000000";
			write_access_out <= "000000000";
      end if;
   end if;
	read_enable_in <= read_access_out;
	write_enable_in <= write_access_out;
end process;

--set_access_outputs : process (clock,reset,read_enable,write_enable) 
--variable read_access_out,write_access_out : std_logic_vector(num_of_ports -1 downto 0);
--begin
--   if clock='1' and clock'event then
--      if reset='1' then 
--         read_access_out := "00000000";
--			write_access_out := "00000000";
--      elsif read_enable = '1' then
--         read_access_out(index_j) :=  '1';
--			write_access_out := "00000000";
--		elsif write_enable = '1' then
--         write_access_out(index_j) :=  '1';
--			read_access_out := "00000000";
--		else
--			read_access_out := "00000000";
--			write_access_out := "00000000";
--      end if;
--   end if;
--	read_enable_in <= read_access_out;
--	write_enable_in <= write_access_out;
--end process;

--set_write_acknowledge_outputs : process (clock,reset,write_enable) 
--variable ack_write_out : std_logic_vector(num_of_ports downto 0);
--begin
--   if clock='1' and clock'event then
--      if reset='1' then 
--         ack_write_out := "000000000";
--		elsif write_enable = '1' then
--         ack_write_out(index_j) :=  '1';
--		else
--			ack_write_out := "000000000";
--      end if;
--   end if;
--	Memory_Access_out.ack_o <= ack_write_out;
--end process;


--access_vector : process (clock) 
----variable cnt : std_logic_vector(5 downto 0);
--begin
--      if reset='1' then 
--         access_count <= (others => '0');
--      elsif inc_count = '1' then
--         access_count <= access_count + 1;
--      end if;
--   end if;
--end process;


arbitration_algorithm: process(CurrentState,request,index_j,index_i,access_count,FIFO_full,FIFO_empty,read_request,write_request,priority_signals)--,Memory_access_in)

   begin
		case (CurrentState) is		
			when reset_state =>
						NextState <= idle_0;
				inc_count <= '0';
				inc_index_i <= '0';
				inc_index_j <= '0';
				clear_index_i <= '0';
				clear_index_j <= '0';
				read_enable <= '0';
				write_enable <= '0';
				
			when idle_0 =>
						NextState <= idle_1;		
				inc_count <= '0';
				inc_index_i <= '0';
				inc_index_j <= '0';
				clear_index_i <= '0';
				clear_index_j <= '0';
				read_enable <= '0';
				write_enable <= '0';
				
			when idle_1 =>
						NextState <= idle_2;		
				inc_count <= '0';
				inc_index_i <= '0';
				inc_index_j <= '0';
				clear_index_i <= '0';
				clear_index_j <= '0';
				read_enable <= '0';
				write_enable <= '0';
				
			when idle_2 =>
						NextState <= idle_3;
				inc_count <= '0';
				inc_index_i <= '0';
				inc_index_j <= '0';
				clear_index_i <= '0';
				clear_index_j <= '0';
				read_enable <= '0';
				write_enable <= '0';
				
			when idle_3 =>
				if(request = "00000000") then
						NextState <= inc_counter;
				else
						NextState <= access_requested;
				end if;
				inc_count <= '0';
				inc_index_i <= '0';
				inc_index_j <= '0';
				clear_index_i <= '0';
				clear_index_j <= '0';
				read_enable <= '0';
				write_enable <= '0';
				
			when inc_counter =>				
						NextState <= idle_0;
				inc_count <= '1';
				inc_index_i <= '0';
				inc_index_j <= '0';
				clear_index_i <= '0';
				clear_index_j <= '0';
				read_enable <= '0';
				write_enable <= '0';
				
------------------------------------------------------------------------------------
-- Access Counter Loop
				
			when access_requested =>
						NextState <= access_requested_check;						
				inc_count <= '0';
				inc_index_i <= '0';
				inc_index_j <= '0';
				clear_index_i <= '0';
				clear_index_j <= '0';
				read_enable <= '0';
				write_enable <= '0';
				
			when access_requested_check =>
			if(access_count(index_i) = '0') then
						NextState <= increment_index_i;
			else
						NextState <= check_request_vector;
			end if;		
				inc_count <= '0';
				inc_index_i <= '0';
				inc_index_j <= '0';
				clear_index_i <= '0';
				clear_index_j <= '0';
				read_enable <= '0';
				write_enable <= '0';
				
			when increment_index_i => 
			if(index_i = 7) then
						NextState <= increment_access_count;
			else
						NextState <= increment_index_i_0;
			end if;
				inc_count <= '0';
				inc_index_i <= '0';
				inc_index_j <= '0';
				clear_index_i <= '0';
				clear_index_j <= '0';
				read_enable <= '0';
				write_enable <= '0';
		
				
			when increment_index_i_0 =>
						NextState <= access_requested_check;				
				inc_count <= '0';
				inc_index_i <= '1';
				inc_index_j <= '0';
				clear_index_i <= '0';
				clear_index_j <= '0';
				read_enable <= '0';
				write_enable <= '0';

-------------------------------------------------------------------------------------
--  Request Vector Loop
			
			when check_request_vector =>
--			if(index_j = 7 AND index_i = 7) then
--						NextState <= increment_access_count;
--			elsif(index_j = 7) then
--						NextState <= pre_clear_index_j;
--			else
						NextState <= check_request_vector_0;
--			end if;		
				inc_count <= '0';
				inc_index_i <= '0';
				inc_index_j <= '0';
				clear_index_i <= '0';
				clear_index_j <= '0';
				read_enable <= '0';
				write_enable <= '0';
				
			when pre_clear_index_j =>
						NextState <= access_requested;
				inc_count <= '0';
				inc_index_i <= '1';
				inc_index_j <= '0';
				clear_index_i <= '0';
				clear_index_j <= '1';
				read_enable <= '0';
				write_enable <= '0';
			
			
			when check_request_vector_0 =>
			if((request(index_j) = '0') AND (index_j = num_of_ports)) then
						NextState <= increment_access_count;
			elsif(request(index_j) = '0') then
						NextState <= increment_index_j;
			else
						NextState <= check_priority;
			end if;		
				inc_count <= '0';
				inc_index_i <= '0';
				inc_index_j <= '0';
				clear_index_i <= '0';
				clear_index_j <= '0';
				read_enable <= '0';
				write_enable <= '0';
				
			when increment_index_j =>
						NextState <= check_request_vector;				
				inc_count <= '0';
				inc_index_i <= '0';
				inc_index_j <= '1';
				clear_index_i <= '0';
				clear_index_j <= '0';
				read_enable <= '0';
				write_enable <= '0';
			
-------------------------------------------------------------------------------------
--  Check Priority

			when check_priority =>
			if(priority_signals(index_j)(index_i) = '1') then
						NextState <= check_access_type;		
			else
						NextState <= check_index_j;
			end if;
				inc_count <= '0';
				inc_index_i <= '0';
				inc_index_j <= '0';
				clear_index_i <= '0';
				clear_index_j <= '0';
				read_enable <= '0';
				write_enable <= '0';
			
			when check_index_j =>
			if(index_j = num_of_ports AND index_i = 7) then 
						NextState <= increment_access_count;
			elsif(index_j = num_of_ports) then 
						NextState <= pre_clear_index_j;
			else
						NextState <= pre_inc_index_j; 
			end if;
				inc_count <= '0';
				inc_index_i <= '0';
				inc_index_j <= '0';
				clear_index_i <= '0';
				clear_index_j <= '0';
				read_enable <= '0';
				write_enable <= '0';
				
			when pre_inc_index_j =>
						NextState <= check_request_vector;
				inc_count <= '0';
				inc_index_i <= '0';
				inc_index_j <= '1';
				clear_index_i <= '0';
				clear_index_j <= '0';
				read_enable <= '0';
				write_enable <= '0';
				
			

----------------------------------------------------------------------------------------
--  Check Access Type
			
			when check_access_type =>
						NextState <= check_access_type_1;
				inc_count <= '0';
				inc_index_i <= '0';
				inc_index_j <= '0';
				clear_index_i <= '0';
				clear_index_j <= '0';
				read_enable <= '0';
				write_enable <= '0';
				
				
			
		when check_access_type_1 =>
						NextState <= check_access_type_2;
				inc_count <= '0';
				inc_index_i <= '0';
				inc_index_j <= '0';
				clear_index_i <= '0';
				clear_index_j <= '0';
				read_enable <= '0';
				write_enable <= '0';
				
			when check_access_type_2 =>
						NextState <= check_access_type_3;
				inc_count <= '0';
				inc_index_i <= '0';
				inc_index_j <= '0';
				clear_index_i <= '0';
				clear_index_j <= '0';
				read_enable <= '0';
				write_enable <= '0';
			
			
			
			
			when check_access_type_3 =>
			if(FIFO_full = '1') then
						NextState <= check_access_type_3;
			elsif(write_request(index_j) = '1') then
						NextState <= grant_write_access;
			else
						NextState <= grant_read_access;
			end if;
				inc_count <= '0';
				inc_index_i <= '0';
				inc_index_j <= '0';
				clear_index_i <= '0';
				clear_index_j <= '0';
				read_enable <= '0';
				write_enable <= '0';

----------------------------------------------------------------------------------------
--  Grant Access
			
--			when grant_write_access =>
--				if(FIFO_empty = '1' AND burst_full(index_j) = '1') then
--						NextState <= grant_write_access_1;
--				else
--						NextState <= grant_write_access;
--				end if;
--				inc_count <= '0';
--				inc_index_i <= '0';
--				inc_index_j <= '0';
--				clear_index_i <= '0';
--				clear_index_j <= '0';
--				read_enable <= '0';
--				write_enable <= '0';
				
			when grant_write_access =>
				if(FIFO_empty = '1') then
						NextState <= grant_write_access_1;
				else
						NextState <= grant_write_access;
				end if;
				inc_count <= '0';
				inc_index_i <= '0';
				inc_index_j <= '0';
				clear_index_i <= '0';
				clear_index_j <= '0';
				read_enable <= '0';
				write_enable <= '0';
			
			when grant_write_access_1 =>
						NextState <= check_i_j;		
				inc_count <= '0';
				inc_index_i <= '0';
				inc_index_j <= '0';
				clear_index_i <= '0';
				clear_index_j <= '0';
				read_enable <= '0';
				write_enable <= '1';
	
			
			when grant_read_access =>
						NextState <= check_i_j;		
				inc_count <= '0';
				inc_index_i <= '0';
				inc_index_j <= '0';
				clear_index_i <= '0';
				clear_index_j <= '0';
				read_enable <= '1';
				write_enable <= '0';
			
			when check_i_j =>
			if(index_i = 7 AND index_j = num_of_ports) then 
						NextState <= increment_access_count;
			elsif(index_j = num_of_ports) then
						NextState <= clear_j;
			else
						NextState <= increment_req_index_i;
			end if;
			
				inc_count <= '0';
				inc_index_i <= '0';
				inc_index_j <= '0';
				clear_index_i <= '0';
				clear_index_j <= '0';
				read_enable <= '0';
				write_enable <= '0';
			
			
			when increment_req_index_i =>
						NextState <= access_requested;		
				inc_count <= '0';
				inc_index_i <= '0';
				inc_index_j <= '1';
				clear_index_i <= '0';
				clear_index_j <= '0';
				read_enable <= '0';
				write_enable <= '0';
			
			
			when clear_j =>
						NextState <= access_requested;		
				inc_count <= '0';
				inc_index_i <= '1';
				inc_index_j <= '0';
				clear_index_i <= '0';
				clear_index_j <= '1';
				read_enable <= '0';
				write_enable <= '0';

			
			
			when increment_access_count =>
						NextState <= reset_state;
				inc_count <= '1';
				inc_index_i <= '0';
				inc_index_j <= '0';
				clear_index_i <= '1';
				clear_index_j <= '1';
				read_enable <= '0';
				write_enable <= '0';
			
			
			when others =>
						NextState <= reset_state;
				inc_count <= '0';
				inc_index_i <= '0';
				inc_index_j <= '0';
				clear_index_i <= '0';
				clear_index_j <= '0';
				read_enable <= '0';
				write_enable <= '0';
			end case;
	end process Arbitration_algorithm;
	
	nextstatelogic: process
	begin
			wait until clock'EVENT and clock = '1'; --WAIT FOR RISING EDGE
			-- INITIALIZATION
			if (Reset = '1') then
				CurrentState <= reset_state;
			else
       				CurrentState <= NextState;
			end if;
end process nextstatelogic;
end Behavioral;



--			when access_requested_check =>
--			if((request(index_i) = '1')  AND Memory_Access_in.priority_i(index_j)(index_k) = access_count(index_i)) then
--						NextState <= idle_0;
--			else
--						NextState <= idle_0;
--			end if;
--						
--				inc_count <= '1';