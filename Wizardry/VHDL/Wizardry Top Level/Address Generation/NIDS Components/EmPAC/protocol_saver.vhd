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
-- Module Name: protocol_fsm - Behavioral 
-- Project Name: Wizardry
-- Target Devices: Virtex 4 ML401
-- Description: Contains FSM that classifies the phy data, providing a corresponding 
-- field identifier called "field_type".  This is the "brains" of EmPAC.
-- Revision: 1.0
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.EmPAC_constants.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity protocol_saver is
    Port ( clock : in std_logic;
			  reset : in std_logic;
			  Protocol_indicator : in  STD_LOGIC;
--			  optional : in std_logic;
           Field_data : in  STD_LOGIC_VECTOR (31 downto 0);
			  Field_type : in std_logic_vector(7 downto 0);
			  TCP_type_out : out std_logic;
			  UDP_type_out : out std_logic;
			  ICMP_type_out : out std_logic);
--			  eoframe : out std_logic;
--           Jump_address : out  STD_LOGIC_VECTOR (7 downto 0));
end protocol_saver;

architecture Behavioral of protocol_saver is

signal TCP_type : std_logic := '0';
signal UDP_type : std_logic := '0';
signal ICMP_type : std_logic := '0';

begin

process(protocol_indicator,field_data,clock,reset)
begin
--wait until clock'event and clock = '1';
	if rising_Edge(clock) then
		if reset = '1' then
			TCP_type <= '0';
			UDP_type <= '0';
			ICMP_type <= '0';
		else--if rising_Edge(clock) then
			if protocol_indicator = '1' then
			--	if field_type = X"06" then										--Etherenet header protocol length is 2 bytes
					--protocol_type <= field_data(15 downto 0);
				if field_type = X"1F" then
					if field_data(7 downto 0) = X"06" then
						TCP_type <= '1';
						UDP_type <= '0';
					ICMP_type <= '0';
					elsif field_data(7 downto 0) = X"11" then
						TCP_type <= '0';
						UDP_type <= '1';
					ICMP_type <= '0';
					elsif field_data(7 downto 0) = X"01" then
						TCP_type <= '0';
						UDP_type <= '0';
						ICMP_type <= '1';
					else
						TCP_type <= '0';
						UDP_type <= '0';
						ICMP_type <= '0';
					end if;
				else
					TCP_type <= '0';
					UDP_type <= '0';
					ICMP_type <= '0';
			--	elsif field_type = X"2A" then
			--		protocol_type <= X"FFFD";
			--	elsif eof = '1' then
			--		protocol_type <= X"FFFF";
			--	elsif field_type = X"1E" or field_type = X"36" then
			--		protocol_type <= X"00" & field_data(7 downto 0);  		--All other header's protocol length is 1 byte.
				end if;
			else
			--	protocol_type <= protocol_type;							   --Retain last protocol value.
				TCP_type <= TCP_type;
				UDP_type <= UDP_type;
				ICMP_type <= ICMP_type;
			end if;
		end if;
	end if;
end process;

TCP_type_out <= TCP_type;
UDP_type_out <= UDP_type;
ICMP_type_out <= ICMP_type;
--opt:process--(optional,field_type)
--begin
--	wait until clock'event and clock = '1';
--	case optional is--_delay is--optional is
--		when '0' =>
--			if ( (field_type = X"2C") or (field_type = X"31") or (field_type = X"40") ) then
--				eof <= '1';
--			else eof <= '0';
--			end if;
--		when '1' => 
--			if ( (field_type = X"22") or (field_type = X"2B") ) then
--				eof <= '1';
--			else eof <= '0';
--			end if;
--		when others => eof <= '0';
--	end case;
--	
--end process;

end Behavioral;

