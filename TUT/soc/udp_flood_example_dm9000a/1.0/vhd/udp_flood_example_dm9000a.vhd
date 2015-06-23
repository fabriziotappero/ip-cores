-- ***************************************************
-- File: udp_flood_example_dm9000a.vhd
-- Creation date: 18.01.2013
-- Creation time: 12:46:22
-- Description: Simple example to test the connection FPGA -> PC.
-- 
-- Flooder unit sends all the time, UDP/IP block transfers them to PC. Designer can use netstat, netcat, wireshark or similar to catch the packet at the PC's end.
-- Created by: matilail
-- This file was generated with Kactus2 vhdl generator.
-- ***************************************************
library IEEE;
library work;
use IEEE.std_logic_1164.all;
use work.all;

entity udp_flood_example_dm9000a is

	port (

		-- Interface: clk_in
		-- Clock input.
		clk_in_CLK : in std_logic;

		-- Interface: DM9000A
		-- Connection to DM9000A chip (Ethernet PHY) found e.g. in DE2 board. Expects 25 MHz clock.
		DM9000A_eth_interrupt_in : in std_logic;
		DM9000A_eth_chip_sel_out : out std_logic;
		DM9000A_eth_clk_out : out std_logic;
		DM9000A_eth_cmd_out : out std_logic;
		DM9000A_eth_read_out : out std_logic;
		DM9000A_eth_reset_out : out std_logic;
		DM9000A_eth_write_out : out std_logic;
		DM9000A_eth_data_inout : inout std_logic_vector(15 downto 0);

		-- Interface: link_up_out
		-- 1-bit status
		link_up_out_gpio_out : out std_logic;

		-- Interface: rst_n
		-- Active-low reset
		rst_n_RESETn : in std_logic
	);

end udp_flood_example_dm9000a;


architecture kactusHierarchical of udp_flood_example_dm9000a is

	signal pll_flooderCLK : std_logic;
	signal udp_flooderrxdest_port_out : std_logic_vector(15 downto 0);
	signal floodertx_udpfatal_error_out : std_logic;
	signal floodertx_udplink_up_out : std_logic;
	signal udp_flooderrxnew_rx_out : std_logic;
	signal floodertx_udpnew_tx_in : std_logic;
	signal floodertx_udpno_arp_target_MAC_in : std_logic_vector(47 downto 0);
	signal udp_flooderrxrx_data_out : std_logic_vector(15 downto 0);
	signal udp_flooderrxrx_data_valid_out : std_logic;
	signal udp_flooderrxrx_erroneous_out : std_logic;
	signal udp_flooderrxrx_error_out : std_logic;
	signal udp_flooderrxrx_len_out : std_logic_vector(10 downto 0);
	signal udp_flooderrxrx_re_in : std_logic;
	signal udp_flooderrxsource_addr_out : std_logic_vector(31 downto 0);
	signal udp_flooderrxsource_port_out : std_logic_vector(15 downto 0);
	signal floodertx_udpsource_port_in : std_logic_vector(15 downto 0);
	signal floodertx_udptarget_addr_in : std_logic_vector(31 downto 0);
	signal floodertx_udptarget_port_in : std_logic_vector(15 downto 0);
	signal floodertx_udptx_data_in : std_logic_vector(15 downto 0);
	signal floodertx_udptx_data_valid_in : std_logic;
	signal floodertx_udptx_len_in : std_logic_vector(10 downto 0);
	signal floodertx_udptx_re_out : std_logic;

	-- Connect to UDP/IP controller. Creates TX operations as quickly as possible. Sends running numbers. 
	-- Destination and packet size are configurable by using generics.
	component simple_udp_flood_example
		generic (
			data_width_g : integer := 16;
			disable_arp_g : integer := 0;
			packet_len_g : integer := 1000;
			source_ip_port_g : integer := 6000;
			target_MAC_addr_g : std_logic_vector(47 downto 0) := x"ACDCABBACD01";
			target_ip_addr_g : std_logic_vector(31 downto 0) := x"0A000001";
			target_ip_port_g : integer := 5000

		);
		port (

			-- Interface: clk
			-- Clock 25 MHz synchronous to UDP/IP/ETH clock.
			clk : in std_logic;

			-- Interface: link_up_out
			-- Connect a LED here; rises a few seconds after the autonegotiation process is done.
			link_up_out : out std_logic;

			-- Interface: rst_n
			-- rst_n
			rst_n : in std_logic;

			-- There ports are contained in many interfaces
			fatal_error_in : in std_logic;
			link_up_in : in std_logic;

			-- Interface: udp_ip_rx
			-- Optional, this example flooder just accepts all incoming data but does nothing with it.
			dest_port_in : in std_logic_vector(15 downto 0);
			new_rx_in : in std_logic;
			rx_data_in : in std_logic_vector(15 downto 0);
			rx_data_valid_in : in std_logic;
			rx_erroneous_in : in std_logic;
			rx_error_in : in std_logic;
			rx_len_in : in std_logic_vector(10 downto 0);
			source_addr_in : in std_logic_vector(31 downto 0);
			source_port_in : in std_logic_vector(15 downto 0);
			rx_re_out : out std_logic;

			-- Interface: udp_ip_tx
			-- Flooder sends
			tx_re_in : in std_logic;
			new_tx_out : out std_logic;
			no_arp_target_MAC_out : out std_logic_vector(47 downto 0);
			source_port_out : out std_logic_vector(15 downto 0);
			target_addr_out : out std_logic_vector(31 downto 0);
			target_port_out : out std_logic_vector(15 downto 0);
			tx_data_out : out std_logic_vector(15 downto 0);
			tx_data_valid_out : out std_logic;
			tx_len_out : out std_logic_vector(10 downto 0)

		);
	end component;

	-- DM9000A controller and UDP/IP.
	component udp_ip_dm9000a
		generic (
			disable_arp_g : integer := 0;
			disable_rx_g : integer := 0

		);
		port (

			-- Interface: app_rx
			-- Application receive operations
			rx_re_in : in std_logic;
			dest_port_out : out std_logic_vector(15 downto 0);
			new_rx_out : out std_logic;
			rx_data_out : out std_logic_vector(15 downto 0);
			rx_data_valid_out : out std_logic;
			rx_erroneous_out : out std_logic;
			rx_error_out : out std_logic;
			rx_len_out : out std_logic_vector(10 downto 0);
			source_addr_out : out std_logic_vector(31 downto 0);
			source_port_out : out std_logic_vector(15 downto 0);

			-- Interface: app_tx
			-- Application transmit operations
			new_tx_in : in std_logic;
			no_arp_target_MAC_in : in std_logic_vector(47 downto 0);
			source_port_in : in std_logic_vector(15 downto 0);
			target_addr_in : in std_logic_vector(31 downto 0);
			target_port_in : in std_logic_vector(15 downto 0);
			tx_data_in : in std_logic_vector(15 downto 0);
			tx_data_valid_in : in std_logic;
			tx_len_in : in std_logic_vector(10 downto 0);
			tx_re_out : out std_logic;

			-- Interface: clk
			-- Clock 25 MHz in.
			clk : in std_logic;

			-- Interface: DM9000A
			-- Connection to the DM9000A chip via IO pins.
			eth_interrupt_in : in std_logic;
			eth_chip_sel_out : out std_logic;
			eth_clk_out : out std_logic;
			eth_cmd_out : out std_logic;
			eth_read_out : out std_logic;
			eth_reset_out : out std_logic;
			eth_write_out : out std_logic;
			eth_data_inout : inout std_logic_vector(15 downto 0);

			-- Interface: rst_n
			-- Asynchronous reset active-low.
			rst_n : in std_logic;

			-- There ports are contained in many interfaces
			fatal_error_out : out std_logic;
			link_up_out : out std_logic

		);
	end component;

	-- 25 MHz Altera ALTPLL instantiation for Cyclone II FPGA's with input clk of 50 MHz (mul = 1, div = 2)
	component altera_de2_pll_25
		port (

			-- Interface: clk_in
			-- Input clock (50 MHz, DE2 PIN_N2)
			inclk0 : in std_logic;

			-- Interface: clk_out
			-- Output clock: input clock divided by 2.
			c0 : out std_logic

		);
	end component;

	-- You can write vhdl code after this tag and it is saved through the generator.
	-- ##KACTUS2_BLACK_BOX_DECLARATIONS_BEGIN##
	-- ##KACTUS2_BLACK_BOX_DECLARATIONS_END##
	-- Stop writing your code after this tag.


begin

	-- You can write vhdl code after this tag and it is saved through the generator.
	-- ##KACTUS2_BLACK_BOX_ASSIGNMENTS_BEGIN##
	-- ##KACTUS2_BLACK_BOX_ASSIGNMENTS_END##
	-- Stop writing your code after this tag.

	altera_de2_pll_25_1 : altera_de2_pll_25
		port map (
			c0 => pll_flooderCLK,
			inclk0 => clk_in_CLK
		);

	simple_udp_flood_example_1 : simple_udp_flood_example
		port map (
			clk => pll_flooderCLK,
			dest_port_in(15 downto 0) => udp_flooderrxdest_port_out(15 downto 0),
			fatal_error_in => floodertx_udpfatal_error_out,
			link_up_in => floodertx_udplink_up_out,
			link_up_out => link_up_out_gpio_out,
			new_rx_in => udp_flooderrxnew_rx_out,
			new_tx_out => floodertx_udpnew_tx_in,
			no_arp_target_MAC_out(47 downto 0) => floodertx_udpno_arp_target_MAC_in(47 downto 0),
			rst_n => rst_n_RESETn,
			rx_data_in(15 downto 0) => udp_flooderrxrx_data_out(15 downto 0),
			rx_data_valid_in => udp_flooderrxrx_data_valid_out,
			rx_erroneous_in => udp_flooderrxrx_erroneous_out,
			rx_error_in => udp_flooderrxrx_error_out,
			rx_len_in(10 downto 0) => udp_flooderrxrx_len_out(10 downto 0),
			rx_re_out => udp_flooderrxrx_re_in,
			source_addr_in(31 downto 0) => udp_flooderrxsource_addr_out(31 downto 0),
			source_port_in(15 downto 0) => udp_flooderrxsource_port_out(15 downto 0),
			source_port_out(15 downto 0) => floodertx_udpsource_port_in(15 downto 0),
			target_addr_out(31 downto 0) => floodertx_udptarget_addr_in(31 downto 0),
			target_port_out(15 downto 0) => floodertx_udptarget_port_in(15 downto 0),
			tx_data_out(15 downto 0) => floodertx_udptx_data_in(15 downto 0),
			tx_data_valid_out => floodertx_udptx_data_valid_in,
			tx_len_out(10 downto 0) => floodertx_udptx_len_in(10 downto 0),
			tx_re_in => floodertx_udptx_re_out
		);

	udp_ip_dm9000a_1 : udp_ip_dm9000a
		port map (
			clk => pll_flooderCLK,
			dest_port_out(15 downto 0) => udp_flooderrxdest_port_out(15 downto 0),
			eth_chip_sel_out => DM9000A_eth_chip_sel_out,
			eth_clk_out => DM9000A_eth_clk_out,
			eth_cmd_out => DM9000A_eth_cmd_out,
			eth_data_inout(15 downto 0) => DM9000A_eth_data_inout(15 downto 0),
			eth_interrupt_in => DM9000A_eth_interrupt_in,
			eth_read_out => DM9000A_eth_read_out,
			eth_reset_out => DM9000A_eth_reset_out,
			eth_write_out => DM9000A_eth_write_out,
			fatal_error_out => floodertx_udpfatal_error_out,
			link_up_out => floodertx_udplink_up_out,
			new_rx_out => udp_flooderrxnew_rx_out,
			new_tx_in => floodertx_udpnew_tx_in,
			no_arp_target_MAC_in(47 downto 0) => floodertx_udpno_arp_target_MAC_in(47 downto 0),
			rst_n => rst_n_RESETn,
			rx_data_out(15 downto 0) => udp_flooderrxrx_data_out(15 downto 0),
			rx_data_valid_out => udp_flooderrxrx_data_valid_out,
			rx_erroneous_out => udp_flooderrxrx_erroneous_out,
			rx_error_out => udp_flooderrxrx_error_out,
			rx_len_out(10 downto 0) => udp_flooderrxrx_len_out(10 downto 0),
			rx_re_in => udp_flooderrxrx_re_in,
			source_addr_out(31 downto 0) => udp_flooderrxsource_addr_out(31 downto 0),
			source_port_in(15 downto 0) => floodertx_udpsource_port_in(15 downto 0),
			source_port_out(15 downto 0) => udp_flooderrxsource_port_out(15 downto 0),
			target_addr_in(31 downto 0) => floodertx_udptarget_addr_in(31 downto 0),
			target_port_in(15 downto 0) => floodertx_udptarget_port_in(15 downto 0),
			tx_data_in(15 downto 0) => floodertx_udptx_data_in(15 downto 0),
			tx_data_valid_in => floodertx_udptx_data_valid_in,
			tx_len_in(10 downto 0) => floodertx_udptx_len_in(10 downto 0),
			tx_re_out => floodertx_udptx_re_out
		);

end kactusHierarchical;

