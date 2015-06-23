-------------------------------------------------------------------------------
-- Title      : Testbech for dctQidct
-- Project    : 
-------------------------------------------------------------------------------
-- File       : tb_dct_top.vhd
-- Author     : 
-- Company    : 
-- Created    : 2006-05-24
-- Last update: 2006-09-06
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: a simple tb 
-------------------------------------------------------------------------------
-- Copyright (c) 2006 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2006-05-24  1.0      rasmusa Created
-------------------------------------------------------------------------------

library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.tb_dct_package.all;

library dct;
library idct;
library quantizer;
library dctQidct;

use dct.DCT_pkg.all;
use idct.IDCT_pkg.all;
use quantizer.Quantizer_pkg.all;

entity tb_dct_top is
  generic (
    hw_fifo_depth_g : integer := 5);
end tb_dct_top;


architecture structural of tb_dct_top is

--  constant hw_fifo_depth_c : integer := dct_hw_fifo_depth_g;
  
  signal clk     : std_logic := '1';
  signal clk_dct : std_logic := '1';
  signal clk_cpu : std_logic := '1';

  signal rst_n   : std_logic := '0';

  signal bus_comm_in : std_logic_vector(comm_width_c-1 downto 0);
  signal bus_data_in : std_logic_vector(data_width_c-1 downto 0);

  signal bus_av_in   : std_logic;
  signal bus_full_in : std_logic;
  signal bus_lock_in : std_logic;

  signal bus_comm_out_cpu : std_logic_vector(comm_width_c-1 downto 0);
  signal bus_data_out_cpu : std_logic_vector(data_width_c-1 downto 0);
  signal bus_av_out_cpu   : std_logic;
  signal bus_full_out_cpu : std_logic;
  signal bus_lock_out_cpu : std_logic;

  signal bus_comm_out_dctqidct : std_logic_vector(comm_width_c-1 downto 0);
  signal bus_data_out_dctqidct : std_logic_vector(data_width_c-1 downto 0);
  signal bus_av_out_dctqidct   : std_logic;
  signal bus_full_out_dctqidct : std_logic;
  signal bus_lock_out_dctqidct : std_logic;

  signal bus_comm_out_pinger1 : std_logic_vector(comm_width_c-1 downto 0);
  signal bus_data_out_pinger1 : std_logic_vector(data_width_c-1 downto 0);
  signal bus_av_out_pinger1   : std_logic;
  signal bus_full_out_pinger1 : std_logic;
  signal bus_lock_out_pinger1 : std_logic;

  signal bus_comm_out_pinger2 : std_logic_vector(comm_width_c-1 downto 0);
  signal bus_data_out_pinger2 : std_logic_vector(data_width_c-1 downto 0);
  signal bus_av_out_pinger2   : std_logic;
  signal bus_full_out_pinger2 : std_logic;
  signal bus_lock_out_pinger2 : std_logic;


  -- Signals between hibi wrapper and DCTQIDCT
  signal dctqidct_data_in  : std_logic_vector(data_width_c-1 downto 0);
  signal dctqidct_comm_in  : std_logic_vector(comm_width_c-1 downto 0);
  signal dctqidct_av_in    : std_logic;
  signal dctqidct_re_out   : std_logic;
  signal dctqidct_empty_in : std_logic;
  signal dctqidct_data_out : std_logic_vector(data_width_c-1 downto 0);
  signal dctqidct_comm_out : std_logic_vector(comm_width_c-1 downto 0);
  signal dctqidct_av_out   : std_logic;
  signal dctqidct_we_out   : std_logic;
  signal dctqidct_full_in  : std_logic;

  -- Signals between hibi wrapper and cpu ( cpu point of view )
  signal cpu_data_in  : std_logic_vector(data_width_c-1 downto 0);
  signal cpu_comm_in  : std_logic_vector(comm_width_c-1 downto 0);
  signal cpu_av_in    : std_logic;
  signal cpu_re_out   : std_logic;
  signal cpu_empty_in : std_logic;
  signal cpu_data_out : std_logic_vector(data_width_c-1 downto 0);
  signal cpu_comm_out : std_logic_vector(comm_width_c-1 downto 0);
  signal cpu_av_out   : std_logic;
  signal cpu_we_out   : std_logic;
  signal cpu_full_in  : std_logic;

  -- Pinger signals
  signal pinger1_data_in  : std_logic_vector(data_width_c-1 downto 0);
  signal pinger1_comm_in  : std_logic_vector(comm_width_c-1 downto 0);
  signal pinger1_av_in    : std_logic;
  signal pinger1_re_out   : std_logic;
  signal pinger1_empty_in : std_logic;
  signal pinger1_data_out : std_logic_vector(data_width_c-1 downto 0);
  signal pinger1_comm_out : std_logic_vector(comm_width_c-1 downto 0);
  signal pinger1_av_out   : std_logic;
  signal pinger1_we_out   : std_logic;
  signal pinger1_full_in  : std_logic;

  signal pinger2_data_in  : std_logic_vector(data_width_c-1 downto 0);
  signal pinger2_comm_in  : std_logic_vector(comm_width_c-1 downto 0);
  signal pinger2_av_in    : std_logic;
  signal pinger2_re_out   : std_logic;
  signal pinger2_empty_in : std_logic;
  signal pinger2_data_out : std_logic_vector(data_width_c-1 downto 0);
  signal pinger2_comm_out : std_logic_vector(comm_width_c-1 downto 0);
  signal pinger2_av_out   : std_logic;
  signal pinger2_we_out   : std_logic;
  signal pinger2_full_in  : std_logic;

  component dct_to_hibi
    generic (
      data_width_g   : integer;
      comm_width_g   : integer;
      use_self_rel_g : integer;
      own_address_g  : integer;
      rtm_address_g  : integer;
      dct_width_g    : integer;
      quant_width_g  : integer;
      idct_width_g   : integer);
    port (
      clk                 : in  std_logic;
      rst_n               : in  std_logic;
      hibi_av_out         : out std_logic;
      hibi_data_out       : out std_logic_vector (data_width_g-1 downto 0);
      hibi_comm_out       : out std_logic_vector (comm_width_g-1 downto 0);
      hibi_we_out         : out std_logic;
      hibi_re_out         : out std_logic;
      hibi_av_in          : in  std_logic;
      hibi_data_in        : in  std_logic_vector (data_width_g-1 downto 0);
      hibi_comm_in        : in  std_logic_vector (comm_width_g-1 downto 0);
      hibi_empty_in       : in  std_logic;
      hibi_full_in        : in  std_logic;
      wr_dct_out          : out std_logic;
      quant_ready4col_out : out std_logic;
      idct_ready4col_out  : out std_logic;
      data_dct_out        : out std_logic_vector(dct_width_g-1 downto 0);
      intra_out           : out std_logic;
      loadQP_out          : out std_logic;
      QP_out              : out std_logic_vector (4 downto 0);
      chroma_out          : out std_logic;
      data_idct_in        : in  std_logic_vector(idct_width_g-1 downto 0);
      data_quant_in       : in  std_logic_vector(quant_width_g-1 downto 0);
      dct_ready4col_in    : in  std_logic;
      wr_idct_in          : in  std_logic;
      wr_quant_in         : in  std_logic);
  end component;

  component dctQidct_core
    port (
      QP_in                 : in  std_logic_vector (4 downto 0);
      chroma_in             : in  std_logic;
      clk                   : in  std_logic;
      data_dct_in           : in  std_logic_vector (DCT_inputw_co-1 downto 0);
      idct_ready4column_in  : in  std_logic;
      intra_in              : in  std_logic;
      loadQP_in             : in  std_logic;
      quant_ready4column_in : in  std_logic;
      rst_n                 : in  std_logic;
      wr_dct_in             : in  std_logic;
      data_idct_out         : out std_logic_vector (IDCT_resultw_co-1 downto 0);
      data_quant_out        : out std_logic_vector (QUANT_resultw_co-1 downto 0);
      dct_ready4column_out  : out std_logic;
      wr_idct_out           : out std_logic;
      wr_quant_out          : out std_logic);
  end component;

  signal QP                 : std_logic_vector (4 downto 0);
  signal chroma             : std_logic;
  signal data_dct           : std_logic_vector (DCT_inputw_co-1 downto 0);
  signal idct_ready4column  : std_logic;
  signal intra              : std_logic;
  signal loadQP             : std_logic;
  signal quant_ready4column : std_logic;
  signal wr_dct             : std_logic;
  signal data_idct          : std_logic_vector (IDCT_resultw_co-1 downto 0);
  signal data_quant         : std_logic_vector (QUANT_resultw_co-1 downto 0);
  signal dct_ready4column   : std_logic;
  signal wr_idct            : std_logic;
  signal wr_quant           : std_logic;

  component hibi_wrapper_r4_top
    generic (
      id_g                : integer;
      base_id_g           : integer;
      id_width_g          : integer;
      addr_width_g        : integer;
      data_width_g        : integer;
      comm_width_g        : integer;
      counter_width_g     : integer;
      rel_agent_freq_g    : integer;
      rel_bus_freq_g      : integer;
      rx_fifo_depth_g     : integer;
      rx_msg_fifo_depth_g : integer;
      tx_fifo_depth_g     : integer;
      tx_msg_fifo_depth_g : integer;
      addr_g              : integer;
      prior_g             : integer;
      inv_addr_en_g       : integer;
      max_send_g          : integer;
      n_agents_g          : integer;
      n_cfg_pages_g       : integer;
      n_time_slots_g      : integer;
      n_extra_params_g    : integer;
      multicast_en_g      : integer;
      cfg_re_g            : integer;
      cfg_we_g            : integer;
      syncmode_sel_g      : integer range 0 to 2);
    port (
      bus_clk         : in  std_logic;
      agent_clk       : in  std_logic;
      agent_synch_clk : in  std_logic;
      rst_n           : in  std_logic;
      bus_comm_in     : in  std_logic_vector (comm_width_g-1 downto 0);
      bus_data_in     : in  std_logic_vector (data_width_g-1 downto 0);
      bus_full_in     : in  std_logic;
      bus_lock_in     : in  std_logic;
      bus_av_in       : in  std_logic;
      agent_comm_in   : in  std_logic_vector (comm_width_g-1 downto 0);
      agent_data_in   : in  std_logic_vector (data_width_g-1 downto 0);
      agent_av_in     : in  std_logic;
      agent_we_in     : in  std_logic;
      agent_re_in     : in  std_logic;
      bus_comm_out    : out std_logic_vector (comm_width_g-1 downto 0);
      bus_data_out    : out std_logic_vector (data_width_g-1 downto 0);
      bus_full_out    : out std_logic;
      bus_lock_out    : out std_logic;
      bus_av_out      : out std_logic;
      agent_comm_out  : out std_logic_vector (comm_width_g-1 downto 0);
      agent_data_out  : out std_logic_vector (data_width_g-1 downto 0);
      agent_av_out    : out std_logic;
      agent_full_out  : out std_logic;
      agent_one_p_out : out std_logic;
      agent_empty_out : out std_logic;
      agent_one_d_out : out std_logic);
  end component;

  component tb_dct_cpu
    generic (
      data_width_g : integer;
      comm_width_g : integer);
    port (
      clk_dctqidct_fast : in  std_logic;
      clk               : in  std_logic;
      rst_n             : in  std_logic;
      data_in           : in  std_logic_vector(data_width_g-1 downto 0);
      comm_in           : in  std_logic_vector(comm_width_g-1 downto 0);
      av_in             : in  std_logic;
      re_out            : out std_logic;
      empty_in          : in  std_logic;
      data_out          : out std_logic_vector(data_width_g-1 downto 0);
      comm_out          : out std_logic_vector(comm_width_g-1 downto 0);
      av_out            : out std_logic;
      we_out            : out std_logic;
      full_in           : in  std_logic;
      dct_data_idct_in  : in  std_logic_vector(IDCT_resultw_co-1 downto 0);
      dct_data_quant_in : in  std_logic_vector(QUANT_resultw_co-1 downto 0);
      dct_wr_idct_in    : in  std_logic;
      dct_wr_quant_in   : in  std_logic;
      dct_wr_dct_in     : in  std_logic;
      dct_data_dct_in   : in  std_logic_vector(DCT_inputw_co-1 downto 0);
      dct_qp_in         : in  std_logic_vector(4 downto 0);
      dct_intra_in      : in  std_logic;
      dct_chroma_in     : in  std_logic;
      dct_loadqp_in     : in  std_logic

      );
  end component;
  
  component tb_pinger
    generic (
      data_width_g     : integer;
      comm_width_g     : integer;
      start_sending_g  : integer;
      own_hibi_addr_g  : integer;
      init_send_addr_g : integer );
    port (
      clk      : in  std_logic;
      rst_n    : in  std_logic;
      data_in  : in  std_logic_vector (data_width_g-1 downto 0);
      comm_in  : in  std_logic_vector (comm_width_g-1 downto 0);
      av_in    : in  std_logic;
      re_out   : out std_logic;
      empty_in : in  std_logic;
      data_out : out std_logic_vector (data_width_g-1 downto 0);
      comm_out : out std_logic_vector (comm_width_g-1 downto 0);
      av_out   : out std_logic;
      we_out   : out std_logic;
      full_in  : in  std_logic);
  end component;

  
begin  -- structural

--  dctqidct_top_1 : dctqidct_top
--    generic map (
--      data_width_g => data_width_c,
--      comm_width_g => comm_width_c,
--      fast_per_slow_g => fast_clk_divider_c)
--    port map (
--      clk_slow => clk,
--      clk_fast => clk_fast,
--      rst_n    => rst_n,
--      data_in  => dctqidct_data_in,
--      comm_in  => dctqidct_comm_in,
--      av_in    => dctqidct_av_in,
--      re_out   => dctqidct_re_out,
--      empty_in => dctqidct_empty_in,
--      data_out => dctqidct_data_out,
--      comm_out => dctqidct_comm_out,
--      av_out   => dctqidct_av_out,
--      we_out   => dctqidct_we_out,
--      full_in  => dctqidct_full_in);


  dct_to_hibi_1_12 : dct_to_hibi
    generic map (
      data_width_g   => data_width_c,
      comm_width_g   => comm_width_c,
      use_self_rel_g => use_self_rel_c,
      own_address_g  => hibi_addr_dct_c,
      rtm_address_g  => hibi_addr_cpu_rtm_c,
      dct_width_g    => DCT_inputw_co,
      quant_width_g  => QUANT_resultw_co,
      idct_width_g   => IDCT_resultw_co)
    port map (
      clk           => clk_dct,
      rst_n         => rst_n,
      hibi_av_out   => dctqidct_av_out,
      hibi_data_out => dctqidct_data_out,
      hibi_comm_out => dctqidct_comm_out,
      hibi_we_out   => dctqidct_we_out,
      hibi_re_out   => dctqidct_re_out,
      hibi_av_in    => dctqidct_av_in,
      hibi_data_in  => dctqidct_data_in,
      hibi_comm_in  => dctqidct_comm_in,
      hibi_empty_in => dctqidct_empty_in,
      hibi_full_in  => dctqidct_full_in,

      wr_dct_out          => wr_dct,
      quant_ready4col_out => quant_ready4column,
      idct_ready4col_out  => idct_ready4column,
      data_dct_out        => data_dct,
      intra_out           => intra,
      loadQP_out          => loadQP,
      QP_out              => QP,
      chroma_out          => chroma,
      data_idct_in        => data_idct,
      data_quant_in       => data_quant,
      dct_ready4col_in    => dct_ready4column,
      wr_idct_in          => wr_idct,
      wr_quant_in         => wr_quant);

  dctQidct_core_1 : dctQidct_core
    port map (
      QP_in                 => QP,
      chroma_in             => chroma,
      clk                   => clk_dct,
      data_dct_in           => data_dct,
      idct_ready4column_in  => idct_ready4column,
      intra_in              => intra,
      loadQP_in             => loadQP,
      quant_ready4column_in => quant_ready4column,
      rst_n                 => rst_n,
      wr_dct_in             => wr_dct,
      data_idct_out         => data_idct,
      data_quant_out        => data_quant,
      dct_ready4column_out  => dct_ready4column,
      wr_idct_out           => wr_idct,
      wr_quant_out          => wr_quant);


  
  hibi_wrapper_dctqidct : hibi_wrapper_r4_top
    generic map (
      id_g                => 3,
      base_id_g           => 2**id_width_c-1,
      id_width_g          => id_width_c,
      addr_width_g        => addr_width_c,
      data_width_g        => data_width_c,
      comm_width_g        => comm_width_c,
      counter_width_g     => counter_width_c,
      rel_agent_freq_g    => fast_clk_divider_c,
      rel_bus_freq_g      => 1,
      rx_fifo_depth_g     => hw_fifo_depth_g,--hw_fifo_depth_c,
      rx_msg_fifo_depth_g => 5,
      tx_fifo_depth_g     => hw_fifo_depth_g,--hw_fifo_depth_c,
      tx_msg_fifo_depth_g => 5,
      addr_g              => hibi_addr_dct_c,
      prior_g             => 3,
      inv_addr_en_g       => 0,
      max_send_g          => max_send_c,
      n_agents_g          => n_agents_c,
      n_cfg_pages_g       => 1,
      n_time_slots_g      => n_time_slots_c,
      n_extra_params_g    => n_extra_params_c,
      multicast_en_g      => 0,
      cfg_re_g            => 0,
      cfg_we_g            => 0,
      syncmode_sel_g      => 0)
    port map (
      bus_clk         => clk,
      agent_clk       => clk_dct,
      agent_synch_clk => clk,
      rst_n           => rst_n,
      bus_comm_in     => bus_comm_in,
      bus_data_in     => bus_data_in,
      bus_full_in     => bus_full_in,
      bus_lock_in     => bus_lock_in,
      bus_av_in       => bus_av_in,

      agent_comm_in => dctqidct_comm_out,
      agent_data_in => dctqidct_data_out,
      agent_av_in   => dctqidct_av_out,
      agent_we_in   => dctqidct_we_out,
      agent_re_in   => dctqidct_re_out,

      bus_comm_out => bus_comm_out_dctqidct,
      bus_data_out => bus_data_out_dctqidct,
      bus_full_out => bus_full_out_dctqidct,
      bus_lock_out => bus_lock_out_dctqidct,
      bus_av_out   => bus_av_out_dctqidct,

      agent_comm_out  => dctqidct_comm_in,
      agent_data_out  => dctqidct_data_in,
      agent_av_out    => dctqidct_av_in,
      agent_full_out  => dctqidct_full_in,
      agent_empty_out => dctqidct_empty_in);

  hibi_wrapper_cpu : hibi_wrapper_r4_top
    generic map (
      id_g                => 4,
      base_id_g           => 2**id_width_c-1,
      id_width_g          => id_width_c,
      addr_width_g        => addr_width_c,
      data_width_g        => data_width_c,
      comm_width_g        => comm_width_c,
      counter_width_g     => counter_width_c,
      rel_agent_freq_g    => 1,
      rel_bus_freq_g      => slow_clk_multiplier_c,
      rx_fifo_depth_g     => hw_fifo_depth_g,
      rx_msg_fifo_depth_g => 5,
      tx_fifo_depth_g     => hw_fifo_depth_g,
      tx_msg_fifo_depth_g => 5,
      addr_g              => hibi_addr_cpu_c,
      prior_g             => 4,
      inv_addr_en_g       => 0,
      max_send_g          => max_send_c,
      n_agents_g          => n_agents_c,
      n_cfg_pages_g       => 1,
      n_time_slots_g      => n_time_slots_c,
      n_extra_params_g    => n_extra_params_c,
      multicast_en_g      => 0,
      cfg_re_g            => 0,
      cfg_we_g            => 0,
      syncmode_sel_g      => 0)
    port map (
      bus_clk         => clk,
      agent_clk       => clk_cpu,
      agent_synch_clk => clk,
      rst_n           => rst_n,

      bus_comm_in => bus_comm_in,
      bus_data_in => bus_data_in,
      bus_full_in => bus_full_in,
      bus_lock_in => bus_lock_in,
      bus_av_in   => bus_av_in,

      agent_comm_in => cpu_comm_out,
      agent_data_in => cpu_data_out,
      agent_av_in   => cpu_av_out,
      agent_we_in   => cpu_we_out,
      agent_re_in   => cpu_re_out,

      bus_comm_out => bus_comm_out_cpu,
      bus_data_out => bus_data_out_cpu,
      bus_full_out => bus_full_out_cpu,
      bus_lock_out => bus_lock_out_cpu,
      bus_av_out   => bus_av_out_cpu,

      agent_comm_out  => cpu_comm_in,
      agent_data_out  => cpu_data_in,
      agent_av_out    => cpu_av_in,
      agent_full_out  => cpu_full_in,
      agent_empty_out => cpu_empty_in);

  tb_dct_cpu_i : tb_dct_cpu
    generic map (
      data_width_g => data_width_c,
      comm_width_g => comm_width_c)
    port map (
      clk               => clk_cpu,
      clk_dctqidct_fast => clk_dct,
      rst_n             => rst_n,
      data_in           => cpu_data_in,
      comm_in           => cpu_comm_in,
      av_in             => cpu_av_in,
      re_out            => cpu_re_out,
      empty_in          => cpu_empty_in,
      data_out          => cpu_data_out,
      comm_out          => cpu_comm_out,
      av_out            => cpu_av_out,
      we_out            => cpu_we_out,
      full_in           => cpu_full_in,
      dct_data_idct_in  => data_idct,
      dct_data_quant_in => data_quant,
      dct_wr_idct_in    => wr_idct,
      dct_wr_quant_in   => wr_quant,
      dct_wr_dct_in     => wr_dct,
      dct_data_dct_in   => data_dct,
      dct_qp_in         => QP,
      dct_intra_in      => intra,
      dct_chroma_in     => chroma,
      dct_loadqp_in     => loadQP
      );


  hibi_wrapper_pinger1 : hibi_wrapper_r4_top
    generic map (
      id_g                => 2,
      base_id_g           => 2**id_width_c-1,
      id_width_g          => id_width_c,
      addr_width_g        => addr_width_c,
      data_width_g        => data_width_c,
      comm_width_g        => comm_width_c,
      counter_width_g     => counter_width_c,
      rel_agent_freq_g    => 1,
      rel_bus_freq_g      => 1,
      rx_fifo_depth_g     => hw_fifo_depth_g,
      rx_msg_fifo_depth_g => 5,
      tx_fifo_depth_g     => hw_fifo_depth_g,
      tx_msg_fifo_depth_g => 5,
      addr_g              => hibi_addr_pinger1_c,
      prior_g             => 2,
      inv_addr_en_g       => 0,
      max_send_g          => max_send_c,
      n_agents_g          => n_agents_c,
      n_cfg_pages_g       => 1,
      n_time_slots_g      => n_time_slots_c,
      n_extra_params_g    => n_extra_params_c,
      multicast_en_g      => 0,
      cfg_re_g            => 0,
      cfg_we_g            => 0,
      syncmode_sel_g      => 0)
    port map (
      bus_clk         => clk,
      agent_clk       => clk,
      agent_synch_clk => clk,
      rst_n           => rst_n,

      bus_comm_in => bus_comm_in,
      bus_data_in => bus_data_in,
      bus_full_in => bus_full_in,
      bus_lock_in => bus_lock_in,
      bus_av_in   => bus_av_in,

      agent_comm_in => pinger1_comm_out,
      agent_data_in => pinger1_data_out,
      agent_av_in   => pinger1_av_out,
      agent_we_in   => pinger1_we_out,
      agent_re_in   => pinger1_re_out,

      bus_comm_out => bus_comm_out_pinger1,
      bus_data_out => bus_data_out_pinger1,
      bus_full_out => bus_full_out_pinger1,
      bus_lock_out => bus_lock_out_pinger1,
      bus_av_out   => bus_av_out_pinger1,

      agent_comm_out  => pinger1_comm_in,
      agent_data_out  => pinger1_data_in,
      agent_av_out    => pinger1_av_in,
      agent_full_out  => pinger1_full_in,
      agent_empty_out => pinger1_empty_in);

  hibi_wrapper_pinger2 : hibi_wrapper_r4_top
    generic map (
      id_g                => 1,
      base_id_g           => 2**id_width_c-1,
      id_width_g          => id_width_c,
      addr_width_g        => addr_width_c,
      data_width_g        => data_width_c,
      comm_width_g        => comm_width_c,
      counter_width_g     => counter_width_c,
      rel_agent_freq_g    => 1,
      rel_bus_freq_g      => 1,
      rx_fifo_depth_g     => 4,
      rx_msg_fifo_depth_g => 5,
      tx_fifo_depth_g     => 4,
      tx_msg_fifo_depth_g => 5,
      addr_g              => hibi_addr_pinger2_c,
      prior_g             => 1,
      inv_addr_en_g       => 0,
      max_send_g          => max_send_c,
      n_agents_g          => n_agents_c,
      n_cfg_pages_g       => 1,
      n_time_slots_g      => n_time_slots_c,
      n_extra_params_g    => n_extra_params_c,
      multicast_en_g      => 0,
      cfg_re_g            => 0,
      cfg_we_g            => 0,
      syncmode_sel_g      => 0)
    port map (
      bus_clk         => clk,
      agent_clk       => clk,
      agent_synch_clk => clk,
      rst_n           => rst_n,

      bus_comm_in => bus_comm_in,
      bus_data_in => bus_data_in,
      bus_full_in => bus_full_in,
      bus_lock_in => bus_lock_in,
      bus_av_in   => bus_av_in,

      agent_comm_in => pinger2_comm_out,
      agent_data_in => pinger2_data_out,
      agent_av_in   => pinger2_av_out,
      agent_we_in   => pinger2_we_out,
      agent_re_in   => pinger2_re_out,

      bus_comm_out => bus_comm_out_pinger2,
      bus_data_out => bus_data_out_pinger2,
      bus_full_out => bus_full_out_pinger2,
      bus_lock_out => bus_lock_out_pinger2,
      bus_av_out   => bus_av_out_pinger2,

      agent_comm_out  => pinger2_comm_in,
      agent_data_out  => pinger2_data_in,
      agent_av_out    => pinger2_av_in,
      agent_full_out  => pinger2_full_in,
      agent_empty_out => pinger2_empty_in);



  tb_pinger_1 : tb_pinger
    generic map (
      data_width_g     => data_width_c,
      comm_width_g     => comm_width_c,
      start_sending_g  => 1,
      own_hibi_addr_g  => hibi_addr_pinger1_c,
      init_send_addr_g => hibi_addr_pinger2_c)
    port map (
      clk      => clk,
      rst_n    => rst_n,
      data_in  => pinger1_data_in,
      comm_in  => pinger1_comm_in,
      av_in    => pinger1_av_in,
      re_out   => pinger1_re_out,
      empty_in => pinger1_empty_in,
      data_out => pinger1_data_out,
      comm_out => pinger1_comm_out,
      av_out   => pinger1_av_out,
      we_out   => pinger1_we_out,
      full_in  => pinger1_full_in);

  tb_pinger_2 : tb_pinger
    generic map (
      data_width_g     => data_width_c,
      comm_width_g     => comm_width_c,
      start_sending_g => 0,
      own_hibi_addr_g  => hibi_addr_pinger2_c,
      init_send_addr_g => hibi_addr_pinger1_c)
    port map (
      clk      => clk,
      rst_n    => rst_n,
      data_in  => pinger2_data_in,
      comm_in  => pinger2_comm_in,
      av_in    => pinger2_av_in,
      re_out   => pinger2_re_out,
      empty_in => pinger2_empty_in,
      data_out => pinger2_data_out,
      comm_out => pinger2_comm_out,
      av_out   => pinger2_av_out,
      we_out   => pinger2_we_out,
      full_in  => pinger2_full_in);  

  clock_gen : process (clk)
  begin
    clk <= not clk after clk_period_c/2;
  end process clock_gen;

  clock_gen_dct : process (clk_dct)
  begin
    clk_dct <= not clk_dct after clk_period_c/(fast_clk_divider_c*2);
  end process clock_gen_dct;

  clock_gen_cpu : process (clk_cpu)
  begin
    clk_cpu <= not clk_cpu after clk_period_c/(2)*slow_clk_multiplier_c;
  end process clock_gen_cpu;

  
  rst_gen : process(rst_n)
  begin  -- process rst_gen
    if rst_n = '0' then
      rst_n <= '1' after reset_time_c;
    else
      rst_n <= '1';
    end if;
  end process rst_gen;

  bus_comm_in <= bus_comm_out_cpu or bus_comm_out_dctqidct or bus_comm_out_pinger1 or bus_comm_out_pinger2;
  bus_data_in <= bus_data_out_cpu or bus_data_out_dctqidct or bus_data_out_pinger1 or bus_data_out_pinger2;
  bus_full_in <= bus_full_out_cpu or bus_full_out_dctqidct or bus_full_out_pinger1 or bus_full_out_pinger2;
  bus_lock_in <= bus_lock_out_cpu or bus_lock_out_dctqidct or bus_lock_out_pinger1 or bus_lock_out_pinger2;
  bus_av_in   <= bus_av_out_cpu or bus_av_out_dctqidct or bus_av_out_pinger1 or bus_av_out_pinger2;
  
end structural;

