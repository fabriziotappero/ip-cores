-------------------------------------------------------------------------------
-- Title      : Ring network, max 16 agents. Number of busses determined by
--              n_ag_g will be used, starting from port0. Currently only
--              even-sized rings will be allowed.
-- Project    : 
-------------------------------------------------------------------------------
-- File       : ring_network_max16ag.vhd
-- Author     : Antti Alhonen
-- Company    : 
-- Last update: 2011-08-26
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2009/08/07  1.0      alhonena        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity ring_network_max16ag is
  generic (
    n_ag_g          : integer := 16;
    stfwd_en_g      : integer := 0;
    diag_en_g       : integer := 0;
    data_width_g    : integer := 32;
    addr_width_g    : integer := 32;
    packet_length_g : integer := 6;
    tx_len_width_g  : integer := 16;
    timeout_g       : integer := 5;
    fill_packet_g   : integer := 0;
    lut_en_g        : integer := 0;
    len_flit_en_g   : integer := 1;
    oaddr_flit_en_g : integer := 0;
    status_en_g     : integer := 0;
    fifo_depth_g    : integer := 6;
    ring_freq_g     : integer := 50000000;
    ip_freq_g       : integer := 50000000);

  port (
    clk_net : in std_logic;
    clk_ip  : in std_logic;
    rst_n   : in std_logic;

    port0_tx_av_in     : in  std_logic;
    port0_tx_data_in   : in  std_logic_vector (data_width_g -1 downto 0);
    port0_tx_we_in     : in  std_logic;
    port0_tx_txlen_in  : in  std_logic_vector (tx_len_width_g -1 downto 0);
    port0_tx_full_out  : out std_logic;
    port0_rx_av_out    : out std_logic;
    port0_rx_data_out  : out std_logic_vector (data_width_g -1 downto 0);
    port0_rx_re_in     : in  std_logic;
    port0_rx_empty_out : out std_logic;

    port1_tx_av_in     : in  std_logic;
    port1_tx_data_in   : in  std_logic_vector (data_width_g -1 downto 0);
    port1_tx_we_in     : in  std_logic;
    port1_tx_txlen_in  : in  std_logic_vector (tx_len_width_g -1 downto 0);
    port1_tx_full_out  : out std_logic;
    port1_rx_av_out    : out std_logic;
    port1_rx_data_out  : out std_logic_vector (data_width_g -1 downto 0);
    port1_rx_re_in     : in  std_logic;
    port1_rx_empty_out : out std_logic;

    port2_tx_av_in     : in  std_logic;
    port2_tx_data_in   : in  std_logic_vector (data_width_g -1 downto 0);
    port2_tx_we_in     : in  std_logic;
    port2_tx_txlen_in  : in  std_logic_vector (tx_len_width_g -1 downto 0);
    port2_tx_full_out  : out std_logic;
    port2_rx_av_out    : out std_logic;
    port2_rx_data_out  : out std_logic_vector (data_width_g -1 downto 0);
    port2_rx_re_in     : in  std_logic;
    port2_rx_empty_out : out std_logic;

    port3_tx_av_in     : in  std_logic;
    port3_tx_data_in   : in  std_logic_vector (data_width_g -1 downto 0);
    port3_tx_we_in     : in  std_logic;
    port3_tx_txlen_in  : in  std_logic_vector (tx_len_width_g -1 downto 0);
    port3_tx_full_out  : out std_logic;
    port3_rx_av_out    : out std_logic;
    port3_rx_data_out  : out std_logic_vector (data_width_g -1 downto 0);
    port3_rx_re_in     : in  std_logic;
    port3_rx_empty_out : out std_logic;

    port4_tx_av_in     : in  std_logic;
    port4_tx_data_in   : in  std_logic_vector (data_width_g -1 downto 0);
    port4_tx_we_in     : in  std_logic;
    port4_tx_txlen_in  : in  std_logic_vector (tx_len_width_g -1 downto 0);
    port4_tx_full_out  : out std_logic;
    port4_rx_av_out    : out std_logic;
    port4_rx_data_out  : out std_logic_vector (data_width_g -1 downto 0);
    port4_rx_re_in     : in  std_logic;
    port4_rx_empty_out : out std_logic;

    port5_tx_av_in     : in  std_logic;
    port5_tx_data_in   : in  std_logic_vector (data_width_g -1 downto 0);
    port5_tx_we_in     : in  std_logic;
    port5_tx_txlen_in  : in  std_logic_vector (tx_len_width_g -1 downto 0);
    port5_tx_full_out  : out std_logic;
    port5_rx_av_out    : out std_logic;
    port5_rx_data_out  : out std_logic_vector (data_width_g -1 downto 0);
    port5_rx_re_in     : in  std_logic;
    port5_rx_empty_out : out std_logic;

    port6_tx_av_in     : in  std_logic;
    port6_tx_data_in   : in  std_logic_vector (data_width_g -1 downto 0);
    port6_tx_we_in     : in  std_logic;
    port6_tx_txlen_in  : in  std_logic_vector (tx_len_width_g -1 downto 0);
    port6_tx_full_out  : out std_logic;
    port6_rx_av_out    : out std_logic;
    port6_rx_data_out  : out std_logic_vector (data_width_g -1 downto 0);
    port6_rx_re_in     : in  std_logic;
    port6_rx_empty_out : out std_logic;

    port7_tx_av_in     : in  std_logic;
    port7_tx_data_in   : in  std_logic_vector (data_width_g -1 downto 0);
    port7_tx_we_in     : in  std_logic;
    port7_tx_txlen_in  : in  std_logic_vector (tx_len_width_g -1 downto 0);
    port7_tx_full_out  : out std_logic;
    port7_rx_av_out    : out std_logic;
    port7_rx_data_out  : out std_logic_vector (data_width_g -1 downto 0);
    port7_rx_re_in     : in  std_logic;
    port7_rx_empty_out : out std_logic;

    port8_tx_av_in     : in  std_logic;
    port8_tx_data_in   : in  std_logic_vector (data_width_g -1 downto 0);
    port8_tx_we_in     : in  std_logic;
    port8_tx_txlen_in  : in  std_logic_vector (tx_len_width_g -1 downto 0);
    port8_tx_full_out  : out std_logic;
    port8_rx_av_out    : out std_logic;
    port8_rx_data_out  : out std_logic_vector (data_width_g -1 downto 0);
    port8_rx_re_in     : in  std_logic;
    port8_rx_empty_out : out std_logic;

    port9_tx_av_in     : in  std_logic;
    port9_tx_data_in   : in  std_logic_vector (data_width_g -1 downto 0);
    port9_tx_we_in     : in  std_logic;
    port9_tx_txlen_in  : in  std_logic_vector (tx_len_width_g -1 downto 0);
    port9_tx_full_out  : out std_logic;
    port9_rx_av_out    : out std_logic;
    port9_rx_data_out  : out std_logic_vector (data_width_g -1 downto 0);
    port9_rx_re_in     : in  std_logic;
    port9_rx_empty_out : out std_logic;

    port10_tx_av_in     : in  std_logic;
    port10_tx_data_in   : in  std_logic_vector (data_width_g -1 downto 0);
    port10_tx_we_in     : in  std_logic;
    port10_tx_txlen_in  : in  std_logic_vector (tx_len_width_g -1 downto 0);
    port10_tx_full_out  : out std_logic;
    port10_rx_av_out    : out std_logic;
    port10_rx_data_out  : out std_logic_vector (data_width_g -1 downto 0);
    port10_rx_re_in     : in  std_logic;
    port10_rx_empty_out : out std_logic;

    port11_tx_av_in     : in  std_logic;
    port11_tx_data_in   : in  std_logic_vector (data_width_g -1 downto 0);
    port11_tx_we_in     : in  std_logic;
    port11_tx_txlen_in  : in  std_logic_vector (tx_len_width_g -1 downto 0);
    port11_tx_full_out  : out std_logic;
    port11_rx_av_out    : out std_logic;
    port11_rx_data_out  : out std_logic_vector (data_width_g -1 downto 0);
    port11_rx_re_in     : in  std_logic;
    port11_rx_empty_out : out std_logic;

    port12_tx_av_in     : in  std_logic;
    port12_tx_data_in   : in  std_logic_vector (data_width_g -1 downto 0);
    port12_tx_we_in     : in  std_logic;
    port12_tx_txlen_in  : in  std_logic_vector (tx_len_width_g -1 downto 0);
    port12_tx_full_out  : out std_logic;
    port12_rx_av_out    : out std_logic;
    port12_rx_data_out  : out std_logic_vector (data_width_g -1 downto 0);
    port12_rx_re_in     : in  std_logic;
    port12_rx_empty_out : out std_logic;

    port13_tx_av_in     : in  std_logic;
    port13_tx_data_in   : in  std_logic_vector (data_width_g -1 downto 0);
    port13_tx_we_in     : in  std_logic;
    port13_tx_txlen_in  : in  std_logic_vector (tx_len_width_g -1 downto 0);
    port13_tx_full_out  : out std_logic;
    port13_rx_av_out    : out std_logic;
    port13_rx_data_out  : out std_logic_vector (data_width_g -1 downto 0);
    port13_rx_re_in     : in  std_logic;
    port13_rx_empty_out : out std_logic;

    port14_tx_av_in     : in  std_logic;
    port14_tx_data_in   : in  std_logic_vector (data_width_g -1 downto 0);
    port14_tx_we_in     : in  std_logic;
    port14_tx_txlen_in  : in  std_logic_vector (tx_len_width_g -1 downto 0);
    port14_tx_full_out  : out std_logic;
    port14_rx_av_out    : out std_logic;
    port14_rx_data_out  : out std_logic_vector (data_width_g -1 downto 0);
    port14_rx_re_in     : in  std_logic;
    port14_rx_empty_out : out std_logic;

    port15_tx_av_in     : in  std_logic;
    port15_tx_data_in   : in  std_logic_vector (data_width_g -1 downto 0);
    port15_tx_we_in     : in  std_logic;
    port15_tx_txlen_in  : in  std_logic_vector (tx_len_width_g -1 downto 0);
    port15_tx_full_out  : out std_logic;
    port15_rx_av_out    : out std_logic;
    port15_rx_data_out  : out std_logic_vector (data_width_g -1 downto 0);
    port15_rx_re_in     : in  std_logic;
    port15_rx_empty_out : out std_logic
    );
end ring_network_max16ag;

architecture structural of ring_network_max16ag is

  component ring_with_pkt_codec_top
    generic (
      n_ag_g          : integer;
      stfwd_en_g      : integer;
      diag_en_g       : integer;
      data_width_g    : integer;
      addr_width_g    : integer;
      packet_length_g : integer;
      tx_len_width_g  : integer;
      timeout_g       : integer;
      fill_packet_g   : integer;
      lut_en_g        : integer;
      len_flit_en_g   : integer;
      oaddr_flit_en_g : integer;
      status_en_g     : integer;
      fifo_depth_g    : integer;
      ring_freq_g     : integer;
      ip_freq_g       : integer);
    port (
      clk_net      : in  std_logic;
      clk_ip       : in  std_logic;
      rst_n        : in  std_logic;
      tx_av_in     : in  std_logic_vector (n_ag_g-1 downto 0);
      tx_data_in   : in  std_logic_vector (n_ag_g * data_width_g -1 downto 0);
      tx_we_in     : in  std_logic_vector (n_ag_g-1 downto 0);
      tx_txlen_in  : in  std_logic_vector (n_ag_g * tx_len_width_g -1 downto 0);
      tx_full_out  : out std_logic_vector (n_ag_g-1 downto 0);
      tx_empty_out : out std_logic_vector (n_ag_g-1 downto 0);
      rx_av_out    : out std_logic_vector (n_ag_g-1 downto 0);
      rx_data_out  : out std_logic_vector (n_ag_g * data_width_g -1 downto 0);
      rx_re_in     : in  std_logic_vector (n_ag_g-1 downto 0);
      rx_empty_out : out std_logic_vector (n_ag_g-1 downto 0));
  end component;

  signal tx_av_in_comp     : std_logic_vector (n_ag_g-1 downto 0);
  signal tx_data_in_comp   : std_logic_vector (n_ag_g * data_width_g -1 downto 0);
  signal tx_we_in_comp     : std_logic_vector (n_ag_g-1 downto 0);
  signal tx_txlen_in_comp  : std_logic_vector (n_ag_g * tx_len_width_g -1 downto 0);
  signal tx_full_out_comp  : std_logic_vector (n_ag_g-1 downto 0);
  signal rx_av_out_comp    : std_logic_vector (n_ag_g-1 downto 0);
  signal rx_data_out_comp  : std_logic_vector (n_ag_g * data_width_g -1 downto 0);
  signal rx_re_in_comp     : std_logic_vector (n_ag_g-1 downto 0);
  signal rx_empty_out_comp : std_logic_vector (n_ag_g-1 downto 0);

begin  -- structural

  assert n_ag_g mod 2 = 0 report "Only even-sized rings currently supported." severity failure;
  assert n_ag_g < 17 report "This ring network supports up to 16 agents." severity failure;

  ag0 : if n_ag_g > 0 generate
    tx_av_in_comp(0)                            <= port0_tx_av_in;
    tx_data_in_comp(data_width_g-1 downto 0)    <= port0_tx_data_in;
    tx_we_in_comp(0)                            <= port0_tx_we_in;
    tx_txlen_in_comp(tx_len_width_g-1 downto 0) <= port0_tx_txlen_in;
    rx_re_in_comp(0)                            <= port0_rx_re_in;

    port0_tx_full_out  <= tx_full_out_comp(0);
    port0_rx_av_out    <= rx_av_out_comp(0);
    port0_rx_data_out  <= rx_data_out_comp(data_width_g-1 downto 0);
    port0_rx_empty_out <= rx_empty_out_comp(0);
  end generate ag0;

  ag1 : if n_ag_g > 1 generate
    tx_av_in_comp(1)                                           <= port1_tx_av_in;
    tx_data_in_comp(2*data_width_g-1 downto data_width_g)      <= port1_tx_data_in;
    tx_we_in_comp(1)                                           <= port1_tx_we_in;
    tx_txlen_in_comp(2*tx_len_width_g-1 downto tx_len_width_g) <= port1_tx_txlen_in;
    rx_re_in_comp(1)                                           <= port1_rx_re_in;

    port1_tx_full_out  <= tx_full_out_comp(1);
    port1_rx_av_out    <= rx_av_out_comp(1);
    port1_rx_data_out  <= rx_data_out_comp(2*data_width_g-1 downto data_width_g);
    port1_rx_empty_out <= rx_empty_out_comp(1);
  end generate ag1;

  ag2 : if n_ag_g > 2 generate
    tx_av_in_comp(2)                                             <= port2_tx_av_in;
    tx_data_in_comp(3*data_width_g-1 downto 2*data_width_g)      <= port2_tx_data_in;
    tx_we_in_comp(2)                                             <= port2_tx_we_in;
    tx_txlen_in_comp(3*tx_len_width_g-1 downto 2*tx_len_width_g) <= port2_tx_txlen_in;
    rx_re_in_comp(2)                                             <= port2_rx_re_in;

    port2_tx_full_out  <= tx_full_out_comp(2);
    port2_rx_av_out    <= rx_av_out_comp(2);
    port2_rx_data_out  <= rx_data_out_comp(3*data_width_g-1 downto 2*data_width_g);
    port2_rx_empty_out <= rx_empty_out_comp(2);
  end generate ag2;

  ag3 : if n_ag_g > 3 generate
    tx_av_in_comp(3)                                             <= port3_tx_av_in;
    tx_data_in_comp(4*data_width_g-1 downto 3*data_width_g)      <= port3_tx_data_in;
    tx_we_in_comp(3)                                             <= port3_tx_we_in;
    tx_txlen_in_comp(4*tx_len_width_g-1 downto 3*tx_len_width_g) <= port3_tx_txlen_in;
    rx_re_in_comp(3)                                             <= port3_rx_re_in;

    port3_tx_full_out  <= tx_full_out_comp(3);
    port3_rx_av_out    <= rx_av_out_comp(3);
    port3_rx_data_out  <= rx_data_out_comp(4*data_width_g-1 downto 3*data_width_g);
    port3_rx_empty_out <= rx_empty_out_comp(3);
  end generate ag3;



  ag4 : if n_ag_g > 4 generate
    tx_av_in_comp(4)                                             <= port4_tx_av_in;
    tx_data_in_comp(5*data_width_g-1 downto 4*data_width_g)      <= port4_tx_data_in;
    tx_we_in_comp(4)                                             <= port4_tx_we_in;
    tx_txlen_in_comp(5*tx_len_width_g-1 downto 4*tx_len_width_g) <= port4_tx_txlen_in;
    rx_re_in_comp(4)                                             <= port4_rx_re_in;

    port4_tx_full_out  <= tx_full_out_comp(4);
    port4_rx_av_out    <= rx_av_out_comp(4);
    port4_rx_data_out  <= rx_data_out_comp(5*data_width_g-1 downto 4*data_width_g);
    port4_rx_empty_out <= rx_empty_out_comp(4);
  end generate ag4;

  ag5 : if n_ag_g > 5 generate
    tx_av_in_comp(5)                                             <= port5_tx_av_in;
    tx_data_in_comp(6*data_width_g-1 downto 5*data_width_g)      <= port5_tx_data_in;
    tx_we_in_comp(5)                                             <= port5_tx_we_in;
    tx_txlen_in_comp(6*tx_len_width_g-1 downto 5*tx_len_width_g) <= port5_tx_txlen_in;
    rx_re_in_comp(5)                                             <= port5_rx_re_in;

    port5_tx_full_out  <= tx_full_out_comp(5);
    port5_rx_av_out    <= rx_av_out_comp(5);
    port5_rx_data_out  <= rx_data_out_comp(6*data_width_g-1 downto 5*data_width_g);
    port5_rx_empty_out <= rx_empty_out_comp(5);
  end generate ag5;

  ag6 : if n_ag_g > 6 generate
    tx_av_in_comp(6)                                             <= port6_tx_av_in;
    tx_data_in_comp(7*data_width_g-1 downto 6*data_width_g)      <= port6_tx_data_in;
    tx_we_in_comp(6)                                             <= port6_tx_we_in;
    tx_txlen_in_comp(7*tx_len_width_g-1 downto 6*tx_len_width_g) <= port6_tx_txlen_in;
    rx_re_in_comp(6)                                             <= port6_rx_re_in;

    port6_tx_full_out  <= tx_full_out_comp(6);
    port6_rx_av_out    <= rx_av_out_comp(6);
    port6_rx_data_out  <= rx_data_out_comp(7*data_width_g-1 downto 6*data_width_g);
    port6_rx_empty_out <= rx_empty_out_comp(6);
  end generate ag6;

  ag7 : if n_ag_g > 7 generate
    tx_av_in_comp(7)                                             <= port7_tx_av_in;
    tx_data_in_comp(8*data_width_g-1 downto 7*data_width_g)      <= port7_tx_data_in;
    tx_we_in_comp(7)                                             <= port7_tx_we_in;
    tx_txlen_in_comp(8*tx_len_width_g-1 downto 7*tx_len_width_g) <= port7_tx_txlen_in;
    rx_re_in_comp(7)                                             <= port7_rx_re_in;

    port7_tx_full_out  <= tx_full_out_comp(7);
    port7_rx_av_out    <= rx_av_out_comp(7);
    port7_rx_data_out  <= rx_data_out_comp(8*data_width_g-1 downto 7*data_width_g);
    port7_rx_empty_out <= rx_empty_out_comp(7);
  end generate ag7;

  ag8 : if n_ag_g > 8 generate
    tx_av_in_comp(8)                                             <= port8_tx_av_in;
    tx_data_in_comp(9*data_width_g-1 downto 8*data_width_g)      <= port8_tx_data_in;
    tx_we_in_comp(8)                                             <= port8_tx_we_in;
    tx_txlen_in_comp(9*tx_len_width_g-1 downto 8*tx_len_width_g) <= port8_tx_txlen_in;
    rx_re_in_comp(8)                                             <= port8_rx_re_in;

    port8_tx_full_out  <= tx_full_out_comp(8);
    port8_rx_av_out    <= rx_av_out_comp(8);
    port8_rx_data_out  <= rx_data_out_comp(9*data_width_g-1 downto 8*data_width_g);
    port8_rx_empty_out <= rx_empty_out_comp(8);
  end generate ag8;

  ag9 : if n_ag_g > 9 generate
    tx_av_in_comp(9)                                             <= port9_tx_av_in;
    tx_data_in_comp(10*data_width_g-1 downto 9*data_width_g)      <= port9_tx_data_in;
    tx_we_in_comp(9)                                             <= port9_tx_we_in;
    tx_txlen_in_comp(10*tx_len_width_g-1 downto 9*tx_len_width_g) <= port9_tx_txlen_in;
    rx_re_in_comp(9)                                             <= port9_rx_re_in;

    port9_tx_full_out  <= tx_full_out_comp(9);
    port9_rx_av_out    <= rx_av_out_comp(9);
    port9_rx_data_out  <= rx_data_out_comp(10*data_width_g-1 downto 9*data_width_g);
    port9_rx_empty_out <= rx_empty_out_comp(9);
  end generate ag9;

  ag10 : if n_ag_g > 10 generate
    tx_av_in_comp(10)                                             <= port10_tx_av_in;
    tx_data_in_comp(11*data_width_g-1 downto 10*data_width_g)      <= port10_tx_data_in;
    tx_we_in_comp(10)                                             <= port10_tx_we_in;
    tx_txlen_in_comp(11*tx_len_width_g-1 downto 10*tx_len_width_g) <= port10_tx_txlen_in;
    rx_re_in_comp(10)                                             <= port10_rx_re_in;

    port10_tx_full_out  <= tx_full_out_comp(10);
    port10_rx_av_out    <= rx_av_out_comp(10);
    port10_rx_data_out  <= rx_data_out_comp(11*data_width_g-1 downto 10*data_width_g);
    port10_rx_empty_out <= rx_empty_out_comp(10);
  end generate ag10;

  ag11 : if n_ag_g > 11 generate
    tx_av_in_comp(11)                                             <= port11_tx_av_in;
    tx_data_in_comp(12*data_width_g-1 downto 11*data_width_g)      <= port11_tx_data_in;
    tx_we_in_comp(11)                                             <= port11_tx_we_in;
    tx_txlen_in_comp(12*tx_len_width_g-1 downto 11*tx_len_width_g) <= port11_tx_txlen_in;
    rx_re_in_comp(11)                                             <= port11_rx_re_in;

    port11_tx_full_out  <= tx_full_out_comp(11);
    port11_rx_av_out    <= rx_av_out_comp(11);
    port11_rx_data_out  <= rx_data_out_comp(12*data_width_g-1 downto 11*data_width_g);
    port11_rx_empty_out <= rx_empty_out_comp(11);
  end generate ag11;

  ag12 : if n_ag_g > 12 generate
    tx_av_in_comp(12)                                             <= port12_tx_av_in;
    tx_data_in_comp(13*data_width_g-1 downto 12*data_width_g)      <= port12_tx_data_in;
    tx_we_in_comp(12)                                             <= port12_tx_we_in;
    tx_txlen_in_comp(13*tx_len_width_g-1 downto 12*tx_len_width_g) <= port12_tx_txlen_in;
    rx_re_in_comp(12)                                             <= port12_rx_re_in;

    port12_tx_full_out  <= tx_full_out_comp(12);
    port12_rx_av_out    <= rx_av_out_comp(12);
    port12_rx_data_out  <= rx_data_out_comp(13*data_width_g-1 downto 12*data_width_g);
    port12_rx_empty_out <= rx_empty_out_comp(12);
  end generate ag12;

  ag13 : if n_ag_g > 13 generate
    tx_av_in_comp(13)                                             <= port13_tx_av_in;
    tx_data_in_comp(14*data_width_g-1 downto 13*data_width_g)      <= port13_tx_data_in;
    tx_we_in_comp(13)                                             <= port13_tx_we_in;
    tx_txlen_in_comp(14*tx_len_width_g-1 downto 13*tx_len_width_g) <= port13_tx_txlen_in;
    rx_re_in_comp(13)                                             <= port13_rx_re_in;

    port13_tx_full_out  <= tx_full_out_comp(13);
    port13_rx_av_out    <= rx_av_out_comp(13);
    port13_rx_data_out  <= rx_data_out_comp(14*data_width_g-1 downto 13*data_width_g);
    port13_rx_empty_out <= rx_empty_out_comp(13);
  end generate ag13;

  ag14 : if n_ag_g > 14 generate
    tx_av_in_comp(14)                                             <= port14_tx_av_in;
    tx_data_in_comp(15*data_width_g-1 downto 14*data_width_g)      <= port14_tx_data_in;
    tx_we_in_comp(14)                                             <= port14_tx_we_in;
    tx_txlen_in_comp(15*tx_len_width_g-1 downto 14*tx_len_width_g) <= port14_tx_txlen_in;
    rx_re_in_comp(14)                                             <= port14_rx_re_in;

    port14_tx_full_out  <= tx_full_out_comp(14);
    port14_rx_av_out    <= rx_av_out_comp(14);
    port14_rx_data_out  <= rx_data_out_comp(15*data_width_g-1 downto 14*data_width_g);
    port14_rx_empty_out <= rx_empty_out_comp(14);
  end generate ag14;

  ag15 : if n_ag_g > 15 generate
    tx_av_in_comp(15)                                             <= port15_tx_av_in;
    tx_data_in_comp(16*data_width_g-1 downto 15*data_width_g)      <= port15_tx_data_in;
    tx_we_in_comp(15)                                             <= port15_tx_we_in;
    tx_txlen_in_comp(16*tx_len_width_g-1 downto 15*tx_len_width_g) <= port15_tx_txlen_in;
    rx_re_in_comp(15)                                             <= port15_rx_re_in;

    port15_tx_full_out  <= tx_full_out_comp(15);
    port15_rx_av_out    <= rx_av_out_comp(15);
    port15_rx_data_out  <= rx_data_out_comp(16*data_width_g-1 downto 15*data_width_g);
    port15_rx_empty_out <= rx_empty_out_comp(15);
  end generate ag15;


  the_network: ring_with_pkt_codec_top
    generic map (
        n_ag_g          => n_ag_g,
        stfwd_en_g      => stfwd_en_g,
        diag_en_g       => diag_en_g,
        data_width_g    => data_width_g,
        addr_width_g    => addr_width_g,
        packet_length_g => packet_length_g,
        tx_len_width_g  => tx_len_width_g,
        timeout_g       => timeout_g,
        fill_packet_g   => fill_packet_g,
        lut_en_g        => lut_en_g,
        len_flit_en_g   => len_flit_en_g,
        oaddr_flit_en_g => oaddr_flit_en_g,
        status_en_g     => status_en_g,
        fifo_depth_g    => fifo_depth_g,
        ring_freq_g     => ring_freq_g,
        ip_freq_g       => ip_freq_g)
    port map (
        clk_net      => clk_net,
        clk_ip       => clk_ip,
        rst_n        => rst_n,
        tx_av_in     => tx_av_in_comp,
        tx_data_in   => tx_data_in_comp,
        tx_we_in     => tx_we_in_comp,
        tx_txlen_in  => tx_txlen_in_comp,
        tx_full_out  => tx_full_out_comp,
        tx_empty_out => open,
        rx_av_out    => rx_av_out_comp,
        rx_data_out  => rx_data_out_comp,
        rx_re_in     => rx_re_in_comp,
        rx_empty_out => rx_empty_out_comp);

end structural;
