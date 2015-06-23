-- ***************************************************
-- File: led_fh_mesh_2d_example.kactusHierarchical.vhd
-- Creation date: 09.12.2011
-- Creation time: 09:50:00
-- Description: 
-- Created by: ege
-- This file was generated with Kactus2 vhdl generator.
-- ***************************************************
library IEEE;
library work;
use work.all;
use IEEE.std_logic_1164.all;

entity led_fh_mesh_2d_example is

	port (

		-- Interface: clk
		clk : in std_logic;

		-- Interface: led_0
		led_0_out : out std_logic;

		-- Interface: led_1
		led_1_out : out std_logic;

		-- Interface: led_2
		led_2_out : out std_logic;

		-- Interface: led_3
		led_3_out : out std_logic;

		-- Interface: led_4
		led_4_out : out std_logic;

		-- Interface: led_5
		led_5_out : out std_logic;

		-- Interface: led_6
		led_6_out : out std_logic;

		-- Interface: led_7
		led_7_out : out std_logic;

		-- Interface: rst_n
		rst_n : in std_logic;

		-- Interface: switch_0
		switch_0_in : in std_logic;

		-- Interface: switch_1
		switch_1_in : in std_logic;

		-- Interface: switch_2
		switch_2_in : in std_logic;

		-- Interface: switch_3
		switch_3_in : in std_logic;

		-- Interface: switch_4
		switch_4_in : in std_logic;

		-- Interface: switch_5
		switch_5_in : in std_logic;

		-- Interface: switch_6
		switch_6_in : in std_logic;

		-- Interface: switch_7
		switch_7_in : in std_logic);

end led_fh_mesh_2d_example;


architecture kactusHierarchical of led_fh_mesh_2d_example is

	signal mesh_network_max16ag_1_p0_to_led_packet_codec_0_pkt_codecRX_AV_TO_IP : std_logic;
	signal mesh_network_max16ag_1_p0_to_led_packet_codec_0_pkt_codecRX_DATA_TO_IP : std_logic_vector(31 downto 0);
	signal mesh_network_max16ag_1_p0_to_led_packet_codec_0_pkt_codecRX_EMPTY_TO_IP : std_logic;
	signal mesh_network_max16ag_1_p0_to_led_packet_codec_0_pkt_codecRX_RE_FROM_IP : std_logic;
	signal mesh_network_max16ag_1_p0_to_led_packet_codec_0_pkt_codecTX_AV_FROM_IP : std_logic;
	signal mesh_network_max16ag_1_p0_to_led_packet_codec_0_pkt_codecTX_DATA_FROM_IP : std_logic_vector(31 downto 0);
	signal mesh_network_max16ag_1_p0_to_led_packet_codec_0_pkt_codecTX_FULL_TO_IP : std_logic;
	signal mesh_network_max16ag_1_p0_to_led_packet_codec_0_pkt_codecTX_TXLEN_FROM_IP : std_logic_vector(15 downto 0);
	signal mesh_network_max16ag_1_p0_to_led_packet_codec_0_pkt_codecTX_WE_FROM_IP : std_logic;
	signal mesh_network_max16ag_1_p1_to_led_packet_codec_1_pkt_codecRX_AV_TO_IP : std_logic;
	signal mesh_network_max16ag_1_p1_to_led_packet_codec_1_pkt_codecRX_DATA_TO_IP : std_logic_vector(31 downto 0);
	signal mesh_network_max16ag_1_p1_to_led_packet_codec_1_pkt_codecRX_EMPTY_TO_IP : std_logic;
	signal mesh_network_max16ag_1_p1_to_led_packet_codec_1_pkt_codecRX_RE_FROM_IP : std_logic;
	signal mesh_network_max16ag_1_p1_to_led_packet_codec_1_pkt_codecTX_AV_FROM_IP : std_logic;
	signal mesh_network_max16ag_1_p1_to_led_packet_codec_1_pkt_codecTX_DATA_FROM_IP : std_logic_vector(31 downto 0);
	signal mesh_network_max16ag_1_p1_to_led_packet_codec_1_pkt_codecTX_FULL_TO_IP : std_logic;
	signal mesh_network_max16ag_1_p1_to_led_packet_codec_1_pkt_codecTX_TXLEN_FROM_IP : std_logic_vector(15 downto 0);
	signal mesh_network_max16ag_1_p1_to_led_packet_codec_1_pkt_codecTX_WE_FROM_IP : std_logic;
	signal mesh_network_max16ag_1_p2_to_led_packet_codec_2_pkt_codecRX_AV_TO_IP : std_logic;
	signal mesh_network_max16ag_1_p2_to_led_packet_codec_2_pkt_codecRX_DATA_TO_IP : std_logic_vector(31 downto 0);
	signal mesh_network_max16ag_1_p2_to_led_packet_codec_2_pkt_codecRX_EMPTY_TO_IP : std_logic;
	signal mesh_network_max16ag_1_p2_to_led_packet_codec_2_pkt_codecRX_RE_FROM_IP : std_logic;
	signal mesh_network_max16ag_1_p2_to_led_packet_codec_2_pkt_codecTX_AV_FROM_IP : std_logic;
	signal mesh_network_max16ag_1_p2_to_led_packet_codec_2_pkt_codecTX_DATA_FROM_IP : std_logic_vector(31 downto 0);
	signal mesh_network_max16ag_1_p2_to_led_packet_codec_2_pkt_codecTX_FULL_TO_IP : std_logic;
	signal mesh_network_max16ag_1_p2_to_led_packet_codec_2_pkt_codecTX_TXLEN_FROM_IP : std_logic_vector(15 downto 0);
	signal mesh_network_max16ag_1_p2_to_led_packet_codec_2_pkt_codecTX_WE_FROM_IP : std_logic;
	signal mesh_network_max16ag_1_p3_to_led_packet_codec_3_pkt_codecRX_AV_TO_IP : std_logic;
	signal mesh_network_max16ag_1_p3_to_led_packet_codec_3_pkt_codecRX_DATA_TO_IP : std_logic_vector(31 downto 0);
	signal mesh_network_max16ag_1_p3_to_led_packet_codec_3_pkt_codecRX_EMPTY_TO_IP : std_logic;
	signal mesh_network_max16ag_1_p3_to_led_packet_codec_3_pkt_codecRX_RE_FROM_IP : std_logic;
	signal mesh_network_max16ag_1_p3_to_led_packet_codec_3_pkt_codecTX_AV_FROM_IP : std_logic;
	signal mesh_network_max16ag_1_p3_to_led_packet_codec_3_pkt_codecTX_DATA_FROM_IP : std_logic_vector(31 downto 0);
	signal mesh_network_max16ag_1_p3_to_led_packet_codec_3_pkt_codecTX_FULL_TO_IP : std_logic;
	signal mesh_network_max16ag_1_p3_to_led_packet_codec_3_pkt_codecTX_TXLEN_FROM_IP : std_logic_vector(15 downto 0);
	signal mesh_network_max16ag_1_p3_to_led_packet_codec_3_pkt_codecTX_WE_FROM_IP : std_logic;
	signal mesh_network_max16ag_1_p4_to_led_packet_codec_4_pkt_codecRX_AV_TO_IP : std_logic;
	signal mesh_network_max16ag_1_p4_to_led_packet_codec_4_pkt_codecRX_DATA_TO_IP : std_logic_vector(31 downto 0);
	signal mesh_network_max16ag_1_p4_to_led_packet_codec_4_pkt_codecRX_EMPTY_TO_IP : std_logic;
	signal mesh_network_max16ag_1_p4_to_led_packet_codec_4_pkt_codecRX_RE_FROM_IP : std_logic;
	signal mesh_network_max16ag_1_p4_to_led_packet_codec_4_pkt_codecTX_AV_FROM_IP : std_logic;
	signal mesh_network_max16ag_1_p4_to_led_packet_codec_4_pkt_codecTX_DATA_FROM_IP : std_logic_vector(31 downto 0);
	signal mesh_network_max16ag_1_p4_to_led_packet_codec_4_pkt_codecTX_FULL_TO_IP : std_logic;
	signal mesh_network_max16ag_1_p4_to_led_packet_codec_4_pkt_codecTX_TXLEN_FROM_IP : std_logic_vector(15 downto 0);
	signal mesh_network_max16ag_1_p4_to_led_packet_codec_4_pkt_codecTX_WE_FROM_IP : std_logic;
	signal mesh_network_max16ag_1_p5_to_led_packet_codec_5_pkt_codecRX_AV_TO_IP : std_logic;
	signal mesh_network_max16ag_1_p5_to_led_packet_codec_5_pkt_codecRX_DATA_TO_IP : std_logic_vector(31 downto 0);
	signal mesh_network_max16ag_1_p5_to_led_packet_codec_5_pkt_codecRX_EMPTY_TO_IP : std_logic;
	signal mesh_network_max16ag_1_p5_to_led_packet_codec_5_pkt_codecRX_RE_FROM_IP : std_logic;
	signal mesh_network_max16ag_1_p5_to_led_packet_codec_5_pkt_codecTX_AV_FROM_IP : std_logic;
	signal mesh_network_max16ag_1_p5_to_led_packet_codec_5_pkt_codecTX_DATA_FROM_IP : std_logic_vector(31 downto 0);
	signal mesh_network_max16ag_1_p5_to_led_packet_codec_5_pkt_codecTX_FULL_TO_IP : std_logic;
	signal mesh_network_max16ag_1_p5_to_led_packet_codec_5_pkt_codecTX_TXLEN_FROM_IP : std_logic_vector(15 downto 0);
	signal mesh_network_max16ag_1_p5_to_led_packet_codec_5_pkt_codecTX_WE_FROM_IP : std_logic;
	signal mesh_network_max16ag_1_p6_to_led_packet_codec_6_pkt_codecRX_AV_TO_IP : std_logic;
	signal mesh_network_max16ag_1_p6_to_led_packet_codec_6_pkt_codecRX_DATA_TO_IP : std_logic_vector(31 downto 0);
	signal mesh_network_max16ag_1_p6_to_led_packet_codec_6_pkt_codecRX_EMPTY_TO_IP : std_logic;
	signal mesh_network_max16ag_1_p6_to_led_packet_codec_6_pkt_codecRX_RE_FROM_IP : std_logic;
	signal mesh_network_max16ag_1_p6_to_led_packet_codec_6_pkt_codecTX_AV_FROM_IP : std_logic;
	signal mesh_network_max16ag_1_p6_to_led_packet_codec_6_pkt_codecTX_DATA_FROM_IP : std_logic_vector(31 downto 0);
	signal mesh_network_max16ag_1_p6_to_led_packet_codec_6_pkt_codecTX_FULL_TO_IP : std_logic;
	signal mesh_network_max16ag_1_p6_to_led_packet_codec_6_pkt_codecTX_TXLEN_FROM_IP : std_logic_vector(15 downto 0);
	signal mesh_network_max16ag_1_p6_to_led_packet_codec_6_pkt_codecTX_WE_FROM_IP : std_logic;
	signal mesh_network_max16ag_1_p7_to_led_packet_codec_7_pkt_codecRX_AV_TO_IP : std_logic;
	signal mesh_network_max16ag_1_p7_to_led_packet_codec_7_pkt_codecRX_DATA_TO_IP : std_logic_vector(31 downto 0);
	signal mesh_network_max16ag_1_p7_to_led_packet_codec_7_pkt_codecRX_EMPTY_TO_IP : std_logic;
	signal mesh_network_max16ag_1_p7_to_led_packet_codec_7_pkt_codecRX_RE_FROM_IP : std_logic;
	signal mesh_network_max16ag_1_p7_to_led_packet_codec_7_pkt_codecTX_AV_FROM_IP : std_logic;
	signal mesh_network_max16ag_1_p7_to_led_packet_codec_7_pkt_codecTX_DATA_FROM_IP : std_logic_vector(31 downto 0);
	signal mesh_network_max16ag_1_p7_to_led_packet_codec_7_pkt_codecTX_FULL_TO_IP : std_logic;
	signal mesh_network_max16ag_1_p7_to_led_packet_codec_7_pkt_codecTX_TXLEN_FROM_IP : std_logic_vector(15 downto 0);
	signal mesh_network_max16ag_1_p7_to_led_packet_codec_7_pkt_codecTX_WE_FROM_IP : std_logic;
	signal mesh_network_max16ag_1_p10_to_switch_packet_codec_2_pkt_codecRX_AV_TO_IP : std_logic;
	signal mesh_network_max16ag_1_p10_to_switch_packet_codec_2_pkt_codecRX_DATA_TO_IP : std_logic_vector(31 downto 0);
	signal mesh_network_max16ag_1_p10_to_switch_packet_codec_2_pkt_codecRX_EMPTY_TO_IP : std_logic;
	signal mesh_network_max16ag_1_p10_to_switch_packet_codec_2_pkt_codecRX_RE_FROM_IP : std_logic;
	signal mesh_network_max16ag_1_p10_to_switch_packet_codec_2_pkt_codecTX_AV_FROM_IP : std_logic;
	signal mesh_network_max16ag_1_p10_to_switch_packet_codec_2_pkt_codecTX_DATA_FROM_IP : std_logic_vector(31 downto 0);
	signal mesh_network_max16ag_1_p10_to_switch_packet_codec_2_pkt_codecTX_FULL_TO_IP : std_logic;
	signal mesh_network_max16ag_1_p10_to_switch_packet_codec_2_pkt_codecTX_TXLEN_FROM_IP : std_logic_vector(15 downto 0);
	signal mesh_network_max16ag_1_p10_to_switch_packet_codec_2_pkt_codecTX_WE_FROM_IP : std_logic;
	signal mesh_network_max16ag_1_p11_to_switch_packet_codec_3_pkt_codecRX_AV_TO_IP : std_logic;
	signal mesh_network_max16ag_1_p11_to_switch_packet_codec_3_pkt_codecRX_DATA_TO_IP : std_logic_vector(31 downto 0);
	signal mesh_network_max16ag_1_p11_to_switch_packet_codec_3_pkt_codecRX_EMPTY_TO_IP : std_logic;
	signal mesh_network_max16ag_1_p11_to_switch_packet_codec_3_pkt_codecRX_RE_FROM_IP : std_logic;
	signal mesh_network_max16ag_1_p11_to_switch_packet_codec_3_pkt_codecTX_AV_FROM_IP : std_logic;
	signal mesh_network_max16ag_1_p11_to_switch_packet_codec_3_pkt_codecTX_DATA_FROM_IP : std_logic_vector(31 downto 0);
	signal mesh_network_max16ag_1_p11_to_switch_packet_codec_3_pkt_codecTX_FULL_TO_IP : std_logic;
	signal mesh_network_max16ag_1_p11_to_switch_packet_codec_3_pkt_codecTX_TXLEN_FROM_IP : std_logic_vector(15 downto 0);
	signal mesh_network_max16ag_1_p11_to_switch_packet_codec_3_pkt_codecTX_WE_FROM_IP : std_logic;
	signal mesh_network_max16ag_1_p12_to_switch_packet_codec_4_pkt_codecRX_AV_TO_IP : std_logic;
	signal mesh_network_max16ag_1_p12_to_switch_packet_codec_4_pkt_codecRX_DATA_TO_IP : std_logic_vector(31 downto 0);
	signal mesh_network_max16ag_1_p12_to_switch_packet_codec_4_pkt_codecRX_EMPTY_TO_IP : std_logic;
	signal mesh_network_max16ag_1_p12_to_switch_packet_codec_4_pkt_codecRX_RE_FROM_IP : std_logic;
	signal mesh_network_max16ag_1_p12_to_switch_packet_codec_4_pkt_codecTX_AV_FROM_IP : std_logic;
	signal mesh_network_max16ag_1_p12_to_switch_packet_codec_4_pkt_codecTX_DATA_FROM_IP : std_logic_vector(31 downto 0);
	signal mesh_network_max16ag_1_p12_to_switch_packet_codec_4_pkt_codecTX_FULL_TO_IP : std_logic;
	signal mesh_network_max16ag_1_p12_to_switch_packet_codec_4_pkt_codecTX_TXLEN_FROM_IP : std_logic_vector(15 downto 0);
	signal mesh_network_max16ag_1_p12_to_switch_packet_codec_4_pkt_codecTX_WE_FROM_IP : std_logic;
	signal mesh_network_max16ag_1_p13_to_switch_packet_codec_5_pkt_codecRX_AV_TO_IP : std_logic;
	signal mesh_network_max16ag_1_p13_to_switch_packet_codec_5_pkt_codecRX_DATA_TO_IP : std_logic_vector(31 downto 0);
	signal mesh_network_max16ag_1_p13_to_switch_packet_codec_5_pkt_codecRX_EMPTY_TO_IP : std_logic;
	signal mesh_network_max16ag_1_p13_to_switch_packet_codec_5_pkt_codecRX_RE_FROM_IP : std_logic;
	signal mesh_network_max16ag_1_p13_to_switch_packet_codec_5_pkt_codecTX_AV_FROM_IP : std_logic;
	signal mesh_network_max16ag_1_p13_to_switch_packet_codec_5_pkt_codecTX_DATA_FROM_IP : std_logic_vector(31 downto 0);
	signal mesh_network_max16ag_1_p13_to_switch_packet_codec_5_pkt_codecTX_FULL_TO_IP : std_logic;
	signal mesh_network_max16ag_1_p13_to_switch_packet_codec_5_pkt_codecTX_TXLEN_FROM_IP : std_logic_vector(15 downto 0);
	signal mesh_network_max16ag_1_p13_to_switch_packet_codec_5_pkt_codecTX_WE_FROM_IP : std_logic;
	signal mesh_network_max16ag_1_p14_to_switch_packet_codec_6_pkt_codecRX_AV_TO_IP : std_logic;
	signal mesh_network_max16ag_1_p14_to_switch_packet_codec_6_pkt_codecRX_DATA_TO_IP : std_logic_vector(31 downto 0);
	signal mesh_network_max16ag_1_p14_to_switch_packet_codec_6_pkt_codecRX_EMPTY_TO_IP : std_logic;
	signal mesh_network_max16ag_1_p14_to_switch_packet_codec_6_pkt_codecRX_RE_FROM_IP : std_logic;
	signal mesh_network_max16ag_1_p14_to_switch_packet_codec_6_pkt_codecTX_AV_FROM_IP : std_logic;
	signal mesh_network_max16ag_1_p14_to_switch_packet_codec_6_pkt_codecTX_DATA_FROM_IP : std_logic_vector(31 downto 0);
	signal mesh_network_max16ag_1_p14_to_switch_packet_codec_6_pkt_codecTX_FULL_TO_IP : std_logic;
	signal mesh_network_max16ag_1_p14_to_switch_packet_codec_6_pkt_codecTX_TXLEN_FROM_IP : std_logic_vector(15 downto 0);
	signal mesh_network_max16ag_1_p14_to_switch_packet_codec_6_pkt_codecTX_WE_FROM_IP : std_logic;
	signal mesh_network_max16ag_1_p15_to_switch_packet_codec_7_pkt_codecRX_AV_TO_IP : std_logic;
	signal mesh_network_max16ag_1_p15_to_switch_packet_codec_7_pkt_codecRX_DATA_TO_IP : std_logic_vector(31 downto 0);
	signal mesh_network_max16ag_1_p15_to_switch_packet_codec_7_pkt_codecRX_EMPTY_TO_IP : std_logic;
	signal mesh_network_max16ag_1_p15_to_switch_packet_codec_7_pkt_codecRX_RE_FROM_IP : std_logic;
	signal mesh_network_max16ag_1_p15_to_switch_packet_codec_7_pkt_codecTX_AV_FROM_IP : std_logic;
	signal mesh_network_max16ag_1_p15_to_switch_packet_codec_7_pkt_codecTX_DATA_FROM_IP : std_logic_vector(31 downto 0);
	signal mesh_network_max16ag_1_p15_to_switch_packet_codec_7_pkt_codecTX_FULL_TO_IP : std_logic;
	signal mesh_network_max16ag_1_p15_to_switch_packet_codec_7_pkt_codecTX_TXLEN_FROM_IP : std_logic_vector(15 downto 0);
	signal mesh_network_max16ag_1_p15_to_switch_packet_codec_7_pkt_codecTX_WE_FROM_IP : std_logic;
	signal mesh_network_max16ag_1_p8_to_switch_packet_codec_0_pkt_codecRX_AV_TO_IP : std_logic;
	signal mesh_network_max16ag_1_p8_to_switch_packet_codec_0_pkt_codecRX_DATA_TO_IP : std_logic_vector(31 downto 0);
	signal mesh_network_max16ag_1_p8_to_switch_packet_codec_0_pkt_codecRX_EMPTY_TO_IP : std_logic;
	signal mesh_network_max16ag_1_p8_to_switch_packet_codec_0_pkt_codecRX_RE_FROM_IP : std_logic;
	signal mesh_network_max16ag_1_p8_to_switch_packet_codec_0_pkt_codecTX_AV_FROM_IP : std_logic;
	signal mesh_network_max16ag_1_p8_to_switch_packet_codec_0_pkt_codecTX_DATA_FROM_IP : std_logic_vector(31 downto 0);
	signal mesh_network_max16ag_1_p8_to_switch_packet_codec_0_pkt_codecTX_FULL_TO_IP : std_logic;
	signal mesh_network_max16ag_1_p8_to_switch_packet_codec_0_pkt_codecTX_TXLEN_FROM_IP : std_logic_vector(15 downto 0);
	signal mesh_network_max16ag_1_p8_to_switch_packet_codec_0_pkt_codecTX_WE_FROM_IP : std_logic;
	signal mesh_network_max16ag_1_p9_to_switch_packet_codec_1_pkt_codecRX_AV_TO_IP : std_logic;
	signal mesh_network_max16ag_1_p9_to_switch_packet_codec_1_pkt_codecRX_DATA_TO_IP : std_logic_vector(31 downto 0);
	signal mesh_network_max16ag_1_p9_to_switch_packet_codec_1_pkt_codecRX_EMPTY_TO_IP : std_logic;
	signal mesh_network_max16ag_1_p9_to_switch_packet_codec_1_pkt_codecRX_RE_FROM_IP : std_logic;
	signal mesh_network_max16ag_1_p9_to_switch_packet_codec_1_pkt_codecTX_AV_FROM_IP : std_logic;
	signal mesh_network_max16ag_1_p9_to_switch_packet_codec_1_pkt_codecTX_DATA_FROM_IP : std_logic_vector(31 downto 0);
	signal mesh_network_max16ag_1_p9_to_switch_packet_codec_1_pkt_codecTX_FULL_TO_IP : std_logic;
	signal mesh_network_max16ag_1_p9_to_switch_packet_codec_1_pkt_codecTX_TXLEN_FROM_IP : std_logic_vector(15 downto 0);
	signal mesh_network_max16ag_1_p9_to_switch_packet_codec_1_pkt_codecTX_WE_FROM_IP : std_logic;

	component mesh_network_max16ag
		generic (
			addr_width_g : integer := 32;
			data_width_g : integer := 32;
			fifo_depth_g : integer := 6;
			fill_packet_g : integer := 0;
			ip_freq_g : integer := 50000000;
			len_flit_en_g : integer := 1;
			lut_en_g : integer := 0;
			n_ag_g : integer := 16;
			net_freq_g : integer := 50000000;
			oaddr_flit_en_g : integer := 0;
			packet_length_g : integer := 4;
			status_en_g : integer := 0;
			stfwd_en_g : integer := 0;
			timeout_g : integer := 5;
			tx_len_width_g : integer := 16

		);
		port (

			-- Interface: clk_ip
			clk_ip : in std_logic;

			-- Interface: clk_net
			clk_net : in std_logic;

			-- Interface: p0
			port0_rx_re_in : in std_logic;
			port0_tx_av_in : in std_logic;
			port0_tx_data_in : in std_logic_vector(31 downto 0);
			port0_tx_txlen_in : in std_logic_vector(15 downto 0);
			port0_tx_we_in : in std_logic;
			port0_rx_av_out : out std_logic;
			port0_rx_data_out : out std_logic_vector(31 downto 0);
			port0_rx_empty_out : out std_logic;
			port0_tx_full_out : out std_logic;

			-- Interface: p1
			port1_rx_re_in : in std_logic;
			port1_tx_av_in : in std_logic;
			port1_tx_data_in : in std_logic_vector(31 downto 0);
			port1_tx_txlen_in : in std_logic_vector(15 downto 0);
			port1_tx_we_in : in std_logic;
			port1_rx_av_out : out std_logic;
			port1_rx_data_out : out std_logic_vector(31 downto 0);
			port1_rx_empty_out : out std_logic;
			port1_tx_full_out : out std_logic;

			-- Interface: p10
			port10_rx_re_in : in std_logic;
			port10_tx_av_in : in std_logic;
			port10_tx_data_in : in std_logic_vector(31 downto 0);
			port10_tx_txlen_in : in std_logic_vector(15 downto 0);
			port10_tx_we_in : in std_logic;
			port10_rx_av_out : out std_logic;
			port10_rx_data_out : out std_logic_vector(31 downto 0);
			port10_rx_empty_out : out std_logic;
			port10_tx_full_out : out std_logic;

			-- Interface: p11
			port11_rx_re_in : in std_logic;
			port11_tx_av_in : in std_logic;
			port11_tx_data_in : in std_logic_vector(31 downto 0);
			port11_tx_txlen_in : in std_logic_vector(15 downto 0);
			port11_tx_we_in : in std_logic;
			port11_rx_av_out : out std_logic;
			port11_rx_data_out : out std_logic_vector(31 downto 0);
			port11_rx_empty_out : out std_logic;
			port11_tx_full_out : out std_logic;

			-- Interface: p12
			port12_rx_re_in : in std_logic;
			port12_tx_av_in : in std_logic;
			port12_tx_data_in : in std_logic_vector(31 downto 0);
			port12_tx_txlen_in : in std_logic_vector(15 downto 0);
			port12_tx_we_in : in std_logic;
			port12_rx_av_out : out std_logic;
			port12_rx_data_out : out std_logic_vector(31 downto 0);
			port12_rx_empty_out : out std_logic;
			port12_tx_full_out : out std_logic;

			-- Interface: p13
			port13_rx_re_in : in std_logic;
			port13_tx_av_in : in std_logic;
			port13_tx_data_in : in std_logic_vector(31 downto 0);
			port13_tx_txlen_in : in std_logic_vector(15 downto 0);
			port13_tx_we_in : in std_logic;
			port13_rx_av_out : out std_logic;
			port13_rx_data_out : out std_logic_vector(31 downto 0);
			port13_rx_empty_out : out std_logic;
			port13_tx_full_out : out std_logic;

			-- Interface: p14
			port14_rx_re_in : in std_logic;
			port14_tx_av_in : in std_logic;
			port14_tx_data_in : in std_logic_vector(31 downto 0);
			port14_tx_txlen_in : in std_logic_vector(15 downto 0);
			port14_tx_we_in : in std_logic;
			port14_rx_av_out : out std_logic;
			port14_rx_data_out : out std_logic_vector(31 downto 0);
			port14_rx_empty_out : out std_logic;
			port14_tx_full_out : out std_logic;

			-- Interface: p15
			port15_rx_re_in : in std_logic;
			port15_tx_av_in : in std_logic;
			port15_tx_data_in : in std_logic_vector(31 downto 0);
			port15_tx_txlen_in : in std_logic_vector(15 downto 0);
			port15_tx_we_in : in std_logic;
			port15_rx_av_out : out std_logic;
			port15_rx_data_out : out std_logic_vector(31 downto 0);
			port15_rx_empty_out : out std_logic;
			port15_tx_full_out : out std_logic;

			-- Interface: p2
			port2_rx_re_in : in std_logic;
			port2_tx_av_in : in std_logic;
			port2_tx_data_in : in std_logic_vector(31 downto 0);
			port2_tx_txlen_in : in std_logic_vector(15 downto 0);
			port2_tx_we_in : in std_logic;
			port2_rx_av_out : out std_logic;
			port2_rx_data_out : out std_logic_vector(31 downto 0);
			port2_rx_empty_out : out std_logic;
			port2_tx_full_out : out std_logic;

			-- Interface: p3
			port3_rx_re_in : in std_logic;
			port3_tx_av_in : in std_logic;
			port3_tx_data_in : in std_logic_vector(31 downto 0);
			port3_tx_txlen_in : in std_logic_vector(15 downto 0);
			port3_tx_we_in : in std_logic;
			port3_rx_av_out : out std_logic;
			port3_rx_data_out : out std_logic_vector(31 downto 0);
			port3_rx_empty_out : out std_logic;
			port3_tx_full_out : out std_logic;

			-- Interface: p4
			port4_rx_re_in : in std_logic;
			port4_tx_av_in : in std_logic;
			port4_tx_data_in : in std_logic_vector(31 downto 0);
			port4_tx_txlen_in : in std_logic_vector(15 downto 0);
			port4_tx_we_in : in std_logic;
			port4_rx_av_out : out std_logic;
			port4_rx_data_out : out std_logic_vector(31 downto 0);
			port4_rx_empty_out : out std_logic;
			port4_tx_full_out : out std_logic;

			-- Interface: p5
			port5_rx_re_in : in std_logic;
			port5_tx_av_in : in std_logic;
			port5_tx_data_in : in std_logic_vector(31 downto 0);
			port5_tx_txlen_in : in std_logic_vector(15 downto 0);
			port5_tx_we_in : in std_logic;
			port5_rx_av_out : out std_logic;
			port5_rx_data_out : out std_logic_vector(31 downto 0);
			port5_rx_empty_out : out std_logic;
			port5_tx_full_out : out std_logic;

			-- Interface: p6
			port6_rx_re_in : in std_logic;
			port6_tx_av_in : in std_logic;
			port6_tx_data_in : in std_logic_vector(31 downto 0);
			port6_tx_txlen_in : in std_logic_vector(15 downto 0);
			port6_tx_we_in : in std_logic;
			port6_rx_av_out : out std_logic;
			port6_rx_data_out : out std_logic_vector(31 downto 0);
			port6_rx_empty_out : out std_logic;
			port6_tx_full_out : out std_logic;

			-- Interface: p7
			port7_rx_re_in : in std_logic;
			port7_tx_av_in : in std_logic;
			port7_tx_data_in : in std_logic_vector(31 downto 0);
			port7_tx_txlen_in : in std_logic_vector(15 downto 0);
			port7_tx_we_in : in std_logic;
			port7_rx_av_out : out std_logic;
			port7_rx_data_out : out std_logic_vector(31 downto 0);
			port7_rx_empty_out : out std_logic;
			port7_tx_full_out : out std_logic;

			-- Interface: p8
			port8_rx_re_in : in std_logic;
			port8_tx_av_in : in std_logic;
			port8_tx_data_in : in std_logic_vector(31 downto 0);
			port8_tx_txlen_in : in std_logic_vector(15 downto 0);
			port8_tx_we_in : in std_logic;
			port8_rx_av_out : out std_logic;
			port8_rx_data_out : out std_logic_vector(31 downto 0);
			port8_rx_empty_out : out std_logic;
			port8_tx_full_out : out std_logic;

			-- Interface: p9
			port9_rx_re_in : in std_logic;
			port9_tx_av_in : in std_logic;
			port9_tx_data_in : in std_logic_vector(31 downto 0);
			port9_tx_txlen_in : in std_logic_vector(15 downto 0);
			port9_tx_we_in : in std_logic;
			port9_rx_av_out : out std_logic;
			port9_rx_data_out : out std_logic_vector(31 downto 0);
			port9_rx_empty_out : out std_logic;
			port9_tx_full_out : out std_logic;

			-- Interface: rst_n
			rst_n : in std_logic

		);
	end component;

	component led_packet_codec
		generic (
			data_width_g : integer := 32;
			tx_len_width_g : integer := 16

		);
		port (

			-- Interface: clk
			clk : in std_logic;

			-- Interface: led
			led_out : out std_logic;

			-- Interface: pkt_codec
			rx_av_in : in std_logic;
			rx_data_in : in std_logic_vector(31 downto 0);
			rx_empty_in : in std_logic;
			tx_full_in : in std_logic;
			rx_re_out : out std_logic;
			tx_av_out : out std_logic;
			tx_data_out : out std_logic_vector(31 downto 0);
			tx_txlen_out : out std_logic_vector(15 downto 0);
			tx_we_out : out std_logic;

			-- Interface: rst_n
			rst_n : in std_logic

		);
	end component;

	component switch_packet_codec
		generic (
			data_width_g : integer := 32;
			my_id_g : integer := 0;
			tx_len_width_g : integer := 16

		);
		port (

			-- Interface: clk
			clk : in std_logic;

			-- Interface: pkt_codec
			rx_av_in : in std_logic;
			rx_data_in : in std_logic_vector(31 downto 0);
			rx_empty_in : in std_logic;
			tx_full_in : in std_logic;
			rx_re_out : out std_logic;
			tx_av_out : out std_logic;
			tx_data_out : out std_logic_vector(31 downto 0);
			tx_txlen_out : out std_logic_vector(15 downto 0);
			tx_we_out : out std_logic;

			-- Interface: rst_n
			rst_n : in std_logic;

			-- Interface: switch
			switch_in : in std_logic

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

	led_packet_codec_0 : led_packet_codec
		port map (
			clk => clk,
			led_out => led_0_out,
			rst_n => rst_n,
			rx_av_in => mesh_network_max16ag_1_p0_to_led_packet_codec_0_pkt_codecRX_AV_TO_IP,
			rx_data_in(31 downto 0) => mesh_network_max16ag_1_p0_to_led_packet_codec_0_pkt_codecRX_DATA_TO_IP(31 downto 0),
			rx_empty_in => mesh_network_max16ag_1_p0_to_led_packet_codec_0_pkt_codecRX_EMPTY_TO_IP,
			rx_re_out => mesh_network_max16ag_1_p0_to_led_packet_codec_0_pkt_codecRX_RE_FROM_IP,
			tx_av_out => mesh_network_max16ag_1_p0_to_led_packet_codec_0_pkt_codecTX_AV_FROM_IP,
			tx_data_out(31 downto 0) => mesh_network_max16ag_1_p0_to_led_packet_codec_0_pkt_codecTX_DATA_FROM_IP(31 downto 0),
			tx_full_in => mesh_network_max16ag_1_p0_to_led_packet_codec_0_pkt_codecTX_FULL_TO_IP,
			tx_txlen_out(15 downto 0) => mesh_network_max16ag_1_p0_to_led_packet_codec_0_pkt_codecTX_TXLEN_FROM_IP(15 downto 0),
			tx_we_out => mesh_network_max16ag_1_p0_to_led_packet_codec_0_pkt_codecTX_WE_FROM_IP
		);

	led_packet_codec_1 : led_packet_codec
		port map (
			clk => clk,
			led_out => led_1_out,
			rst_n => rst_n,
			rx_av_in => mesh_network_max16ag_1_p1_to_led_packet_codec_1_pkt_codecRX_AV_TO_IP,
			rx_data_in(31 downto 0) => mesh_network_max16ag_1_p1_to_led_packet_codec_1_pkt_codecRX_DATA_TO_IP(31 downto 0),
			rx_empty_in => mesh_network_max16ag_1_p1_to_led_packet_codec_1_pkt_codecRX_EMPTY_TO_IP,
			rx_re_out => mesh_network_max16ag_1_p1_to_led_packet_codec_1_pkt_codecRX_RE_FROM_IP,
			tx_av_out => mesh_network_max16ag_1_p1_to_led_packet_codec_1_pkt_codecTX_AV_FROM_IP,
			tx_data_out(31 downto 0) => mesh_network_max16ag_1_p1_to_led_packet_codec_1_pkt_codecTX_DATA_FROM_IP(31 downto 0),
			tx_full_in => mesh_network_max16ag_1_p1_to_led_packet_codec_1_pkt_codecTX_FULL_TO_IP,
			tx_txlen_out(15 downto 0) => mesh_network_max16ag_1_p1_to_led_packet_codec_1_pkt_codecTX_TXLEN_FROM_IP(15 downto 0),
			tx_we_out => mesh_network_max16ag_1_p1_to_led_packet_codec_1_pkt_codecTX_WE_FROM_IP
		);

	led_packet_codec_2 : led_packet_codec
		port map (
			clk => clk,
			led_out => led_2_out,
			rst_n => rst_n,
			rx_av_in => mesh_network_max16ag_1_p2_to_led_packet_codec_2_pkt_codecRX_AV_TO_IP,
			rx_data_in(31 downto 0) => mesh_network_max16ag_1_p2_to_led_packet_codec_2_pkt_codecRX_DATA_TO_IP(31 downto 0),
			rx_empty_in => mesh_network_max16ag_1_p2_to_led_packet_codec_2_pkt_codecRX_EMPTY_TO_IP,
			rx_re_out => mesh_network_max16ag_1_p2_to_led_packet_codec_2_pkt_codecRX_RE_FROM_IP,
			tx_av_out => mesh_network_max16ag_1_p2_to_led_packet_codec_2_pkt_codecTX_AV_FROM_IP,
			tx_data_out(31 downto 0) => mesh_network_max16ag_1_p2_to_led_packet_codec_2_pkt_codecTX_DATA_FROM_IP(31 downto 0),
			tx_full_in => mesh_network_max16ag_1_p2_to_led_packet_codec_2_pkt_codecTX_FULL_TO_IP,
			tx_txlen_out(15 downto 0) => mesh_network_max16ag_1_p2_to_led_packet_codec_2_pkt_codecTX_TXLEN_FROM_IP(15 downto 0),
			tx_we_out => mesh_network_max16ag_1_p2_to_led_packet_codec_2_pkt_codecTX_WE_FROM_IP
		);

	led_packet_codec_3 : led_packet_codec
		port map (
			clk => clk,
			led_out => led_3_out,
			rst_n => rst_n,
			rx_av_in => mesh_network_max16ag_1_p3_to_led_packet_codec_3_pkt_codecRX_AV_TO_IP,
			rx_data_in(31 downto 0) => mesh_network_max16ag_1_p3_to_led_packet_codec_3_pkt_codecRX_DATA_TO_IP(31 downto 0),
			rx_empty_in => mesh_network_max16ag_1_p3_to_led_packet_codec_3_pkt_codecRX_EMPTY_TO_IP,
			rx_re_out => mesh_network_max16ag_1_p3_to_led_packet_codec_3_pkt_codecRX_RE_FROM_IP,
			tx_av_out => mesh_network_max16ag_1_p3_to_led_packet_codec_3_pkt_codecTX_AV_FROM_IP,
			tx_data_out(31 downto 0) => mesh_network_max16ag_1_p3_to_led_packet_codec_3_pkt_codecTX_DATA_FROM_IP(31 downto 0),
			tx_full_in => mesh_network_max16ag_1_p3_to_led_packet_codec_3_pkt_codecTX_FULL_TO_IP,
			tx_txlen_out(15 downto 0) => mesh_network_max16ag_1_p3_to_led_packet_codec_3_pkt_codecTX_TXLEN_FROM_IP(15 downto 0),
			tx_we_out => mesh_network_max16ag_1_p3_to_led_packet_codec_3_pkt_codecTX_WE_FROM_IP
		);

	led_packet_codec_4 : led_packet_codec
		port map (
			clk => clk,
			led_out => led_4_out,
			rst_n => rst_n,
			rx_av_in => mesh_network_max16ag_1_p4_to_led_packet_codec_4_pkt_codecRX_AV_TO_IP,
			rx_data_in(31 downto 0) => mesh_network_max16ag_1_p4_to_led_packet_codec_4_pkt_codecRX_DATA_TO_IP(31 downto 0),
			rx_empty_in => mesh_network_max16ag_1_p4_to_led_packet_codec_4_pkt_codecRX_EMPTY_TO_IP,
			rx_re_out => mesh_network_max16ag_1_p4_to_led_packet_codec_4_pkt_codecRX_RE_FROM_IP,
			tx_av_out => mesh_network_max16ag_1_p4_to_led_packet_codec_4_pkt_codecTX_AV_FROM_IP,
			tx_data_out(31 downto 0) => mesh_network_max16ag_1_p4_to_led_packet_codec_4_pkt_codecTX_DATA_FROM_IP(31 downto 0),
			tx_full_in => mesh_network_max16ag_1_p4_to_led_packet_codec_4_pkt_codecTX_FULL_TO_IP,
			tx_txlen_out(15 downto 0) => mesh_network_max16ag_1_p4_to_led_packet_codec_4_pkt_codecTX_TXLEN_FROM_IP(15 downto 0),
			tx_we_out => mesh_network_max16ag_1_p4_to_led_packet_codec_4_pkt_codecTX_WE_FROM_IP
		);

	led_packet_codec_5 : led_packet_codec
		port map (
			clk => clk,
			led_out => led_5_out,
			rst_n => rst_n,
			rx_av_in => mesh_network_max16ag_1_p5_to_led_packet_codec_5_pkt_codecRX_AV_TO_IP,
			rx_data_in(31 downto 0) => mesh_network_max16ag_1_p5_to_led_packet_codec_5_pkt_codecRX_DATA_TO_IP(31 downto 0),
			rx_empty_in => mesh_network_max16ag_1_p5_to_led_packet_codec_5_pkt_codecRX_EMPTY_TO_IP,
			rx_re_out => mesh_network_max16ag_1_p5_to_led_packet_codec_5_pkt_codecRX_RE_FROM_IP,
			tx_av_out => mesh_network_max16ag_1_p5_to_led_packet_codec_5_pkt_codecTX_AV_FROM_IP,
			tx_data_out(31 downto 0) => mesh_network_max16ag_1_p5_to_led_packet_codec_5_pkt_codecTX_DATA_FROM_IP(31 downto 0),
			tx_full_in => mesh_network_max16ag_1_p5_to_led_packet_codec_5_pkt_codecTX_FULL_TO_IP,
			tx_txlen_out(15 downto 0) => mesh_network_max16ag_1_p5_to_led_packet_codec_5_pkt_codecTX_TXLEN_FROM_IP(15 downto 0),
			tx_we_out => mesh_network_max16ag_1_p5_to_led_packet_codec_5_pkt_codecTX_WE_FROM_IP
		);

	led_packet_codec_6 : led_packet_codec
		port map (
			clk => clk,
			led_out => led_6_out,
			rst_n => rst_n,
			rx_av_in => mesh_network_max16ag_1_p6_to_led_packet_codec_6_pkt_codecRX_AV_TO_IP,
			rx_data_in(31 downto 0) => mesh_network_max16ag_1_p6_to_led_packet_codec_6_pkt_codecRX_DATA_TO_IP(31 downto 0),
			rx_empty_in => mesh_network_max16ag_1_p6_to_led_packet_codec_6_pkt_codecRX_EMPTY_TO_IP,
			rx_re_out => mesh_network_max16ag_1_p6_to_led_packet_codec_6_pkt_codecRX_RE_FROM_IP,
			tx_av_out => mesh_network_max16ag_1_p6_to_led_packet_codec_6_pkt_codecTX_AV_FROM_IP,
			tx_data_out(31 downto 0) => mesh_network_max16ag_1_p6_to_led_packet_codec_6_pkt_codecTX_DATA_FROM_IP(31 downto 0),
			tx_full_in => mesh_network_max16ag_1_p6_to_led_packet_codec_6_pkt_codecTX_FULL_TO_IP,
			tx_txlen_out(15 downto 0) => mesh_network_max16ag_1_p6_to_led_packet_codec_6_pkt_codecTX_TXLEN_FROM_IP(15 downto 0),
			tx_we_out => mesh_network_max16ag_1_p6_to_led_packet_codec_6_pkt_codecTX_WE_FROM_IP
		);

	led_packet_codec_7 : led_packet_codec
		port map (
			clk => clk,
			led_out => led_7_out,
			rst_n => rst_n,
			rx_av_in => mesh_network_max16ag_1_p7_to_led_packet_codec_7_pkt_codecRX_AV_TO_IP,
			rx_data_in(31 downto 0) => mesh_network_max16ag_1_p7_to_led_packet_codec_7_pkt_codecRX_DATA_TO_IP(31 downto 0),
			rx_empty_in => mesh_network_max16ag_1_p7_to_led_packet_codec_7_pkt_codecRX_EMPTY_TO_IP,
			rx_re_out => mesh_network_max16ag_1_p7_to_led_packet_codec_7_pkt_codecRX_RE_FROM_IP,
			tx_av_out => mesh_network_max16ag_1_p7_to_led_packet_codec_7_pkt_codecTX_AV_FROM_IP,
			tx_data_out(31 downto 0) => mesh_network_max16ag_1_p7_to_led_packet_codec_7_pkt_codecTX_DATA_FROM_IP(31 downto 0),
			tx_full_in => mesh_network_max16ag_1_p7_to_led_packet_codec_7_pkt_codecTX_FULL_TO_IP,
			tx_txlen_out(15 downto 0) => mesh_network_max16ag_1_p7_to_led_packet_codec_7_pkt_codecTX_TXLEN_FROM_IP(15 downto 0),
			tx_we_out => mesh_network_max16ag_1_p7_to_led_packet_codec_7_pkt_codecTX_WE_FROM_IP
		);

	mesh_network_max16ag_1 : mesh_network_max16ag
		port map (
			clk_ip => clk,
			clk_net => clk,
			port0_rx_av_out => mesh_network_max16ag_1_p0_to_led_packet_codec_0_pkt_codecRX_AV_TO_IP,
			port0_rx_data_out(31 downto 0) => mesh_network_max16ag_1_p0_to_led_packet_codec_0_pkt_codecRX_DATA_TO_IP(31 downto 0),
			port0_rx_empty_out => mesh_network_max16ag_1_p0_to_led_packet_codec_0_pkt_codecRX_EMPTY_TO_IP,
			port0_rx_re_in => mesh_network_max16ag_1_p0_to_led_packet_codec_0_pkt_codecRX_RE_FROM_IP,
			port0_tx_av_in => mesh_network_max16ag_1_p0_to_led_packet_codec_0_pkt_codecTX_AV_FROM_IP,
			port0_tx_data_in(31 downto 0) => mesh_network_max16ag_1_p0_to_led_packet_codec_0_pkt_codecTX_DATA_FROM_IP(31 downto 0),
			port0_tx_full_out => mesh_network_max16ag_1_p0_to_led_packet_codec_0_pkt_codecTX_FULL_TO_IP,
			port0_tx_txlen_in(15 downto 0) => mesh_network_max16ag_1_p0_to_led_packet_codec_0_pkt_codecTX_TXLEN_FROM_IP(15 downto 0),
			port0_tx_we_in => mesh_network_max16ag_1_p0_to_led_packet_codec_0_pkt_codecTX_WE_FROM_IP,
			port10_rx_av_out => mesh_network_max16ag_1_p10_to_switch_packet_codec_2_pkt_codecRX_AV_TO_IP,
			port10_rx_data_out(31 downto 0) => mesh_network_max16ag_1_p10_to_switch_packet_codec_2_pkt_codecRX_DATA_TO_IP(31 downto 0),
			port10_rx_empty_out => mesh_network_max16ag_1_p10_to_switch_packet_codec_2_pkt_codecRX_EMPTY_TO_IP,
			port10_rx_re_in => mesh_network_max16ag_1_p10_to_switch_packet_codec_2_pkt_codecRX_RE_FROM_IP,
			port10_tx_av_in => mesh_network_max16ag_1_p10_to_switch_packet_codec_2_pkt_codecTX_AV_FROM_IP,
			port10_tx_data_in(31 downto 0) => mesh_network_max16ag_1_p10_to_switch_packet_codec_2_pkt_codecTX_DATA_FROM_IP(31 downto 0),
			port10_tx_full_out => mesh_network_max16ag_1_p10_to_switch_packet_codec_2_pkt_codecTX_FULL_TO_IP,
			port10_tx_txlen_in(15 downto 0) => mesh_network_max16ag_1_p10_to_switch_packet_codec_2_pkt_codecTX_TXLEN_FROM_IP(15 downto 0),
			port10_tx_we_in => mesh_network_max16ag_1_p10_to_switch_packet_codec_2_pkt_codecTX_WE_FROM_IP,
			port11_rx_av_out => mesh_network_max16ag_1_p11_to_switch_packet_codec_3_pkt_codecRX_AV_TO_IP,
			port11_rx_data_out(31 downto 0) => mesh_network_max16ag_1_p11_to_switch_packet_codec_3_pkt_codecRX_DATA_TO_IP(31 downto 0),
			port11_rx_empty_out => mesh_network_max16ag_1_p11_to_switch_packet_codec_3_pkt_codecRX_EMPTY_TO_IP,
			port11_rx_re_in => mesh_network_max16ag_1_p11_to_switch_packet_codec_3_pkt_codecRX_RE_FROM_IP,
			port11_tx_av_in => mesh_network_max16ag_1_p11_to_switch_packet_codec_3_pkt_codecTX_AV_FROM_IP,
			port11_tx_data_in(31 downto 0) => mesh_network_max16ag_1_p11_to_switch_packet_codec_3_pkt_codecTX_DATA_FROM_IP(31 downto 0),
			port11_tx_full_out => mesh_network_max16ag_1_p11_to_switch_packet_codec_3_pkt_codecTX_FULL_TO_IP,
			port11_tx_txlen_in(15 downto 0) => mesh_network_max16ag_1_p11_to_switch_packet_codec_3_pkt_codecTX_TXLEN_FROM_IP(15 downto 0),
			port11_tx_we_in => mesh_network_max16ag_1_p11_to_switch_packet_codec_3_pkt_codecTX_WE_FROM_IP,
			port12_rx_av_out => mesh_network_max16ag_1_p12_to_switch_packet_codec_4_pkt_codecRX_AV_TO_IP,
			port12_rx_data_out(31 downto 0) => mesh_network_max16ag_1_p12_to_switch_packet_codec_4_pkt_codecRX_DATA_TO_IP(31 downto 0),
			port12_rx_empty_out => mesh_network_max16ag_1_p12_to_switch_packet_codec_4_pkt_codecRX_EMPTY_TO_IP,
			port12_rx_re_in => mesh_network_max16ag_1_p12_to_switch_packet_codec_4_pkt_codecRX_RE_FROM_IP,
			port12_tx_av_in => mesh_network_max16ag_1_p12_to_switch_packet_codec_4_pkt_codecTX_AV_FROM_IP,
			port12_tx_data_in(31 downto 0) => mesh_network_max16ag_1_p12_to_switch_packet_codec_4_pkt_codecTX_DATA_FROM_IP(31 downto 0),
			port12_tx_full_out => mesh_network_max16ag_1_p12_to_switch_packet_codec_4_pkt_codecTX_FULL_TO_IP,
			port12_tx_txlen_in(15 downto 0) => mesh_network_max16ag_1_p12_to_switch_packet_codec_4_pkt_codecTX_TXLEN_FROM_IP(15 downto 0),
			port12_tx_we_in => mesh_network_max16ag_1_p12_to_switch_packet_codec_4_pkt_codecTX_WE_FROM_IP,
			port13_rx_av_out => mesh_network_max16ag_1_p13_to_switch_packet_codec_5_pkt_codecRX_AV_TO_IP,
			port13_rx_data_out(31 downto 0) => mesh_network_max16ag_1_p13_to_switch_packet_codec_5_pkt_codecRX_DATA_TO_IP(31 downto 0),
			port13_rx_empty_out => mesh_network_max16ag_1_p13_to_switch_packet_codec_5_pkt_codecRX_EMPTY_TO_IP,
			port13_rx_re_in => mesh_network_max16ag_1_p13_to_switch_packet_codec_5_pkt_codecRX_RE_FROM_IP,
			port13_tx_av_in => mesh_network_max16ag_1_p13_to_switch_packet_codec_5_pkt_codecTX_AV_FROM_IP,
			port13_tx_data_in(31 downto 0) => mesh_network_max16ag_1_p13_to_switch_packet_codec_5_pkt_codecTX_DATA_FROM_IP(31 downto 0),
			port13_tx_full_out => mesh_network_max16ag_1_p13_to_switch_packet_codec_5_pkt_codecTX_FULL_TO_IP,
			port13_tx_txlen_in(15 downto 0) => mesh_network_max16ag_1_p13_to_switch_packet_codec_5_pkt_codecTX_TXLEN_FROM_IP(15 downto 0),
			port13_tx_we_in => mesh_network_max16ag_1_p13_to_switch_packet_codec_5_pkt_codecTX_WE_FROM_IP,
			port14_rx_av_out => mesh_network_max16ag_1_p14_to_switch_packet_codec_6_pkt_codecRX_AV_TO_IP,
			port14_rx_data_out(31 downto 0) => mesh_network_max16ag_1_p14_to_switch_packet_codec_6_pkt_codecRX_DATA_TO_IP(31 downto 0),
			port14_rx_empty_out => mesh_network_max16ag_1_p14_to_switch_packet_codec_6_pkt_codecRX_EMPTY_TO_IP,
			port14_rx_re_in => mesh_network_max16ag_1_p14_to_switch_packet_codec_6_pkt_codecRX_RE_FROM_IP,
			port14_tx_av_in => mesh_network_max16ag_1_p14_to_switch_packet_codec_6_pkt_codecTX_AV_FROM_IP,
			port14_tx_data_in(31 downto 0) => mesh_network_max16ag_1_p14_to_switch_packet_codec_6_pkt_codecTX_DATA_FROM_IP(31 downto 0),
			port14_tx_full_out => mesh_network_max16ag_1_p14_to_switch_packet_codec_6_pkt_codecTX_FULL_TO_IP,
			port14_tx_txlen_in(15 downto 0) => mesh_network_max16ag_1_p14_to_switch_packet_codec_6_pkt_codecTX_TXLEN_FROM_IP(15 downto 0),
			port14_tx_we_in => mesh_network_max16ag_1_p14_to_switch_packet_codec_6_pkt_codecTX_WE_FROM_IP,
			port15_rx_av_out => mesh_network_max16ag_1_p15_to_switch_packet_codec_7_pkt_codecRX_AV_TO_IP,
			port15_rx_data_out(31 downto 0) => mesh_network_max16ag_1_p15_to_switch_packet_codec_7_pkt_codecRX_DATA_TO_IP(31 downto 0),
			port15_rx_empty_out => mesh_network_max16ag_1_p15_to_switch_packet_codec_7_pkt_codecRX_EMPTY_TO_IP,
			port15_rx_re_in => mesh_network_max16ag_1_p15_to_switch_packet_codec_7_pkt_codecRX_RE_FROM_IP,
			port15_tx_av_in => mesh_network_max16ag_1_p15_to_switch_packet_codec_7_pkt_codecTX_AV_FROM_IP,
			port15_tx_data_in(31 downto 0) => mesh_network_max16ag_1_p15_to_switch_packet_codec_7_pkt_codecTX_DATA_FROM_IP(31 downto 0),
			port15_tx_full_out => mesh_network_max16ag_1_p15_to_switch_packet_codec_7_pkt_codecTX_FULL_TO_IP,
			port15_tx_txlen_in(15 downto 0) => mesh_network_max16ag_1_p15_to_switch_packet_codec_7_pkt_codecTX_TXLEN_FROM_IP(15 downto 0),
			port15_tx_we_in => mesh_network_max16ag_1_p15_to_switch_packet_codec_7_pkt_codecTX_WE_FROM_IP,
			port1_rx_av_out => mesh_network_max16ag_1_p1_to_led_packet_codec_1_pkt_codecRX_AV_TO_IP,
			port1_rx_data_out(31 downto 0) => mesh_network_max16ag_1_p1_to_led_packet_codec_1_pkt_codecRX_DATA_TO_IP(31 downto 0),
			port1_rx_empty_out => mesh_network_max16ag_1_p1_to_led_packet_codec_1_pkt_codecRX_EMPTY_TO_IP,
			port1_rx_re_in => mesh_network_max16ag_1_p1_to_led_packet_codec_1_pkt_codecRX_RE_FROM_IP,
			port1_tx_av_in => mesh_network_max16ag_1_p1_to_led_packet_codec_1_pkt_codecTX_AV_FROM_IP,
			port1_tx_data_in(31 downto 0) => mesh_network_max16ag_1_p1_to_led_packet_codec_1_pkt_codecTX_DATA_FROM_IP(31 downto 0),
			port1_tx_full_out => mesh_network_max16ag_1_p1_to_led_packet_codec_1_pkt_codecTX_FULL_TO_IP,
			port1_tx_txlen_in(15 downto 0) => mesh_network_max16ag_1_p1_to_led_packet_codec_1_pkt_codecTX_TXLEN_FROM_IP(15 downto 0),
			port1_tx_we_in => mesh_network_max16ag_1_p1_to_led_packet_codec_1_pkt_codecTX_WE_FROM_IP,
			port2_rx_av_out => mesh_network_max16ag_1_p2_to_led_packet_codec_2_pkt_codecRX_AV_TO_IP,
			port2_rx_data_out(31 downto 0) => mesh_network_max16ag_1_p2_to_led_packet_codec_2_pkt_codecRX_DATA_TO_IP(31 downto 0),
			port2_rx_empty_out => mesh_network_max16ag_1_p2_to_led_packet_codec_2_pkt_codecRX_EMPTY_TO_IP,
			port2_rx_re_in => mesh_network_max16ag_1_p2_to_led_packet_codec_2_pkt_codecRX_RE_FROM_IP,
			port2_tx_av_in => mesh_network_max16ag_1_p2_to_led_packet_codec_2_pkt_codecTX_AV_FROM_IP,
			port2_tx_data_in(31 downto 0) => mesh_network_max16ag_1_p2_to_led_packet_codec_2_pkt_codecTX_DATA_FROM_IP(31 downto 0),
			port2_tx_full_out => mesh_network_max16ag_1_p2_to_led_packet_codec_2_pkt_codecTX_FULL_TO_IP,
			port2_tx_txlen_in(15 downto 0) => mesh_network_max16ag_1_p2_to_led_packet_codec_2_pkt_codecTX_TXLEN_FROM_IP(15 downto 0),
			port2_tx_we_in => mesh_network_max16ag_1_p2_to_led_packet_codec_2_pkt_codecTX_WE_FROM_IP,
			port3_rx_av_out => mesh_network_max16ag_1_p3_to_led_packet_codec_3_pkt_codecRX_AV_TO_IP,
			port3_rx_data_out(31 downto 0) => mesh_network_max16ag_1_p3_to_led_packet_codec_3_pkt_codecRX_DATA_TO_IP(31 downto 0),
			port3_rx_empty_out => mesh_network_max16ag_1_p3_to_led_packet_codec_3_pkt_codecRX_EMPTY_TO_IP,
			port3_rx_re_in => mesh_network_max16ag_1_p3_to_led_packet_codec_3_pkt_codecRX_RE_FROM_IP,
			port3_tx_av_in => mesh_network_max16ag_1_p3_to_led_packet_codec_3_pkt_codecTX_AV_FROM_IP,
			port3_tx_data_in(31 downto 0) => mesh_network_max16ag_1_p3_to_led_packet_codec_3_pkt_codecTX_DATA_FROM_IP(31 downto 0),
			port3_tx_full_out => mesh_network_max16ag_1_p3_to_led_packet_codec_3_pkt_codecTX_FULL_TO_IP,
			port3_tx_txlen_in(15 downto 0) => mesh_network_max16ag_1_p3_to_led_packet_codec_3_pkt_codecTX_TXLEN_FROM_IP(15 downto 0),
			port3_tx_we_in => mesh_network_max16ag_1_p3_to_led_packet_codec_3_pkt_codecTX_WE_FROM_IP,
			port4_rx_av_out => mesh_network_max16ag_1_p4_to_led_packet_codec_4_pkt_codecRX_AV_TO_IP,
			port4_rx_data_out(31 downto 0) => mesh_network_max16ag_1_p4_to_led_packet_codec_4_pkt_codecRX_DATA_TO_IP(31 downto 0),
			port4_rx_empty_out => mesh_network_max16ag_1_p4_to_led_packet_codec_4_pkt_codecRX_EMPTY_TO_IP,
			port4_rx_re_in => mesh_network_max16ag_1_p4_to_led_packet_codec_4_pkt_codecRX_RE_FROM_IP,
			port4_tx_av_in => mesh_network_max16ag_1_p4_to_led_packet_codec_4_pkt_codecTX_AV_FROM_IP,
			port4_tx_data_in(31 downto 0) => mesh_network_max16ag_1_p4_to_led_packet_codec_4_pkt_codecTX_DATA_FROM_IP(31 downto 0),
			port4_tx_full_out => mesh_network_max16ag_1_p4_to_led_packet_codec_4_pkt_codecTX_FULL_TO_IP,
			port4_tx_txlen_in(15 downto 0) => mesh_network_max16ag_1_p4_to_led_packet_codec_4_pkt_codecTX_TXLEN_FROM_IP(15 downto 0),
			port4_tx_we_in => mesh_network_max16ag_1_p4_to_led_packet_codec_4_pkt_codecTX_WE_FROM_IP,
			port5_rx_av_out => mesh_network_max16ag_1_p5_to_led_packet_codec_5_pkt_codecRX_AV_TO_IP,
			port5_rx_data_out(31 downto 0) => mesh_network_max16ag_1_p5_to_led_packet_codec_5_pkt_codecRX_DATA_TO_IP(31 downto 0),
			port5_rx_empty_out => mesh_network_max16ag_1_p5_to_led_packet_codec_5_pkt_codecRX_EMPTY_TO_IP,
			port5_rx_re_in => mesh_network_max16ag_1_p5_to_led_packet_codec_5_pkt_codecRX_RE_FROM_IP,
			port5_tx_av_in => mesh_network_max16ag_1_p5_to_led_packet_codec_5_pkt_codecTX_AV_FROM_IP,
			port5_tx_data_in(31 downto 0) => mesh_network_max16ag_1_p5_to_led_packet_codec_5_pkt_codecTX_DATA_FROM_IP(31 downto 0),
			port5_tx_full_out => mesh_network_max16ag_1_p5_to_led_packet_codec_5_pkt_codecTX_FULL_TO_IP,
			port5_tx_txlen_in(15 downto 0) => mesh_network_max16ag_1_p5_to_led_packet_codec_5_pkt_codecTX_TXLEN_FROM_IP(15 downto 0),
			port5_tx_we_in => mesh_network_max16ag_1_p5_to_led_packet_codec_5_pkt_codecTX_WE_FROM_IP,
			port6_rx_av_out => mesh_network_max16ag_1_p6_to_led_packet_codec_6_pkt_codecRX_AV_TO_IP,
			port6_rx_data_out(31 downto 0) => mesh_network_max16ag_1_p6_to_led_packet_codec_6_pkt_codecRX_DATA_TO_IP(31 downto 0),
			port6_rx_empty_out => mesh_network_max16ag_1_p6_to_led_packet_codec_6_pkt_codecRX_EMPTY_TO_IP,
			port6_rx_re_in => mesh_network_max16ag_1_p6_to_led_packet_codec_6_pkt_codecRX_RE_FROM_IP,
			port6_tx_av_in => mesh_network_max16ag_1_p6_to_led_packet_codec_6_pkt_codecTX_AV_FROM_IP,
			port6_tx_data_in(31 downto 0) => mesh_network_max16ag_1_p6_to_led_packet_codec_6_pkt_codecTX_DATA_FROM_IP(31 downto 0),
			port6_tx_full_out => mesh_network_max16ag_1_p6_to_led_packet_codec_6_pkt_codecTX_FULL_TO_IP,
			port6_tx_txlen_in(15 downto 0) => mesh_network_max16ag_1_p6_to_led_packet_codec_6_pkt_codecTX_TXLEN_FROM_IP(15 downto 0),
			port6_tx_we_in => mesh_network_max16ag_1_p6_to_led_packet_codec_6_pkt_codecTX_WE_FROM_IP,
			port7_rx_av_out => mesh_network_max16ag_1_p7_to_led_packet_codec_7_pkt_codecRX_AV_TO_IP,
			port7_rx_data_out(31 downto 0) => mesh_network_max16ag_1_p7_to_led_packet_codec_7_pkt_codecRX_DATA_TO_IP(31 downto 0),
			port7_rx_empty_out => mesh_network_max16ag_1_p7_to_led_packet_codec_7_pkt_codecRX_EMPTY_TO_IP,
			port7_rx_re_in => mesh_network_max16ag_1_p7_to_led_packet_codec_7_pkt_codecRX_RE_FROM_IP,
			port7_tx_av_in => mesh_network_max16ag_1_p7_to_led_packet_codec_7_pkt_codecTX_AV_FROM_IP,
			port7_tx_data_in(31 downto 0) => mesh_network_max16ag_1_p7_to_led_packet_codec_7_pkt_codecTX_DATA_FROM_IP(31 downto 0),
			port7_tx_full_out => mesh_network_max16ag_1_p7_to_led_packet_codec_7_pkt_codecTX_FULL_TO_IP,
			port7_tx_txlen_in(15 downto 0) => mesh_network_max16ag_1_p7_to_led_packet_codec_7_pkt_codecTX_TXLEN_FROM_IP(15 downto 0),
			port7_tx_we_in => mesh_network_max16ag_1_p7_to_led_packet_codec_7_pkt_codecTX_WE_FROM_IP,
			port8_rx_av_out => mesh_network_max16ag_1_p8_to_switch_packet_codec_0_pkt_codecRX_AV_TO_IP,
			port8_rx_data_out(31 downto 0) => mesh_network_max16ag_1_p8_to_switch_packet_codec_0_pkt_codecRX_DATA_TO_IP(31 downto 0),
			port8_rx_empty_out => mesh_network_max16ag_1_p8_to_switch_packet_codec_0_pkt_codecRX_EMPTY_TO_IP,
			port8_rx_re_in => mesh_network_max16ag_1_p8_to_switch_packet_codec_0_pkt_codecRX_RE_FROM_IP,
			port8_tx_av_in => mesh_network_max16ag_1_p8_to_switch_packet_codec_0_pkt_codecTX_AV_FROM_IP,
			port8_tx_data_in(31 downto 0) => mesh_network_max16ag_1_p8_to_switch_packet_codec_0_pkt_codecTX_DATA_FROM_IP(31 downto 0),
			port8_tx_full_out => mesh_network_max16ag_1_p8_to_switch_packet_codec_0_pkt_codecTX_FULL_TO_IP,
			port8_tx_txlen_in(15 downto 0) => mesh_network_max16ag_1_p8_to_switch_packet_codec_0_pkt_codecTX_TXLEN_FROM_IP(15 downto 0),
			port8_tx_we_in => mesh_network_max16ag_1_p8_to_switch_packet_codec_0_pkt_codecTX_WE_FROM_IP,
			port9_rx_av_out => mesh_network_max16ag_1_p9_to_switch_packet_codec_1_pkt_codecRX_AV_TO_IP,
			port9_rx_data_out(31 downto 0) => mesh_network_max16ag_1_p9_to_switch_packet_codec_1_pkt_codecRX_DATA_TO_IP(31 downto 0),
			port9_rx_empty_out => mesh_network_max16ag_1_p9_to_switch_packet_codec_1_pkt_codecRX_EMPTY_TO_IP,
			port9_rx_re_in => mesh_network_max16ag_1_p9_to_switch_packet_codec_1_pkt_codecRX_RE_FROM_IP,
			port9_tx_av_in => mesh_network_max16ag_1_p9_to_switch_packet_codec_1_pkt_codecTX_AV_FROM_IP,
			port9_tx_data_in(31 downto 0) => mesh_network_max16ag_1_p9_to_switch_packet_codec_1_pkt_codecTX_DATA_FROM_IP(31 downto 0),
			port9_tx_full_out => mesh_network_max16ag_1_p9_to_switch_packet_codec_1_pkt_codecTX_FULL_TO_IP,
			port9_tx_txlen_in(15 downto 0) => mesh_network_max16ag_1_p9_to_switch_packet_codec_1_pkt_codecTX_TXLEN_FROM_IP(15 downto 0),
			port9_tx_we_in => mesh_network_max16ag_1_p9_to_switch_packet_codec_1_pkt_codecTX_WE_FROM_IP,
			rst_n => rst_n
		);

	switch_packet_codec_0 : switch_packet_codec
		generic map (
			my_id_g => 0
		)
		port map (
			clk => clk,
			rst_n => rst_n,
			rx_av_in => mesh_network_max16ag_1_p8_to_switch_packet_codec_0_pkt_codecRX_AV_TO_IP,
			rx_data_in(31 downto 0) => mesh_network_max16ag_1_p8_to_switch_packet_codec_0_pkt_codecRX_DATA_TO_IP(31 downto 0),
			rx_empty_in => mesh_network_max16ag_1_p8_to_switch_packet_codec_0_pkt_codecRX_EMPTY_TO_IP,
			rx_re_out => mesh_network_max16ag_1_p8_to_switch_packet_codec_0_pkt_codecRX_RE_FROM_IP,
			switch_in => switch_0_in,
			tx_av_out => mesh_network_max16ag_1_p8_to_switch_packet_codec_0_pkt_codecTX_AV_FROM_IP,
			tx_data_out(31 downto 0) => mesh_network_max16ag_1_p8_to_switch_packet_codec_0_pkt_codecTX_DATA_FROM_IP(31 downto 0),
			tx_full_in => mesh_network_max16ag_1_p8_to_switch_packet_codec_0_pkt_codecTX_FULL_TO_IP,
			tx_txlen_out(15 downto 0) => mesh_network_max16ag_1_p8_to_switch_packet_codec_0_pkt_codecTX_TXLEN_FROM_IP(15 downto 0),
			tx_we_out => mesh_network_max16ag_1_p8_to_switch_packet_codec_0_pkt_codecTX_WE_FROM_IP
		);

	switch_packet_codec_1 : switch_packet_codec
		generic map (
			my_id_g => 1
		)
		port map (
			clk => clk,
			rst_n => rst_n,
			rx_av_in => mesh_network_max16ag_1_p9_to_switch_packet_codec_1_pkt_codecRX_AV_TO_IP,
			rx_data_in(31 downto 0) => mesh_network_max16ag_1_p9_to_switch_packet_codec_1_pkt_codecRX_DATA_TO_IP(31 downto 0),
			rx_empty_in => mesh_network_max16ag_1_p9_to_switch_packet_codec_1_pkt_codecRX_EMPTY_TO_IP,
			rx_re_out => mesh_network_max16ag_1_p9_to_switch_packet_codec_1_pkt_codecRX_RE_FROM_IP,
			switch_in => switch_1_in,
			tx_av_out => mesh_network_max16ag_1_p9_to_switch_packet_codec_1_pkt_codecTX_AV_FROM_IP,
			tx_data_out(31 downto 0) => mesh_network_max16ag_1_p9_to_switch_packet_codec_1_pkt_codecTX_DATA_FROM_IP(31 downto 0),
			tx_full_in => mesh_network_max16ag_1_p9_to_switch_packet_codec_1_pkt_codecTX_FULL_TO_IP,
			tx_txlen_out(15 downto 0) => mesh_network_max16ag_1_p9_to_switch_packet_codec_1_pkt_codecTX_TXLEN_FROM_IP(15 downto 0),
			tx_we_out => mesh_network_max16ag_1_p9_to_switch_packet_codec_1_pkt_codecTX_WE_FROM_IP
		);

	switch_packet_codec_2 : switch_packet_codec
		generic map (
			my_id_g => 2
		)
		port map (
			clk => clk,
			rst_n => rst_n,
			rx_av_in => mesh_network_max16ag_1_p10_to_switch_packet_codec_2_pkt_codecRX_AV_TO_IP,
			rx_data_in(31 downto 0) => mesh_network_max16ag_1_p10_to_switch_packet_codec_2_pkt_codecRX_DATA_TO_IP(31 downto 0),
			rx_empty_in => mesh_network_max16ag_1_p10_to_switch_packet_codec_2_pkt_codecRX_EMPTY_TO_IP,
			rx_re_out => mesh_network_max16ag_1_p10_to_switch_packet_codec_2_pkt_codecRX_RE_FROM_IP,
			switch_in => switch_2_in,
			tx_av_out => mesh_network_max16ag_1_p10_to_switch_packet_codec_2_pkt_codecTX_AV_FROM_IP,
			tx_data_out(31 downto 0) => mesh_network_max16ag_1_p10_to_switch_packet_codec_2_pkt_codecTX_DATA_FROM_IP(31 downto 0),
			tx_full_in => mesh_network_max16ag_1_p10_to_switch_packet_codec_2_pkt_codecTX_FULL_TO_IP,
			tx_txlen_out(15 downto 0) => mesh_network_max16ag_1_p10_to_switch_packet_codec_2_pkt_codecTX_TXLEN_FROM_IP(15 downto 0),
			tx_we_out => mesh_network_max16ag_1_p10_to_switch_packet_codec_2_pkt_codecTX_WE_FROM_IP
		);

	switch_packet_codec_3 : switch_packet_codec
		generic map (
			my_id_g => 3
		)
		port map (
			clk => clk,
			rst_n => rst_n,
			rx_av_in => mesh_network_max16ag_1_p11_to_switch_packet_codec_3_pkt_codecRX_AV_TO_IP,
			rx_data_in(31 downto 0) => mesh_network_max16ag_1_p11_to_switch_packet_codec_3_pkt_codecRX_DATA_TO_IP(31 downto 0),
			rx_empty_in => mesh_network_max16ag_1_p11_to_switch_packet_codec_3_pkt_codecRX_EMPTY_TO_IP,
			rx_re_out => mesh_network_max16ag_1_p11_to_switch_packet_codec_3_pkt_codecRX_RE_FROM_IP,
			switch_in => switch_3_in,
			tx_av_out => mesh_network_max16ag_1_p11_to_switch_packet_codec_3_pkt_codecTX_AV_FROM_IP,
			tx_data_out(31 downto 0) => mesh_network_max16ag_1_p11_to_switch_packet_codec_3_pkt_codecTX_DATA_FROM_IP(31 downto 0),
			tx_full_in => mesh_network_max16ag_1_p11_to_switch_packet_codec_3_pkt_codecTX_FULL_TO_IP,
			tx_txlen_out(15 downto 0) => mesh_network_max16ag_1_p11_to_switch_packet_codec_3_pkt_codecTX_TXLEN_FROM_IP(15 downto 0),
			tx_we_out => mesh_network_max16ag_1_p11_to_switch_packet_codec_3_pkt_codecTX_WE_FROM_IP
		);

	switch_packet_codec_4 : switch_packet_codec
		generic map (
			my_id_g => 65536
		)
		port map (
			clk => clk,
			rst_n => rst_n,
			rx_av_in => mesh_network_max16ag_1_p12_to_switch_packet_codec_4_pkt_codecRX_AV_TO_IP,
			rx_data_in(31 downto 0) => mesh_network_max16ag_1_p12_to_switch_packet_codec_4_pkt_codecRX_DATA_TO_IP(31 downto 0),
			rx_empty_in => mesh_network_max16ag_1_p12_to_switch_packet_codec_4_pkt_codecRX_EMPTY_TO_IP,
			rx_re_out => mesh_network_max16ag_1_p12_to_switch_packet_codec_4_pkt_codecRX_RE_FROM_IP,
			switch_in => switch_4_in,
			tx_av_out => mesh_network_max16ag_1_p12_to_switch_packet_codec_4_pkt_codecTX_AV_FROM_IP,
			tx_data_out(31 downto 0) => mesh_network_max16ag_1_p12_to_switch_packet_codec_4_pkt_codecTX_DATA_FROM_IP(31 downto 0),
			tx_full_in => mesh_network_max16ag_1_p12_to_switch_packet_codec_4_pkt_codecTX_FULL_TO_IP,
			tx_txlen_out(15 downto 0) => mesh_network_max16ag_1_p12_to_switch_packet_codec_4_pkt_codecTX_TXLEN_FROM_IP(15 downto 0),
			tx_we_out => mesh_network_max16ag_1_p12_to_switch_packet_codec_4_pkt_codecTX_WE_FROM_IP
		);

	switch_packet_codec_5 : switch_packet_codec
		generic map (
			my_id_g => 65537
		)
		port map (
			clk => clk,
			rst_n => rst_n,
			rx_av_in => mesh_network_max16ag_1_p13_to_switch_packet_codec_5_pkt_codecRX_AV_TO_IP,
			rx_data_in(31 downto 0) => mesh_network_max16ag_1_p13_to_switch_packet_codec_5_pkt_codecRX_DATA_TO_IP(31 downto 0),
			rx_empty_in => mesh_network_max16ag_1_p13_to_switch_packet_codec_5_pkt_codecRX_EMPTY_TO_IP,
			rx_re_out => mesh_network_max16ag_1_p13_to_switch_packet_codec_5_pkt_codecRX_RE_FROM_IP,
			switch_in => switch_5_in,
			tx_av_out => mesh_network_max16ag_1_p13_to_switch_packet_codec_5_pkt_codecTX_AV_FROM_IP,
			tx_data_out(31 downto 0) => mesh_network_max16ag_1_p13_to_switch_packet_codec_5_pkt_codecTX_DATA_FROM_IP(31 downto 0),
			tx_full_in => mesh_network_max16ag_1_p13_to_switch_packet_codec_5_pkt_codecTX_FULL_TO_IP,
			tx_txlen_out(15 downto 0) => mesh_network_max16ag_1_p13_to_switch_packet_codec_5_pkt_codecTX_TXLEN_FROM_IP(15 downto 0),
			tx_we_out => mesh_network_max16ag_1_p13_to_switch_packet_codec_5_pkt_codecTX_WE_FROM_IP
		);

	switch_packet_codec_6 : switch_packet_codec
		generic map (
			my_id_g => 65538
		)
		port map (
			clk => clk,
			rst_n => rst_n,
			rx_av_in => mesh_network_max16ag_1_p14_to_switch_packet_codec_6_pkt_codecRX_AV_TO_IP,
			rx_data_in(31 downto 0) => mesh_network_max16ag_1_p14_to_switch_packet_codec_6_pkt_codecRX_DATA_TO_IP(31 downto 0),
			rx_empty_in => mesh_network_max16ag_1_p14_to_switch_packet_codec_6_pkt_codecRX_EMPTY_TO_IP,
			rx_re_out => mesh_network_max16ag_1_p14_to_switch_packet_codec_6_pkt_codecRX_RE_FROM_IP,
			switch_in => switch_6_in,
			tx_av_out => mesh_network_max16ag_1_p14_to_switch_packet_codec_6_pkt_codecTX_AV_FROM_IP,
			tx_data_out(31 downto 0) => mesh_network_max16ag_1_p14_to_switch_packet_codec_6_pkt_codecTX_DATA_FROM_IP(31 downto 0),
			tx_full_in => mesh_network_max16ag_1_p14_to_switch_packet_codec_6_pkt_codecTX_FULL_TO_IP,
			tx_txlen_out(15 downto 0) => mesh_network_max16ag_1_p14_to_switch_packet_codec_6_pkt_codecTX_TXLEN_FROM_IP(15 downto 0),
			tx_we_out => mesh_network_max16ag_1_p14_to_switch_packet_codec_6_pkt_codecTX_WE_FROM_IP
		);

	switch_packet_codec_7 : switch_packet_codec
		generic map (
			my_id_g => 65539
		)
		port map (
			clk => clk,
			rst_n => rst_n,
			rx_av_in => mesh_network_max16ag_1_p15_to_switch_packet_codec_7_pkt_codecRX_AV_TO_IP,
			rx_data_in(31 downto 0) => mesh_network_max16ag_1_p15_to_switch_packet_codec_7_pkt_codecRX_DATA_TO_IP(31 downto 0),
			rx_empty_in => mesh_network_max16ag_1_p15_to_switch_packet_codec_7_pkt_codecRX_EMPTY_TO_IP,
			rx_re_out => mesh_network_max16ag_1_p15_to_switch_packet_codec_7_pkt_codecRX_RE_FROM_IP,
			switch_in => switch_7_in,
			tx_av_out => mesh_network_max16ag_1_p15_to_switch_packet_codec_7_pkt_codecTX_AV_FROM_IP,
			tx_data_out(31 downto 0) => mesh_network_max16ag_1_p15_to_switch_packet_codec_7_pkt_codecTX_DATA_FROM_IP(31 downto 0),
			tx_full_in => mesh_network_max16ag_1_p15_to_switch_packet_codec_7_pkt_codecTX_FULL_TO_IP,
			tx_txlen_out(15 downto 0) => mesh_network_max16ag_1_p15_to_switch_packet_codec_7_pkt_codecTX_TXLEN_FROM_IP(15 downto 0),
			tx_we_out => mesh_network_max16ag_1_p15_to_switch_packet_codec_7_pkt_codecTX_WE_FROM_IP
		);

end kactusHierarchical;
