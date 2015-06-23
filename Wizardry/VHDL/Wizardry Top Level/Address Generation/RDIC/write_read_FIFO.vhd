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
-- Module Name: Write_read_FIFO - Behavioral 
-- Project Name: Wizardry
-- Target Devices: Virtex 4 ML401
-- Description: Behavioral description for read and write access.
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

entity write_read_FIFO is
    Port ( clock : in  STD_LOGIC;
		     reset : in  STD_LOGIC;
			  DAT_I : in  v_data_i;
           SEL_I : in  v_sel_i;
           Read_Enable : in  STD_LOGIC;
           Write_Enable : in  std_logic_vector(num_of_ports downto 0);
			  decoded_write_address : in std_logic_vector(physical_address_width -1 downto 0);
			  decoded_read_address : in std_logic_vector(physical_address_width -1 downto 0);
           Acknowledge_in : in  STD_LOGIC;
           Write_data_out : out  std_logic_vector(data_width -1 downto 0);
           address_out : out  std_logic_vector(physical_address_width -1 downto 0);
           write_enable_out : out  STD_LOGIC;
           read_enable_out : out  STD_LOGIC;
           FIFO_empty : out  STD_LOGIC;
           FIFO_full : out  STD_LOGIC);
end write_read_FIFO;

architecture Behavioral of write_read_FIFO is
type Data_Array is
	array (0 to stack_depth -1) of std_logic_vector(WR_FIFO_witdh -1 downto 0);
signal full_s,empty_s : std_logic;
signal count_v_s : std_logic_vector(2 downto 0);
signal decoded_write_address_s : std_logic_vector(physical_address_width -1 downto 0);
	
begin
counter : process(clock,decoded_write_address) --(clock,store_index) --reset_index,store_index)
--variable index_i_v_v : integer range 0 to num_of_ports;
--variable read_enable_in_v : STD_LOGIC_VECTOR (num_of_ports -1 downto 0);
begin
--	if(clock'event and clock = '1') then
	if(rising_edge(clock)) then
		decoded_write_address_s <= decoded_write_address;
	end if;
end process;



store_WR_data : process(clock,reset,read_enable,write_enable,acknowledge_in)
variable Data_array_v : data_array;
variable var_a, var_b : integer range 0 to stack_depth -1;
--variable read_ack_v : STD_LOGIC_VECTOR(7 downto 0);
variable count_v : std_logic_vector(2 downto 0);
begin
if clock='1' and clock'event then
-------------------Works------------------------
      if reset='1' then 
			var_a := 0;
			var_b := 0;
			count_v := "000";
			for i in 0 to (stack_depth -1) loop
				data_array_v(i) := (others => '0');
			end loop;
		else			
			if(read_enable = '1' AND acknowledge_in = '1') then -- AND full_s = '0') then
					Data_array_v(var_a) := decoded_read_address & dummy_data & read_cmd;
--					read_ack_v(index_array(var_b)) := '1';
					count_v := count_v;
					if(var_a = stack_depth -1) then
						var_a := 0;
					else
						var_a := var_a +1;
					end if;
					if(var_b = stack_depth -1) then
						var_b := 0;
					else
						var_b := var_b +1;
					end if;
			elsif(read_enable = '1') then -- AND full_s = '0') then
				if(full_s = '0') then
					Data_array_v(var_a) := decoded_read_address & dummy_data & read_cmd;
					count_v := count_v +1;
					if(var_a = stack_depth -1) then
						var_a := 0;
					else
						var_a := var_a +1;
					end if;
				end if;

----------------------------------------------------------------------
			elsif(write_enable > "000000000" AND acknowledge_in = '1') then -- AND full_s = '0') then
					case(write_enable) is
						when "000000001" => 
							Data_array_v(var_a) := decoded_write_address_s & dat_i(0) & write_cmd;
						when "000000010" => 
							Data_array_v(var_a) := decoded_write_address_s & dat_i(1) & write_cmd;
						when "000000100" => 
							Data_array_v(var_a) := decoded_write_address_s & dat_i(2) & write_cmd;
						when "000001000" => 
							Data_array_v(var_a) := decoded_write_address_s & dat_i(3) & write_cmd;
						when "000010000" => 
							Data_array_v(var_a) := decoded_write_address_s & dat_i(4) & write_cmd;
						when "000100000" => 
							Data_array_v(var_a) := decoded_write_address_s & dat_i(5) & write_cmd;
						when "001000000" => 
							Data_array_v(var_a) := decoded_write_address_s & dat_i(6) & write_cmd;
						when "010000000" => 
							Data_array_v(var_a) := decoded_write_address_s & dat_i(7) & write_cmd;
						when "100000000" => 
							Data_array_v(var_a) := decoded_write_address_s & dat_i(8) & write_cmd;
						when others => 
							Data_array_v(var_a) := decoded_write_address_s & dummy_data & "00";
					end case;
					count_v := count_v;
					if(var_a = stack_depth -1) then
						var_a := 0;
					else
						var_a := var_a +1;
					end if;
					if(var_b = stack_depth -1) then
						var_b := 0;
					else
						var_b := var_b +1;
					end if;
			
			elsif(write_enable > "000000000") then
				if(full_s = '0') then
					count_v := count_v +1;
					case(write_enable) is
						when "000000001" => 
							Data_array_v(var_a) := decoded_write_address_s & dat_i(0) & write_cmd;
						when "000000010" => 
							Data_array_v(var_a) := decoded_write_address_s & dat_i(1) & write_cmd;
						when "000000100" => 
							Data_array_v(var_a) := decoded_write_address_s & dat_i(2) & write_cmd;
						when "000001000" => 
							Data_array_v(var_a) := decoded_write_address_s & dat_i(3) & write_cmd;
						when "000010000" => 
							Data_array_v(var_a) := decoded_write_address_s & dat_i(4) & write_cmd;
						when "000100000" => 
							Data_array_v(var_a) := decoded_write_address_s & dat_i(5) & write_cmd;
						when "001000000" => 
							Data_array_v(var_a) := decoded_write_address_s & dat_i(6) & write_cmd;
						when "010000000" => 
							Data_array_v(var_a) := decoded_write_address_s & dat_i(7) & write_cmd;
						when "100000000" => 
							Data_array_v(var_a) := decoded_write_address_s & dat_i(8) & write_cmd;
						when others => 
							Data_array_v(var_a) := decoded_write_address_s & dummy_data & "00";
					end case;
					if(var_a = stack_depth -1) then
						var_a := 0;
					else
						var_a := var_a +1;
					end if;
				end if;
			elsif(acknowledge_in = '1') then -- AND empty_s = '0') then
				if(empty_s = '0') then
					count_v := count_v -1;
					if(var_b = stack_depth -1) then
						var_b := 0;
					else
						var_b := var_b +1;
					end if;
				end if;
			else
				count_v := count_v;
				var_a := var_a;
				var_b := var_b;
			end if;	
		end if;
end if;
count_v_s <= count_v;
Write_data_out <= Data_array_v(var_b)(data_delimiter downto read_write_delimiter); 
address_out <= Data_array_v(var_b)(address_delimiter downto data_delimiter +1);
--Write_data_out <= Data_array_v(var_b)(33 downto 2); 
--address_out <= Data_array_v(var_b)(57 downto 34);
write_enable_out <= Data_array_v(var_b)(1);
read_enable_out <= Data_array_v(var_b)(0);

end process store_WR_data;

FULL_s      <=  '1'when (conv_integer(count_v_s) = stack_depth) else '0';
EMPTY_s     <=  '1'when (conv_integer(count_v_s) = 0) else '0';

fifo_full <= full_s;
fifo_empty <= empty_s;

end Behavioral;

