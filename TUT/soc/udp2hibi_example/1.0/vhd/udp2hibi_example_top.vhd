-------------------------------------------------------------------------------
-- Title      : udp2hibi example
-- Project    : 
-------------------------------------------------------------------------------
-- File       : udp2hibi_example_top.vhd
-- Author     :   <alhonena@AHVEN>
-- Company    : 
-- Created    : 2012-01-19
-- Last update: 2012-02-07
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: Instantiates NIOS II CPU, SDRAM CTRL, UDP2HIBI and HIBI to
-- interconnect those. UDP2HIBI further instantiates UDP/IP packetizer and
-- a controller for DM9000A eth chip.
-- Hence, you can demonstrate ethernet TX and RX operations from the software
-- on NIOS, utilizing SW-initiated DMA between SDRAM and UDP2HIBI.
-- You can connect an FPGA board and a PC, but it may be even easier to connect
-- two FPGA boards with identical configuration.
-------------------------------------------------------------------------------
-- Copyright (c) 2012 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2012-01-19  1.0      alhonena        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity udp2hibi_example_top is
  
  port (
    CLOCK_50   : in    std_logic;
    SW         : in    std_logic_vector(17 downto 0);
    KEY        : in    std_logic_vector(3 downto 0);
    LEDR       : out   std_logic_vector(17 downto 0);
    LEDG       : out   std_logic_vector(8 downto 0);

    DRAM_ADDR  : out   std_logic_vector(11 downto 0);
    DRAM_BA    : out   std_logic_vector(1 downto 0);
    DRAM_CAS_N : out   std_logic;
    DRAM_CKE   : out   std_logic;
    DRAM_CLK   : out   std_logic;
    DRAM_CS_N  : out   std_logic;
    DRAM_DQ    : inout std_logic_vector(15 downto 0);
    DRAM_DQM   : out   std_logic_vector(1 downto 0);
    DRAM_RAS_N : out   std_logic;
    DRAM_WE_N  : out   std_logic;

    ENET_DATA  : inout std_logic_vector(15 downto 0);
    ENET_CLK   : out   std_logic;
    ENET_CMD   : out   std_logic;
    ENET_CS_N  : out   std_logic;
    ENET_INT   : in    std_logic;
    ENET_RD_N  : out   std_logic;
    ENET_WR_N  : out   std_logic;
    ENET_RST_N : out   std_logic

    );

end udp2hibi_example_top;

architecture structural of udp2hibi_example_top is

  signal clk_cpu, clk_eth, rst_n : std_logic;

  -- hibi terminology:
  -- r4 interface = simpler interface; one signal set for both priorities, multiplexed addr&data (1-bit av signal)
  -- r3 interface = two signal sets ("normal" and hi-prio ("msg")), separate addr and data.

  constant hibi_comm_w_c : integer := 5;
  constant hibi_data_w_c : integer := 32;
  constant hibi_addr_w_c : integer := 32;
  
  constant num_r4_ips_c : integer := 2;  -- nios, udp2hibi
  constant num_r3_ips_c : integer := 1;  -- sdram

  -- r3 signals for sdram

  signal r3_wra_ag_addr : std_logic_vector(num_r3_ips_c*hibi_addr_w_c-1 downto 0);
  signal r3_wra_ag_data : std_logic_vector(num_r3_ips_c*hibi_data_w_c-1 downto 0);
  signal r3_wra_ag_comm : std_logic_vector(num_r3_ips_c*hibi_comm_w_c-1 downto 0);
  signal r3_wra_ag_empty : std_logic_vector(num_r3_ips_c-1 downto 0);
  signal r3_ag_wra_re : std_logic_vector(num_r3_ips_c-1 downto 0);
  signal r3_ag_wra_addr : std_logic_vector(num_r3_ips_c*hibi_addr_w_c-1 downto 0);
  signal r3_ag_wra_data : std_logic_vector(num_r3_ips_c*hibi_data_w_c-1 downto 0);
  signal r3_ag_wra_comm : std_logic_vector(num_r3_ips_c*hibi_comm_w_c-1 downto 0);
  signal r3_wra_ag_full : std_logic_vector(num_r3_ips_c-1 downto 0);
  signal r3_ag_wra_we : std_logic_vector(num_r3_ips_c-1 downto 0);
  signal r3_wra_ag_msg_addr : std_logic_vector(num_r3_ips_c*hibi_addr_w_c-1 downto 0);
  signal r3_wra_ag_msg_data : std_logic_vector(num_r3_ips_c*hibi_data_w_c-1 downto 0);
  signal r3_wra_ag_msg_comm : std_logic_vector(num_r3_ips_c*hibi_comm_w_c-1 downto 0);
  signal r3_wra_ag_msg_empty : std_logic_vector(num_r3_ips_c-1 downto 0);
  signal r3_ag_wra_msg_re : std_logic_vector(num_r3_ips_c-1 downto 0);
  signal r3_ag_wra_msg_addr : std_logic_vector(num_r3_ips_c*hibi_addr_w_c-1 downto 0);
  signal r3_ag_wra_msg_data : std_logic_vector(num_r3_ips_c*hibi_data_w_c-1 downto 0);
  signal r3_ag_wra_msg_comm : std_logic_vector(num_r3_ips_c*hibi_comm_w_c-1 downto 0);
  signal r3_wra_ag_msg_full : std_logic_vector(num_r3_ips_c-1 downto 0);
  signal r3_ag_wra_msg_we : std_logic_vector(num_r3_ips_c-1 downto 0);
  
  signal r4_wra_ag_av : std_logic_vector(num_r4_ips_c-1 downto 0);
  signal r4_wra_ag_data : std_logic_vector(num_r4_ips_c*hibi_data_w_c-1 downto 0);
  signal r4_wra_ag_comm : std_logic_vector(num_r4_ips_c*hibi_comm_w_c-1 downto 0);
  signal r4_wra_ag_empty : std_logic_vector(num_r4_ips_c-1 downto 0);
  signal r4_ag_wra_re : std_logic_vector(num_r4_ips_c-1 downto 0);
  signal r4_ag_wra_av : std_logic_vector(num_r4_ips_c-1 downto 0);
  signal r4_ag_wra_data : std_logic_vector(num_r4_ips_c*hibi_data_w_c-1 downto 0);
  signal r4_ag_wra_comm : std_logic_vector(num_r4_ips_c*hibi_comm_w_c-1 downto 0);
  signal r4_wra_ag_full : std_logic_vector(num_r4_ips_c-1 downto 0);
  signal r4_ag_wra_we : std_logic_vector(num_r4_ips_c-1 downto 0);
  
    
  
begin  -- structural

  pll_1: entity work.pll
    port map (
      areset => not SW(17),
      inclk0 => CLOCK_50,
      c0     => clk_cpu,                -- 50 MHz
      c1     => DRAM_CLK,              -- 50 MHz -54 deg
      c2     => clk_eth,                -- 25 MHz
      locked => rst_n);

  
  udp2hibi_demo_cpu_1 : entity work.udp2hibi_demo_cpu
    port map(
      hibi_av_out_from_the_n2h2_chan_0 => r4_ag_wra_av(0),
      hibi_comm_out_from_the_n2h2_chan_0 => r4_ag_wra_comm(hibi_comm_w_c-1 downto 0),
      hibi_data_out_from_the_n2h2_chan_0 => r4_ag_wra_data(hibi_data_w_c-1 downto 0),
      hibi_re_out_from_the_n2h2_chan_0 => r4_ag_wra_re(0),
      hibi_we_out_from_the_n2h2_chan_0 => r4_ag_wra_we(0),
      out_port_from_the_pout => LEDR(7 downto 0),
      clk_0 => clk_cpu,
      hibi_av_in_to_the_n2h2_chan_0 => r4_wra_ag_av(0),
      hibi_comm_in_to_the_n2h2_chan_0 => r4_wra_ag_comm(hibi_comm_w_c-1 downto 0),      
      hibi_data_in_to_the_n2h2_chan_0 => r4_wra_ag_data(hibi_data_w_c-1 downto 0),
      hibi_empty_in_to_the_n2h2_chan_0 => r4_wra_ag_empty(0),
      hibi_full_in_to_the_n2h2_chan_0 =>  r4_wra_ag_full(0),
      in_port_to_the_pin => SW(7 downto 0),
      reset_n => rst_n
    );
  
  hibi_segment_v3_1: entity work.hibi_segment_v3
    generic map (
--      id_width_g          => id_width_g,
      addr_width_g        => 32,
      data_width_g        => 32,
      comm_width_g        => 5,
--      counter_width_g     => counter_width_g,
      rel_agent_freq_g    => 1,
      rel_bus_freq_g      => 1,
--      arb_type_g          => arb_type_g,
      fifo_sel_g          => 0,
--      rx_fifo_depth_g     => rx_fifo_depth_g,
--      rx_msg_fifo_depth_g => rx_msg_fifo_depth_g,
--      tx_fifo_depth_g     => tx_fifo_depth_g,
--      tx_msg_fifo_depth_g => tx_msg_fifo_depth_g,
--      max_send_g          => max_send_g,
--      n_cfg_pages_g       => n_cfg_pages_g,
--      n_time_slots_g      => n_time_slots_g,
--      keep_slot_g         => keep_slot_g,
--      n_extra_params_g    => n_extra_params_g,
--      cfg_re_g            => cfg_re_g,
--      cfg_we_g            => cfg_we_g,
--      debug_width_g       => debug_width_g,
      n_r3_agents_g       => num_r3_ips_c,
      n_r4_agents_g       => num_r4_ips_c,
      n_segments_g        => 1,
      separate_addr_g     => 0)
    port map (
      clk_in                 => clk_cpu,
      rst_n                  => rst_n,
      r4_agent_comm_in       => r4_ag_wra_comm,
      r4_agent_data_in       => r4_ag_wra_data,
      r4_agent_av_in         => r4_ag_wra_av,
      r4_agent_we_in         => r4_ag_wra_we,
      r4_agent_re_in         => r4_ag_wra_re,
      r4_agent_comm_out      => r4_wra_ag_comm,
      r4_agent_data_out      => r4_wra_ag_data,
      r4_agent_av_out        => r4_wra_ag_av,
      r4_agent_full_out      => r4_wra_ag_full,
      r4_agent_one_p_out     => open,
      r4_agent_empty_out     => r4_wra_ag_empty,
      r4_agent_one_d_out     => open,
      r3_agent_comm_in       => r3_ag_wra_comm,
      r3_agent_data_in       => r3_ag_wra_data,
      r3_agent_addr_in       => r3_ag_wra_addr,
      r3_agent_we_in         => r3_ag_wra_we,
      r3_agent_re_in         => r3_ag_wra_re,
      r3_agent_comm_out      => r3_wra_ag_comm,
      r3_agent_data_out      => r3_wra_ag_data,
      r3_agent_addr_out      => r3_wra_ag_addr,
      r3_agent_full_out      => r3_wra_ag_full,
      r3_agent_one_p_out     => open,
      r3_agent_empty_out     => r3_wra_ag_empty,
      r3_agent_one_d_out     => open,
      r3_agent_msg_comm_in   => r3_ag_wra_msg_comm,
      r3_agent_msg_data_in   => r3_ag_wra_msg_data,      
      r3_agent_msg_addr_in   => r3_ag_wra_msg_addr,
      r3_agent_msg_we_in     => r3_ag_wra_msg_we,
      r3_agent_msg_re_in     => r3_ag_wra_msg_re,
      r3_agent_msg_comm_out  => r3_wra_ag_msg_comm,
      r3_agent_msg_data_out  => r3_wra_ag_msg_data,
      r3_agent_msg_addr_out  => r3_wra_ag_msg_addr,
      r3_agent_msg_full_out  => r3_wra_ag_msg_full,
      r3_agent_msg_one_p_out => open,
      r3_agent_msg_empty_out => r3_wra_ag_msg_empty,
      r3_agent_msg_one_d_out => open);


  sdram_toplevel_1: entity work.sdram_toplevel  -- use the 16-bit (de2) version.
    generic map (
      hibi_data_width_g    => 32,
      mem_data_width_g     => 16,
--      mem_addr_width_g     => 22,
--      comm_width_g         => 5,
--      input_fifo_depth_g   => input_fifo_depth_g,
--      num_of_read_ports_g  => num_of_read_ports_g,
--      num_of_write_ports_g => num_of_write_ports_g,
--      offset_width_g       => offset_width_g,
--      rq_fifo_depth_g      => rq_fifo_depth_g,
--      op_arb_type_g        => op_arb_type_g,
--      port_arb_type_g      => port_arb_type_g,
--      blk_rd_prior_g       => blk_rd_prior_g,
--      blk_wr_prior_g       => blk_wr_prior_g,
--      single_op_prior_g    => single_op_prior_g,
--      block_overlap_g      => block_overlap_g,
      clk_freq_mhz_g       => 50
--      block_read_length_g  => block_read_length_g
      )
    port map (
      clk               => clk_cpu,
      rst_n             => rst_n,
      hibi_addr_in      => r3_wra_ag_addr(hibi_addr_w_c-1 downto 0),
      hibi_data_in      => r3_wra_ag_data(hibi_data_w_c-1 downto 0),
      hibi_comm_in      => r3_wra_ag_comm(hibi_comm_w_c-1 downto 0),
      hibi_empty_in     => r3_wra_ag_empty(0),
      hibi_re_out       => r3_ag_wra_re(0),
      hibi_addr_out     => r3_ag_wra_addr(hibi_addr_w_c-1 downto 0),
      hibi_data_out     => r3_ag_wra_data(hibi_data_w_c-1 downto 0),
      hibi_comm_out     => r3_ag_wra_comm(hibi_comm_w_c-1 downto 0),
      hibi_full_in      => r3_wra_ag_full(0),
      hibi_we_out       => r3_ag_wra_we(0), 
      hibi_msg_addr_in  => r3_wra_ag_msg_addr(hibi_addr_w_c-1 downto 0),
      hibi_msg_data_in  => r3_wra_ag_msg_data(hibi_data_w_c-1 downto 0),
      hibi_msg_comm_in  => r3_wra_ag_msg_comm(hibi_comm_w_c-1 downto 0),
      hibi_msg_empty_in => r3_wra_ag_msg_empty(0),
      hibi_msg_re_out   => r3_ag_wra_msg_re(0),
      hibi_msg_data_out => r3_ag_wra_msg_data(hibi_data_w_c-1 downto 0),
      hibi_msg_addr_out => r3_ag_wra_msg_addr(hibi_addr_w_c-1 downto 0),
      hibi_msg_comm_out => r3_ag_wra_msg_comm(hibi_comm_w_c-1 downto 0),
      hibi_msg_full_in  => r3_wra_ag_msg_full(0),
      hibi_msg_we_out   => r3_ag_wra_msg_we(0), 
      sdram_data_inout  => DRAM_DQ,
      sdram_cke_out     => DRAM_CKE,
      sdram_cs_n_out    => DRAM_CS_N,
      sdram_we_n_out    => DRAM_WE_N,
      sdram_ras_n_out   => DRAM_RAS_N,
      sdram_cas_n_out   => DRAM_CAS_N,
      sdram_dqm_out     => DRAM_DQM,
      sdram_ba_out      => DRAM_BA,
      sdram_address_out => DRAM_ADDR);

  eth_udpip_udp2hibi_top_1: entity work.eth_udpip_udp2hibi_top
    generic map (
--      receiver_table_size_g    => receiver_table_size_g,
--      ack_fifo_depth_g         => ack_fifo_depth_g,
--      tx_multiclk_fifo_depth_g => tx_multiclk_fifo_depth_g,
--      rx_multiclk_fifo_depth_g => rx_multiclk_fifo_depth_g,
--      hibi_tx_fifo_depth_g     => hibi_tx_fifo_depth_g,
      hibi_data_width_g        => 32,
      hibi_addr_width_g        => 32,
      hibi_comm_width_g        => 5,
      frequency_g              => 50000000)
    port map (
      clk              => clk_cpu,
      clk_udp          => clk_eth,
      rst_n            => rst_n,
      eth_clk_out      => ENET_CLK,
      eth_reset_out    => ENET_RST_N,
      eth_cmd_out      => ENET_CMD,
      eth_write_out    => ENET_WR_N,
      eth_read_out     => ENET_RD_N,
      eth_interrupt_in => ENET_INT,
      eth_data_inout   => ENET_DATA,
      eth_chip_sel_out => ENET_CS_N,
      ready_out        => LEDG(8),
      fatal_error_out  => LEDR(17),
      hibi_comm_in     => r4_wra_ag_comm(2*hibi_comm_w_c-1 downto 1*hibi_comm_w_c),
      hibi_data_in     => r4_wra_ag_data(2*hibi_data_w_c-1 downto 1*hibi_data_w_c),
      hibi_av_in       => r4_wra_ag_av(1),
      hibi_empty_in    => r4_wra_ag_empty(1),
      hibi_re_out      => r4_ag_wra_re(1),
      hibi_comm_out    => r4_ag_wra_comm(2*hibi_comm_w_c-1 downto 1*hibi_comm_w_c),
      hibi_data_out    => r4_ag_wra_data(2*hibi_data_w_c-1 downto 1*hibi_data_w_c),
      hibi_av_out      => r4_ag_wra_av(1),
      hibi_we_out      => r4_ag_wra_we(1),
      hibi_full_in     => r4_wra_ag_full(1));
  
end structural;
