-- ***************************************************
-- File: basic_tester_hibi_example.vhd
-- Creation date: 23.11.2012
-- Creation time: 16:44:19
-- Description: Simple example on how to use basic_tester with hibi.
-- Hibi is instantiated a) as a segment, b) from 4 wrappers and an OR-network. 
-- 
--  Tx sends few words to rx which takes and checks them. 
-- Basic_tester is meant for simulation only.
-- Created by: matilail
-- This file was generated with Kactus2 vhdl generator.
-- ***************************************************
library IEEE;
library work;
use work.all;
use IEEE.std_logic_1164.all;

entity basic_tester_hibi_example is

end basic_tester_hibi_example;

-- Instantiates hibi as segement.
-- Graphical block diagram view. Hence, its type is "hierarchical".
architecture structural_seg of basic_tester_hibi_example is

	signal basic_tester_rx_0_hibi_slave_to_hibi_segment_0_ip_mSlave_1AV : std_logic;
	signal basic_tester_rx_0_hibi_slave_to_hibi_segment_0_ip_mSlave_1COMM : std_logic_vector(4 downto 0);
	signal basic_tester_rx_0_hibi_slave_to_hibi_segment_0_ip_mSlave_1DATA : std_logic_vector(31 downto 0);
	signal basic_tester_rx_0_hibi_slave_to_hibi_segment_0_ip_mSlave_1EMPTY : std_logic;
	signal basic_tester_rx_0_hibi_slave_to_hibi_segment_0_ip_mSlave_1ONE_D : std_logic;
	signal basic_tester_rx_0_hibi_master_to_hibi_segment_0_ip_mMaster_1RE : std_logic;
	signal clk_gen_0_Generated_hibi_clk_to_hibi_segment_0_clocks_0AGENT_SYNC_CLK : std_logic;
	signal rst_gen_0_Generated_reset_to_hibi_segment_0_rst_nRESETn : std_logic;
	signal hibi_segment_0_ip_mMaster_0_to_basic_tester_tx_0_hibi_masterAV : std_logic;
	signal hibi_segment_0_ip_mMaster_0_to_basic_tester_tx_0_hibi_masterCOMM : std_logic_vector(4 downto 0);
	signal hibi_segment_0_ip_mMaster_0_to_basic_tester_tx_0_hibi_masterDATA : std_logic_vector(31 downto 0);
	signal hibi_segment_0_ip_mSlave_0_to_basic_tester_tx_0_hibi_slaveFULL : std_logic;
	signal hibi_segment_0_ip_mSlave_0_to_basic_tester_tx_0_hibi_slaveONE_P : std_logic;
	signal hibi_segment_0_ip_mMaster_0_to_basic_tester_tx_0_hibi_masterWE : std_logic;

	-- Simple unit for receiving test data. There are separate units for transmitting (tx) and receiving (rx). This one can check the data coming from a IP  (e.g. via HIBI). The other unit can send the commands to the tested IP.
	-- 
	-- This IP-XACT component is fixed to 32-bit data and 5-bit command.
	-- 
	-- Works only in simulation because configuration is done with ASCII file.
	component basic_tester_rx
		generic (
			comm_width_g : integer := 5;
			conf_file_g : string := "test_rx.txt"; -- File that contains parameters for expected incoming data
			data_width_g : integer := 32

		);
		port (

			-- Interface: clock
			clk : in std_logic;

			-- Interface: hibi_master
			-- Tester sends data via this port. Regular and hi-prior data muxed. Addr and data muxed also.
			agent_re_out : out std_logic;

			-- Interface: hibi_slave
			agent_av_in : in std_logic;
			agent_comm_in : in std_logic_vector(4 downto 0);
			agent_data_in : in std_logic_vector(31 downto 0);
			agent_empty_in : in std_logic;
			agent_one_d_in : in std_logic;

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
			conf_file_g : string := "test_tx.txt"; -- File that contains the sent data
			data_width_g : integer := 32

		);
		port (

			-- Interface: clock
			clk : in std_logic;

			-- Interface: hibi_master
			-- Tester sends data via this port. Regular and hi-prior data muxed. Addr and data muxed also.
			agent_av_out : out std_logic;
			agent_comm_out : out std_logic_vector(4 downto 0);
			agent_data_out : out std_logic_vector(31 downto 0);
			agent_we_out : out std_logic;

			-- Interface: hibi_slave
			agent_full_in : in std_logic;
			agent_one_p_in : in std_logic;

			-- These ports are not in any interface
			-- done_out : out std_logic;

			-- Interface: reset
			rst_n : in std_logic -- Active low

		);
	end component;

	component hibi_segment
		generic (
			ip_mslave_0_addr_end : integer := 2; -- HIBI end address for interface 0
			ip_mslave_0_addr_start : integer := 1; -- HIBI address for interface 0
			ip_mslave_1_addr_end : integer := 4; -- HIBI end address for interface 1
			ip_mslave_1_addr_start : integer := 3; -- HIBI address for interface 1
			ip_mslave_2_addr_end : integer := 6; -- HIBI end address for interface 2
			ip_mslave_2_addr_start : integer := 5; -- HIBI address for interface 2
			ip_mslave_3_addr_end : integer := 8; -- HIBI end address for interface 3
			ip_mslave_3_addr_start : integer := 7 -- HIBI address for interface 3

		);
		port (

			-- Interface: clocks_0
			-- Clock inputs  interface for hibi wrapper_3
			agent_clk : in std_logic;
			agent_sync_clk : in std_logic;
			bus_clk : in std_logic;
			bus_sync_clk : in std_logic;

			-- Interface: clocks_1
			-- Clock inputs  interface for hibi wrapper_3
			agent_clk_1 : in std_logic;
			agent_sync_clk_1 : in std_logic;
			bus_clk_1 : in std_logic;
			bus_sync_clk_1 : in std_logic;

			-- Interface: clocks_2
			-- Clock inputs  interface for hibi wrapper_3
			agent_clk_2 : in std_logic;
			agent_sync_clk_2 : in std_logic;
			bus_clk_2 : in std_logic;
			bus_sync_clk_2 : in std_logic;

			-- Interface: clocks_3
			-- Clock inputs  interface for hibi wrapper_3
			agent_clk_3 : in std_logic;
			agent_sync_clk_3 : in std_logic;
			bus_clk_3 : in std_logic;
			bus_sync_clk_3 : in std_logic;

			-- Interface: ip_mMaster_0
			-- HIBI ip mirrored master agent interface 0 (r4 wrapper)
			agent_av_in : in std_logic;
			agent_comm_in : in std_logic_vector(4 downto 0);
			agent_data_in : in std_logic_vector(31 downto 0);
			agent_re_in : in std_logic;
			agent_we_in : in std_logic;

			-- Interface: ip_mMaster_1
			-- HIBI ip mirrored master agent interface 1 (r4 wrapper)
			agent_av_in_1 : in std_logic;
			agent_comm_in_1 : in std_logic_vector(4 downto 0);
			agent_data_in_1 : in std_logic_vector(31 downto 0);
			agent_re_in_1 : in std_logic;
			agent_we_in_1 : in std_logic;

			-- Interface: ip_mMaster_2
			-- HIBI ip mirrored master agent interface 2 (r4 wrapper)
			agent_av_in_2 : in std_logic;
			agent_comm_in_2 : in std_logic_vector(4 downto 0);
			agent_data_in_2 : in std_logic_vector(31 downto 0);
			agent_re_in_2 : in std_logic;
			agent_we_in_2 : in std_logic;

			-- Interface: ip_mMaster_3
			-- HIBI ip mirrored master agent interface 3 (r4 wrapper)
			agent_av_in_3 : in std_logic;
			agent_comm_in_3 : in std_logic_vector(4 downto 0);
			agent_data_in_3 : in std_logic_vector(31 downto 0);
			agent_re_in_3 : in std_logic;
			agent_we_in_3 : in std_logic;

			-- Interface: ip_mSlave_0
			-- HIBI ip mirrored slave agent interface 0 (r4 wrapper)
			-- agent_av_out : out std_logic;
			-- agent_comm_out : out std_logic_vector(4 downto 0);
			-- agent_data_out : out std_logic_vector(31 downto 0);
			-- agent_empty_out : out std_logic;
			agent_full_out : out std_logic;
			-- agent_one_d_out : out std_logic;
			agent_one_p_out : out std_logic;

			-- Interface: ip_mSlave_1
			-- HIBI ip mirrored slave agent interface 1  (r4 wrapper)
			agent_av_out_1 : out std_logic;
			agent_comm_out_1 : out std_logic_vector(4 downto 0);
			agent_data_out_1 : out std_logic_vector(31 downto 0);
			agent_empty_out_1 : out std_logic;
			-- agent_full_out_1 : out std_logic;
			agent_one_d_out_1 : out std_logic;
			-- agent_one_p_out_1 : out std_logic;

			-- Interface: ip_mSlave_2
			-- HIBI ip mirrored slave agent interface 2 (r4 wrapper)
			-- agent_av_out_2 : out std_logic;
			-- agent_comm_out_2 : out std_logic_vector(4 downto 0);
			-- agent_data_out_2 : out std_logic_vector(31 downto 0);
			-- agent_empty_out_2 : out std_logic;
			-- agent_full_out_2 : out std_logic;
			-- agent_one_d_out_2 : out std_logic;
			-- agent_one_p_out_2 : out std_logic;

			-- Interface: ip_mSlave_3
			-- HIBI ip mirrored slave agent interface_3 (r4 wrapper)
			-- agent_av_out_3 : out std_logic;
			-- agent_comm_out_3 : out std_logic_vector(4 downto 0);
			-- agent_data_out_3 : out std_logic_vector(31 downto 0);
			-- agent_empty_out_3 : out std_logic;
			-- agent_full_out_3 : out std_logic;
			-- agent_one_d_out_3 : out std_logic;
			-- agent_one_p_out_3 : out std_logic;

			-- Interface: rst_n
			-- Active low reset interface.
			rst_n : in std_logic

		);
	end component;

	-- Simple clock generator dor simulation.
	component clk_gen
		generic (
			hi_period_ns_g : integer := 1;
			lo_period_ns_g : integer := 1

		);
		port (

			-- There ports are contained in many interfaces
			clk_out : out std_logic

		);
	end component;

	-- Simple active-low reset signal generator dor simulation
	component rst_gen
		generic (
			active_period_ns_g : integer := 100

		);
		port (

			-- Interface: Generated_reset
			rst_n_out : out std_logic

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

	basic_tester_rx_0 : basic_tester_rx
		generic map (
			conf_file_g => "test_rx.txt"
		)
		port map (
			agent_av_in => basic_tester_rx_0_hibi_slave_to_hibi_segment_0_ip_mSlave_1AV,
			agent_comm_in(4 downto 0) => basic_tester_rx_0_hibi_slave_to_hibi_segment_0_ip_mSlave_1COMM(4 downto 0),
			agent_data_in(31 downto 0) => basic_tester_rx_0_hibi_slave_to_hibi_segment_0_ip_mSlave_1DATA(31 downto 0),
			agent_empty_in => basic_tester_rx_0_hibi_slave_to_hibi_segment_0_ip_mSlave_1EMPTY,
			agent_one_d_in => basic_tester_rx_0_hibi_slave_to_hibi_segment_0_ip_mSlave_1ONE_D,
			agent_re_out => basic_tester_rx_0_hibi_master_to_hibi_segment_0_ip_mMaster_1RE,
			clk => clk_gen_0_Generated_hibi_clk_to_hibi_segment_0_clocks_0AGENT_SYNC_CLK,
			rst_n => rst_gen_0_Generated_reset_to_hibi_segment_0_rst_nRESETn
		);

	basic_tester_tx_0 : basic_tester_tx
		generic map (
			conf_file_g => "test_tx.txt"
		)
		port map (
			agent_av_out => hibi_segment_0_ip_mMaster_0_to_basic_tester_tx_0_hibi_masterAV,
			agent_comm_out(4 downto 0) => hibi_segment_0_ip_mMaster_0_to_basic_tester_tx_0_hibi_masterCOMM(4 downto 0),
			agent_data_out(31 downto 0) => hibi_segment_0_ip_mMaster_0_to_basic_tester_tx_0_hibi_masterDATA(31 downto 0),
			agent_full_in => hibi_segment_0_ip_mSlave_0_to_basic_tester_tx_0_hibi_slaveFULL,
			agent_one_p_in => hibi_segment_0_ip_mSlave_0_to_basic_tester_tx_0_hibi_slaveONE_P,
			agent_we_out => hibi_segment_0_ip_mMaster_0_to_basic_tester_tx_0_hibi_masterWE,
			clk => clk_gen_0_Generated_hibi_clk_to_hibi_segment_0_clocks_0AGENT_SYNC_CLK,
			rst_n => rst_gen_0_Generated_reset_to_hibi_segment_0_rst_nRESETn
		);

	clk_gen_0 : clk_gen
		port map (
			clk_out => clk_gen_0_Generated_hibi_clk_to_hibi_segment_0_clocks_0AGENT_SYNC_CLK
		);

	hibi_segment_0 : hibi_segment
		port map (
			agent_av_in => hibi_segment_0_ip_mMaster_0_to_basic_tester_tx_0_hibi_masterAV,
			agent_av_in_1 => '0',
			agent_av_in_2 => '0',
			agent_av_in_3 => '0',
			agent_av_out_1 => basic_tester_rx_0_hibi_slave_to_hibi_segment_0_ip_mSlave_1AV,
			agent_clk => clk_gen_0_Generated_hibi_clk_to_hibi_segment_0_clocks_0AGENT_SYNC_CLK,
			agent_clk_1 => clk_gen_0_Generated_hibi_clk_to_hibi_segment_0_clocks_0AGENT_SYNC_CLK,
			agent_clk_2 => '0',
			agent_clk_3 => '0',
			agent_comm_in(4 downto 0) => hibi_segment_0_ip_mMaster_0_to_basic_tester_tx_0_hibi_masterCOMM(4 downto 0),
			agent_comm_in_1 => (others => '0'),
			agent_comm_in_2 => (others => '0'),
			agent_comm_in_3 => (others => '0'),
			agent_comm_out_1(4 downto 0) => basic_tester_rx_0_hibi_slave_to_hibi_segment_0_ip_mSlave_1COMM(4 downto 0),
			agent_data_in(31 downto 0) => hibi_segment_0_ip_mMaster_0_to_basic_tester_tx_0_hibi_masterDATA(31 downto 0),
			agent_data_in_1 => (others => '0'),
			agent_data_in_2 => (others => '0'),
			agent_data_in_3 => (others => '0'),
			agent_data_out_1(31 downto 0) => basic_tester_rx_0_hibi_slave_to_hibi_segment_0_ip_mSlave_1DATA(31 downto 0),
			agent_empty_out_1 => basic_tester_rx_0_hibi_slave_to_hibi_segment_0_ip_mSlave_1EMPTY,
			agent_full_out => hibi_segment_0_ip_mSlave_0_to_basic_tester_tx_0_hibi_slaveFULL,
			agent_one_d_out_1 => basic_tester_rx_0_hibi_slave_to_hibi_segment_0_ip_mSlave_1ONE_D,
			agent_one_p_out => hibi_segment_0_ip_mSlave_0_to_basic_tester_tx_0_hibi_slaveONE_P,
			agent_re_in => '0',
			agent_re_in_1 => basic_tester_rx_0_hibi_master_to_hibi_segment_0_ip_mMaster_1RE,
			agent_re_in_2 => '0',
			agent_re_in_3 => '0',
			agent_sync_clk => clk_gen_0_Generated_hibi_clk_to_hibi_segment_0_clocks_0AGENT_SYNC_CLK,
			agent_sync_clk_1 => clk_gen_0_Generated_hibi_clk_to_hibi_segment_0_clocks_0AGENT_SYNC_CLK,
			agent_sync_clk_2 => '0',
			agent_sync_clk_3 => '0',
			agent_we_in => hibi_segment_0_ip_mMaster_0_to_basic_tester_tx_0_hibi_masterWE,
			agent_we_in_1 => '0',
			agent_we_in_2 => '0',
			agent_we_in_3 => '0',
			bus_clk => clk_gen_0_Generated_hibi_clk_to_hibi_segment_0_clocks_0AGENT_SYNC_CLK,
			bus_clk_1 => clk_gen_0_Generated_hibi_clk_to_hibi_segment_0_clocks_0AGENT_SYNC_CLK,
			bus_clk_2 => '0',
			bus_clk_3 => '0',
			bus_sync_clk => clk_gen_0_Generated_hibi_clk_to_hibi_segment_0_clocks_0AGENT_SYNC_CLK,
			bus_sync_clk_1 => clk_gen_0_Generated_hibi_clk_to_hibi_segment_0_clocks_0AGENT_SYNC_CLK,
			bus_sync_clk_2 => '0',
			bus_sync_clk_3 => '0',
			rst_n => rst_gen_0_Generated_reset_to_hibi_segment_0_rst_nRESETn
		);

	rst_gen_0 : rst_gen
		port map (
			rst_n_out => rst_gen_0_Generated_reset_to_hibi_segment_0_rst_nRESETn
		);

end structural_seg;

