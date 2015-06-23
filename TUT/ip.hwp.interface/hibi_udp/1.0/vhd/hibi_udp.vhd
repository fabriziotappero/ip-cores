-- ***************************************************
-- File: hibi_udp.vhd
-- Creation date: 27.03.2013
-- Creation time: 09:27:53
-- Description: 
-- Created by: matilail
-- This file was generated with Kactus2 vhdl generator.
-- ***************************************************
library IEEE;
library udp2hibi;
library work;
use IEEE.std_logic_1164.all;
use udp2hibi.all;
use work.all;

entity hibi_udp is

	port (

		-- Interface: clk
		clk : in std_logic;

		-- Interface: clk_udp
		clk_udp : in std_logic;

		-- Interface: DM9000A
		eth_interrupt_in : in std_logic;
		eth_chip_sel_out : out std_logic;
		eth_clk_out : out std_logic;
		eth_cmd_out : out std_logic;
		eth_read_out : out std_logic;
		eth_reset_out : out std_logic;
		eth_write_out : out std_logic;
		eth_data_inout : inout std_logic_vector(15 downto 0);

		-- Interface: hibi_master
		hibi_av_out : out std_logic;
		hibi_comm_out : out std_logic_vector(4 downto 0);
		hibi_data_out : out std_logic_vector(31 downto 0);
		hibi_re_out : out std_logic;
		hibi_we_out : out std_logic;

		-- Interface: hibi_slave
		hibi_av_in : in std_logic;
		hibi_comm_in : in std_logic_vector(4 downto 0);
		hibi_data_in : in std_logic_vector(31 downto 0);
		hibi_empty_in : in std_logic;
		hibi_full_in : in std_logic;

		-- Interface: rst_n
		rst_n : in std_logic
	);

end hibi_udp;


architecture structural of hibi_udp is

	signal udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxdest_port_out : std_logic_vector(15 downto 0);
	signal udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxlink_up_out : std_logic;
	signal udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxnew_rx_out : std_logic;
	signal udp2hibi_0_udp_ip_tx_to_udp_ip_dm9000a_0_app_txnew_tx_in : std_logic;
	signal udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxrx_data_out : std_logic_vector(15 downto 0);
	signal udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxrx_data_valid_out : std_logic;
	signal udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxrx_erroneous_out : std_logic;
	signal udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxrx_len_out : std_logic_vector(10 downto 0);
	signal udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxrx_re_in : std_logic;
	signal udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxsource_addr_out : std_logic_vector(31 downto 0);
	signal udp2hibi_0_udp_ip_tx_to_udp_ip_dm9000a_0_app_txsource_port_in : std_logic_vector(15 downto 0);
	signal udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxsource_port_out : std_logic_vector(15 downto 0);
	signal udp2hibi_0_udp_ip_tx_to_udp_ip_dm9000a_0_app_txtarget_addr_in : std_logic_vector(31 downto 0);
	signal udp2hibi_0_udp_ip_tx_to_udp_ip_dm9000a_0_app_txtarget_port_in : std_logic_vector(15 downto 0);
	signal udp2hibi_0_udp_ip_tx_to_udp_ip_dm9000a_0_app_txtx_data_in : std_logic_vector(15 downto 0);
	signal udp2hibi_0_udp_ip_tx_to_udp_ip_dm9000a_0_app_txtx_data_valid_in : std_logic;
	signal udp2hibi_0_udp_ip_tx_to_udp_ip_dm9000a_0_app_txtx_len_in : std_logic_vector(10 downto 0);
	signal udp2hibi_0_udp_ip_tx_to_udp_ip_dm9000a_0_app_txtx_re_out : std_logic;

	-- - Interface between a UDP/IP block and the HIBI bus.
	-- - Capable of handling one transmission and one incoming packet at a time
	-- - UDP2HIBI uses HIBI addresses to separate transfers from different agents
	-- - So all agents must use different addresses when sending to UDP2HIBI
	-- 
	component udp2hibi
		generic (
			ack_fifo_depth_g : integer := 4;
			frequency_g : integer := 50000000;
			hibi_addr_width_g : integer := 32;
			hibi_comm_width_g : integer := 5;
			hibi_data_width_g : integer := 32;
			hibi_tx_fifo_depth_g : integer := 10;
			receiver_table_size_g : integer := 4;
			rx_multiclk_fifo_depth_g : integer := 10;
			tx_multiclk_fifo_depth_g : integer := 10

		);
		port (

			-- Interface: clk
			-- clock input
			clk : in std_logic;

			-- Interface: clk_udp
			-- clock udp input (25MHz)
			clk_udp : in std_logic;

			-- Interface: hibi_master
			-- HIBI master interface
			hibi_av_out : out std_logic;
			hibi_comm_out : out std_logic_vector(4 downto 0);
			hibi_data_out : out std_logic_vector(31 downto 0);
			hibi_re_out : out std_logic;
			hibi_we_out : out std_logic;

			-- Interface: hibi_slave
			-- HIBI slave interface
			hibi_av_in : in std_logic;
			hibi_comm_in : in std_logic_vector(4 downto 0);
			hibi_data_in : in std_logic_vector(31 downto 0);
			hibi_empty_in : in std_logic;
			hibi_full_in : in std_logic;

			-- Interface: rst_n
			-- active low reset
			rst_n : in std_logic;

			-- Interface: udp_ip_rx
			-- udp_ip_rx
			dest_port_in : in std_logic_vector(15 downto 0);
			eth_link_up_in : in std_logic;
			new_rx_in : in std_logic;
			rx_data_in : in std_logic_vector(15 downto 0);
			rx_data_valid_in : in std_logic;
			rx_erroneous_in : in std_logic;
			rx_len_in : in std_logic_vector(10 downto 0);
			source_ip_in : in std_logic_vector(31 downto 0);
			source_port_in : in std_logic_vector(15 downto 0);
			rx_re_out : out std_logic;

			-- Interface: udp_ip_tx
			-- udp_ip_tx
			tx_re_in : in std_logic;
			dest_ip_out : out std_logic_vector(31 downto 0);
			dest_port_out : out std_logic_vector(15 downto 0);
			new_tx_out : out std_logic;
			source_port_out : out std_logic_vector(15 downto 0);
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
			-- rx_error_out : out std_logic;
			rx_len_out : out std_logic_vector(10 downto 0);
			source_addr_out : out std_logic_vector(31 downto 0);
			source_port_out : out std_logic_vector(15 downto 0);

			-- Interface: app_tx
			-- Application transmit operations
			new_tx_in : in std_logic;
			-- no_arp_target_MAC_in : in std_logic_vector(47 downto 0);
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
			-- fatal_error_out : out std_logic;
			link_up_out : out std_logic

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

	udp2hibi_0 : udp2hibi
		port map (
			clk => clk,
			clk_udp => clk_udp,
			dest_ip_out(31 downto 0) => udp2hibi_0_udp_ip_tx_to_udp_ip_dm9000a_0_app_txtarget_addr_in(31 downto 0),
			dest_port_in(15 downto 0) => udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxdest_port_out(15 downto 0),
			dest_port_out(15 downto 0) => udp2hibi_0_udp_ip_tx_to_udp_ip_dm9000a_0_app_txtarget_port_in(15 downto 0),
			eth_link_up_in => udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxlink_up_out,
			hibi_av_in => hibi_av_in,
			hibi_av_out => hibi_av_out,
			hibi_comm_in(4 downto 0) => hibi_comm_in(4 downto 0),
			hibi_comm_out(4 downto 0) => hibi_comm_out(4 downto 0),
			hibi_data_in(31 downto 0) => hibi_data_in(31 downto 0),
			hibi_data_out(31 downto 0) => hibi_data_out(31 downto 0),
			hibi_empty_in => hibi_empty_in,
			hibi_full_in => hibi_full_in,
			hibi_re_out => hibi_re_out,
			hibi_we_out => hibi_we_out,
			new_rx_in => udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxnew_rx_out,
			new_tx_out => udp2hibi_0_udp_ip_tx_to_udp_ip_dm9000a_0_app_txnew_tx_in,
			rst_n => rst_n,
			rx_data_in(15 downto 0) => udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxrx_data_out(15 downto 0),
			rx_data_valid_in => udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxrx_data_valid_out,
			rx_erroneous_in => udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxrx_erroneous_out,
			rx_len_in(10 downto 0) => udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxrx_len_out(10 downto 0),
			rx_re_out => udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxrx_re_in,
			source_ip_in(31 downto 0) => udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxsource_addr_out(31 downto 0),
			source_port_in(15 downto 0) => udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxsource_port_out(15 downto 0),
			source_port_out(15 downto 0) => udp2hibi_0_udp_ip_tx_to_udp_ip_dm9000a_0_app_txsource_port_in(15 downto 0),
			tx_data_out(15 downto 0) => udp2hibi_0_udp_ip_tx_to_udp_ip_dm9000a_0_app_txtx_data_in(15 downto 0),
			tx_data_valid_out => udp2hibi_0_udp_ip_tx_to_udp_ip_dm9000a_0_app_txtx_data_valid_in,
			tx_len_out(10 downto 0) => udp2hibi_0_udp_ip_tx_to_udp_ip_dm9000a_0_app_txtx_len_in(10 downto 0),
			tx_re_in => udp2hibi_0_udp_ip_tx_to_udp_ip_dm9000a_0_app_txtx_re_out
		);

	udp_ip_dm9000a_0 : udp_ip_dm9000a
		port map (
			clk => clk_udp,
			dest_port_out(15 downto 0) => udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxdest_port_out(15 downto 0),
			eth_chip_sel_out => eth_chip_sel_out,
			eth_clk_out => eth_clk_out,
			eth_cmd_out => eth_cmd_out,
			eth_data_inout(15 downto 0) => eth_data_inout(15 downto 0),
			eth_interrupt_in => eth_interrupt_in,
			eth_read_out => eth_read_out,
			eth_reset_out => eth_reset_out,
			eth_write_out => eth_write_out,
			link_up_out => udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxlink_up_out,
			new_rx_out => udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxnew_rx_out,
			new_tx_in => udp2hibi_0_udp_ip_tx_to_udp_ip_dm9000a_0_app_txnew_tx_in,
			rst_n => rst_n,
			rx_data_out(15 downto 0) => udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxrx_data_out(15 downto 0),
			rx_data_valid_out => udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxrx_data_valid_out,
			rx_erroneous_out => udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxrx_erroneous_out,
			rx_len_out(10 downto 0) => udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxrx_len_out(10 downto 0),
			rx_re_in => udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxrx_re_in,
			source_addr_out(31 downto 0) => udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxsource_addr_out(31 downto 0),
			source_port_in(15 downto 0) => udp2hibi_0_udp_ip_tx_to_udp_ip_dm9000a_0_app_txsource_port_in(15 downto 0),
			source_port_out(15 downto 0) => udp_ip_dm9000a_0_app_rx_to_udp2hibi_0_udp_ip_rxsource_port_out(15 downto 0),
			target_addr_in(31 downto 0) => udp2hibi_0_udp_ip_tx_to_udp_ip_dm9000a_0_app_txtarget_addr_in(31 downto 0),
			target_port_in(15 downto 0) => udp2hibi_0_udp_ip_tx_to_udp_ip_dm9000a_0_app_txtarget_port_in(15 downto 0),
			tx_data_in(15 downto 0) => udp2hibi_0_udp_ip_tx_to_udp_ip_dm9000a_0_app_txtx_data_in(15 downto 0),
			tx_data_valid_in => udp2hibi_0_udp_ip_tx_to_udp_ip_dm9000a_0_app_txtx_data_valid_in,
			tx_len_in(10 downto 0) => udp2hibi_0_udp_ip_tx_to_udp_ip_dm9000a_0_app_txtx_len_in(10 downto 0),
			tx_re_out => udp2hibi_0_udp_ip_tx_to_udp_ip_dm9000a_0_app_txtx_re_out
		);

end structural;

