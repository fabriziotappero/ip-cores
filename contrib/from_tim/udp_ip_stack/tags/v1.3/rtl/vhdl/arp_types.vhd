--
--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 
--
--   To use any of the example code shown below, uncomment the lines and modify as necessary
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;

package arp_types is

	type arp_req_req_type is
		record
				lookup_req	: std_logic;									-- set high when wanting mac adr for the requested IP
				ip				: std_logic_vector (31 downto 0);
		end record;

	type arp_req_rslt_type is
		record
				got_mac		: std_logic;									-- indicates that we got the mac
				mac			: std_logic_vector (47 downto 0);
				got_err		: std_logic;									-- indicates that we got an error (prob a timeout)
		end record;

	type arp_control_type is
		record
				clear_cache	: std_logic;
		end record;
 
end arp_types;
