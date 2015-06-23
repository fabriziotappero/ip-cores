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
-- Module Name: read_data_buffer - Behavioral 
-- Project Name: Wizardry
-- Target Devices: Virtex 4 ML401
-- Description: Behavioral description for read data buffer.
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

entity read_data_buffer is
    Port ( clock : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  clear_buffer : in STD_LOGIC;
           push : in  STD_LOGIC;
           pop : in  STD_LOGIC;
           data_in : in  STD_LOGIC_VECTOR(data_width -1 downto 0);
           data_out : out  STD_LOGIC_VECTOR(data_width -1 downto 0);
			  buffer_full : out std_logic;
			  buffer_empty : out std_logic
			  );
end read_data_buffer;

architecture Behavioral of read_data_buffer is
signal data_array_v : burst_read_data_array;
signal var_a, var_b : integer range 0 to burst_length -1;
signal count_v : std_logic_vector(2 downto 0);
signal empty_s, full_s : std_logic;
signal count_v_s : std_logic_vector(2 downto 0);

begin
read_burst_data : process(clock,reset,pop,push,count_v,data_array_v,clear_buffer)
begin
if clock='1' and clock'event then

      if (reset='1' OR clear_buffer = '1') then 
			var_a <= 0;
			var_b <= 0;
			count_v <= "000";
			for i in 0 to (burst_length -1) loop
				data_array_v(i) <= (others => '0');
			end loop;
		else			
		
			if(push = '1') then -- AND full_s = '0') then
				if(count_v < "100") then
					Data_array_v(var_a) <= data_in;
					count_v <= count_v +1;
					if(var_a = burst_length -1) then
						var_a <= 0;
					else
						var_a <= var_a +1;
					end if;
				end if;
			
			elsif(pop = '1') then -- AND empty_s = '0') then
				if(empty_s = '0') then
					count_v <= count_v -1;
					if(var_b = burst_length -1) then
						var_b <= 0;
					else
						var_b <= var_b +1;
					end if;
				end if;
			else
				count_v <= count_v;
				var_a <= var_a;
				var_b <= var_b;
			end if;	
		end if;
end if;



count_v_s <= count_v;
data_out <= Data_array_v(var_b); 

end process read_burst_data;

--FULL_s      <=  '1' when (conv_integer(count_v_s) = stack_depth)  else '0';
FULL_s      <=  '1' when (conv_integer(count_v_s) = 1)  else '0';
EMPTY_s     <=  '1' when (conv_integer(count_v_s) = 0) else '0';

buffer_full <= full_s;
buffer_empty <= empty_s;

end Behavioral;

