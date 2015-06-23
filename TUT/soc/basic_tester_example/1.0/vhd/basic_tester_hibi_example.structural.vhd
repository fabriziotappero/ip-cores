-- ***************************************************
-- File: basic_tester_hibi_example.structural.vhd
-- Creation date: 03.02.2012
-- Creation time: 11:21:33
-- Description: 
-- Created by: ege
-- This file was generated with Kactus2 vhdl generator.
-- ***************************************************
library IEEE;
library work;
library hibi;
use work.all;
use hibi.all;
use IEEE.std_logic_1164.all;

entity basic_tester_hibi_example is

end basic_tester_hibi_example;


architecture structural of basic_tester_hibi_example is

	signal basic_tester_rx_1_hibi_port_to_hibi_segment_small_1_hibi_p1AV_TO_IP : std_logic;
	signal basic_tester_rx_1_hibi_port_to_hibi_segment_small_1_hibi_p1COMM_TO_IP : std_logic_vector(4 downto 0);
	signal basic_tester_rx_1_hibi_port_to_hibi_segment_small_1_hibi_p1DATA_TO_IP : std_logic_vector(31 downto 0);
	signal basic_tester_rx_1_hibi_port_to_hibi_segment_small_1_hibi_p1EMPTY_TO_IP : std_logic;
	signal basic_tester_rx_1_hibi_port_to_hibi_segment_small_1_hibi_p1ONE_D_TO_IP : std_logic;
	signal basic_tester_rx_1_hibi_port_to_hibi_segment_small_1_hibi_p1RE_FROM_IP : std_logic;
	signal clk_gen_1_Generated_clk_to_basic_tester_tx_1_clockCLK : std_logic;
	signal rst_gen_1_Generated_reset_to_basic_tester_tx_1_resetRESETn : std_logic;
	signal basic_tester_tx_1_hibi_port_to_hibi_segment_small_1_hibi_p2AV_FROM_IP : std_logic;
	signal basic_tester_tx_1_hibi_port_to_hibi_segment_small_1_hibi_p2COMM_FROM_IP : std_logic_vector(4 downto 0);
	signal basic_tester_tx_1_hibi_port_to_hibi_segment_small_1_hibi_p2DATA_FROM_IP : std_logic_vector(31 downto 0);
	signal basic_tester_tx_1_hibi_port_to_hibi_segment_small_1_hibi_p2FULL_TO_IP : std_logic;
	signal basic_tester_tx_1_hibi_port_to_hibi_segment_small_1_hibi_p2ONE_P_TO_IP : std_logic;
	signal basic_tester_tx_1_hibi_port_to_hibi_segment_small_1_hibi_p2WE_FROM_IP : std_logic;

	-- Simple unit for receiving test data. There are separate units for transmitting (tx) and receiving (rx). This one can check the data coming from a IP  (e.g. via HIBI). The other unit can send the commands to the tested IP.
	-- 
	-- This IP-XACT component is fixed to 32-bit data and 5-bit command.
	-- 
	-- Works only in simulation because configuration is done with ASCII file.
	component basic_tester_rx
		generic (
			comm_width_g : integer := 5;
			conf_file_g : string := "test_rx.txt"; -- File that contains 
			data_width_g : integer := 32

		);
		port (

			-- Interface: clock
			clk : in std_logic;

			-- Interface: hibi_port
			-- Tester sends data via this port. Regular and hi-prior data muxed. Addr and data muxed also.
			agent_av_in : in std_logic;
			agent_comm_in : in std_logic_vector(4 downto 0);
			agent_data_in : in std_logic_vector(31 downto 0);
			agent_empty_in : in std_logic;
			agent_one_d_in : in std_logic;
			agent_re_out : out std_logic;

			-- These ports are not in any interface
			-- done_out : out std_logic;

			-- Interface: reset
			rst_n : in std_logic -- Active low

		);
	end component;

	-- Simple unit for sending test data. There are separate units for transmitting (tx) and receiving (rx). This one sends commands to the tested IP (e.g. via HIBI). The other unit can then check the returned data. 
	-- 
	-- This IP-XACT component is fixed to 32-bit data and 5-bit command.
	-- 
	-- Works only in simulation because configuration is done with ASCII file.
	component basic_tester_tx
		generic (
			comm_width_g : integer := 5;
			conf_file_g : string := "test_tx.txt"; -- File that contains 
			data_width_g : integer := 32

		);
		port (

			-- Interface: clock
			clk : in std_logic;

			-- Interface: hibi_port
			-- Tester sends data via this port. Regular and hi-prior data muxed. Addr and data muxed also.
			agent_full_in : in std_logic;
			agent_one_p_in : in std_logic;
			agent_av_out : out std_logic;
			agent_comm_out : out std_logic_vector(4 downto 0);
			agent_data_out : out std_logic_vector(31 downto 0);
			agent_we_out : out std_logic;

			-- These ports are not in any interface
			-- done_out : out std_logic;

			-- Interface: reset
			rst_n : in std_logic -- Active low

		);
	end component;

	-- Shared bust for IP blocks
	component hibi_segment_small
		port (

			-- Interface: clk_in
			clk_in : in std_logic;

			-- Interface: ddr2_ctrl_p
			agent_addr_in_17 : in std_logic_vector(31 downto 0);
			agent_comm_in_17 : in std_logic_vector(4 downto 0);
			agent_data_in_17 : in std_logic_vector(31 downto 0);
			agent_msg_addr_in_17 : in std_logic_vector(31 downto 0);
			agent_msg_comm_in_17 : in std_logic_vector(4 downto 0);
			agent_msg_data_in_17 : in std_logic_vector(31 downto 0);
			agent_msg_re_in_17 : in std_logic;
			agent_msg_we_in_17 : in std_logic;
			agent_re_in_17 : in std_logic;
			agent_we_in_17 : in std_logic;
			-- agent_addr_out_17 : out std_logic_vector(31 downto 0);
			-- agent_comm_out_17 : out std_logic_vector(4 downto 0);
			-- agent_data_out_17 : out std_logic_vector(31 downto 0);
			-- agent_empty_out_17 : out std_logic;
			-- agent_full_out_17 : out std_logic;
			-- agent_msg_addr_out_17 : out std_logic_vector(31 downto 0);
			-- agent_msg_comm_out_17 : out std_logic_vector(4 downto 0);
			-- agent_msg_data_out_17 : out std_logic_vector(31 downto 0);
			-- agent_msg_empty_out_17 : out std_logic;
			-- agent_msg_full_out_17 : out std_logic;
			-- agent_msg_one_p_out_17 : out std_logic;
			-- agent_one_p_out_17 : out std_logic;

			-- Interface: hibi_p1
			agent_av_in_1 : in std_logic;
			agent_comm_in_1 : in std_logic_vector(4 downto 0);
			agent_data_in_1 : in std_logic_vector(31 downto 0);
			agent_re_in_1 : in std_logic;
			agent_we_in_1 : in std_logic;
			agent_av_out_1 : out std_logic;
			agent_comm_out_1 : out std_logic_vector(4 downto 0);
			agent_data_out_1 : out std_logic_vector(31 downto 0);
			agent_empty_out_1 : out std_logic;
			-- agent_full_out_1 : out std_logic;
			agent_one_d_out_1 : out std_logic;
			-- agent_one_p_out_1 : out std_logic;

			-- Interface: hibi_p2
			agent_av_in_2 : in std_logic;
			agent_comm_in_2 : in std_logic_vector(4 downto 0);
			agent_data_in_2 : in std_logic_vector(31 downto 0);
			agent_re_in_2 : in std_logic;
			agent_we_in_2 : in std_logic;
			-- agent_av_out_2 : out std_logic;
			-- agent_comm_out_2 : out std_logic_vector(4 downto 0);
			-- agent_data_out_2 : out std_logic_vector(31 downto 0);
			-- agent_empty_out_2 : out std_logic;
			agent_full_out_2 : out std_logic;
			-- agent_one_d_out_2 : out std_logic;
			agent_one_p_out_2 : out std_logic;

			-- Interface: hibi_p3
			agent_av_in_3 : in std_logic;
			agent_comm_in_3 : in std_logic_vector(4 downto 0);
			agent_data_in_3 : in std_logic_vector(31 downto 0);
			agent_re_in_3 : in std_logic;
			agent_we_in_3 : in std_logic;
			-- agent_av_out_3 : out std_logic;
			-- agent_comm_out_3 : out std_logic_vector(4 downto 0);
			-- agent_data_out_3 : out std_logic_vector(31 downto 0);
			-- agent_empty_out_3 : out std_logic;
			-- agent_full_out_3 : out std_logic;
			-- agent_one_d_out_3 : out std_logic;
			-- agent_one_p_out_3 : out std_logic;

			-- These ports are not in any interface
			-- agent_av_in_4 : in std_logic;
			-- agent_av_in_5 : in std_logic;
			-- agent_av_in_6 : in std_logic;
			-- agent_av_in_7 : in std_logic;
			-- agent_av_in_8 : in std_logic;
			-- agent_comm_in_4 : in std_logic_vector(4 downto 0);
			-- agent_comm_in_5 : in std_logic_vector(4 downto 0);
			-- agent_comm_in_6 : in std_logic_vector(4 downto 0);
			-- agent_comm_in_7 : in std_logic_vector(4 downto 0);
			-- agent_comm_in_8 : in std_logic_vector(4 downto 0);
			-- agent_data_in_4 : in std_logic_vector(31 downto 0);
			-- agent_data_in_5 : in std_logic_vector(31 downto 0);
			-- agent_data_in_6 : in std_logic_vector(31 downto 0);
			-- agent_data_in_7 : in std_logic_vector(31 downto 0);
			-- agent_data_in_8 : in std_logic_vector(31 downto 0);
			-- agent_re_in_4 : in std_logic;
			-- agent_re_in_5 : in std_logic;
			-- agent_re_in_6 : in std_logic;
			-- agent_re_in_7 : in std_logic;
			-- agent_re_in_8 : in std_logic;
			-- agent_we_in_4 : in std_logic;
			-- agent_we_in_5 : in std_logic;
			-- agent_we_in_6 : in std_logic;
			-- agent_we_in_7 : in std_logic;
			-- agent_we_in_8 : in std_logic;
			-- agent_av_out_4 : out std_logic;
			-- agent_av_out_5 : out std_logic;
			-- agent_av_out_6 : out std_logic;
			-- agent_av_out_7 : out std_logic;
			-- agent_av_out_8 : out std_logic;
			-- agent_comm_out_4 : out std_logic_vector(4 downto 0);
			-- agent_comm_out_5 : out std_logic_vector(4 downto 0);
			-- agent_comm_out_6 : out std_logic_vector(4 downto 0);
			-- agent_comm_out_7 : out std_logic_vector(4 downto 0);
			-- agent_comm_out_8 : out std_logic_vector(4 downto 0);
			-- agent_data_out_4 : out std_logic_vector(31 downto 0);
			-- agent_data_out_5 : out std_logic_vector(31 downto 0);
			-- agent_data_out_6 : out std_logic_vector(31 downto 0);
			-- agent_data_out_7 : out std_logic_vector(31 downto 0);
			-- agent_data_out_8 : out std_logic_vector(31 downto 0);
			-- agent_empty_out_4 : out std_logic;
			-- agent_empty_out_5 : out std_logic;
			-- agent_empty_out_6 : out std_logic;
			-- agent_empty_out_7 : out std_logic;
			-- agent_empty_out_8 : out std_logic;
			-- agent_full_out_4 : out std_logic;
			-- agent_full_out_5 : out std_logic;
			-- agent_full_out_6 : out std_logic;
			-- agent_full_out_7 : out std_logic;
			-- agent_full_out_8 : out std_logic;
			-- agent_one_d_out_4 : out std_logic;
			-- agent_one_d_out_5 : out std_logic;
			-- agent_one_d_out_6 : out std_logic;
			-- agent_one_d_out_7 : out std_logic;
			-- agent_one_d_out_8 : out std_logic;
			-- agent_one_p_out_4 : out std_logic;
			-- agent_one_p_out_5 : out std_logic;
			-- agent_one_p_out_6 : out std_logic;
			-- agent_one_p_out_7 : out std_logic;
			-- agent_one_p_out_8 : out std_logic;

			-- Interface: rst_n
			rst_n_in : in std_logic

		);
	end component;

	component clk_gen
		generic (
			hi_period_ns_g : integer := 1;
			lo_period_ns_g : integer := 1

		);
		port (

			-- Interface: Generated_clk
			clk_out : out std_logic

		);
	end component;

	component rst_gen
		generic (
			active_period_ns_g : integer := 100

		);
		port (

			-- Interface: Generated_reset
			rst_out : out std_logic

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

	basic_tester_rx_1 : basic_tester_rx
		generic map (
			conf_file_g => "test_rx.txt"
		)
		port map (
			agent_av_in => basic_tester_rx_1_hibi_port_to_hibi_segment_small_1_hibi_p1AV_TO_IP,
			agent_comm_in(4 downto 0) => basic_tester_rx_1_hibi_port_to_hibi_segment_small_1_hibi_p1COMM_TO_IP(4 downto 0),
			agent_data_in(31 downto 0) => basic_tester_rx_1_hibi_port_to_hibi_segment_small_1_hibi_p1DATA_TO_IP(31 downto 0),
			agent_empty_in => basic_tester_rx_1_hibi_port_to_hibi_segment_small_1_hibi_p1EMPTY_TO_IP,
			agent_one_d_in => basic_tester_rx_1_hibi_port_to_hibi_segment_small_1_hibi_p1ONE_D_TO_IP,
			agent_re_out => basic_tester_rx_1_hibi_port_to_hibi_segment_small_1_hibi_p1RE_FROM_IP,
			clk => clk_gen_1_Generated_clk_to_basic_tester_tx_1_clockCLK,
			rst_n => rst_gen_1_Generated_reset_to_basic_tester_tx_1_resetRESETn
		);

	basic_tester_tx_1 : basic_tester_tx
		generic map (
			conf_file_g => "test_tx.txt"
		)
		port map (
			agent_av_out => basic_tester_tx_1_hibi_port_to_hibi_segment_small_1_hibi_p2AV_FROM_IP,
			agent_comm_out(4 downto 0) => basic_tester_tx_1_hibi_port_to_hibi_segment_small_1_hibi_p2COMM_FROM_IP(4 downto 0),
			agent_data_out(31 downto 0) => basic_tester_tx_1_hibi_port_to_hibi_segment_small_1_hibi_p2DATA_FROM_IP(31 downto 0),
			agent_full_in => basic_tester_tx_1_hibi_port_to_hibi_segment_small_1_hibi_p2FULL_TO_IP,
			agent_one_p_in => basic_tester_tx_1_hibi_port_to_hibi_segment_small_1_hibi_p2ONE_P_TO_IP,
			agent_we_out => basic_tester_tx_1_hibi_port_to_hibi_segment_small_1_hibi_p2WE_FROM_IP,
			clk => clk_gen_1_Generated_clk_to_basic_tester_tx_1_clockCLK,
			rst_n => rst_gen_1_Generated_reset_to_basic_tester_tx_1_resetRESETn
		);

	clk_gen_1 : clk_gen
		generic map (
			hi_period_ns_g => 5,
			lo_period_ns_g => 3
		)
		port map (
			clk_out => clk_gen_1_Generated_clk_to_basic_tester_tx_1_clockCLK
		);

	hibi_segment_small_1 : hibi_segment_small
		port map (
			agent_addr_in_17 => (others => '0'),
			agent_av_in_1 => '0',
			agent_av_in_2 => basic_tester_tx_1_hibi_port_to_hibi_segment_small_1_hibi_p2AV_FROM_IP,
			agent_av_in_3 => '0',
			agent_av_out_1 => basic_tester_rx_1_hibi_port_to_hibi_segment_small_1_hibi_p1AV_TO_IP,
			agent_comm_in_1 => (others => '0'),
			agent_comm_in_17 => (others => '0'),
			agent_comm_in_2(4 downto 0) => basic_tester_tx_1_hibi_port_to_hibi_segment_small_1_hibi_p2COMM_FROM_IP(4 downto 0),
			agent_comm_in_3 => (others => '0'),
			agent_comm_out_1(4 downto 0) => basic_tester_rx_1_hibi_port_to_hibi_segment_small_1_hibi_p1COMM_TO_IP(4 downto 0),
			agent_data_in_1 => (others => '0'),
			agent_data_in_17 => (others => '0'),
			agent_data_in_2(31 downto 0) => basic_tester_tx_1_hibi_port_to_hibi_segment_small_1_hibi_p2DATA_FROM_IP(31 downto 0),
			agent_data_in_3 => (others => '0'),
			agent_data_out_1(31 downto 0) => basic_tester_rx_1_hibi_port_to_hibi_segment_small_1_hibi_p1DATA_TO_IP(31 downto 0),
			agent_empty_out_1 => basic_tester_rx_1_hibi_port_to_hibi_segment_small_1_hibi_p1EMPTY_TO_IP,
			agent_full_out_2 => basic_tester_tx_1_hibi_port_to_hibi_segment_small_1_hibi_p2FULL_TO_IP,
			agent_msg_addr_in_17 => (others => '0'),
			agent_msg_comm_in_17 => (others => '0'),
			agent_msg_data_in_17 => (others => '0'),
			agent_msg_re_in_17 => '0',
			agent_msg_we_in_17 => '0',
			agent_one_d_out_1 => basic_tester_rx_1_hibi_port_to_hibi_segment_small_1_hibi_p1ONE_D_TO_IP,
			agent_one_p_out_2 => basic_tester_tx_1_hibi_port_to_hibi_segment_small_1_hibi_p2ONE_P_TO_IP,
			agent_re_in_1 => basic_tester_rx_1_hibi_port_to_hibi_segment_small_1_hibi_p1RE_FROM_IP,
			agent_re_in_17 => '0',
			agent_re_in_2 => '0',
			agent_re_in_3 => '0',
			agent_we_in_1 => '0',
			agent_we_in_17 => '0',
			agent_we_in_2 => basic_tester_tx_1_hibi_port_to_hibi_segment_small_1_hibi_p2WE_FROM_IP,
			agent_we_in_3 => '0',
			clk_in => clk_gen_1_Generated_clk_to_basic_tester_tx_1_clockCLK,
			rst_n_in => rst_gen_1_Generated_reset_to_basic_tester_tx_1_resetRESETn
		);

	rst_gen_1 : rst_gen
		port map (
			rst_out => rst_gen_1_Generated_reset_to_basic_tester_tx_1_resetRESETn
		);

end structural;

