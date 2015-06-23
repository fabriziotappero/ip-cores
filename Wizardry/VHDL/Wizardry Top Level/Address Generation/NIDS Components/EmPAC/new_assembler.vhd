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
-- Module Name: new_assembler - Behavioral 
-- Project Name: Wizardry
-- Target Devices: Virtex 4 ML401
-- Description: The assembler combines 8-bit phy data to 32-bit phy data for other 
-- components to further process.
-- Revision: 1.0
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity new_assembler is
    Port ( clock : in  STD_LOGIC;
--           reset : in  STD_LOGIC;
           phy_data : in  STD_LOGIC_VECTOR (7 downto 0);
           phy_data_valid : in  STD_LOGIC;
           field_data_early : out  STD_LOGIC_VECTOR (31 downto 0);
			  valid : out std_logic
			  );
end new_assembler;

architecture Behavioral of new_assembler is

signal q3 : std_logic_vector(7 downto 0) := X"00";
signal q2 : std_logic_vector(7 downto 0) := X"00";
signal q1 : std_logic_vector(7 downto 0) := X"00";
signal q0 : std_logic_vector(7 downto 0) := X"00";
--signal q4 : std_logic_vector(7 downto 0);
signal valid3 : std_logic := '0';
signal valid2 : std_logic := '0';
signal valid1 : std_logic := '0';
signal valid0 : std_logic := '0';
--signal valid4 : std_logic;
signal field_data_early_s : STD_LOGIC_VECTOR (31 downto 0) := X"00000000";

begin
field_data_early <= field_data_early_s;
process(clock)
begin
	if rising_Edge(clock) then
		field_data_early_s <= field_data_early_s(23 downto 0) & q0;
	end if;
end process;

process(clock)
begin
	if rising_Edge(clock) then
		valid <= valid0;
	end if;
end process;


process(clock)
begin
	if rising_edge(clock) then
		q3 <= phy_data;
	end if;
end process;

process(clock)
begin
	if rising_edge(clock) then
		valid3 <= phy_data_valid;
	end if;
end process;

process(clock)
begin
	if rising_edge(clock) then
		q2 <= q3;
	end if;
end process;

process(clock)
begin
	if rising_Edge(clock) then
		valid2 <= valid3;
	end if;
end process;

process(clock) 
begin
	if rising_edge(clock) then
		q1 <= q2;
	end if;
end process;

process(clock)
begin
	if rising_Edge(clock) then
		valid1 <= valid2;
	end if;
end process;

process(clock)
begin
	if rising_edge(clock) then
		q0 <= q1;
	end if;
end process;

process(clock)
begin
	if rising_Edge(clock) then
		valid0 <= valid1;
	end if;
end process;

end Behavioral;

