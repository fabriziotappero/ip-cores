-------------------------------------------------------------------------------
-- Title      : N2H2 Top level
-- Project    : 
-------------------------------------------------------------------------------
-- File       : n2h2.vhd
-- Author     : kulmala3
-- Created    : 30.03.2005
-- Last update: 2011-04-04
-- Description: Wires together rx and tx
-------------------------------------------------------------------------------
-- Copyright (c) 2005 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 30.03.2005  1.0      AK      Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
--use work.log2_pkg.all;

entity n2h2 is
  
  generic (
    data_width_g       : integer := 32;  -- 32 and 64 supported
    addr_width_g       : integer := 32;
    amount_width_g     : integer := 16;
    n_chans_g          : integer := 8;
    n_chans_bits_g     : integer := 3;   -- how many bits to show n_chans
    -- eg 2 for 4, 3 for 5, basically log2(n_chans_g)
    hibi_addr_cmp_lo_g : integer := 8;
    hibi_addr_cmp_hi_g : integer := 31
    );

  port (
    clk_cfg : in std_logic;             -- not even used...
    clk_tx  : in std_logic;
    clk_rx  : in std_logic;
    rst_n   : in std_logic;             -- THIS IS ACTIVE HIGH!

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

end n2h2;

architecture structural of n2h2 is

  signal tx_start_from_rx     : std_logic;
  signal tx_comm_from_rx      : std_logic_vector(4 downto 0);
  signal tx_mem_addr_from_rx  : std_logic_vector(addr_width_g-1 downto 0);
  signal tx_hibi_addr_from_rx : std_logic_vector(addr_width_g-1 downto 0);
  signal tx_amount_from_rx    : std_logic_vector(amount_width_g-1 downto 0);
  signal tx_status_done_to_rx : std_logic;
  signal real_rst_n           : std_logic;

  component n2h2_rx_channels
    generic (
      n_chans_g          : integer;
      n_chans_bits_g     : integer;
      data_width_g       : integer;
      addr_width_g       : integer;
      hibi_addr_cmp_hi_g : integer;
      hibi_addr_cmp_lo_g : integer;
      amount_width_g     : integer);
    port (
      clk                     : in  std_logic;
      rst_n                   : in  std_logic;
      avalon_addr_out         : out std_logic_vector(addr_width_g-1 downto 0);
      avalon_we_out           : out std_logic;
      avalon_be_out           : out std_logic_vector(data_width_g/8-1 downto 0);
      avalon_writedata_out    : out std_logic_vector(data_width_g-1 downto 0);
      avalon_waitrequest_in   : in  std_logic;
      hibi_data_in            : in  std_logic_vector(data_width_g-1 downto 0);
      hibi_av_in              : in  std_logic;
      hibi_empty_in           : in  std_logic;
      hibi_comm_in            : in  std_logic_vector(4 downto 0);
      hibi_re_out             : out std_logic;
      avalon_cfg_addr_in      : in  std_logic_vector(n_chans_bits_g+4-1 downto 0);
      avalon_cfg_writedata_in : in  std_logic_vector(addr_width_g-1 downto 0);
      avalon_cfg_we_in        : in  std_logic;
      avalon_cfg_readdata_out : out std_logic_vector(addr_width_g-1 downto 0);
      avalon_cfg_re_in        : in  std_logic;
      avalon_cfg_cs_in        : in  std_logic;
      avalon_cfg_waitrequest_out : out std_logic;
      rx_irq_out              : out std_logic;
      tx_start_out            : out std_logic;
      tx_comm_out             : out std_logic_vector(4 downto 0);
      tx_mem_addr_out         : out std_logic_vector(addr_width_g-1 downto 0);
      tx_hibi_addr_out        : out std_logic_vector(addr_width_g-1 downto 0);
      tx_amount_out           : out std_logic_vector(amount_width_g-1 downto 0);
      tx_status_done_in       : in  std_logic);
  end component;

  component n2h2_tx
    generic (
      data_width_g   : integer;
      addr_width_g   : integer;
      amount_width_g : integer);
    port (
      clk                     : in  std_logic;
      rst_n                   : in  std_logic;
      avalon_addr_out         : out std_logic_vector(addr_width_g-1 downto 0);
      avalon_re_out           : out std_logic;
      avalon_readdata_in      : in  std_logic_vector(data_width_g-1 downto 0);
      avalon_waitrequest_in   : in  std_logic;
      avalon_readdatavalid_in : in  std_logic;

      hibi_data_out      : out std_logic_vector(data_width_g-1 downto 0);
      hibi_av_out        : out std_logic;
      hibi_full_in       : in  std_logic;
      hibi_comm_out      : out std_logic_vector(4 downto 0);
      hibi_we_out        : out std_logic;
      tx_start_in        : in  std_logic;
      tx_status_done_out : out std_logic;
      tx_comm_in         : in  std_logic_vector(4 downto 0);
      tx_hibi_addr_in    : in  std_logic_vector(addr_width_g-1 downto 0);
      tx_ram_addr_in     : in  std_logic_vector(addr_width_g-1 downto 0);
      tx_amount_in       : in  std_logic_vector(amount_width_g-1 downto 0));
  end component;


begin  -- structural


  
  real_rst_n <= rst_n;

  assert data_width_g = 64 or data_width_g = 32 report "Data width other than 32 or 64 not currently supported" severity failure;

   n2h2_rx_chan_1 : n2h2_rx_channels
    generic map (
      n_chans_g          => n_chans_g,
      n_chans_bits_g     => n_chans_bits_g,
      data_width_g       => data_width_g,
      addr_width_g       => addr_width_g,
      hibi_addr_cmp_hi_g => hibi_addr_cmp_hi_g,
      hibi_addr_cmp_lo_g => hibi_addr_cmp_lo_g,
      amount_width_g     => amount_width_g
      )
    port map (
      clk                     => clk_rx,
      rst_n                   => real_rst_n,
      avalon_addr_out         => avalon_addr_out_rx,
      avalon_we_out           => avalon_we_out_rx,
      avalon_be_out           => avalon_be_out_rx,
      avalon_writedata_out    => avalon_writedata_out_rx,
      avalon_waitrequest_in   => avalon_waitrequest_in_rx,
      hibi_data_in            => hibi_data_in,
      hibi_av_in              => hibi_av_in,
      hibi_empty_in           => hibi_empty_in,
      hibi_comm_in            => hibi_comm_in,
      hibi_re_out             => hibi_re_out,
      avalon_cfg_addr_in      => avalon_cfg_addr_in,
      avalon_cfg_writedata_in => avalon_cfg_writedata_in,
      avalon_cfg_we_in        => avalon_cfg_we_in,
      avalon_cfg_readdata_out => avalon_cfg_readdata_out,
      avalon_cfg_re_in        => avalon_cfg_re_in,
      avalon_cfg_cs_in        => avalon_cfg_cs_in,
      avalon_cfg_waitrequest_out => avalon_cfg_waitrequest_out,
      rx_irq_out              => rx_irq_out,
      tx_start_out            => tx_start_from_rx,
      tx_comm_out             => tx_comm_from_rx,
      tx_mem_addr_out         => tx_mem_addr_from_rx,
      tx_hibi_addr_out        => tx_hibi_addr_from_rx,
      tx_amount_out           => tx_amount_from_rx,
      tx_status_done_in       => tx_status_done_to_rx
      );

  n2h2_tx_1 : n2h2_tx
    generic map (
      data_width_g   => data_width_g,
      addr_width_g   => addr_width_g,
      amount_width_g => amount_width_g)
    port map (
      clk                     => clk_tx,
      rst_n                   => real_rst_n,
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
      tx_amount_in            => tx_amount_from_rx
      );

end structural;
