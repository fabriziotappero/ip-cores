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
-- Module Name: frame_counting - Behavioral 
-- Project Name: Wizardry
-- Target Devices: Virtex 4 ML401
-- Description: Contains several counters that keep track of the number of packets
-- received of each protocol type.
-- Revision: 1.0
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.port_block_constants.all;

entity frame_counting is
    Port ( clock : in  STD_LOGIC;
			  sys_clock : in std_logic;
           reset : in  STD_LOGIC;
--			  ICMP_type : in std_logic;
           field_type : in  STD_LOGIC_VECTOR (7 downto 0);
			  field_data : in std_logic_vector(7 downto 0);
           data_ready : in  STD_LOGIC;
			  frame_counters : out frame_counters_type);
--           total_count : out  STD_LOGIC_VECTOR (31 downto 0);
--           ipv4_count : out  STD_LOGIC_VECTOR (31 downto 0);
--           ipv6_count : out  STD_LOGIC_VECTOR (31 downto 0);
--           tcp_count : out  STD_LOGIC_VECTOR (31 downto 0);
--           udp_count : out  STD_LOGIC_VECTOR (31 downto 0);
--           arp_count : out  STD_LOGIC_VECTOR (31 downto 0);
--           unknown_count : out  STD_LOGIC_VECTOR (31 downto 0));
end frame_counting;

architecture Behavioral of frame_counting is

signal total_frame_count_s : std_logic_vector(31 downto 0);
signal ipv4_frame_count_s : std_logic_vector(31 downto 0);
signal ipv6_frame_count_s : std_logic_vector(31 downto 0);
signal tcp_frame_count_s : std_logic_Vector(31 downto 0);
signal udp_frame_count_s : std_logic_Vector(31 downto 0);
signal arp_frame_count_s : std_logic_Vector(31 downto 0);
signal unknown_packet_count_s : std_logic_vector(31 downto 0);
signal icmp_frame_count_s : std_logic_vector(31 downto 0);
begin

process(sys_clock)
begin
	if rising_edge(sys_clock) then
		frame_counters.count0 <= total_frame_count_s;
	end if;
end process;

process(sys_clock)
begin
	if rising_Edge(sys_clock) then
		frame_counters.count1 <= ipv4_frame_count_s;
	end if;
end process;

process(sys_clock)
begin
	if rising_edge(sys_clock) then
		frame_counters.count2 <= ipv6_frame_count_s;
	end if;
end process;

process(sys_clock)
begin
	if rising_Edge(sys_clock) then
		frame_counters.count3 <= tcp_frame_count_s;
	end if;
end process;

process(sys_clock)
begin
	if rising_edge(sys_clock) then
		frame_counters.count4 <= udp_frame_count_s;
	end if;
end process;

process(sys_clock)
begin
	if rising_edge(sys_clock) then
		frame_counters.count5 <= arp_frame_count_s;
	end if;
end process;

process(sys_clock)
begin
	if rising_edge(sys_clock) then
		frame_counters.count6 <= unknown_packet_count_s;
	end if;
end process;

process(sys_clock)
begin
	if rising_edge(sys_clock) then
		frame_counters.count7 <= ICMP_frame_count_s;
	end if;
end process;

total_frame_count_s <= tcp_frame_count_s + udp_frame_count_s + arp_frame_count_s + unknown_packet_count_s;
--tot_cnt:process(reset,data_ready,field_type)
--begin
----	if rising_edge(clock) then
--		if reset = '1' then
--			total_frame_count_s <= (others => '0');
--		elsif data_ready'event and data_ready = '1' then 
--			if field_type = X"05" then
--				total_frame_count_s <= total_frame_count_s + 1;
--			else
--				total_frame_count_s <= total_frame_count_s;
--			end if;
--		end if;
----	end if;
--end process;

ipv4_cnt:process(clock,reset,data_ready,field_type)
variable ipv4 : std_logic_vector(31 downto 0);
begin
--	if rising_edge(clock) then
		if reset = '1' then
			ipv4 := (others => '0');
		elsif rising_edge(clock) then 
			if data_ready = '1' and field_type = X"1C" then
				ipv4 := ipv4 + 1;
			else
				ipv4 := ipv4;
			end if;
		else	
			ipv4 := ipv4;
		end if;
ipv4_frame_count_s <= ipv4;
--	end if;
end process;

ipv6_cnt:process(clock,reset,data_ready,field_type)
variable ipv6 : std_logic_Vector(31 downto 0);
begin
--	if rising_edge(clock) then
		if reset = '1' then
			ipv6 := (others => '0');
		elsif rising_edge(clock) then
			if data_ready = '1' and field_type = X"33" then
				ipv6 := ipv6 + 1;
			else
				ipv6 := ipv6;
			end if;
		else
			ipv6 := ipv6;
		end if;
ipv6_frame_count_s <= ipv6;		
--	end if;
end process;

tcp_cnt:process(clock,reset,data_ready,field_type)
variable tcp : std_logic_Vector(31 downto 0);
begin
--	if rising_edge(clock) then
		if reset = '1' then
			tcp := (others => '0');
		elsif rising_edge(clock) then
			if data_ready = '1' and field_type = X"25" then
				tcp := tcp + 1;
			else
				tcp := tcp;
			end if;
		else
			tcp := tcp;
		end if;
tcp_frame_count_s <= tcp;
--	end if;
end process;

udp_cnt:process(clock,reset,data_ready,field_type)
variable udp : std_logic_Vector(31 downto 0);
begin
--	if rising_edge(clock) then
		if reset = '1' then
			udp := (others => '0');
		elsif rising_edge(clock) then
			if data_ready = '1' and field_type = X"2F" then
				udp := udp + 1;
			else
				udp := udp;
			end if;
		else
			udp := udp;
		end if;
udp_frame_count_s <= udp;
--	end if;
end process;

arp_cnt:process(clock,reset,data_ready,field_type)
variable arp : std_logic_Vector(31 downto 0);
begin
--	if rising_edge(clock) then
		if reset = '1' then
			arp := (others => '0');
		elsif rising_edge(clock) then
			if data_ready = '1' and field_type = X"07" then
				arp := arp + 1;
			else
				arp := arp;
			end if;
		else
			arp := arp;
		end if;
arp_frame_count_s <= arp;
--	end if;
end process;

icmp_cnt: process(clock,reset,data_ready,field_type)
variable icmp : std_logic_vector(31 downto 0);
begin
	if rising_edge(clock) then
		if reset = '1' then
			icmp := (others => '0');
		elsif data_ready = '1' and field_type = X"43" then-- AND icmp_type = '1' then
				icmp := icmp + 1;
		else
			icmp := icmp;
		end if;
	end if;
icmp_frame_count_s <= icmp;
end process;
------------Marlon's version that works----------------------------------
--icmp_cnt: process(clock,reset,data_ready,field_type,icmp_type)
--variable icmp : std_logic_vector(31 downto 0);
--begin
--	if rising_edge(clock) then
--		if reset = '1' then
--			icmp := (others => '0');
--		elsif data_ready = '1' and field_type = X"1F" AND icmp_type = '1' then
--				icmp := icmp + 1;
--		else
--			icmp := icmp;
--		end if;
--	end if;
--icmp_frame_count_s <= icmp;
--end process;
----------------end Marlon's version--------------------------------------
------------Stacie's version that doesn't work----------------------------------
--icmp_cnt: process(clock,reset,data_ready,field_type,field_data)
--variable icmp : std_logic_vector(31 downto 0);
--begin
--	if reset = '1' then
--		icmp := (others => '0');
--	elsif rising_edge(clock) then
--		if data_ready = '1' and field_type = X"1F" then
--			if field_data = X"01" then
--				icmp := icmp + 1;
--			else
--				icmp := icmp;
--			end if;
--		else
--			icmp := icmp;
--		end if;
--	end if;
--icmp_frame_count_s <= icmp;
--end process;
----------------end Stacie's version--------------------------------------
unk_cnt:process(clock,reset,field_type,data_ready)
variable count_once : std_logic := '0';
variable unknown : std_Logic_Vector(31 downto 0);
begin
--	if rising_edge(clock) then
		if reset = '1' then
			unknown := (others => '0');
			count_once := '0';
		elsif rising_edge(clock) then
			if data_ready = '1' and field_type = X"42" and count_once = '0' then
				unknown := unknown + 1;
				count_once := '1';
			elsif field_type = X"03" then-- and count_once = '1' then
				count_once := '0';
				unknown := unknown; 
			else
				count_once := count_once;
				unknown := unknown;
			end if;
		else
			unknown := unknown;
			count_once := count_once;
		end if;
--		end if;
--	end if;
unknown_packet_count_s <= unknown;
end process;


--ipv4_cnt:process(reset,data_ready,field_type)
--begin
----	if rising_edge(clock) then
--		if reset = '1' then
--			IPv4_frame_count_s <= (others => '0');
--		elsif data_ready'event and data_ready = '1' then
--			if field_type = X"1C" then
--				IPv4_frame_count_s <= IPv4_frame_count_s + 1;
--			else
--				IPv4_frame_count_s <= IPv4_frame_count_s;
--			end if;
--		end if;
----	end if;
--end process;
--
--ipv6_cnt:process(reset,data_ready,field_type)
--begin
----	if rising_edge(clock) then
--		if reset = '1' then
--			IPv6_frame_count_s <= (others => '0');
--		elsif data_ready'event and data_ready = '1' then
--			if field_type = X"33" then
--				IPv6_frame_count_s <= IPv6_frame_count_s + 1;
--			else
--				IPv6_frame_count_s <= IPv6_frame_count_s;
--			end if;
--		end if;
----	end if;
--end process;
--
--tcp_cnt:process(reset,data_ready,field_type)
--begin
----	if rising_edge(clock) then
--		if reset = '1' then
--			tcp_frame_count_s <= (others => '0');
--		elsif data_ready'event and data_ready = '1' then
--			if field_type = X"25" then
--				tcp_frame_count_s <= tcp_frame_count_s + 1;
--			else
--				tcp_frame_count_s <= tcp_frame_count_s;
--			end if;
--		end if;
----	end if;
--end process;
--
--udp_cnt:process(reset,data_ready,field_type)
--begin
----	if rising_edge(clock) then
--		if reset = '1' then
--			udp_frame_count_s <= (others => '0');
--		elsif data_ready'event and data_ready = '1' then
--			if field_type = X"2F" then
--				udp_frame_count_s <= udp_frame_count_s + 1;
--			else
--				udp_frame_count_s <= udp_frame_count_s;
--			end if;
--		end if;
----	end if;
--end process;
--
--arp_cnt:process(reset,data_ready,field_type)
--variable arp : std_logic_Vector(31 downto 0);
--begin
----	if rising_edge(clock) then
--		if reset = '1' then
--			ARP_frame_count_s <= (others => '0');
--		elsif data_ready'event and data_ready = '1' then
--			if field_type = X"07" then
--				ARP_frame_count_s <= ARP_frame_count_s + 1;
--			else
--				ARP_frame_count_s <= ARP_frame_count_s;
--			end if;
--		end if;
----	end if;
--end process;
--
--unk_cnt:process(clock,reset,field_type,data_ready)
--variable count_once : std_logic := '0';
--begin
--	if rising_edge(clock) then
--		if reset = '1' then
--			unknown_packet_count_s <= (others => '0');
--			count_once := '0';
--		elsif data_ready = '1' then
--			if field_type = X"42" and count_once = '0' then
--				unknown_packet_count_s <= unknown_packet_count_s + 1;
--				count_once := '1';
--			elsif field_type = X"03" then-- and count_once = '1' then
--				count_once := '0';
--				unknown_packet_count_s <= unknown_packet_count_s; 
--			else
--				count_once := count_once;
--				unknown_packet_count_s <= unknown_packet_count_s;
--			end if;
--		else
--			unknown_packet_count_s <= unknown_packet_count_s;
--			count_once := count_once;
--		end if;
----		end if;
--	end if;
--end process;

end Behavioral;

