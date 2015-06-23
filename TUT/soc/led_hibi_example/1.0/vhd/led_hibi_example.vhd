-- ***************************************************
-- File: led_hibi_example.vhd
-- Creation date: 16.03.2012
-- Creation time: 16:46:56
-- Description: 
-- Created by: ege
-- This file was generated with Kactus2 vhdl generator.
-- ***************************************************
library IEEE;
library work;
library hibi;
use IEEE.std_logic_1164.all;
use work.all;
use hibi.all;

entity led_hibi_example is

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
		agent_addr_out_17 : out std_logic_vector(31 downto 0);
		agent_comm_out_17 : out std_logic_vector(4 downto 0);
		agent_data_out_17 : out std_logic_vector(31 downto 0);
		agent_empty_out_17 : out std_logic;
		agent_full_out_17 : out std_logic;
		agent_msg_addr_out_17 : out std_logic_vector(31 downto 0);
		agent_msg_comm_out_17 : out std_logic_vector(4 downto 0);
		agent_msg_data_out_17 : out std_logic_vector(31 downto 0);
		agent_msg_empty_out_17 : out std_logic;
		agent_msg_full_out_17 : out std_logic;
		agent_msg_one_p_out_17 : out std_logic;
		agent_one_p_out_17 : out std_logic;

		-- Interface: hibi_p3
		agent_av_in_3 : in std_logic;
		agent_comm_in_3 : in std_logic_vector(4 downto 0);
		agent_data_in_3 : in std_logic_vector(31 downto 0);
		agent_re_in_3 : in std_logic;
		agent_we_in_3 : in std_logic;
		agent_av_out_3 : out std_logic;
		agent_comm_out_3 : out std_logic_vector(4 downto 0);
		agent_data_out_3 : out std_logic_vector(31 downto 0);
		agent_empty_out_3 : out std_logic;
		agent_full_out_3 : out std_logic;
		agent_one_d_out_3 : out std_logic;
		agent_one_p_out_3 : out std_logic;

		-- Interface: led_0_out
		led_0_out : out std_logic;

		-- Interface: rst_n_in
		rst_n : in std_logic;

		-- Interface: switch_0_in
		switch_0_in : in std_logic
	);

end led_hibi_example;


architecture for_syn of led_hibi_example is

	signal switch_packet_codec_1_to_hibi_to_hibi_segment_small_1_hibi_p0AV_FROM_IP : std_logic;
	signal hibi_segment_small_1_hibi_p1_to_led_packet_codec_1_from_hibiAV_FROM_IP : std_logic;
	signal switch_packet_codec_1_to_hibi_to_hibi_segment_small_1_hibi_p0AV_TO_IP : std_logic;
	signal hibi_segment_small_1_hibi_p1_to_led_packet_codec_1_from_hibiAV_TO_IP : std_logic;
	signal switch_packet_codec_1_to_hibi_to_hibi_segment_small_1_hibi_p0COMM_FROM_IP : std_logic_vector(4 downto 0);
	signal switch_packet_codec_1_to_hibi_to_hibi_segment_small_1_hibi_p0DATA_FROM_IP : std_logic_vector(31 downto 0);
	signal hibi_segment_small_1_hibi_p1_to_led_packet_codec_1_from_hibiDATA_FROM_IP : std_logic_vector(31 downto 0);
	signal switch_packet_codec_1_to_hibi_to_hibi_segment_small_1_hibi_p0DATA_TO_IP : std_logic_vector(31 downto 0);
	signal hibi_segment_small_1_hibi_p1_to_led_packet_codec_1_from_hibiDATA_TO_IP : std_logic_vector(31 downto 0);
	signal switch_packet_codec_1_to_hibi_to_hibi_segment_small_1_hibi_p0EMPTY_TO_IP : std_logic;
	signal hibi_segment_small_1_hibi_p1_to_led_packet_codec_1_from_hibiEMPTY_TO_IP : std_logic;
	signal switch_packet_codec_1_to_hibi_to_hibi_segment_small_1_hibi_p0FULL_TO_IP : std_logic;
	signal hibi_segment_small_1_hibi_p1_to_led_packet_codec_1_from_hibiFULL_TO_IP : std_logic;
	signal switch_packet_codec_1_to_hibi_to_hibi_segment_small_1_hibi_p0RE_FROM_IP : std_logic;
	signal hibi_segment_small_1_hibi_p1_to_led_packet_codec_1_from_hibiRE_FROM_IP : std_logic;
	signal switch_packet_codec_1_to_hibi_to_hibi_segment_small_1_hibi_p0WE_FROM_IP : std_logic;
	signal hibi_segment_small_1_hibi_p1_to_led_packet_codec_1_from_hibiWE_FROM_IP : std_logic;

	-- Shared bus for IP blocks
	component hibi_segment_small
		port (

			-- Interface: clk_in
			clk_in : in std_logic;

			-- Interface: ddr2_ctrl_p
			agent_addr_in_16 : in std_logic_vector(31 downto 0);
			agent_comm_in_16 : in std_logic_vector(4 downto 0);
			agent_data_in_16 : in std_logic_vector(31 downto 0);
			agent_msg_addr_in_16 : in std_logic_vector(31 downto 0);
			agent_msg_comm_in_16 : in std_logic_vector(4 downto 0);
			agent_msg_data_in_16 : in std_logic_vector(31 downto 0);
			agent_msg_re_in_16 : in std_logic;
			agent_msg_we_in_16 : in std_logic;
			agent_re_in_16 : in std_logic;
			agent_we_in_16 : in std_logic;
			agent_addr_out_16 : out std_logic_vector(31 downto 0);
			agent_comm_out_16 : out std_logic_vector(4 downto 0);
			agent_data_out_16 : out std_logic_vector(31 downto 0);
			agent_empty_out_16 : out std_logic;
			agent_full_out_16 : out std_logic;
			agent_msg_addr_out_16 : out std_logic_vector(31 downto 0);
			agent_msg_comm_out_16 : out std_logic_vector(4 downto 0);
			agent_msg_data_out_16 : out std_logic_vector(31 downto 0);
			agent_msg_empty_out_16 : out std_logic;
			agent_msg_full_out_16 : out std_logic;
			agent_msg_one_p_out_16 : out std_logic;
			agent_one_p_out_16 : out std_logic;

			-- Interface: hibi_p0
			agent_av_in_0 : in std_logic;
			agent_comm_in_0 : in std_logic_vector(4 downto 0);
			agent_data_in_0 : in std_logic_vector(31 downto 0);
			agent_re_in_0 : in std_logic;
			agent_we_in_0 : in std_logic;
			agent_av_out_0 : out std_logic;
			-- agent_comm_out_0 : out std_logic_vector(4 downto 0);
			agent_data_out_0 : out std_logic_vector(31 downto 0);
			agent_empty_out_0 : out std_logic;
			agent_full_out_0 : out std_logic;
			-- agent_one_d_out_0 : out std_logic;
			-- agent_one_p_out_0 : out std_logic;

			-- Interface: hibi_p1
			agent_av_in_1 : in std_logic;
			agent_comm_in_1 : in std_logic_vector(4 downto 0);
			agent_data_in_1 : in std_logic_vector(31 downto 0);
			agent_re_in_1 : in std_logic;
			agent_we_in_1 : in std_logic;
			agent_av_out_1 : out std_logic;
			-- agent_comm_out_1 : out std_logic_vector(4 downto 0);
			agent_data_out_1 : out std_logic_vector(31 downto 0);
			agent_empty_out_1 : out std_logic;
			agent_full_out_1 : out std_logic;
			-- agent_one_d_out_1 : out std_logic;
			-- agent_one_p_out_1 : out std_logic;

			-- Interface: hibi_p2
			agent_av_in_2 : in std_logic;
			agent_comm_in_2 : in std_logic_vector(4 downto 0);
			agent_data_in_2 : in std_logic_vector(31 downto 0);
			agent_re_in_2 : in std_logic;
			agent_we_in_2 : in std_logic;
			agent_av_out_2 : out std_logic;
			agent_comm_out_2 : out std_logic_vector(4 downto 0);
			agent_data_out_2 : out std_logic_vector(31 downto 0);
			agent_empty_out_2 : out std_logic;
			agent_full_out_2 : out std_logic;
			agent_one_d_out_2 : out std_logic;
			agent_one_p_out_2 : out std_logic;

			-- These ports are not in any interface
			-- agent_one_d_out_7 : out std_logic;
			-- agent_one_d_out_8 : out std_logic;

			-- Interface: rst_n
			rst_n_in : in std_logic

		);
	end component;

	-- Inverts the led output every time a message is received.
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
			-- tx_txlen_out : out std_logic_vector(15 downto 0);

			-- Interface: rst_n
			rst_n : in std_logic;

			-- There ports are contained in many interfaces
			rx_av_in : in std_logic;
			rx_data_in : in std_logic_vector(31 downto 0);
			rx_empty_in : in std_logic;
			tx_full_in : in std_logic;
			rx_re_out : out std_logic;
			tx_av_out : out std_logic;
			tx_data_out : out std_logic_vector(31 downto 0);
			tx_we_out : out std_logic

		);
	end component;

	-- Converts a toggle of a switch into constant one-word transfer.
	component switch_packet_codec
		generic (
			data_width_g : integer := 32;
			my_id_g : integer := 0; -- To which terminal the message is sent
			tx_len_width_g : integer := 16

		);
		port (

			-- Interface: clk
			clk : in std_logic;

			-- Interface: pkt_codec
			-- tx_txlen_out : out std_logic_vector(15 downto 0);

			-- Interface: rst_n
			rst_n : in std_logic;

			-- There ports are contained in many interfaces
			rx_av_in : in std_logic;
			rx_data_in : in std_logic_vector(31 downto 0);
			rx_empty_in : in std_logic;
			tx_full_in : in std_logic;
			rx_re_out : out std_logic;
			tx_av_out : out std_logic;
			tx_data_out : out std_logic_vector(31 downto 0);
			tx_we_out : out std_logic;

			-- Interface: switch
			switch_in : in std_logic;

			-- Interface: to_hibi
			tx_comm_out : out std_logic_vector(4 downto 0)

		);
	end component;

	-- You can write vhdl code after this tag and it is saved through the generator.
	-- ##KACTUS2_BLACK_BOX_DECLARATIONS_BEGIN##

        signal wr_cmd_c : std_logic_vector ( 4 downto 0) := "00010";
	-- ##KACTUS2_BLACK_BOX_DECLARATIONS_END##
	-- Stop writing your code after this tag.


begin

	-- You can write vhdl code after this tag and it is saved through the generator.
	-- ##KACTUS2_BLACK_BOX_ASSIGNMENTS_BEGIN##
	-- ##KACTUS2_BLACK_BOX_ASSIGNMENTS_END##
	-- Stop writing your code after this tag.

	hibi_segment_small_1 : hibi_segment_small
		port map (
			agent_addr_in_16(31 downto 0) => agent_addr_in_17(31 downto 0),
			agent_addr_out_16(31 downto 0) => agent_addr_out_17(31 downto 0),
			agent_av_in_0 => switch_packet_codec_1_to_hibi_to_hibi_segment_small_1_hibi_p0AV_FROM_IP,
			agent_av_in_1 => hibi_segment_small_1_hibi_p1_to_led_packet_codec_1_from_hibiAV_FROM_IP,
			agent_av_in_2 => agent_av_in_3,
			agent_av_out_0 => switch_packet_codec_1_to_hibi_to_hibi_segment_small_1_hibi_p0AV_TO_IP,
			agent_av_out_1 => hibi_segment_small_1_hibi_p1_to_led_packet_codec_1_from_hibiAV_TO_IP,
			agent_av_out_2 => agent_av_out_3,
			agent_comm_in_0(4 downto 0) => switch_packet_codec_1_to_hibi_to_hibi_segment_small_1_hibi_p0COMM_FROM_IP(4 downto 0),
			agent_comm_in_1 => (others => '0'),
			agent_comm_in_16(4 downto 0) => agent_comm_in_17(4 downto 0),
			agent_comm_in_2(4 downto 0) => agent_comm_in_3(4 downto 0),
			agent_comm_out_16(4 downto 0) => agent_comm_out_17(4 downto 0),
			agent_comm_out_2(4 downto 0) => agent_comm_out_3(4 downto 0),
			agent_data_in_0(31 downto 0) => switch_packet_codec_1_to_hibi_to_hibi_segment_small_1_hibi_p0DATA_FROM_IP(31 downto 0),
			agent_data_in_1(31 downto 0) => hibi_segment_small_1_hibi_p1_to_led_packet_codec_1_from_hibiDATA_FROM_IP(31 downto 0),
			agent_data_in_16(31 downto 0) => agent_data_in_17(31 downto 0),
			agent_data_in_2(31 downto 0) => agent_data_in_3(31 downto 0),
			agent_data_out_0(31 downto 0) => switch_packet_codec_1_to_hibi_to_hibi_segment_small_1_hibi_p0DATA_TO_IP(31 downto 0),
			agent_data_out_1(31 downto 0) => hibi_segment_small_1_hibi_p1_to_led_packet_codec_1_from_hibiDATA_TO_IP(31 downto 0),
			agent_data_out_16(31 downto 0) => agent_data_out_17(31 downto 0),
			agent_data_out_2(31 downto 0) => agent_data_out_3(31 downto 0),
			agent_empty_out_0 => switch_packet_codec_1_to_hibi_to_hibi_segment_small_1_hibi_p0EMPTY_TO_IP,
			agent_empty_out_1 => hibi_segment_small_1_hibi_p1_to_led_packet_codec_1_from_hibiEMPTY_TO_IP,
			agent_empty_out_16 => agent_empty_out_17,
			agent_empty_out_2 => agent_empty_out_3,
			agent_full_out_0 => switch_packet_codec_1_to_hibi_to_hibi_segment_small_1_hibi_p0FULL_TO_IP,
			agent_full_out_1 => hibi_segment_small_1_hibi_p1_to_led_packet_codec_1_from_hibiFULL_TO_IP,
			agent_full_out_16 => agent_full_out_17,
			agent_full_out_2 => agent_full_out_3,
			agent_msg_addr_in_16(31 downto 0) => agent_msg_addr_in_17(31 downto 0),
			agent_msg_addr_out_16(31 downto 0) => agent_msg_addr_out_17(31 downto 0),
			agent_msg_comm_in_16(4 downto 0) => agent_msg_comm_in_17(4 downto 0),
			agent_msg_comm_out_16(4 downto 0) => agent_msg_comm_out_17(4 downto 0),
			agent_msg_data_in_16(31 downto 0) => agent_msg_data_in_17(31 downto 0),
			agent_msg_data_out_16(31 downto 0) => agent_msg_data_out_17(31 downto 0),
			agent_msg_empty_out_16 => agent_msg_empty_out_17,
			agent_msg_full_out_16 => agent_msg_full_out_17,
			agent_msg_one_p_out_16 => agent_msg_one_p_out_17,
			agent_msg_re_in_16 => agent_msg_re_in_17,
			agent_msg_we_in_16 => agent_msg_we_in_17,
			agent_one_d_out_2 => agent_one_d_out_3,
			agent_one_p_out_16 => agent_one_p_out_17,
			agent_one_p_out_2 => agent_one_p_out_3,
			agent_re_in_0 => switch_packet_codec_1_to_hibi_to_hibi_segment_small_1_hibi_p0RE_FROM_IP,
			agent_re_in_1 => hibi_segment_small_1_hibi_p1_to_led_packet_codec_1_from_hibiRE_FROM_IP,
			agent_re_in_16 => agent_re_in_17,
			agent_re_in_2 => agent_re_in_3,
			agent_we_in_0 => switch_packet_codec_1_to_hibi_to_hibi_segment_small_1_hibi_p0WE_FROM_IP,
			agent_we_in_1 => hibi_segment_small_1_hibi_p1_to_led_packet_codec_1_from_hibiWE_FROM_IP,
			agent_we_in_16 => agent_we_in_17,
			agent_we_in_2 => agent_we_in_3,
			clk_in => clk_in,
			rst_n_in => rst_n
		);

	led_packet_codec_1 : led_packet_codec
		port map (
			clk => clk_in,
			led_out => led_0_out,
			rst_n => rst_n,
			rx_av_in => hibi_segment_small_1_hibi_p1_to_led_packet_codec_1_from_hibiAV_TO_IP,
			rx_data_in(31 downto 0) => hibi_segment_small_1_hibi_p1_to_led_packet_codec_1_from_hibiDATA_TO_IP(31 downto 0),
			rx_empty_in => hibi_segment_small_1_hibi_p1_to_led_packet_codec_1_from_hibiEMPTY_TO_IP,
			rx_re_out => hibi_segment_small_1_hibi_p1_to_led_packet_codec_1_from_hibiRE_FROM_IP,
			tx_av_out => hibi_segment_small_1_hibi_p1_to_led_packet_codec_1_from_hibiAV_FROM_IP,
			tx_data_out(31 downto 0) => hibi_segment_small_1_hibi_p1_to_led_packet_codec_1_from_hibiDATA_FROM_IP(31 downto 0),
			tx_full_in => hibi_segment_small_1_hibi_p1_to_led_packet_codec_1_from_hibiFULL_TO_IP,
			tx_we_out => hibi_segment_small_1_hibi_p1_to_led_packet_codec_1_from_hibiWE_FROM_IP
		);

	switch_packet_codec_1 : switch_packet_codec
		generic map (
			my_id_g => 16#03000000#
		)
		port map (
			clk => clk_in,
			rst_n => rst_n,
			rx_av_in => switch_packet_codec_1_to_hibi_to_hibi_segment_small_1_hibi_p0AV_TO_IP,
			rx_data_in(31 downto 0) => switch_packet_codec_1_to_hibi_to_hibi_segment_small_1_hibi_p0DATA_TO_IP(31 downto 0),
			rx_empty_in => switch_packet_codec_1_to_hibi_to_hibi_segment_small_1_hibi_p0EMPTY_TO_IP,
			rx_re_out => switch_packet_codec_1_to_hibi_to_hibi_segment_small_1_hibi_p0RE_FROM_IP,
			switch_in => switch_0_in,
			tx_av_out => switch_packet_codec_1_to_hibi_to_hibi_segment_small_1_hibi_p0AV_FROM_IP,
			tx_comm_out(4 downto 0) => switch_packet_codec_1_to_hibi_to_hibi_segment_small_1_hibi_p0COMM_FROM_IP(4 downto 0),
			tx_data_out(31 downto 0) => switch_packet_codec_1_to_hibi_to_hibi_segment_small_1_hibi_p0DATA_FROM_IP(31 downto 0),
			tx_full_in => switch_packet_codec_1_to_hibi_to_hibi_segment_small_1_hibi_p0FULL_TO_IP,
			tx_we_out => switch_packet_codec_1_to_hibi_to_hibi_segment_small_1_hibi_p0WE_FROM_IP
		);

end for_syn;

