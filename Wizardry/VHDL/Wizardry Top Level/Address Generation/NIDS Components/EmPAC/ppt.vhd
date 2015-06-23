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
-- Module Name: port_block - Structural 
-- Project Name: Wizardry
-- Target Devices: Virtex 4 ML401
-- Description: Keeps track of which ports have been encountered
-- Revision: 1.0
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.port_block_Constants.all;
---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity port_block is
    Port ( sys_clock : in std_logic;
			  clock : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  reset_100 : in std_logic;
			  fifo_empty_out : out std_logic;
			  fifo_full_out : out std_logic;
			  field_data : in std_logic_vector(31 downto 0);
			  field_type : in std_logic_vector(7 downto 0);
			  data_ready : in std_logic;
--			  config_trig : in std_logic;
			  frame_counters : in frame_counters_type;
           ack_i : in  STD_LOGIC;
           dat_i : in  STD_LOGIC_vector(31 downto 0);
           dat_o : out  STD_LOGIC_VECTOR (31 downto 0);
           adr_o : out  STD_LOGIC_VECTOR (21 downto 0);
           we_o : out  STD_LOGIC;
           cyc_o : out  STD_LOGIC;
           stb_o : out  STD_LOGIC;
			  fifo_push_count : out std_logic_vector(11 downto 0));
end port_block;

architecture Behavioral of port_block is


signal lut_ptr : integer range 0 to MAX_NUM_PORTS_2_FIND-1 := 0;
signal lut_info : lut_check;
signal fifo_push,fifo_pop,fifo_full,fifo_empty : std_logic;
signal fifo_push_s : std_logic;
signal fifo_empty_delay_0,fifo_empty_delay_1,fifo_empty_delay_2 : std_logic := '1';
signal fifo_data_out,fifo_data_in : std_logic_vector(24 downto 0);
signal fifo_data_in_s : std_logic_vector(24 downto 0);
signal ready_check : std_logic;
signal fifo0 : std_logic := '1';
signal load_lut : std_logic;
signal enable_lut_search : std_logic;
signal counter_data : std_Logic_Vector(31 downto 0);
--signal fifo_push_count : std_logic_vector(11 downto 0);

component fifo_ppt is
    Port ( reset : in  STD_LOGIC;
			  push_clock : in  STD_LOGIC;
           push : in  STD_LOGIC;
           fifo_data_in : in std_logic_vector(24 downto 0);
			  full : out  STD_LOGIC;
			  pop_clock : in  STD_LOGIC;
           pop : in  STD_LOGIC;
			  fifo_data_out : out std_logic_vector(24 downto 0);
           empty : out  STD_LOGIC;
			  fifo_push_count : out std_logic_vector(11 downto 0)); 
end component;

component lut_ppt is
port(
			clock : in std_logic;
			reset : in std_logic;
			enable_lut_search : in std_logic;
			load_lut : in std_logic;
			lut_data : in std_Logic_vector(16 downto 0);
			lut_info : out lut_check;
			lut_ptr : out integer range 0 to MAX_NUM_PORTS_2_FIND-1
);
end component;

component fsm_ppt is
    Port ( clock : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  frame_counters : in frame_counters_type;
           fifo_empty : in  STD_LOGIC;
           lut_info : in  lut_check;
			  lut_ptr : in integer range 0 to MAX_NUM_PORTS_2_FIND-1;
           fifo_data_out : in  STD_LOGIC_VECTOR (16 downto 0);
           ack_i : in  STD_LOGIC;
           dat_i : in  STD_LOGIC_VECTOR (31 downto 0);
           dat_o : out  STD_LOGIC_VECTOR (31 downto 0);
           adr_o : out  STD_LOGIC_VECTOR (21 downto 0);
           cyc_o : out  STD_LOGIC;
           stb_o : out  STD_LOGIC;
           we_o : out  STD_LOGIC;
           fifo_pop : out  STD_LOGIC;
           load_lut : out  STD_LOGIC;
           enable_lut_search : out  STD_LOGIC);
end component;

begin
fifo_empty_out <= fifo_empty;
fifo_full_out <= fifo_full;

fifo: fifo_ppt
    Port map( reset => reset,
			  push_clock => clock,
           push => fifo_push,
           fifo_data_in => fifo_data_in,
			  full => fifo_full,
			  pop_clock => sys_clock,
           pop => fifo_pop,
			  fifo_data_out => fifo_data_out,
           empty => fifo_empty,
			  fifo_push_count => fifo_push_count);

fifo_store:process(clock,reset,field_type,field_data,data_ready,fifo_full)
begin
	if reset = '1' then
		fifo_push_s <= '0';
		fifo_data_in_s <= (others => '0');
	elsif rising_Edge(Clock) then
		if ((data_ready = '1' and fifo_full = '0') and (field_type = TCP_SOURCE OR field_type = UDP_SOURCE)) then
			fifo_push_s <= '1';
			fifo_data_in_s <= field_type & '0' & field_data(15 downto 0);
		elsif ((data_ready = '1' and fifo_full = '0') and (field_type = TCP_destination OR field_type = UDP_destination)) then
			fifo_push_s <= '1';
			fifo_data_in_s <= field_type & '1' & field_data(15 downto 0);	
		else
			fifo_push_s <= '0';
			fifo_data_in_s <= fifo_data_in_s;
		end if;
	end if;
end process;

process(clock)
begin
	if rising_edge(clock) then
		fifo_push <= fifo_push_s;
		fifo_data_in <= fifo_data_in_s;
	end if;
end process;

lut_cmp: lut_ppt
port map(
			clock => sys_clock,
			reset => reset_100,
			enable_lut_search => enable_lut_search,
			load_lut => load_lut,
			lut_data => fifo_data_out(16 downto 0),
			lut_info => lut_info,
			lut_ptr => lut_ptr
);

fsm_cmp: fsm_ppt
    Port map( clock => sys_clock,
           reset => reset_100,
			  frame_counters => frame_counters,
           fifo_empty => fifo_empty,
           lut_info => lut_info,
			  lut_ptr => lut_ptr,
           fifo_data_out => fifo_data_out(16 downto 0),
           ack_i => ack_i,
           dat_i => dat_i,
           dat_o => dat_o,
           adr_o => adr_o,
           cyc_o => cyc_o,
           stb_o => stb_o,
           we_o => we_o,
           fifo_pop => fifo_pop,
           load_lut => load_lut,
           enable_lut_search => enable_lut_search);


end Behavioral;

