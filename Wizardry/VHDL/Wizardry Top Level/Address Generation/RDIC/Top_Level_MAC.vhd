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
-- Module Name: Top_Level_MAC - Structural 
-- Project Name: Wizardry
-- Target Devices: Virtex 4 ML401
-- Description: Top-level structural description for Memory Access Controller (MAC).
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

entity Top_Level_MAC is
    Port ( clock : in  STD_LOGIC;
			  device_clock : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           Memory_Access_in : in  Memory_Access_Port_in;
           Memory_Access_out : out  Memory_Access_Port_out;
			  MAC_in : in Preprocessor_Interface_Port_in;
			  MAC_out : out Preprocessor_Interface_Port_out
			  );
end Top_Level_MAC;

architecture Structural of Top_Level_MAC is

component Arbitration_Path is
    Port ( clock : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  FIFO_full : in  STD_LOGIC;
			  FIFO_empty : in std_logic;
			  read_request : in std_logic_vector(num_of_ports downto 0);
			  write_request : in std_logic_vector(num_of_ports downto 0);
--           Memory_Access_in : in  Memory_Access_Port_in;
			  priority_signals : in priority_type;
			  read_acknowledge : in std_logic_vector(num_of_ports downto 0);
			  read_enable_in : out  std_logic_vector(num_of_ports downto 0);
			  write_enable_in : out  std_logic_vector(num_of_ports downto 0)
			  );
end component;

component write_read_FIFO is
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
end component;

component write_address_decoder is
    Port ( 	clock : std_logic;
				ports_in : memory_access_port_in;
				write_enable_in : in  STD_LOGIC_VECTOR (num_of_ports -1 downto 0);
				decoded_write_address : out  STD_LOGIC_VECTOR (physical_address_width -1 downto 0);
				write_enable_out : out  STD_LOGIC_VECTOR (num_of_ports -1 downto 0));
end component;

signal read_enable_in_s, write_enable_in_s, write_enable_out_s,burst_write_enable_s,
		 read_request_s,write_request_s, acknowledge_s : std_logic_vector(num_of_ports downto 0);
signal read_enable_out_s,FIFO_full_s,FIFO_empty_s: std_logic;
signal decoded_read_address_out_s : std_logic_vector(physical_address_width -1 downto 0);
signal Decoded_write_address_out_s : std_logic_vector(physical_address_width -1 downto 0);
signal Read_Acknowledge_out_s,Read_Acknowledge_out_s_1,read_err_o_s,write_err_o_s,pop_burst_data_s : std_logic_vector(num_of_ports downto 0); 
--signal Memory_Access_out_s : Memory_Access_Port_out;
signal burst_data_s : v_data_i;
signal burst_full_s, burst_empty_s,reset_buffer_s, acknowledge_read_data_s,reset_pop_count_s : std_logic_vector(num_of_ports downto 0);
signal address_vectors,burst_addresses_s : v_adr_i;
signal data_out_s : Data_out_Array;
signal pop_index_s, store_data_s : std_logic;
signal read_data_out_s,read_data_reg_s : std_logic_vector(data_width -1 downto 0);
signal read_index_s : integer range 0 to num_of_ports;
signal read_buffer_enable_s, pop_dummy_s, buffer_full_dummy_s, buffer_empty_dummy_s,pop_read_data_s : std_logic_vector(num_of_ports downto 0);
signal data_out_dummy_s : read_data_array;

component Address_Path is
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
end component;

component burst_data_fetch is
    Port ( 	reset : in std_logic;
				clock : in  STD_LOGIC;
				buffer_empty : in  STD_LOGIC_VECTOR (num_of_ports downto 0);
				write_enable_in : in  STD_LOGIC_VECTOR (num_of_ports downto 0);
				pop_o : out  STD_LOGIC_VECTOR (num_of_ports downto 0);
				burst_write_enable : out STD_LOGIC_VECTOR (num_of_ports downto 0);
				reset_pop_count : out STD_LOGIC_VECTOR (num_of_ports downto 0)
				);
end component;

component Burst_data_Buffer is
    Port (clock : in  STD_LOGIC;
			device_clock : in  STD_LOGIC;
			reset : in std_logic;
			we_i : in std_logic;
			data_in : in std_logic_vector(data_width -1 downto 0);
			address_in : in std_logic_vector(virtual_address_width -1 downto 0);
			data_out : out std_logic_vector((data_width + virtual_address_width)-1 downto 0);
			read_address : out std_logic_vector(virtual_address_width -1 downto 0);
			pop : in std_logic;
			cyc_i : in std_logic;
			stb_i : in std_logic;
			lock_i : in std_logic;
			read_err_i : in std_logic;
			write_err_i : in std_logic;
			err_o : out std_logic;
			read_buffer_full : in std_logic;
			read_serviced : in std_logic;
			reset_pop_count_in : in std_logic;
			read_acknowledge : in std_logic;
			buffer_full : out std_logic; 
			buffer_empty : out std_logic;
			write_enable_out : out std_logic;
			read_enable_out : out std_logic;
			acknowledge : out std_logic;
			reset_buffer : out std_logic; 
			acknowledge_read_data : out std_logic 
			);
end component;

component burst_read_data_fetcher is
    Port ( clock : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           acknowledge_read_data_in : in  STD_LOGIC;
           data_in : in  std_logic_vector(data_width -1 downto 0);
			  data_out : out std_logic_vector(data_width -1 downto 0);
           pop_index : out  STD_LOGIC;
			  store_data : out  STD_LOGIC
			  );
end component;

component read_data_buffer is
    Port ( clock : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  clear_buffer : in std_logic;
           push : in  STD_LOGIC;
           pop : in  STD_LOGIC;
           data_in : in  STD_LOGIC_VECTOR(data_width -1 downto 0);
           data_out : out  STD_LOGIC_VECTOR(data_width -1 downto 0);
			  buffer_full : out std_logic;
			  buffer_empty : out std_logic
			  );
end component;

begin
--process(Read_Acknowledge_out_s,Memory_Access_out_s)
--begin
----if clock='1' and clock'event then
--	for i in 0 to num_of_ports loop
--		if(Memory_Access_out_s.ack_o(i) = '1') then
--			Memory_Access_out.ack_o(i) <= '1';
--		elsif(Read_Acknowledge_out_s(i) = '1') then
--			Memory_Access_out.ack_o(i) <= '1';
--		else
--			Memory_Access_out.ack_o(i) <= '0';
--		end if;
--	end loop;
----end if;
--end process;

--process(clock,read_err_o_s,write_err_o_s)
--begin
--if clock='1' and clock'event then
--	for i in 0 to num_of_ports loop
--		if(read_err_o_s(i) = '1') then
--			Memory_Access_out.err_o(i) <= '1';
--		elsif(write_err_o_s(i) = '1') then
--			Memory_Access_out.err_o(i) <= '1';
--		else
--			Memory_Access_out.err_o(i) <= '0';
--		end if;
--	end loop;
--end if;
--end process;

register_read_data : process(clock,reset,MAC_in.Acknowledge_read_data_in)
begin
if(clock ='1' AND clock'event) then
	if(reset = '1') then
		read_data_reg_s <= (others => '0');
	elsif(MAC_in.Acknowledge_read_data_in = '1') then
		read_data_reg_s <= MAC_in.read_data_in;
	else
		read_data_reg_s <= read_data_reg_s;
	end if;
end if;
end process;

multiplex_read_data : process(clock,reset,read_index_s,store_data_s)
begin
if(clock ='1' AND clock'event) then  -- May not need to use clock enable for this signal
	if(store_data_s = '1') then
		read_buffer_enable_s(read_index_s) <= '1';
	else
		read_buffer_enable_s <= (others => '0');
	end if;
end if;
end process;
		

process(data_out_s)
begin
	for i in 0 to num_of_ports loop
		burst_data_s(i) <= data_out_s(i)(53 downto 22);
		burst_addresses_s(i) <= data_out_s(i)(21 downto 0);
	end loop;
--end if;
end process;



A0 : Address_Path
    Port Map( clock => clock,
           reset => reset,
           read_enable_in => read_enable_in_s,
           write_enable_in => write_enable_in_s,
           Memory_Access_in => Memory_Access_in,
			  burst_addresses => burst_addresses_s,
			  read_address => address_vectors,
			  acknowledge_read_data_in => pop_index_s,
			  read_index => read_index_s,
			  read_err_o => read_err_o_s,
			  write_err_o => write_err_o_s,
           Decoded_write_address_out => Decoded_write_address_out_s,
           Write_enable_out => write_enable_out_s,
           Decoded_Read_address_out => Decoded_Read_address_out_s,
           read_enable_out => read_enable_out_s,
           Read_Acknowledge_out => Read_Acknowledge_out_s
			  );
			  

A1 : Arbitration_Path
    Port Map( clock => clock,
           reset => reset,
			  FIFO_full => FIFO_full_s,
			  FIFO_empty => FIFO_empty_s,
			  read_request => read_request_s,
			  write_request => write_request_s,
			  priority_signals => Memory_Access_in.priority_i,
			  read_acknowledge => Read_Acknowledge_out_s,
			  read_enable_in => read_enable_in_s,
			  write_enable_in => write_enable_in_s
			  );
			  
			  
A2 : write_read_FIFO 
    Port MAP( clock => clock,
		     reset => reset,
			  DAT_I =>  burst_data_s,
           SEL_I => Memory_Access_in.sel_i,
           Read_Enable => read_enable_out_s,
           Write_Enable => burst_write_enable_s,
			  decoded_write_address => Decoded_write_address_out_s,
			  decoded_read_address => Decoded_Read_address_out_s,
           Acknowledge_in => MAC_in.ack_access_in,
           Write_data_out => MAC_out.Write_data_out,
           address_out => MAC_out.address_out,
           write_enable_out => MAC_out.write_enable_out,
           read_enable_out => MAC_out.read_enable_out,
           FIFO_empty => FIFO_empty_s,
           FIFO_full => FIFO_full_s
			  );
			  
Burts_write_data_fetcher : burst_data_fetch 
    Port Map( 	reset => reset,
				clock => clock,
				buffer_empty => burst_empty_s,
				write_enable_in => write_enable_out_s,
				pop_o => pop_burst_data_s,
				burst_write_enable => burst_write_enable_s,
				reset_pop_count => reset_pop_count_s
				);

Make_Buffers: for i in 0 to num_of_ports generate
begin			
Buffer_FIFO : Burst_data_Buffer
    Port Map( clock => clock,
				device_clock => device_clock,
				reset => reset,
				we_i => Memory_Access_in.we_i(i),
				data_in => Memory_Access_in.dat_i(i),
				address_in => Memory_Access_in.adr_i(i),
				read_address => address_vectors(i),
				pop => pop_burst_data_s(i),
				data_out => data_out_s(i),
				cyc_i => Memory_Access_in.cyc_i(i),
				stb_i => Memory_Access_in.stb_i(i),
				lock_i => Memory_Access_in.lock_i(i),
				read_err_i => read_err_o_s(i),
				write_err_i => write_err_o_s(i),
				err_o => Memory_Access_out.err_o(i),
				read_buffer_full => buffer_full_dummy_s(i),
				read_serviced => read_enable_in_s(i),
				reset_pop_count_in => reset_pop_count_s(i),
				read_acknowledge => pop_burst_data_s(i),
				buffer_full => burst_full_s(i),
				buffer_empty => burst_empty_s(i),
				write_enable_out => write_request_s(i),
				read_enable_out => read_request_s(i),
				reset_buffer => reset_buffer_s(i),
				acknowledge => Read_Acknowledge_out_s_1(i),
				acknowledge_read_data => acknowledge_read_data_s(i)
			);
end generate;

read_data_fetcher : burst_read_data_fetcher
    Port Map( clock => clock,
           reset => reset,
           acknowledge_read_data_in => MAC_in.Acknowledge_read_data_in,
           data_in => MAC_in.Read_data_in,
			  data_out => read_data_out_s,
           pop_index => pop_index_s,
			  store_data => store_data_s
			  );

Make_Read_Buffers : for i in 0 to num_of_ports generate
begin						  
read_buffers : read_data_buffer
    Port Map( clock => clock,
           reset => reset,
			  clear_buffer => reset_buffer_s(i),
           push => read_buffer_enable_s(i),
           pop => pop_read_data_s(i),
--			  pop => acknowledge_read_data_s(i),
--			  pop => pop_read_data_s(i),
           data_in => read_data_reg_s,
           data_out => Memory_Access_Out.dat_o(i),
			  buffer_full => buffer_full_dummy_s(i),
			  buffer_empty => buffer_empty_dummy_s(i)
			  );
end generate;


MAC_out.FIFO_empty_out <= FIFO_empty_s;
Memory_Access_out.burst_full <= burst_full_s;
Memory_Access_out.burst_empty <= burst_empty_s;

process(Read_Acknowledge_out_s_1,buffer_full_dummy_s,clock,acknowledge_read_data_s)
begin
if(rising_Edge(clock)) then
	for i in 0 to (num_of_ports) loop
		if(acknowledge_read_data_s(i) = '1') then
			Memory_Access_out.ack_o(i) <= '1';
			pop_read_data_s(i) <= '1';
		elsif(Read_Acknowledge_out_s_1(i) = '1') then
			Memory_Access_out.ack_o(i) <= '1';
			pop_read_data_s(i) <= '0';
		else
			Memory_Access_out.ack_o(i) <= '0';
			pop_read_data_s(i) <= '0';
		end if;
	end loop;
end if;
end process;

end Structural;

