-------------------------------------------------------------------------------
-- Title      : HIBI PE DMA - top level
-- Project    : 
-------------------------------------------------------------------------------
-- File       : hibi_pe_dma.vhd
-- Author     : kulmala3
-- Created    : 2011-04-04
-- Last update: 2012-02-08
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2005 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 30.03.2005  1.0      AK      Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;


entity hibi_pe_dma is
  
  generic (
    data_width_g       : integer := 32;  -- 32 and 64 supported
    addr_width_g       : integer := 32;
    words_width_g      : integer := 16;
    n_stream_chans_g   : integer := 4;   -- how many streaming channels
    n_packet_chans_g   : integer := 4;   -- how many packet channels
    n_chans_bits_g     : integer := 3;   -- how many bits to show all channels
    -- eg 2 for 4, 3 for 5, basically log2(n_packet_chans_g+n_stream_chans_g)
    hibi_addr_cmp_lo_g : integer := 8;
    hibi_addr_cmp_hi_g : integer := 31
    );

  port (
    clk   : in std_logic;
    rst_n : in std_logic;

    -- avalon master (rx) if
    avalon_addr_out_rx       : out std_logic_vector(addr_width_g-1 downto 0);
    avalon_we_out_rx         : out std_logic;
    avalon_be_out_rx         : out std_logic_vector(data_width_g/8-1 downto 0);
    avalon_writedata_out_rx  : out std_logic_vector(data_width_g-1 downto 0);
    avalon_waitrequest_in_rx : in  std_logic;

    --avalon slave if (config)
    avalon_cfg_addr_in         : in  std_logic_vector(n_chans_bits_g+4-1 downto 0);
    avalon_cfg_writedata_in    : in  std_logic_vector(addr_width_g-1 downto 0);
    avalon_cfg_we_in           : in  std_logic;
    avalon_cfg_readdata_out    : out std_logic_vector(addr_width_g-1 downto 0);
    avalon_cfg_re_in           : in  std_logic;
    avalon_cfg_cs_in           : in  std_logic;
    avalon_cfg_waitrequest_out : out std_logic;

    -- Avalon master read interface (tx)
    avalon_addr_out_tx         : out std_logic_vector(addr_width_g-1 downto 0);
    avalon_re_out_tx           : out std_logic;
    avalon_readdata_in_tx      : in  std_logic_vector(data_width_g-1 downto 0);
    avalon_waitrequest_in_tx   : in  std_logic;
    avalon_readdatavalid_in_tx : in  std_logic;

    -- hibi (rx) if
    hibi_data_in  : in  std_logic_vector(data_width_g-1 downto 0);
    hibi_av_in    : in  std_logic;
    hibi_empty_in : in  std_logic;
    hibi_comm_in  : in  std_logic_vector(4 downto 0);
    hibi_re_out   : out std_logic;

    -- hibi write interface (tx)
    hibi_data_out : out std_logic_vector(data_width_g-1 downto 0);
    hibi_av_out   : out std_logic;
    hibi_full_in  : in  std_logic;
    hibi_comm_out : out std_logic_vector(4 downto 0);
    hibi_we_out   : out std_logic;

    rx_irq_out : out std_logic

    );

end hibi_pe_dma;



architecture structural of hibi_pe_dma is

  signal tx_start_from_rx     : std_logic;
  signal tx_comm_from_rx      : std_logic_vector(4 downto 0);
  signal tx_mem_addr_from_rx  : std_logic_vector(addr_width_g-1 downto 0);
  signal tx_hibi_addr_from_rx : std_logic_vector(addr_width_g-1 downto 0);
  signal tx_words_from_rx     : std_logic_vector(words_width_g-1 downto 0);
  signal tx_status_done_to_rx : std_logic;


begin  -- structural

  assert data_width_g = 64 or data_width_g = 32
    report "Data width other than 32 or 64 not currently supported"
    severity failure;

  rx_conf : entity work.hpd_rx_and_conf
    generic map (
      n_stream_chans_g   => n_stream_chans_g,
      n_packet_chans_g   => n_packet_chans_g,
      n_chans_bits_g     => n_chans_bits_g,
      data_width_g       => data_width_g,
      addr_width_g       => addr_width_g,
      hibi_addr_cmp_hi_g => hibi_addr_cmp_hi_g,
      hibi_addr_cmp_lo_g => hibi_addr_cmp_lo_g,
      words_width_g      => words_width_g
      )
    port map (
      clk                        => clk,
      rst_n                      => rst_n,
      avalon_addr_out            => avalon_addr_out_rx,
      avalon_we_out              => avalon_we_out_rx,
      avalon_be_out              => avalon_be_out_rx,
      avalon_writedata_out       => avalon_writedata_out_rx,
      avalon_waitrequest_in      => avalon_waitrequest_in_rx,
      hibi_data_in               => hibi_data_in,
      hibi_av_in                 => hibi_av_in,
      hibi_empty_in              => hibi_empty_in,
      hibi_comm_in               => hibi_comm_in,
      hibi_re_out                => hibi_re_out,
      avalon_cfg_addr_in         => avalon_cfg_addr_in,
      avalon_cfg_writedata_in    => avalon_cfg_writedata_in,
      avalon_cfg_we_in           => avalon_cfg_we_in,
      avalon_cfg_readdata_out    => avalon_cfg_readdata_out,
      avalon_cfg_re_in           => avalon_cfg_re_in,
      avalon_cfg_cs_in           => avalon_cfg_cs_in,
      avalon_cfg_waitrequest_out => avalon_cfg_waitrequest_out,
      rx_irq_out                 => rx_irq_out,
      tx_start_out               => tx_start_from_rx,
      tx_comm_out                => tx_comm_from_rx,
      tx_mem_addr_out            => tx_mem_addr_from_rx,
      tx_hibi_addr_out           => tx_hibi_addr_from_rx,
      tx_words_out               => tx_words_from_rx,
      tx_status_done_in          => tx_status_done_to_rx
      );

  tx_control : entity work.hpd_tx_control
    generic map (
      data_width_g  => data_width_g,
      addr_width_g  => addr_width_g,
      words_width_g => words_width_g)
    port map (
      clk                     => clk,
      rst_n                   => rst_n,
      avalon_addr_out         => avalon_addr_out_tx,
      avalon_re_out           => avalon_re_out_tx,
      avalon_readdata_in      => avalon_readdata_in_tx,
      avalon_waitrequest_in   => avalon_waitrequest_in_tx,
      avalon_readdatavalid_in => avalon_readdatavalid_in_tx,
      hibi_data_out           => hibi_data_out,
      hibi_av_out             => hibi_av_out,
      hibi_full_in            => hibi_full_in,
      hibi_comm_out           => hibi_comm_out,
      hibi_we_out             => hibi_we_out,
      tx_start_in             => tx_start_from_rx,
      tx_status_done_out      => tx_status_done_to_rx,
      tx_hibi_addr_in         => tx_hibi_addr_from_rx,
      tx_comm_in              => tx_comm_from_rx,
      tx_ram_addr_in          => tx_mem_addr_from_rx,
      tx_words_in             => tx_words_from_rx
      );

end structural;
