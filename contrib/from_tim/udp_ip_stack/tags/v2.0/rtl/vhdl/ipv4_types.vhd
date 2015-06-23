--
--
--	Purpose: This package defines types for use in IPv4


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.axi.all;
use work.arp_types.all;

package ipv4_types is

	constant IP_BC_ADDR		: std_logic_vector (31 downto 0) := x"ffffffff";
	constant MAC_BC_ADDR		: std_logic_vector (47 downto 0) := x"ffffffffffff";

	--------------
	-- IPv4 TX --
	--------------

	-- coding for result in tx
	constant IPTX_RESULT_NONE 		: std_logic_vector (1 downto 0) := "00";
	constant IPTX_RESULT_SENDING 	: std_logic_vector (1 downto 0) := "01";
	constant IPTX_RESULT_ERR 		: std_logic_vector (1 downto 0) := "10";
	constant IPTX_RESULT_SENT 		: std_logic_vector (1 downto 0) := "11";

	type ipv4_tx_header_type is record
		protocol				: std_logic_vector (7 downto 0);
		data_length			: STD_LOGIC_VECTOR (15 downto 0);		-- user data size, bytes
		dst_ip_addr 		: STD_LOGIC_VECTOR (31 downto 0);
	end record;
	
	type ipv4_tx_type is record
		hdr				: ipv4_tx_header_type;						-- header to tx
		data				: axi_out_type;								-- tx axi bus
	end record;


	--------------
	-- IPv4 RX --
	--------------

	-- coding for last_error_code in rx hdr
	constant RX_EC_NONE 		: std_logic_vector (3 downto 0) := x"0";
	constant RX_EC_ET_ETH 	: std_logic_vector (3 downto 0) := x"1"; -- early termination in ETH hdr phase
	constant RX_EC_ET_IP 	: std_logic_vector (3 downto 0) := x"2"; -- early termination in IP hdr phase
	constant RX_EC_ET_USER 	: std_logic_vector (3 downto 0) := x"3"; -- early termination in USER DATA phase

	type ipv4_rx_header_type is record
		is_valid				: std_logic;
		protocol				: std_logic_vector (7 downto 0);
		data_length			: STD_LOGIC_VECTOR (15 downto 0);	-- user data size, bytes
		src_ip_addr 		: STD_LOGIC_VECTOR (31 downto 0);
		num_frame_errors	: std_logic_vector (7 downto 0);
		last_error_code	: std_logic_vector (3 downto 0);		-- see RX_EC_xxx constants
		is_broadcast		: std_logic;								-- set if the msg received is a broadcast
	end record;

	type ipv4_rx_type is record
		hdr				: ipv4_rx_header_type;						-- header received
		data				: axi_in_type;									-- rx axi bus
	end record;
	
	type ip_control_type is record
		arp_controls	: arp_control_type;
	end record;

	------------
	-- UDP TX --
	------------

	-- coding for result in tx
	constant UDPTX_RESULT_NONE 		: std_logic_vector (1 downto 0) := "00";
	constant UDPTX_RESULT_SENDING 	: std_logic_vector (1 downto 0) := "01";
	constant UDPTX_RESULT_ERR 			: std_logic_vector (1 downto 0) := "10";
	constant UDPTX_RESULT_SENT 		: std_logic_vector (1 downto 0) := "11";

	type udp_tx_header_type is record
		dst_ip_addr 		: STD_LOGIC_VECTOR (31 downto 0);
		dst_port	 			: STD_LOGIC_VECTOR (15 downto 0);
		src_port	 			: STD_LOGIC_VECTOR (15 downto 0);
		data_length			: STD_LOGIC_VECTOR (15 downto 0);	-- user data size, bytes
		checksum				: STD_LOGIC_VECTOR (15 downto 0);
	end record;


	type udp_tx_type is record
		hdr				: udp_tx_header_type;						-- header received
		data				: axi_out_type;								-- tx axi bus
	end record;
	
	
	------------
	-- UDP RX --
	------------

	type udp_rx_header_type is record
		is_valid				: std_logic;
		src_ip_addr 		: STD_LOGIC_VECTOR (31 downto 0);
		src_port	 			: STD_LOGIC_VECTOR (15 downto 0);
		dst_port	 			: STD_LOGIC_VECTOR (15 downto 0);
		data_length			: STD_LOGIC_VECTOR (15 downto 0);	-- user data size, bytes
	end record;


	type udp_rx_type is record
		hdr				: udp_rx_header_type;						-- header received
		data				: axi_in_type;									-- rx axi bus
	end record;
	
	type udp_addr_type is record
		ip_addr 			: STD_LOGIC_VECTOR (31 downto 0);
		port_num	 		: STD_LOGIC_VECTOR (15 downto 0);
	end record;
	
	type udp_control_type is record
		ip_controls	: ip_control_type;
	end record;

	
end ipv4_types;
