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
-- Module Name: Burst_write_data_fetcher - Behavioral 
-- Project Name: Wizardry
-- Target Devices: Virtex 4 ML401
-- Description: Behavioral description for writing data to memory.
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

entity burst_data_fetch is
    Port ( 	reset : in std_logic;
				clock : in  STD_LOGIC;
				buffer_empty : in  STD_LOGIC_VECTOR (num_of_ports downto 0);
				write_enable_in : in  STD_LOGIC_VECTOR (num_of_ports downto 0);
				pop_o : out  STD_LOGIC_VECTOR (num_of_ports downto 0);
				burst_write_enable : out STD_LOGIC_VECTOR (num_of_ports downto 0);
				reset_pop_count : out STD_LOGIC_VECTOR (num_of_ports downto 0)
				);
end burst_data_fetch;

architecture Behavioral of burst_data_fetch is
type StateType is (reset_state,idle_0,enable_burst_write,pop_0,wait_0,clear_pop_count);
signal CurrentState,NextState: StateType;
signal index_i : integer range 0 to num_of_ports;
signal pop_s : STD_LOGIC_VECTOR (num_of_ports downto 0);	
signal count : integer range 0 to burst_length;
signal inc_count,reset_count,stop : std_logic;
begin

store_index_value : process(clock,write_enable_in) --(clock,store_index) --reset_index,store_index)
--variable index_i_v_v : integer range 0 to num_of_ports;
--variable read_enable_in_v : STD_LOGIC_VECTOR (num_of_ports -1 downto 0);
begin
--	if(clock'event and clock = '1') then
	if(rising_edge(clock)) then
		if(reset = '1') then
			index_i <= 0;
			pop_s <= "000000000";
		elsif(write_enable_in = "000000001") then
			index_i <= 0;
			pop_s <= "000000001";
		elsif(write_enable_in = "000000010") then
			index_i <= 1;
			pop_s <= "000000010";
		elsif(write_enable_in = "000000100") then
			index_i <= 2;
			pop_s <= "000000100";
		elsif(write_enable_in = "000001000") then
			index_i <= 3;
			pop_s <= "000001000";
		elsif(write_enable_in = "000010000") then
			index_i <= 4;
			pop_s <= "000010000";
		elsif(write_enable_in = "000100000") then
			index_i <= 5;
			pop_s <= "000100000";
		elsif(write_enable_in = "001000000") then
			index_i <= 6;
			pop_s <= "001000000";
		elsif(write_enable_in = "010000000") then
			index_i <= 7;
			pop_s <= "010000000";
		elsif(write_enable_in = "100000000") then
			index_i <= 8;
			pop_s <= "100000000";
		else
			index_i <= index_i;
			pop_s <= pop_s;
		end if;
	end if;
end process;

counter : process(clock,inc_count) --(clock,store_index) --reset_index,store_index)
--variable index_i_v_v : integer range 0 to num_of_ports;
--variable read_enable_in_v : STD_LOGIC_VECTOR (num_of_ports -1 downto 0);
begin
--	if(clock'event and clock = '1') then
	if(rising_edge(clock)) then
		if(reset_count = '1') then
			count <= 0;
		elsif(inc_count = '0') then
			count <= count;
		elsif(inc_count = '1') then
			count <= count + 1;
		else
			count <= count;
		end if;
	end if;
end process;

burst_access_process: process(CurrentState,write_enable_in,stop,pop_s)--,Memory_access_in)
variable index_i : integer;
   begin
		case (CurrentState) is		
			when reset_state =>
					NextState <= idle_0;
					
				reset_count <= '1';		
				pop_o <= "000000000";
				inc_count <= '0';
				burst_write_enable <= "000000000";
				reset_pop_count <= (others => '0');
				
			when idle_0 =>
				if(write_enable_in = "000000000") then
					NextState <= idle_0;
				else
					NextState <= enable_burst_write;
				end if;
				
				reset_count <= '0';
				pop_o <= "000000000";
				inc_count <= '0';
				burst_write_enable <= "000000000";
				reset_pop_count <= (others => '0');
				
			
			when enable_burst_write =>			
						NextState <= wait_0;
						
				reset_count <= '0';
				pop_o <= pop_s;
				inc_count <= '1';
				burst_write_enable <= pop_s;
				reset_pop_count <= (others => '0');
			
--			when pop_0 =>			
--						NextState <= wait_0;
--						
--				reset_count <= '0';
--				pop_o <= pop_s;
--				inc_count <= '1';
--				burst_write_enable <= "000000000";
				
			when wait_0 =>	
				if(stop = '1') then
						NextState <= clear_pop_count;
				else
						NextState <= enable_burst_write;
				end if;
				
				reset_count <= '0';
				pop_o <= "000000000";
				inc_count <= '0';
				burst_write_enable <= "000000000";
				reset_pop_count <= (others => '0');
				
			when clear_pop_count =>	
						NextState <= reset_state;

				reset_count <= '0';
				pop_o <= "000000000";
				inc_count <= '0';
				burst_write_enable <= "000000000";
				reset_pop_count <= pop_s;
				
			when others =>
						NextState <= reset_state;
				
				reset_count <= '0';				
				pop_o <= "000000000";
				inc_count <= '0';
				burst_write_enable <= "000000000";
				reset_pop_count <= (others => '0');
			end case;
	end process burst_access_process;
	
	nextstatelogic: process
	begin
			wait until clock'EVENT and clock = '1'; --WAIT FOR RISING EDGE
			if (Reset = '1') then
				CurrentState <= reset_state;
			else
       				CurrentState <= NextState;
			end if;
end process nextstatelogic;

stop <=  '1'when buffer_empty(index_i) = '1' else '0';

end Behavioral;

