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
-- Module Name: store_count_data - Behavioral 
-- Project Name: Wizardry
-- Target Devices: Virtex 4 ML401
-- Description: Stores count values for each eRCP counter. (up to 32)
-- Revision: 1.0
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.eRCP_Constants.ALL;
use work.MAC_Constants.all;
use work.port_block_constants.all;

--library UNISIM;
--use UNISIM.VComponents.all;
 
entity match_store is
  port ( Reset : in std_logic;
			Clock : in std_logic;
			match_counts : in  counter_interface;
			statistics_interface : in statistical_interface;
--			boot_index : std_logic_vector(127 downto 0);
			---WB Signals
			adr_o	 	:     out std_logic_vector(virtual_address_width -1 downto 0);
			dat_o	 	:     out std_logic_vector(data_width -1 downto 0);
			we_o	 	:     out std_logic;
			sel_o	 	:     out std_logic_vector(data_resolution -1 downto 0);
			stb_o	 	:     out std_logic;
			cyc_o	 	:     out std_logic;
			ID_o	 	:     out std_logic_vector(ID_width -1 downto 0);
			priority_o :   out std_logic_vector(priority_width -1 downto 0);
			lock_o   :  	out std_logic;			
			err_i	 	:     in std_logic;
			ack_i	 	:     in std_logic
--			busy : out boolean      
			);  
end match_store;

architecture RTL of match_store is

     type StateType is (reset_state, reset_count,reset_count_wait,register_count,register_count_0,
		store_count,store_count_0,wait_acknowledge, increment_pointer, check_pointer
--		, to_primitive_ram,to_primitive_ram_inc_ptr,
--		to_primitive_ram_check_ptr
		
--		store_count_2,wait_acknowledge_2,  store_count_3,wait_acknowledge_3,
--		store_count_4,wait_acknowledge_4, store_count_5,wait_acknowledge_5,  store_count_6,wait_acknowledge_6,
--		store_count_7,wait_acknowledge_7, store_count_8,wait_acknowledge_8
			

			
			
			);
			
signal CurrentState,NextState: StateType;   
signal count_s : std_logic_vector(8 downto 0);
signal count_internal : counter_interface;
signal cnt_rst,reg_cnt : std_logic;

--signal pointer_hex : std_logic_vector(6 downto 0); -- integer range 0 to 95;
signal pointer_s : integer range 0 to 32; --std_logic_vector(6 downto 0); -- integer range 0 to 95;
signal inc_ptr : std_logic;
signal store_ram, ram_we : std_logic;
signal ram_reg_out,ram_reg_out_s,ram_reg_in : std_logic_vector(31 downto 0);
signal clr_ptr : std_logic;
	  
begin
priority_o <= "00000001";
ID_o	 	<= ID_eRCP0_SHARED(4 downto 0);--"00001";
lock_o <= '0';
	
	process(pointer_s,count_internal,statistics_interface)
	begin
		case (pointer_s) is				
			when 0 => ram_reg_out <= count_internal.count_0;
			when 1 => ram_reg_out <= count_internal.count_1;
			when 2 => ram_reg_out <= count_internal.count_2;
			when 3 => ram_reg_out <= count_internal.count_3;
			when 4 => ram_reg_out <= count_internal.count_4;
			when 5 => ram_reg_out <= count_internal.count_5;
			when 6 => ram_reg_out <= count_internal.count_6;
			when 7 => ram_reg_out <= count_internal.count_7;
			when 8 => ram_reg_out <= count_internal.count_8;
			when 9 => ram_reg_out <= count_internal.count_9;
			when 10 => ram_reg_out <= count_internal.count_10;
			when 11 => ram_reg_out <= count_internal.count_11;
			when 12 => ram_reg_out <= count_internal.count_12;
			when 13 => ram_reg_out <= count_internal.count_13;
			when 14 => ram_reg_out <= count_internal.count_14;
			when 15 => ram_reg_out <= count_internal.count_15;
			when 16 => ram_reg_out <= count_internal.count_16;
			when 17 => ram_reg_out <= count_internal.count_17;
			when 18 => ram_reg_out <= count_internal.count_18;
			when 19 => ram_reg_out <= count_internal.count_19;
			when 20 => ram_reg_out <= count_internal.count_20;
			when 21 => ram_reg_out <= count_internal.count_21;
			when 22 => ram_reg_out <= count_internal.count_22;
			when 23 => ram_reg_out <= count_internal.count_23;
			when 24 => ram_reg_out <= count_internal.count_24;
			when 25 => ram_reg_out <= count_internal.count_25;
			when 26 => ram_reg_out <= count_internal.count_26;
			when 27 => ram_reg_out <= count_internal.count_27;
			when 28 => ram_reg_out <= count_internal.count_28;
			when 29 => ram_reg_out <=  X"000000" & "000" & statistics_interface.available_LU; --count_internal.count_29;
			when 30 => ram_reg_out <= X"000000" & "000" & statistics_interface.available_CE; --count_internal.count_30;
			when 31 => ram_reg_out <= X"000000" & "000" & statistics_interface.available_CmpE;
				--count_internal.count_31;
				
--			when 32 => ram_reg_out <= count_internal.count_a_0;
--			when 33 => ram_reg_out <= count_internal.count_a_1;
--			when 34 => ram_reg_out <= count_internal.count_a_2;
--			when 35 => ram_reg_out <= count_internal.count_a_3;
--			when 36 => ram_reg_out <= count_internal.count_a_4;
--			when 37 => ram_reg_out <= count_internal.count_a_5;
--			when 38 => ram_reg_out <= count_internal.count_a_6;
--			when 39 => ram_reg_out <= count_internal.count_a_7;
--			when 40 => ram_reg_out <= count_internal.count_a_8;
--			when 41 => ram_reg_out <= count_internal.count_a_9;
--			when 42 => ram_reg_out <= count_internal.count_a_10;
--			when 43 => ram_reg_out <= count_internal.count_a_11;
--			when 44 => ram_reg_out <= count_internal.count_a_12;
--			when 45 => ram_reg_out <= count_internal.count_a_13;
--			when 46 => ram_reg_out <= count_internal.count_a_14;
--			when 47 => ram_reg_out <= count_internal.count_a_15;
--			when 48 => ram_reg_out <= count_internal.count_a_16;
--			when 49 => ram_reg_out <= count_internal.count_a_17;
--			when 50 => ram_reg_out <= count_internal.count_a_18;
--			when 51 => ram_reg_out <= count_internal.count_a_19;
--			when 52 => ram_reg_out <= count_internal.count_a_20;
--			when 53 => ram_reg_out <= count_internal.count_a_21;
--			when 54 => ram_reg_out <= count_internal.count_a_22;
--			when 55 => ram_reg_out <= count_internal.count_a_23;
--			when 56 => ram_reg_out <= count_internal.count_a_24;
--			when 57 => ram_reg_out <= count_internal.count_a_25;
--			when 58 => ram_reg_out <= count_internal.count_a_26;
--			when 59 => ram_reg_out <= count_internal.count_a_27;
--			when 60 => ram_reg_out <= count_internal.count_a_28;
--			when 61 => ram_reg_out <= count_internal.count_a_29;
--			when 62 => ram_reg_out <= count_internal.count_a_30;
--			when 63 => ram_reg_out <= count_internal.count_a_31;
--			when 64 => ram_reg_out <= count_internal.count_b_0;
--			when 65 => ram_reg_out <= count_internal.count_b_1;
--			when 66 => ram_reg_out <= count_internal.count_b_2;
--			when 67 => ram_reg_out <= count_internal.count_b_3;
--			when 68 => ram_reg_out <= count_internal.count_b_4;
--			when 69 => ram_reg_out <= count_internal.count_b_5;
--			when 70 => ram_reg_out <= count_internal.count_b_6;
--			when 71 => ram_reg_out <= count_internal.count_b_7;
--			when 72 => ram_reg_out <= count_internal.count_b_8;
--			when 73 => ram_reg_out <= count_internal.count_b_9;
--			when 74 => ram_reg_out <= count_internal.count_b_10;
--			when 75 => ram_reg_out <= count_internal.count_b_11;
--			when 76 => ram_reg_out <= count_internal.count_b_12;
--			when 77 => ram_reg_out <= count_internal.count_b_13;
--			when 78 => ram_reg_out <= count_internal.count_b_14;
--			when 79 => ram_reg_out <= count_internal.count_b_15;
--			when 80 => ram_reg_out <= count_internal.count_b_16;
--			when 81 => ram_reg_out <= count_internal.count_b_17;
--			when 82 => ram_reg_out <= count_internal.count_b_18;
--			when 83 => ram_reg_out <= count_internal.count_b_19;
--			when 84 => ram_reg_out <= count_internal.count_b_20;
--			when 85 => ram_reg_out <= count_internal.count_b_21;
--			when 86 => ram_reg_out <= count_internal.count_b_22;
--			when 87 => ram_reg_out <= count_internal.count_b_23;
--			when 88 => ram_reg_out <= count_internal.count_b_24;
--			when 89 => ram_reg_out <= count_internal.count_b_25;
--			when 90 => ram_reg_out <= count_internal.count_b_26;
--			when 91 => ram_reg_out <= count_internal.count_b_27;
--			when 92 => ram_reg_out <= count_internal.count_b_28;
--			when 93 => ram_reg_out <= count_internal.count_b_29;
--			when 94 => ram_reg_out <= count_internal.count_b_30;
--			when 95 => ram_reg_out <= count_internal.count_b_31;
--			
			when others => ram_reg_out <= count_internal.count_0;
		end case;
	end process;
	
	process(reset,clock,inc_ptr)
--	variable pointer_v : integer range 0 to 95;
	begin
		if(reset = '1') then
--			pointer_v := 0;
			pointer_s <= 0;
		elsif(rising_edge(clock)) then
			if(inc_ptr = '1') then
--				pointer_v := pointer_v + 1;
				pointer_s <= pointer_s + 1;
			elsif(clr_ptr = '1') then
--				pointer_v := 0;
				pointer_s <= 0;
			else
--				pointer_v := pointer_v;
				pointer_s <= pointer_s;
			end if;
		end if;
--		pointer_s <= pointer_v;
--		pointer_hex <= conv_std_logic_vector(pointer_v,7);
	end process;
	
--	process(pointer_s,count_internal)
--	begin
--		case (pointer_s) is				
--			when 0 => ram_reg_out <= count_internal.count_0;
--			when 1 => ram_reg_out <= count_internal.count_1;
--			when 2 => ram_reg_out <= count_internal.count_2;
--			when 3 => ram_reg_out <= count_internal.count_3;
--			when 4 => ram_reg_out <= count_internal.count_4;
--			when 5 => ram_reg_out <= count_internal.count_5;
--			when 6 => ram_reg_out <= count_internal.count_6;
--			when 7 => ram_reg_out <= count_internal.count_7;
--			when 8 => ram_reg_out <= count_internal.count_8;
--			when 9 => ram_reg_out <= count_internal.count_9;
--			when 10 => ram_reg_out <= count_internal.count_10;
--			when 11 => ram_reg_out <= count_internal.count_11;
--			when 12 => ram_reg_out <= count_internal.count_12;
--			when 13 => ram_reg_out <= count_internal.count_13;
--			when 14 => ram_reg_out <= count_internal.count_14;
--			when 15 => ram_reg_out <= count_internal.count_15;
--			when 16 => ram_reg_out <= count_internal.count_16;
--			when 17 => ram_reg_out <= count_internal.count_17;
--			when 18 => ram_reg_out <= count_internal.count_18;
--			when 19 => ram_reg_out <= count_internal.count_29;
--			when 20 => ram_reg_out <= count_internal.count_20;
--			when 21 => ram_reg_out <= count_internal.count_21;
--			when 22 => ram_reg_out <= count_internal.count_22;
--			when 23 => ram_reg_out <= count_internal.count_23;
--			when 24 => ram_reg_out <= count_internal.count_24;
--			when 25 => ram_reg_out <= count_internal.count_25;
--			when 26 => ram_reg_out <= count_internal.count_26;
--			when 27 => ram_reg_out <= count_internal.count_27;
--			when 28 => ram_reg_out <= count_internal.count_28;
--			when 29 => ram_reg_out <= count_internal.count_29;
--			when 30 => ram_reg_out <= count_internal.count_30;
--			when 31 => ram_reg_out <= count_internal.count_31;
--			when 32 => ram_reg_out <= count_internal.count_a_0;
--			when 33 => ram_reg_out <= count_internal.count_a_1;
--			when 34 => ram_reg_out <= count_internal.count_a_2;
--			when 35 => ram_reg_out <= count_internal.count_a_3;
--			when 36 => ram_reg_out <= count_internal.count_a_4;
--			when 37 => ram_reg_out <= count_internal.count_a_5;
--			when 38 => ram_reg_out <= count_internal.count_a_6;
--			when 39 => ram_reg_out <= count_internal.count_a_7;
--			when 40 => ram_reg_out <= count_internal.count_a_8;
--			when 41 => ram_reg_out <= count_internal.count_a_9;
--			when 42 => ram_reg_out <= count_internal.count_a_10;
--			when 43 => ram_reg_out <= count_internal.count_a_11;
--			when 44 => ram_reg_out <= count_internal.count_a_12;
--			when 45 => ram_reg_out <= count_internal.count_a_13;
--			when 46 => ram_reg_out <= count_internal.count_a_14;
--			when 47 => ram_reg_out <= count_internal.count_a_15;
--			when 48 => ram_reg_out <= count_internal.count_a_16;
--			when 49 => ram_reg_out <= count_internal.count_a_17;
--			when 50 => ram_reg_out <= count_internal.count_a_18;
--			when 51 => ram_reg_out <= count_internal.count_a_19;
--			when 52 => ram_reg_out <= count_internal.count_a_20;
--			when 53 => ram_reg_out <= count_internal.count_a_21;
--			when 54 => ram_reg_out <= count_internal.count_a_22;
--			when 55 => ram_reg_out <= count_internal.count_a_23;
--			when 56 => ram_reg_out <= count_internal.count_a_24;
--			when 57 => ram_reg_out <= count_internal.count_a_25;
--			when 58 => ram_reg_out <= count_internal.count_a_26;
--			when 59 => ram_reg_out <= count_internal.count_a_27;
--			when 60 => ram_reg_out <= count_internal.count_a_28;
--			when 61 => ram_reg_out <= count_internal.count_a_29;
--			when 62 => ram_reg_out <= count_internal.count_a_30;
--			when 63 => ram_reg_out <= count_internal.count_b_31;
--			when 64 => ram_reg_out <= count_internal.count_b_0;
--			when 65 => ram_reg_out <= count_internal.count_b_1;
--			when 66 => ram_reg_out <= count_internal.count_b_2;
--			when 67 => ram_reg_out <= count_internal.count_b_3;
--			when 68 => ram_reg_out <= count_internal.count_b_4;
--			when 69 => ram_reg_out <= count_internal.count_b_5;
--			when 70 => ram_reg_out <= count_internal.count_b_6;
--			when 71 => ram_reg_out <= count_internal.count_b_7;
--			when 72 => ram_reg_out <= count_internal.count_b_8;
--			when 73 => ram_reg_out <= count_internal.count_b_9;
--			when 74 => ram_reg_out <= count_internal.count_b_10;
--			when 75 => ram_reg_out <= count_internal.count_b_11;
--			when 76 => ram_reg_out <= count_internal.count_b_12;
--			when 77 => ram_reg_out <= count_internal.count_b_13;
--			when 78 => ram_reg_out <= count_internal.count_b_14;
--			when 79 => ram_reg_out <= count_internal.count_b_15;
--			when 80 => ram_reg_out <= count_internal.count_b_16;
--			when 81 => ram_reg_out <= count_internal.count_b_17;
--			when 82 => ram_reg_out <= count_internal.count_b_18;
--			when 83 => ram_reg_out <= count_internal.count_b_19;
--			when 84 => ram_reg_out <= count_internal.count_b_20;
--			when 85 => ram_reg_out <= count_internal.count_b_21;
--			when 86 => ram_reg_out <= count_internal.count_b_22;
--			when 87 => ram_reg_out <= count_internal.count_b_23;
--			when 88 => ram_reg_out <= count_internal.count_b_24;
--			when 89 => ram_reg_out <= count_internal.count_b_25;
--			when 90 => ram_reg_out <= count_internal.count_b_26;
--			when 91 => ram_reg_out <= count_internal.count_b_27;
--			when 92 => ram_reg_out <= count_internal.count_b_28;
--			when 93 => ram_reg_out <= count_internal.count_b_29;
--			when 94 => ram_reg_out <= count_internal.count_b_30;
--			when 95 => ram_reg_out <= count_internal.count_b_31;
--			
--			when others => ram_reg_out <= (others => '0');
--		end case;
----			end if;
----		else
----			ram_reg_out <= ram_reg_out;
----		end if;
--	end process;
	
	process(clock,reset,ram_reg_out)
	begin
		if(reset = '1') then
			ram_reg_out_s  <= (others => '0');
		elsif(rising_edge(clock)) then
			if(store_ram = '1') then
				ram_reg_out_s <= ram_reg_out;
			end if;
		end if;
	end process;
	
	refresh_count : process(clock,reset,cnt_rst,count_s)
	begin
	if(cnt_rst = '0') then
		count_s <= (others => '0');
	elsif(rising_edge(clock)) then
		if(cnt_rst = '1') then
			count_s <= count_s + 1;
		end if;
	end if;
	end process refresh_count;
		
	register_counters : process(clock,reset,reg_cnt,match_counts)
--	variable count_internal_v : counter_interface;
--	variable match_count_array : match_counters_array_type;
	begin
	if(reset = '1') then
--		for i in 0 to 95 loop
--			count_internal <= (others => '0');
--		end loop;
	elsif(rising_edge(clock)) then
		if(reg_cnt = '1') then
			count_internal.count_0 <= match_counts.count_0;
			count_internal.count_1 <= match_counts.count_1;
			count_internal.count_2 <= match_counts.count_2;
			count_internal.count_3 <= match_counts.count_3;
			count_internal.count_4 <= match_counts.count_4;
			count_internal.count_5 <= match_counts.count_5;
			count_internal.count_6 <= match_counts.count_6;
			count_internal.count_7 <= match_counts.count_7;
			count_internal.count_8 <= match_counts.count_8;
			count_internal.count_9 <= match_counts.count_9;
			count_internal.count_10 <= match_counts.count_10;
			count_internal.count_11 <= match_counts.count_11;
			count_internal.count_12 <= match_counts.count_12;
			count_internal.count_13 <= match_counts.count_13;
			count_internal.count_14 <= match_counts.count_14;
			count_internal.count_15 <= match_counts.count_15;
			count_internal.count_16 <= match_counts.count_16;
			count_internal.count_17 <= match_counts.count_17;
			count_internal.count_18 <= match_counts.count_18;
			count_internal.count_19 <= match_counts.count_19;
			count_internal.count_20 <= match_counts.count_20;
			count_internal.count_21 <= match_counts.count_21;
			count_internal.count_22 <= match_counts.count_22;
			count_internal.count_23 <= match_counts.count_23;
			count_internal.count_24 <= match_counts.count_24;
			count_internal.count_25 <= match_counts.count_25;
			count_internal.count_26 <= match_counts.count_26;
			count_internal.count_27 <= match_counts.count_27;
			count_internal.count_28 <= match_counts.count_28;
			count_internal.count_29 <= match_counts.count_29;
			count_internal.count_30 <= match_counts.count_30;
			count_internal.count_31 <= match_counts.count_31;
			count_internal.count_a_0 <= match_counts.count_a_0;
			count_internal.count_a_1 <= match_counts.count_a_1;
			count_internal.count_a_2 <= match_counts.count_a_2;
			count_internal.count_a_3 <= match_counts.count_a_3;
			count_internal.count_a_4 <= match_counts.count_a_4;
			count_internal.count_a_5 <= match_counts.count_a_5;
			count_internal.count_a_6 <= match_counts.count_a_6;
			count_internal.count_a_7 <= match_counts.count_a_7;
			count_internal.count_a_8 <= match_counts.count_a_8;
			count_internal.count_a_9 <= match_counts.count_a_9;
			count_internal.count_a_10 <= match_counts.count_a_10;
			count_internal.count_a_11 <= match_counts.count_a_11;
			count_internal.count_a_12 <= match_counts.count_a_12;
			count_internal.count_a_13 <= match_counts.count_a_13;
			count_internal.count_a_14 <= match_counts.count_a_14;
			count_internal.count_a_15 <= match_counts.count_a_15;
			count_internal.count_a_16 <= match_counts.count_a_16;
			count_internal.count_a_17 <= match_counts.count_a_17;
			count_internal.count_a_18 <= match_counts.count_a_18;
			count_internal.count_a_19 <= match_counts.count_a_19;
			count_internal.count_a_20 <= match_counts.count_a_20;
			count_internal.count_a_21 <= match_counts.count_a_21;
			count_internal.count_a_22 <= match_counts.count_a_22;
			count_internal.count_a_23 <= match_counts.count_a_23;
			count_internal.count_a_24 <= match_counts.count_a_24;
			count_internal.count_a_25 <= match_counts.count_a_25;
			count_internal.count_a_26 <= match_counts.count_a_26;
			count_internal.count_a_27 <= match_counts.count_a_27;
			count_internal.count_a_28 <= match_counts.count_a_28;
			count_internal.count_a_29 <= match_counts.count_a_29;
			count_internal.count_a_30 <= match_counts.count_a_30;
			count_internal.count_a_31 <= match_counts.count_a_31;
			count_internal.count_b_0 <= match_counts.count_b_0;
			count_internal.count_b_1 <= match_counts.count_b_1;
			count_internal.count_b_2 <= match_counts.count_b_2;
			count_internal.count_b_3 <= match_counts.count_b_3;
			count_internal.count_b_4 <= match_counts.count_b_4;
			count_internal.count_b_5 <= match_counts.count_b_5;
			count_internal.count_b_6 <= match_counts.count_b_6;
			count_internal.count_b_7 <= match_counts.count_b_7;
			count_internal.count_b_8 <= match_counts.count_b_8;
			count_internal.count_b_9 <= match_counts.count_b_9;
			count_internal.count_b_10 <= match_counts.count_b_10;
			count_internal.count_b_11 <= match_counts.count_b_11;
			count_internal.count_b_12 <= match_counts.count_b_12;
			count_internal.count_b_13 <= match_counts.count_b_13;
			count_internal.count_b_14 <= match_counts.count_b_14;
			count_internal.count_b_15 <= match_counts.count_b_15;
			count_internal.count_b_16 <= match_counts.count_b_16;
			count_internal.count_b_17 <= match_counts.count_b_17;
			count_internal.count_b_18 <= match_counts.count_b_18;
			count_internal.count_b_19 <= match_counts.count_b_19;
			count_internal.count_b_20 <= match_counts.count_b_20;
			count_internal.count_b_21 <= match_counts.count_b_21;
			count_internal.count_b_22 <= match_counts.count_b_22;
			count_internal.count_b_23 <= match_counts.count_b_23;
			count_internal.count_b_24 <= match_counts.count_b_24;
			count_internal.count_b_25 <= match_counts.count_b_25;
			count_internal.count_b_26 <= match_counts.count_b_26;
			count_internal.count_b_27 <= match_counts.count_b_27;
			count_internal.count_b_28 <= match_counts.count_b_28;
			count_internal.count_b_29 <= match_counts.count_b_29;
			count_internal.count_b_30 <= match_counts.count_b_30;
			count_internal.count_b_31 <= match_counts.count_b_31;
		else
			count_internal <= count_internal;
		end if;
	end if;
	end process register_counters;
	
	
   FSM: process(CurrentState, count_s,ack_i,pointer_s,ram_reg_out_s,ram_reg_out) --count_internal)
   
   begin

		case (CurrentState) is
		
			when reset_state =>
					NextState <= reset_count;
			
			reg_cnt 	<= '0';
			cnt_rst 	<= '0';
			adr_o	 	<= (others => '0');
			dat_o	 	<= (others => '0');
			we_o	 	<= '0';
			sel_o	 	<= (others => '0');
			stb_o	 	<= '0';
			cyc_o	 	<= '0';
			lock_o   <= '0';
			inc_ptr	<= '0';
			store_ram <= '0';
			ram_we    <= '0';
			clr_ptr <= '0';
			
			when reset_count =>
					NextState <= reset_count_wait;
			
			reg_cnt 	<= '0';
			cnt_rst 	<= '0';
			adr_o	 	<= (others => '0');
			dat_o	 	<= (others => '0');
			we_o	 	<= '0';
			sel_o	 	<= (others => '0');
			stb_o	 	<= '0';
			cyc_o	 	<= '0';
			lock_o   <= '0';
			inc_ptr	<= '0';
			store_ram <= '0';
			ram_we    <= '0';
			clr_ptr <= '1';
			
			when reset_count_wait =>
				if(count_s = "000000000") then
					NextState <= register_count;
				else
					NextState <= reset_count_wait;
				end if;
						
			cnt_rst 	<= '1';
			reg_cnt 	<= '0';
			adr_o	 	<= (others => '0');
			dat_o	 	<= (others => '0');
			we_o	 	<= '0';
			sel_o	 	<= (others => '0');
			stb_o	 	<= '0';
			cyc_o	 	<= '0';
			lock_o   <= '0';
			inc_ptr	<= '0';
			store_ram <= '0';
			ram_we    <= '0';
			clr_ptr <= '0';
			
			when register_count =>
					NextState <= register_count_0;	
			
			cnt_rst 	<= '0';
			reg_cnt 	<= '1';
			adr_o	 	<= (others => '0');
			dat_o	 	<= (others => '0');
			we_o	 	<= '0';
			sel_o	 	<= (others => '0');
			stb_o	 	<= '0';
			cyc_o	 	<= '0';
			lock_o   <= '0';
			inc_ptr	<= '0';
			store_ram <= '0';
			ram_we    <= '0';
			clr_ptr <= '0';
			
			when register_count_0 =>
					NextState <= store_count_0;	
			
			cnt_rst 	<= '0';
			reg_cnt 	<= '0';
			adr_o	 	<= (others => '0');
			dat_o	 	<= (others => '0');
			we_o	 	<= '0';
			sel_o	 	<= (others => '0');
			stb_o	 	<= '0';
			cyc_o	 	<= '0';
			lock_o   <= '0';
			inc_ptr	<= '0';
			store_ram <= '1';
			ram_we    <= '0';
			clr_ptr <= '0';
			
---- NEW CHANGE 4-17-08						
-- SIMPLE EXPRESSION 0			
			when store_count_0 =>
					NextState <= store_count;
									
			cnt_rst 	<= '0';
			reg_cnt 	<= '0';
			adr_o	 	<= (others => '0'); --
			dat_o	 	<= (others => '0'); --
			we_o	 	<= '0';
			sel_o	 	<= (others => '0');
			stb_o	 	<= '0';
			cyc_o	 	<= '0';
			lock_o   <= '0';
			inc_ptr	<= '0';
			store_ram <= '0';
			ram_we    <= '0';
			clr_ptr <= '1';
			
			when store_count =>
					NextState <= wait_acknowledge;
									
			cnt_rst 	<= '0';
			reg_cnt 	<= '0';
			adr_o	 	<= "011011000000000" & conv_std_logic_vector(pointer_s,7);
			dat_o	 	<= ram_reg_out; --match_count_array_s(pointer_s);  --count_internal.count_0;
			we_o	 	<= '1';
			sel_o	 	<= (others => '0');
			stb_o	 	<= '1';
			cyc_o	 	<= '1';
			lock_o   <= '0';
			inc_ptr	<= '0';
			store_ram <= '0';
			ram_we    <= '0';
			clr_ptr <= '0';
			
			when wait_acknowledge =>
				if(ack_i = '1') then
					NextState <= increment_pointer;
				else
					NextState <= wait_acknowledge;
				end if;
									
			cnt_rst 	<= '0';
			reg_cnt 	<= '0';
			adr_o	 	<= "011011000000000" & conv_std_logic_vector(pointer_s,7);
			dat_o	 	<= ram_reg_out; --match_count_array_s(pointer_s); --count_internal.count_0;
			we_o	 	<= '1';
			sel_o	 	<= (others => '0');
			stb_o	 	<= '1';
			cyc_o	 	<= '1';
			lock_o   <= '0';
			inc_ptr	<= '0';
			store_ram <= '0';
			ram_we    <= '0';
			clr_ptr <= '0';
			
			when increment_pointer =>
					NextState <= check_pointer;
								
			cnt_rst 	<= '0';
			reg_cnt 	<= '0';
			adr_o	 	<= (others => '0'); --"0110110000000000000000";
			dat_o	 	<= (others => '0'); --match_count_array_s(0); --count_internal.count_0;
			we_o	 	<= '0';
			sel_o	 	<= (others => '0');
			stb_o	 	<= '0';
			cyc_o	 	<= '0';
			lock_o   <= '0';
			inc_ptr	<= '1';
			store_ram <= '0';
			ram_we    <= '0';
			clr_ptr <= '0';
			
			when check_pointer =>
				if(pointer_s = 32) then
					NextState <= reset_count;
				else
					NextState <= store_count;
				end if;
									
			cnt_rst 	<= '0';
			reg_cnt 	<= '0';
			adr_o	 	<= (others => '0'); --"0110110000000000000000";
			dat_o	 	<= (others => '0'); --match_count_array_s(0); --count_internal.count_0;
			we_o	 	<= '0';
			sel_o	 	<= (others => '0');
			stb_o	 	<= '0';
			cyc_o	 	<= '0';
			lock_o   <= '0';
			inc_ptr	<= '0';
			store_ram <= '0';
			ram_we    <= '0';
			clr_ptr <= '0';
			
---- SIMPLE EXPRESSION 0			
--			when store_count =>
--					NextState <= wait_acknowledge;
--									
--			cnt_rst 	<= '0';
--			reg_cnt 	<= '0';
--			adr_o	 	<= "0110110000000000000000";
--			dat_o	 	<= match_count_array_s(0);  --count_internal.count_0;
--			we_o	 	<= '1';
--			sel_o	 	<= (others => '0');
--			stb_o	 	<= '1';
--			cyc_o	 	<= '1';
--			
--			lock_o   <= '0';
--			
--			when wait_acknowledge =>
--				if(ack_i = '1') then
--					NextState <= store_count_2;
--				else
--					NextState <= wait_acknowledge;
--				end if;
--									
--			cnt_rst 	<= '0';
--			reg_cnt 	<= '0';
--			adr_o	 	<= "0110110000000000000000";
--			dat_o	 	<= match_count_array_s(0); --count_internal.count_0;
--			we_o	 	<= '1';
--			sel_o	 	<= (others => '0');
--			stb_o	 	<= '1';
--			cyc_o	 	<= '1';
--			
--			lock_o   <= '0';
--
--
---- NEW CHANGES 3-27-08
---- SIMPLE EXPRESSION 1
--
--			when store_count_2 =>
--					NextState <= wait_acknowledge_2;
--									
--			cnt_rst 	<= '0';
--			reg_cnt 	<= '0';
--			adr_o	 	<= "0110110000000000000001";
--			dat_o	 	<= match_count_array_s(1);  --count_internal.count_1;
--			we_o	 	<= '1';
--			sel_o	 	<= (others => '0');
--			stb_o	 	<= '1';
--			cyc_o	 	<= '1';
--			
--			lock_o   <= '0';
--			
--			when wait_acknowledge_2 =>
--				if(ack_i = '1') then
--					NextState <= store_count_3;
--				else
--					NextState <= wait_acknowledge_2;
--				end if;
--									
--			cnt_rst 	<= '0';
--			reg_cnt 	<= '0';
--			adr_o	 	<= "0110110000000000000001";
--			dat_o	 	<= match_count_array_s(1);  --count_internal.count_1;
--			we_o	 	<= '1';
--			sel_o	 	<= (others => '0');
--			stb_o	 	<= '1';
--			cyc_o	 	<= '1';
--			
--			lock_o   <= '0';
--			
---- SIMPLE EXPRESSION 2
--			when store_count_3 =>
--					NextState <= wait_acknowledge_3;
--									
--			cnt_rst 	<= '0';
--			reg_cnt 	<= '0';
--			adr_o	 	<= "0110110000000000000010";
--			dat_o	 	<= match_count_array_s(2);  --count_internal.count_2;
--			we_o	 	<= '1';
--			sel_o	 	<= (others => '0');
--			stb_o	 	<= '1';
--			cyc_o	 	<= '1';
--			
--			lock_o   <= '0';
--			
--			when wait_acknowledge_3 =>
--				if(ack_i = '1') then
--					NextState <= store_count_4;
--				else
--					NextState <= wait_acknowledge_3;
--				end if;
--									
--			cnt_rst 	<= '0';
--			reg_cnt 	<= '0';
--			adr_o	 	<= "0110110000000000000010";
--			dat_o	 	<= match_count_array_s(2); --count_internal.count_2;
--			we_o	 	<= '1';
--			sel_o	 	<= (others => '0');
--			stb_o	 	<= '1';
--			cyc_o	 	<= '1';
--			
--			lock_o   <= '0';
--			
---- SIMPLE EXPRESSION 3
--			when store_count_4 =>
--					NextState <= wait_acknowledge_4;
--									
--			cnt_rst 	<= '0';
--			reg_cnt 	<= '0';
--			adr_o	 	<= "0110110000000000000011";
--			dat_o	 	<= match_count_array_s(3); --count_internal.count_3;
--			we_o	 	<= '1';
--			sel_o	 	<= (others => '0');
--			stb_o	 	<= '1';
--			cyc_o	 	<= '1';
--			
--			lock_o   <= '0';
--			
--			when wait_acknowledge_4 =>
--				if(ack_i = '1') then
--					NextState <= store_count_5;
--				else
--					NextState <= wait_acknowledge_4;
--				end if;
--									
--			cnt_rst 	<= '0';
--			reg_cnt 	<= '0';
--			adr_o	 	<= "0110110000000000000011";
--			dat_o	 	<= match_count_array_s(3);  --count_internal.count_3;
--			we_o	 	<= '1';
--			sel_o	 	<= (others => '0');
--			stb_o	 	<= '1';
--			cyc_o	 	<= '1';
--			
--			lock_o   <= '0';
--			
--			
---- SIMPLE EXPRESSION 4
--			when store_count_5 =>
--					NextState <= wait_acknowledge_5;
--									
--			cnt_rst 	<= '0';
--			reg_cnt 	<= '0';
--			adr_o	 	<= "0110110000000000000100";
--			dat_o	 	<= match_count_array_s(4); --count_internal.count_4;
--			we_o	 	<= '1';
--			sel_o	 	<= (others => '0');
--			stb_o	 	<= '1';
--			cyc_o	 	<= '1';
--			
--			lock_o   <= '0';
--			
--			when wait_acknowledge_5 =>
--				if(ack_i = '1') then
--					NextState <= store_count_6;
--				else
--					NextState <= wait_acknowledge_5;
--				end if;
--									
--			cnt_rst 	<= '0';
--			reg_cnt 	<= '0';
--			adr_o	 	<= "0110110000000000000100";
--			dat_o	 	<= match_count_array_s(4);  --count_internal.count_4;
--			we_o	 	<= '1';
--			sel_o	 	<= (others => '0');
--			stb_o	 	<= '1';
--			cyc_o	 	<= '1';
--			
--			lock_o   <= '0';
--			
--
---- SIMPLE EXPRESSION 5
--			when store_count_6 =>
--					NextState <= wait_acknowledge_6;
--									
--			cnt_rst 	<= '0';
--			reg_cnt 	<= '0';
--			adr_o	 	<= "0110110000000000000101";
--			dat_o	 	<= match_count_array_s(5); --count_internal.count_5;
--			we_o	 	<= '1';
--			sel_o	 	<= (others => '0');
--			stb_o	 	<= '1';
--			cyc_o	 	<= '1';
--			
--			lock_o   <= '0';
--			
--			when wait_acknowledge_6 =>
--				if(ack_i = '1') then
--					NextState <= store_count_7;
--				else
--					NextState <= wait_acknowledge_6;
--				end if;
--									
--			cnt_rst 	<= '0';
--			reg_cnt 	<= '0';
--			adr_o	 	<= "0110110000000000000101";
--			dat_o	 	<= match_count_array_s(5);  --count_internal.count_5;
--			we_o	 	<= '1';
--			sel_o	 	<= (others => '0');
--			stb_o	 	<= '1';
--			cyc_o	 	<= '1';
--			
--			lock_o   <= '0';
--			
--			
---- SIMPLE EXPRESSION 6
--			when store_count_7 =>
--					NextState <= wait_acknowledge_7;
--									
--			cnt_rst 	<= '0';
--			reg_cnt 	<= '0';
--			adr_o	 	<= "0110110000000000000110";
--			dat_o	 	<= match_count_array_s(6); --count_internal.count_6;
--			we_o	 	<= '1';
--			sel_o	 	<= (others => '0');
--			stb_o	 	<= '1';
--			cyc_o	 	<= '1';
--			
--			lock_o   <= '0';
--			
--			when wait_acknowledge_7 =>
--				if(ack_i = '1') then
--					NextState <= store_count_8;
--				else
--					NextState <= wait_acknowledge_7;
--				end if;
--									
--			cnt_rst 	<= '0';
--			reg_cnt 	<= '0';
--			adr_o	 	<= "0110110000000000000110";
--			dat_o	 	<= match_count_array_s(6); --count_internal.count_6;
--			we_o	 	<= '1';
--			sel_o	 	<= (others => '0');
--			stb_o	 	<= '1';
--			cyc_o	 	<= '1';
--			
--			lock_o   <= '0';
--			
---- SIMPLE EXPRESSION 7
--			when store_count_8 =>
--					NextState <= wait_acknowledge_8;
--									
--			cnt_rst 	<= '0';
--			reg_cnt 	<= '0';
--			adr_o	 	<= "0110110000000000000111";
--			dat_o	 	<= match_count_array_s(7);  --count_internal.count_7;
--			we_o	 	<= '1';
--			sel_o	 	<= (others => '0');
--			stb_o	 	<= '1';
--			cyc_o	 	<= '1';
--			
--			lock_o   <= '0';
--			
--			when wait_acknowledge_8 =>
--				if(ack_i = '1') then
--					NextState <= reset_count;
--				else
--					NextState <= wait_acknowledge_8;
--				end if;
--									
--			cnt_rst 	<= '0';
--			reg_cnt 	<= '0';
--			adr_o	 	<= "0110110000000000000111";
--			dat_o	 	<= match_count_array_s(7); --count_internal.count_7;
--			we_o	 	<= '1';
--			sel_o	 	<= (others => '0');
--			stb_o	 	<= '1';
--			cyc_o	 	<= '1';
--			
--			lock_o   <= '0';
		
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------			
			
            when others =>
               NextState <= reset_state;
					
			cnt_rst 	<= '0';
			reg_cnt 	<= '0';
			adr_o	 	<= (others => '0');
			dat_o	 	<= (others => '0');
			we_o	 	<= '0';
			sel_o	 	<= (others => '0');
			stb_o	 	<= '0';
			cyc_o	 	<= '0';
			lock_o   <= '0';
			inc_ptr	<= '0';
			store_ram <= '0';
			ram_we    <= '0';
			clr_ptr <= '0';
			
         end case;  

   end process FSM;

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

--make_primitive_ram: for i in 0 to 31 generate
--begin
--  
--   RAM128X1S_inst : RAM128X1S
--   generic map (
--      INIT => X"00000000000000000000000000000000")
--   port map (
--      O => ram_reg_out(i),        -- 1-bit data output
--      A0 => pointer_hex(0), --A0,      -- Address[0] input bit
--      A1 => pointer_hex(1), --A1,      -- Address[1] input bit
--      A2 => pointer_hex(2), --A2,      -- Address[2] input bit
--      A3 => pointer_hex(3), --A3,      -- Address[3] input bit
--      A4 => pointer_hex(4), --A4,      -- Address[4] input bit
--      A5 => pointer_hex(5), --A5,      -- Address[5] input bit
--      A6 => pointer_hex(6), --A6,      -- Address[6] input bit
--      D => ram_reg_in(i),        -- 1-bit data input
--      WCLK => clock,  -- Write clock input
--      WE => ram_we       -- Write enable input
--   );
--end generate;
--   -- End of RAM128X1S_inst instantiation
end RTL;