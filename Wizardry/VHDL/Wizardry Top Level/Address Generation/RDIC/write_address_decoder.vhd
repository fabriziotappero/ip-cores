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
-- Module Name: write_address_decoder - Behavioral 
-- Project Name: Wizardry
-- Target Devices: Virtex 4 ML401
-- Description: Behavioral description for write address decoder.
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

entity write_address_decoder is
    Port ( 	clock : std_logic;
				ports_in : memory_access_port_in;
				burst_addresses : v_adr_i;
				write_enable_in : in  STD_LOGIC_VECTOR (num_of_ports downto 0);
				decoded_write_address : out  STD_LOGIC_VECTOR (physical_address_width -1 downto 0);
				write_enable_out : out  STD_LOGIC_VECTOR (num_of_ports downto 0);
				write_error_out : out STD_LOGIC_VECTOR (num_of_ports downto 0)
				);
end write_address_decoder;

architecture Behavioral of write_address_decoder is
signal decoded_addresses : v_adr_i;

begin
decode_write_addresses : process(clock,ports_in.adr_i)
variable decoded_addresses_v : v_adr_i;
begin
	if(clock'event and clock = '1') then
		for i in 0 to (num_of_ports) loop
			decoded_addresses_v(i) := burst_addresses(i);
		end loop;
	decoded_addresses <= decoded_addresses_v;	
	end if;
end process;

--transmit_write_enables : process(clock,ports_in.adr_i,write_enable_in)
--variable write_enable_out_v : STD_LOGIC_VECTOR (8 downto 0);
--begin
--	if(clock'event and clock = '1') then
--		for i in 0 to (num_of_ports -1) loop
--			if(ports_in.adr_i(i) < "0111110000000000000000" AND write_enable_in(i) = '1') then
--				write_enable_out_v(i) := '1';
--			else
--				write_enable_out_v(i) := '0';
--			end if;
--		end loop;
--		if(ports_in.adr_i(num_of_ports) < "0010000000000000000000" AND write_enable_in(num_of_ports) = '1') then
--				write_enable_out_v(num_of_ports) := '1';
--			else
--				write_enable_out_v(num_of_ports) := '0';
--		end if;
----		write_enable_out <= write_enable_out_v;
--	end if;
--	write_enable_out <= write_enable_out_v;
--end process;

transmit_write_enables : process(clock,burst_addresses,write_enable_in)
variable write_enable_out_v : STD_LOGIC_VECTOR (8 downto 0);
begin
	if(clock'event and clock = '1') then
		if(write_enable_in(0) = '1') then
			if(decoded_addresses(0)(20 downto 18) < "111") then
				write_enable_out_v(0) := '1';
			end if;
			
		elsif(write_enable_in(1) = '1') then
			if(decoded_addresses(1)(20 downto 18) < "111") then
				write_enable_out_v(1) := '1';
			end if;
		elsif(write_enable_in(2) = '1') then
			if(decoded_addresses(2)(20 downto 18) < "111") then
				write_enable_out_v(2) := '1';
			end if;
		elsif(write_enable_in(3) = '1') then
			if(decoded_addresses(3)(20 downto 18) < "111") then
				write_enable_out_v(3) := '1';
			end if;
		elsif(write_enable_in(4) = '1') then
			if(decoded_addresses(4)(20 downto 18) < "111") then
				write_enable_out_v(4) := '1';
			end if;
		elsif(write_enable_in(5) = '1') then
			if(decoded_addresses(5)(20 downto 18) < "111") then
				write_enable_out_v(5) := '1';
			end if;
		elsif(write_enable_in(6) = '1') then
			if(decoded_addresses(6)(20 downto 18) < "111") then
				write_enable_out_v(6) := '1';
			end if;
		elsif(write_enable_in(7) = '1') then
			if(decoded_addresses(7)(20 downto 18) < "111") then
				write_enable_out_v(7) := '1';
			end if;
			
		elsif(write_enable_in(8) = '1') then
--			if(burst_addresses(num_of_ports) < "0010000000000000000000") then
				write_enable_out_v(8) := '1';
--			else
--				write_enable_out_v(8) := '0';
--			end if;
		else
			write_enable_out_v := "000000000";
		end if;

--		if(burst_addresses(num_of_ports) < "0010000000000000000000" AND write_enable_in(num_of_ports) = '1') then
--				write_enable_out_v(num_of_ports) := '1';
--			else
--				write_enable_out_v(num_of_ports) := '0';
--		end if;
		write_enable_out <= write_enable_out_v;
	end if;
--	write_enable_out <= write_enable_out_v;
end process;

select_write_enable : process(clock,write_enable_in,decoded_addresses)
begin
if(clock'event and clock = '1') then
	if(write_enable_in < "100000000") then
		case write_enable_in is
			when "000000001" => decoded_write_address <= "000" & decoded_addresses(0)(20 downto 0);
			when "000000010" => decoded_write_address <= "001" & decoded_addresses(1)(20 downto 0);
			when "000000100" => decoded_write_address <= "010" & decoded_addresses(2)(20 downto 0);
			when "000001000" => decoded_write_address <= "011" & decoded_addresses(3)(20 downto 0);
			when "000010000" => decoded_write_address <= "100" & decoded_addresses(4)(20 downto 0);
			when "000100000" => decoded_write_address <= "101" & decoded_addresses(5)(20 downto 0);
			when "001000000" => decoded_write_address <= "110" & decoded_addresses(6)(20 downto 0);
			when "010000000" => decoded_write_address <= "111" & decoded_addresses(7)(20 downto 0);
			when others => decoded_write_address <= "000000000000000000000000";
		end case;
	else
		case (decoded_addresses(8)(18 downto 16)) is
			when "000" => decoded_write_address <= "00011" & decoded_addresses(num_of_ports)(18 downto 0);
			when "001" => decoded_write_address <= "00111" & decoded_addresses(num_of_ports)(18 downto 0);
			when "010" => decoded_write_address <= "01011" & decoded_addresses(num_of_ports)(18 downto 0);
			when "011" => decoded_write_address <= "01111" & decoded_addresses(num_of_ports)(18 downto 0);
			when "100" => decoded_write_address <= "10011" & decoded_addresses(num_of_ports)(18 downto 0);
			when "101" => decoded_write_address <= "10111" & decoded_addresses(num_of_ports)(18 downto 0);
			when "110" => decoded_write_address <= "11011" & decoded_addresses(num_of_ports)(18 downto 0);
			when "111" => decoded_write_address <= "11111" & decoded_addresses(num_of_ports)(18 downto 0);
			when others => decoded_write_address <= "000000000000000000000000";
		end case;
	end if;
end if;
end process select_write_enable;

transmit_errors : process(clock,write_enable_in,decoded_addresses)
begin
if(clock'event and clock = '1') then
	for i in 0 to (num_of_ports -1) loop
		if(write_enable_in(i) = '1') then
			if(decoded_addresses(i)(20 downto 18) = "111") then
				write_error_out(i) <= '1';
			end if;
		else	
				write_error_out(i) <= '0';
		end if;
	end loop;
	write_error_out(num_of_ports) <= '0';
end if;
end process transmit_errors;

end Behavioral;

