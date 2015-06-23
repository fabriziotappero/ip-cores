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
-- Module Name: lut_ppt - Behavioral 
-- Project Name: Wizardry
-- Target Devices: Virtex 4 ML401
-- Description: Keeps track of which ports have been encountered and 
-- Revision: 1.0
-- Additional Comments: 
--
----------------------------------------------------------------------------------library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.port_block_constants.all;
---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity lut_ppt is
    Port ( clock : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           enable_lut_search : in  STD_LOGIC;
           load_lut : in  STD_LOGIC;
           lut_data : in  STD_LOGIC_VECTOR (16 downto 0);
           lut_info : out  lut_check;
           lut_ptr : out  integer range 0 to MAX_NUM_PORTS_2_FIND-1);
end lut_ppt;

architecture Behavioral of lut_ppt is

signal lut : array_table;
signal lut_ptr_s : integer range 0 to MAX_NUM_PORTS_2_FIND-1 := 0;

begin

--search_lut:process(clock,reset,enable_lut_search,lut,lut_data)
--variable lut_find : lut_check;
--begin
--	if reset = '1' then
--		lut_find.in_lut := false;
--		lut_find.lut_pointer := 0;
--	else
--		if rising_edge(clock) then
--			if enable_lut_search = '1' then
--				for i in 0 to MAX_NUM_PORTS_2_FIND -1 loop
--					if(lut(i) = lut_data) then
--						lut_find.in_lut := true;
--						lut_find.lut_pointer := i;
--						exit;
--					else
--						lut_find.in_lut := false;
--						lut_find.lut_pointer := 0;
--					end if;
--				end loop;
--			else
--				lut_find := lut_find;
--			end if;
--		end if;
--	end if;
--lut_info <= lut_find;
--end process;

search_lut:process(clock,reset,enable_lut_search,lut,lut_data)
variable lut_find : lut_check;
begin
	if reset = '1' then
		lut_find.in_lut := false;
		lut_find.lut_pointer := 0;
	else
		if rising_edge(clock) then
			if enable_lut_search = '1' then
				lut_find := check_lut(lut,lut_data);
			else
				lut_find := lut_find;
			end if;
		end if;
	end if;
	lut_info <= lut_find;
end process;

process(clock,reset,load_lut,lut_ptr_s,lut_data)
begin
	if reset = '1' then
		lut_ptr_s <= 0;
	else
		if rising_edge(clock) then
			if load_lut = '1' then
				if lut_ptr_s = MAX_NUM_PORTS_2_FIND-1 then
					lut_ptr_s <= lut_ptr_s;
				else
					lut_ptr_s <= lut_ptr_s + 1;
				end if;
			else
				lut_ptr_s <= lut_ptr_s;
			end if;
		end if;
	end if;
end process;

process(clock,reset,load_lut,lut_data,lut_ptr_s)
begin
	if rising_edge(clock) then
		if reset = '1' then
			for i in 0 to MAX_NUM_PORTS_2_FIND-1 loop
				lut(i) <= (others => '0');
			end loop;
		elsif load_lut = '1' then
			if lut_ptr_s = MAX_NUM_PORTS_2_FIND-1 then
				lut(lut_ptr_s) <= lut(lut_ptr_s);
			else
				lut(lut_ptr_s) <= lut_data;
			end if;
		else
			lut(lut_ptr_s) <= lut(lut_ptr_s);
		end if;
	end if;
end process;

lut_ptr <= lut_ptr_s;
end Behavioral;

------------------------------------------------------------------------------------
---- Company: 
---- Engineer: 
---- 
---- Create Date:    16:02:26 03/18/2008 
---- Design Name: 
---- Module Name:    lut_ppt - Behavioral 
---- Project Name: 
---- Target Devices: 
---- Tool versions: 
---- Description: 
----
---- Dependencies: 
----
---- Revision: 
---- Revision 0.01 - File Created
---- Additional Comments: 
----
------------------------------------------------------------------------------------
--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
--use work.port_block_constants.all;
------ Uncomment the following library declaration if instantiating
------ any Xilinx primitives in this code.
----library UNISIM;
----use UNISIM.VComponents.all;
--
--entity lut_ppt is
--    Port ( clock : in  STD_LOGIC;
--           reset : in  STD_LOGIC;
--           enable_lut_search : in  STD_LOGIC;
--           load_lut : in  STD_LOGIC;
--           lut_data : in  STD_LOGIC_VECTOR (16 downto 0);
--           lut_info : out  lut_check;
--           lut_ptr : out  integer range 0 to MAX_NUM_PORTS_2_FIND-1);
--end lut_ppt;
--
--architecture Behavioral of lut_ppt is
--
--signal lut : array_table;
--signal lut_ptr_s : integer range 0 to MAX_NUM_PORTS_2_FIND-1 := 0;
--
--begin
--
--search_lut:process(clock,reset,load_lut,enable_lut_search,lut_ptr_s)
--variable lut_find : lut_check;
--variable lut_ptr_v : integer;
--begin
--		if reset = '1' then
--			lut_ptr_s <= 0;
--			lut_find.in_lut := false;
--			lut_find.lut_pointer := 0;
--			for i in 0 to MAX_NUM_PORTS_2_FIND-1 loop
--				lut(i) <= (others => '0');
--			end loop;
--			
--		elsif rising_Edge(clock) then
--			if enable_lut_search = '1' then--search lut--_empty_delay_0 = '0' then
--					lut_find := check_lut(lut,lut_data);
--			else
--				lut_find := lut_find;
--			end if;
--			
--			if (load_lut = '1') then	--store value into lut
--				if lut_ptr_s = MAX_NUM_PORTS_2_FIND-1 then
--					lut(lut_ptr_s) <= lut(lut_ptr_s);
--					lut_ptr_s <= lut_ptr_s;
--				else
--					lut(lut_ptr_s) <= lut_data;
--					lut_ptr_s <= lut_ptr_s + 1;
--				end if;
--			else
--					lut(lut_ptr_s) <= lut(lut_ptr_s);
--					lut_ptr_s <= lut_ptr_s;
--			end if;
----				else --everything remains the same
----					lut_find.in_lut := lut_find.in_lut;
----					lut_find.lut_pointer := lut_find.lut_pointer;
----					lut(lut_ptr) <= lut(lut_ptr);
----					lut_ptr <= lut_ptr;
----			end if;
--		end if;
----	end if;
--	lut_info <= lut_find;
--end process;
--lut_ptr <= lut_ptr_s;
--end Behavioral;

