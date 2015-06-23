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
-- Module Name: burst_read_data_fetcher - Behavioral 
-- Project Name: Wizardry
-- Target Devices: Virtex 4 ML401
-- Description: Behavioral description for burst read data fetcher.
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

entity burst_read_data_fetcher is
    Port ( clock : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           acknowledge_read_data_in : in  STD_LOGIC;
           data_in : in  std_logic_vector(data_width -1 downto 0);
			  data_out : out std_logic_vector(data_width -1 downto 0);
           pop_index : out  STD_LOGIC;
			  store_data : out  STD_LOGIC
			  );
end burst_read_data_fetcher;

architecture Behavioral of burst_read_data_fetcher is
type StateType is (idle, store_read_data
		
		);

signal CurrentState,NextState: StateType;
signal count_s : integer range 0 to 4;
--signal count_s : integer range 0 to burst_length;
signal data_s : std_logic_vector(data_width -1 downto 0);
begin
read_counter : process(clock,reset,acknowledge_read_data_in,data_s,count_s)
begin
if(clock = '1' and clock'event) then
	if(reset = '1') then
		count_s <= 0; 
		data_s <= (others => '0');
	elsif(count_s = 2 or count_s = 4) then
--	elsif(count_s = burst_length) then
		count_s <= 0;
		data_s <= data_s;
	elsif(acknowledge_read_data_in = '1') then
		count_s <= count_s + 1;
		data_s <= data_in;
	else
		count_s <= count_s;
		data_s <= data_s;
	end if;
end if;
data_out <= data_s;
end process read_counter;

pop_index <= '1' when (count_s = 2 OR count_s = 4) else '0';

--pop_index <= '1' when (count_s = burst_length) else '0';

read_data_storage: process(CurrentState,acknowledge_read_data_in)--,Memory_access_in)

   begin
		case (CurrentState) is
			when idle =>
					if(acknowledge_read_data_in = '1') then
						NextState <= store_read_data;
					else
						NextState <= idle;
					end if;		
				store_data <= '0';
				
			when store_read_data =>
						NextState <= idle;	
				store_data <= '1';
				
			when others =>
						NextState <= idle;	
				store_data <= '0';
			end case;
end process read_data_storage;

	nextstatelogic: process
	begin
			wait until clock'EVENT and clock = '1'; --WAIT FOR RISING EDGE
			-- INITIALIZATION
			if (Reset = '1') then
				CurrentState <= idle;
			else
       				CurrentState <= NextState;
			end if;
end process nextstatelogic;



end Behavioral;

