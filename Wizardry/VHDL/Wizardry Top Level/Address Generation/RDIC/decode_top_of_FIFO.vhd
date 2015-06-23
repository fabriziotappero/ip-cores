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
-- Module Name: Acknowledge_Path - Behavioral 
-- Project Name: Wizardry
-- Target Devices: Virtex 4 ML401
-- Description: Behavioral description for memory access acknowledgement (read and write).
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

entity Acknowledge_Path is
    Port ( clock : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           read_index : in  integer range 0 to num_of_ports;
			  read_index_out : out  integer range 0 to num_of_ports;
           read_enable : in  STD_LOGIC;
           acknowledge_read_data_in : in  STD_LOGIC;
           read_acknowledge : out  STD_LOGIC_VECTOR (num_of_ports downto 0));
end Acknowledge_Path;

architecture Behavioral of Acknowledge_Path is
type read_array is
	array (0 to num_of_ports) of integer range 0 to num_of_ports;
signal full_s,empty_s : std_logic;
--signal read_enable_s, acknowledge_read_data_in_s : std_logic;
signal read_ack_v_s : STD_LOGIC_VECTOR(8 downto 0);
signal count_v_s : std_logic_vector(2 downto 0);

begin
store_index_values : process(clock,reset,read_enable,acknowledge_read_data_in)
variable index_array : read_array;
variable var_a, var_b : integer range 0 to num_of_ports;
variable read_ack_v : STD_LOGIC_VECTOR(8 downto 0);
variable count_v : std_logic_vector(2 downto 0);
begin
if clock='1' and clock'event then
-------------------Works------------------------
      if reset='1' then 
			var_a := 0;
			var_b := 0;
			count_v := "000";
			read_ack_v := "000000000";
		else			
			
			if(read_enable = '1' AND acknowledge_read_data_in = '1') then -- AND full_s = '0') then
					index_array(var_a) := read_index;
					read_ack_v(index_array(var_b)) := '1';
					count_v := count_v;
					if(var_a = num_of_ports) then
						var_a := 0;
					else
						var_a := var_a +1;
					end if;
					if(var_b = num_of_ports) then
						var_b := 0;
					else
						var_b := var_b +1;
					end if;
			elsif(read_enable = '1') then -- AND full_s = '0') then
				if(full_s = '0') then
					index_array(var_a) := read_index;
					count_v := count_v +1;
					if(var_a = num_of_ports) then
						var_a := 0;
					else
						var_a := var_a +1;
					end if;
				end if;
			elsif(acknowledge_read_data_in = '1') then -- AND empty_s = '0') then
				if(empty_s = '0') then
					read_ack_v(index_array(var_b)) := '1';
					count_v := count_v -1;
					if(var_b = num_of_ports) then
						var_b := 0;
					else
						var_b := var_b +1;
					end if;
				end if;
			else
				read_ack_v := "000000000";
				count_v := count_v;
				var_a := var_a;
				var_b := var_b;
			end if;	
		end if;
end if;
read_ack_v_s <= read_ack_v;
count_v_s <= count_v;
read_index_out <= index_array(var_b);
end process store_index_values;

FULL_s      <=  '1'when (conv_integer(count_v_s) = num_of_ports) else '0';
EMPTY_s     <=  '1'when (conv_integer(count_v_s) = 0) else '0';

read_acknowledge <= read_ack_v_s;
end Behavioral;