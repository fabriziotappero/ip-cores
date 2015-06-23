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
-- Module Name: Address_Path - Structural 
-- Project Name: Wizardry
-- Target Devices: Virtex 4 ML401
-- Description: Structural description for Address path for Memory Access Controller.
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

entity Address_Path is
    Port ( clock : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           read_enable_in : in std_logic_vector(num_of_ports downto 0);
           write_enable_in : in std_logic_vector(num_of_ports downto 0);
           Memory_Access_in : in  Memory_Access_Port_in;
			  burst_addresses : in v_adr_i;
			  read_address : in v_adr_i;
			  acknowledge_read_data_in : in  STD_LOGIC;
			  read_index : out integer range 0 to num_of_ports;
			  read_err_o : out  STD_LOGIC_VECTOR (num_of_ports downto 0);
			  write_err_o : out  STD_LOGIC_VECTOR (num_of_ports downto 0);
           Decoded_write_address_out : out  std_logic_vector(physical_address_width -1 downto 0);
           Write_enable_out : out  STD_LOGIC_VECTOR (num_of_ports downto 0);
           Decoded_Read_address_out : out  std_logic_vector(physical_address_width -1 downto 0);
           read_enable_out : out  STD_LOGIC;
           Read_Acknowledge_out : out  STD_LOGIC_VECTOR(num_of_ports downto 0)
			  );
end Address_Path;

architecture Behavioral of Address_Path is

component read_address_decoder is
    Port ( 	reset : in std_logic;
				clock : in  STD_LOGIC;
				read_enable_in : in  STD_LOGIC_VECTOR (num_of_ports downto 0);
				adr_i : in  v_adr_i;
				id_i : in ID_type;
				read_index : out integer range 0 to num_of_ports;
				decoded_read_address_out : out  STD_LOGIC_VECTOR(physical_address_width -1 downto 0);
				err_o : out  STD_LOGIC_VECTOR (num_of_ports downto 0);
				read_enable_out : out  STD_LOGIC);
end component;

component write_address_decoder is
    Port ( 	clock : std_logic;
				ports_in : memory_access_port_in;
				burst_addresses : v_adr_i;
				write_enable_in : in  STD_LOGIC_VECTOR (num_of_ports downto 0);
				decoded_write_address : out  STD_LOGIC_VECTOR (physical_address_width -1 downto 0);
				write_enable_out : out  STD_LOGIC_VECTOR (num_of_ports downto 0);
				write_error_out : out STD_LOGIC_VECTOR (num_of_ports downto 0)
				);
end component;

component Acknowledge_Path is
    Port ( clock : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           read_index : in  integer range 0 to num_of_ports;
			  read_index_out : out  integer range 0 to num_of_ports;
           read_enable : in  STD_LOGIC;
           acknowledge_read_data_in : in  STD_LOGIC;
           read_acknowledge : out  STD_LOGIC_VECTOR (num_of_ports downto 0));
end component;

signal read_index_s,read_index_out_s : integer range 0 to num_of_ports;
signal read_enable_out_s : std_logic;
signal write_enable_out_s : std_logic_vector(num_of_ports downto 0);
--signal burst_addresses_s : v_adr_i;

begin
A0 : read_address_decoder
    Port Map( 	reset => reset,
				clock => clock,
				read_enable_in => read_enable_in,
				adr_i => read_address,
				id_i => Memory_Access_in.ID_i,
				read_index => read_index_s,
				decoded_read_address_out => decoded_read_address_out,
				err_o => read_err_o,
				read_enable_out => read_enable_out_s
				);

A1 : write_address_decoder
    Port Map( 	clock => clock,
				ports_in => Memory_Access_in,
				burst_addresses => burst_addresses,
				write_enable_in => write_enable_in,
				decoded_write_address => decoded_write_address_out,
				write_enable_out => write_enable_out_s,
				write_error_out => write_err_o
				);

A2 : Acknowledge_Path
    Port Map ( clock => clock,
           reset => reset,
           read_index => read_index_s,
			  read_index_out => read_index_out_s,
           read_enable => read_enable_out_s,
           acknowledge_read_data_in => acknowledge_read_data_in,
           read_acknowledge => Read_Acknowledge_out);
read_index <= read_index_out_s;
read_enable_out <= read_enable_out_s;
write_enable_out <= write_enable_out_s;
end Behavioral;

