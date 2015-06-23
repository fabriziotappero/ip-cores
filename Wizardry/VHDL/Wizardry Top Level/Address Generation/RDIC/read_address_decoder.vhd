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
-- Module Name: read_address_decoder - Behavioral 
-- Project Name: Wizardry
-- Target Devices: Virtex 4 ML401
-- Description: Behavioral description for read address decoder.
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

entity read_address_decoder is
    Port ( 	reset : in std_logic;
				clock : in  STD_LOGIC;
				read_enable_in : in  STD_LOGIC_VECTOR (num_of_ports downto 0);
				adr_i : in  v_adr_i;
				id_i : in ID_type;
				read_index : out integer range 0 to num_of_ports;
				decoded_read_address_out : out  STD_LOGIC_VECTOR(physical_address_width -1 downto 0);
				err_o : out  STD_LOGIC_VECTOR (num_of_ports downto 0);
				read_enable_out : out  STD_LOGIC);
end read_address_decoder;

architecture Behavioral of read_address_decoder is
type StateType is (reset_state,idle_0,read_requested,check_availability,
				check_type, error_state,local_read, shared_read,
				check_availability_1, find_port, find_port_0, send_read, send_read_0);
signal CurrentState,NextState: StateType;
signal store_index,store_port,send_error : std_logic;
signal index_i_v, port_i_v : integer range 0 to num_of_ports;
signal read_enable_in_v : STD_LOGIC_VECTOR (num_of_ports downto 0);
signal BA,BA_0 : std_logic_vector(2 downto 0);
		
begin

--store_index_value : process(clock,read_enable_in) --(clock,store_index) --reset_index,store_index)
--begin
--	case(read_enable_in) is
--		when "00000001" => index_i_v <= 0;
--		when "00000010" => index_i_v <= 1;
--		when "00000100" => index_i_v <= 2;
--		when "00001000" => index_i_v <= 3;
--		when "00010000" => index_i_v <= 4;
--		when "00100000" => index_i_v <= 5;
--		when "01000000" => index_i_v <= 6;
--		when "10000000" => index_i_v <= 7;
--		when others => index_i_v <= 0;
--	end case;
--end process;

store_index_value : process(clock,store_index,read_enable_in) --(clock,store_index) --reset_index,store_index)
variable index_i_v_v : integer range 0 to num_of_ports;
--variable read_enable_in_v : STD_LOGIC_VECTOR (num_of_ports -1 downto 0);
begin
--	if(clock'event and clock = '1') then
	if(rising_edge(clock)) then
		read_enable_in_v <= read_enable_in;
		if(store_index = '1') then
			index_i_v_v := find_high_bit(read_enable_in_v);
		else
			index_i_v_v := index_i_v_v;
		end if;
	end if;
index_i_v <= index_i_v_v;
end process;

--store_index_value : process(clock,store_index,read_enable_in) --(clock,store_index) --reset_index,store_index)
--begin
----	if(clock'event and clock = '1') then
--	if(rising_edge(clock)) then
--		read_enable_in_v <= read_enable_in;
--		if(store_index = '1') then
--			index_i_v <= find_high_bit(read_enable_in_v);
--		else
--			index_i_v <= index_i_v;
--		end if;
--	end if;
--end process;

save_port: process(clock,store_port,adr_i,index_i_v,id_i)
begin
--	if(clock'event and clock = '1') then
	if(rising_edge(clock)) then
		if(store_port = '1') then
			port_i_v <= check_ID(adr_i,index_i_v, id_i).return_port;
		else
			port_i_v <= port_i_v;
		end if;
	end if;
end process;

assert_error: process(clock,send_error)
begin
--	if(clock'event and clock = '1') then
	if(rising_edge(clock)) then
		if(send_error = '1') then
			err_o(index_i_v) <= '1';
		else
			err_o <= "000000000";
		end if;
	end if;
end process;

decode_adr : process(clock,port_i_v,adr_i) --FOR SHARED READS
begin
--if(rising_edge(clock)) then
--if(port_i_v < 7) then
--dummy_vector <= "11110";
	case(port_i_v) is
		when 0 => BA <= "000"; --11110";
		when 1 => BA <= "001"; --11110";
		when 2 => BA <= "010"; --11110";
		when 3 => BA <= "011"; --11110";
		when 4 => BA <= "100"; --11110";
		when 5 => BA <= "101"; --11110";
		when 6 => BA <= "110"; --11110";
		when 7 => BA <= "111"; --11110";
		when others => BA <= "000";
	end case;
--else
--dummy_vector <= "11110";
--	case (adr_i(8)(18 downto 16)) is
--		when "000" => BA <= "000" ;--& decoded_addresses(num_of_ports)(15 downto 0);
--		when "001" => BA <= "001" ;--& decoded_addresses(num_of_ports)(15 downto 0);
--		when "010" => BA <= "010" ;--& decoded_addresses(num_of_ports)(15 downto 0);
--		when "011" => BA <= "011" ;--& decoded_addresses(num_of_ports)(15 downto 0);
--		when "100" => BA <= "100" ;--& decoded_addresses(num_of_ports)(15 downto 0);
--		when "101" => BA <= "101" ;--& decoded_addresses(num_of_ports)(15 downto 0);
--		when "110" => BA <= "110" ;--& decoded_addresses(num_of_ports)(15 downto 0);
--		when "111" => BA <= "111" ;--& decoded_addresses(num_of_ports)(15 downto 0);
--		when others => BA <= "000";
--	end case;
--end if;
end process;

decode_adr_0 : process(clock,read_enable_in)  --FOR LOCAL READS
begin
if(rising_edge(clock)) then
--if(port_i_v < 7) then
--dummy_vector <= "11110";
	case(read_enable_in) is
		when "000000001" => BA_0 <= "000"; --11110";
		when "000000010" => BA_0 <= "001"; --11110";
		when "000000100" => BA_0 <= "010"; --11110";
		when "000001000" => BA_0 <= "011"; --11110";
		when "000010000" => BA_0 <= "100"; --11110";
		when "000100000" => BA_0 <= "101"; --11110";
		when "001000000" => BA_0 <= "110"; --11110";
		when "010000000" => BA_0 <= "111"; --11110";
		when others => BA_0 <= BA_0;
	end case;
end if;
END PROCESS;




read_acces_process: process(CurrentState,read_enable_in,adr_i,index_i_v,id_i,BA,BA_0)--,Memory_access_in)

   begin
		case (CurrentState) is		
			when reset_state =>
						NextState <= idle_0;
						
				read_enable_out <= '0';
				store_index <= '0';
				store_port <= '0';
				decoded_read_address_out <= (others => '0');
				read_index <= 0;
				send_error <= '0';
				
			when idle_0 =>
				if(read_enable_in = "00000000") then
						NextState <= idle_0;
				else
						NextState <= read_requested;
				end if;
				
				read_enable_out <= '0';
				store_index <= '0';
				store_port <= '0';
				decoded_read_address_out <= (others => '0');
				read_index <= 0;
				send_error <= '0';
				
			when read_requested =>									
						NextState <= check_type;
						
				read_enable_out <= '0';
				store_index <= '1';
				store_port <= '0';
				decoded_read_address_out <= (others => '0');				
				read_index <= 0;
				send_error <= '0';
								
			when check_availability =>
				
						NextState <= check_availability_1;
						
				read_enable_out <= '0';
				store_index <= '0';
				store_port <= '0';
				decoded_read_address_out <= (others => '0');
				read_index <= 0;
				send_error <= '0';
				
			when check_availability_1 =>
				if(check_ID(adr_i,index_i_v, id_i).id_avail) then
						NextState <= shared_read;
				else
						NextState <= error_state;
				end if;
						
				read_enable_out <= '0';
				store_index <= '0';
				store_port <= '0';
				decoded_read_address_out <= (others => '0');
				read_index <= 0;
				send_error <= '0';
				
			when check_type =>
				if(adr_i(index_i_v)(21) = '0') then
						NextState <= local_read;
				else 
						NextState <= check_availability;
				end if;
				
				read_enable_out <= '0';
				store_index <= '0';
				store_port <= '0';
				decoded_read_address_out <= (others => '0');
				read_index <= 0;
				send_error <= '0';
				
			when local_read =>
				
						NextState <= find_port_0;
				
				read_enable_out <= '0';
				store_index <= '0';
				store_port <= '0';
				decoded_read_address_out <= (others => '0');
				read_index <= 0;
				send_error <= '0';
				
			when find_port =>
				
						NextState <= send_read;
				
				read_enable_out <= '0';
				store_index <= '0';
				store_port <= '1';
				decoded_read_address_out <= (others => '0');
				read_index <= 0;
				send_error <= '0';
				
			when find_port_0 =>
				
						NextState <= send_read_0;
				
				read_enable_out <= '0';
				store_index <= '0';
				store_port <= '1';
				decoded_read_address_out <= (others => '0');
				read_index <= 0;
				send_error <= '0';
				
--			when decode_address
--						NextState <= idle_0;
--				
--				read_enable_out <= '0';
--				store_index <= '0';
--				store_port <= '0';
				
			when send_read =>
						NextState <= idle_0;
				
				read_enable_out <= '1';
				store_index <= '0';
				store_port <= '0';
				decoded_read_address_out <= BA & "11011" & adr_i(index_i_v) (15 downto 0);
				read_index <= index_i_v;
				send_error <= '0';
				
			when send_read_0 =>
						NextState <= idle_0;
				
				read_enable_out <= '1';
				store_index <= '0';
				store_port <= '0';
				decoded_read_address_out <= BA_0 & adr_i(index_i_v)(20 downto 0) ;
				read_index <= index_i_v;
				send_error <= '0';
				
			when shared_read =>
				
						NextState <= find_port;
				
				read_enable_out <= '0';
				store_index <= '0';
				store_port <= '0';
				decoded_read_address_out <= (others => '0');
				read_index <= 0;
				send_error <= '0';
				
			when error_state =>
				
						NextState <= reset_state;
				
				read_enable_out <= '0';
				store_index <= '0';
				store_port <= '0';
				decoded_read_address_out <= (others => '0');
				read_index <= 0;
				send_error <= '1';
								
			when others =>
						NextState <= reset_state;
						
				read_enable_out <= '0';
				store_index <= '0';
				store_port <= '0';
				decoded_read_address_out <= (others => '0');
				read_index <= 0;
				send_error <= '0';
				
			end case;
	end process read_acces_process;
	
	nextstatelogic: process
	begin
			wait until clock'EVENT and clock = '1'; --WAIT FOR RISING EDGE
			if (Reset = '1') then
				CurrentState <= reset_state;
			else
       				CurrentState <= NextState;
			end if;
end process nextstatelogic;


end Behavioral;

