-------------------------------------------------------------------------------
-- Title      : Basic tester for Hibi v3
-- Project    : 
-------------------------------------------------------------------------------
-- File       : basic_test_hibiv3.vhd
-- Author     : Lasse Lehtonen
-- Company    : 
-- Created    : 2011-09-29
-- Last update: 2013-03-22
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: Shows how HIBI can be used.
--              Instantiates two, very simple, basic test components and
--              connects them to HIBI. The first one sends few words (e.g. 8)
--              and the other receives and checks them.
--              The traffic is defined with two ASCII files: tx_file.txt and
--              rx_file.txt
-------------------------------------------------------------------------------
-- Copyright (c) 2011 
--
--  This file is part of Funbase IP library.
--
--  Funbase IP library is free software: you can redistribute it and/or modify
--  it under the terms of the Lesser GNU General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.
--
--  Funbase IP library is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  Lesser GNU General Public License for more details.
--
--  You should have received a copy of the Lesser GNU General Public License
--  along with Funbase IP library.  If not, see <http://www.gnu.org/licenses/>.
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2011-09-29  1.0      lehton87        Created
-------------------------------------------------------------------------------


library ieee;
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

entity tb_dct_top_2 is
end tb_dct_top_2;


architecture tb of tb_dct_top_2 is

  -----------------------------------------------------------------------------
  -- CONSTANTS
  -----------------------------------------------------------------------------
  -- System size
  constant n_agents_g   : integer := 2;
  constant n_segments_g : integer := 1;

  -- Values for HIBI generics
  -- a) signal and counter sizes
  constant id_width_g      : integer := 4;
  constant addr_width_g    : integer := 32;
  constant data_width_g    : integer := 32;
  constant comm_width_g    : integer := 5;
  constant counter_width_g : integer := 8;
  constant separate_addr_g : integer := 0;

  -- b) clocking and buffering
  constant rel_agent_freq_g    : integer := 1;
  constant rel_bus_freq_g      : integer := 1;
  constant fifo_sel_g          : integer := 0;
  constant rx_fifo_depth_g     : integer := 4;
  constant rx_msg_fifo_depth_g : integer := 4;
  constant tx_fifo_depth_g     : integer := 4;
  constant tx_msg_fifo_depth_g : integer := 4;

  -- c) arbitration
  constant arb_type_g       : integer := 3;
  constant max_send_g       : integer := 20;
  constant n_cfg_pages_g    : integer := 1;
  constant n_time_slots_g   : integer := 0;
  constant keep_slot_g      : integer := 0;
  constant n_extra_params_g : integer := 1;
  constant cfg_re_g         : integer := 1;
  constant cfg_we_g         : integer := 1;
  constant debug_width_g    : integer := 0;



  -- clock generation
  constant noc_cycle_time_c : time := 10 ns;
  constant ip_cycle_time_c  : time := 10 ns;

  -----------------------------------------------------------------------------
  -- SIGNALSxs
  -----------------------------------------------------------------------------
  signal clk_noc : std_logic := '1';
  signal clk_ip  : std_logic := '1';
  signal rst_n   : std_logic := '0';

  -- Sending, data goes IP -> net
  signal comm_ip_net : std_logic_vector(n_agents_g*comm_width_g-1 downto 0)
 := (others => '0');
  signal data_ip_net : std_logic_vector(n_agents_g*data_width_g-1 downto 0)
 := (others => '0');
  signal av_ip_net : std_logic_vector(n_agents_g-1 downto 0)
 := (others => '0');
  signal we_ip_net : std_logic_vector(n_agents_g-1 downto 0)
 := (others => '0');
  signal full_net_ip : std_logic_vector(n_agents_g-1 downto 0)
 := (others => '0');
  signal one_p_net_ip : std_logic_vector(n_agents_g-1 downto 0)
 := (others => '0');

  -- Receiving, data goes net -> IP
  signal comm_net_ip : std_logic_vector(n_agents_g*comm_width_g-1 downto 0)
 := (others => '0');
  signal data_net_ip : std_logic_vector(n_agents_g*data_width_g-1 downto 0)
 := (others => '0');
  signal av_net_ip : std_logic_vector(n_agents_g-1 downto 0)
 := (others => '0');
  signal re_ip_net : std_logic_vector(n_agents_g-1 downto 0)
 := (others => '0');
  signal empty_net_ip : std_logic_vector(n_agents_g-1 downto 0)
 := (others => '0');
  signal one_d_net_ip : std_logic_vector(n_agents_g-1 downto 0)
 := (others => '0');

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
  

  --COMPONENT DECLARATIONS--

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
    
    






    begin  -- tb


      clk_noc <= not clk_noc after noc_cycle_time_c;
      clk_ip  <= not clk_ip  after ip_cycle_time_c;
      rst_n   <= '1'         after 100 ns;


      -- HIBI network
      i_hibiv3_r4_1 : entity work.hibiv3_r4
        generic map (
          id_width_g          => id_width_g,
          addr_width_g        => addr_width_g,
          data_width_g        => data_width_g,
          comm_width_g        => comm_width_g,
          counter_width_g     => counter_width_g,
          rel_agent_freq_g    => rel_agent_freq_g,
          rel_bus_freq_g      => rel_bus_freq_g,
          arb_type_g          => arb_type_g,
          fifo_sel_g          => fifo_sel_g,
          rx_fifo_depth_g     => rx_fifo_depth_g,
          rx_msg_fifo_depth_g => rx_msg_fifo_depth_g,
          tx_fifo_depth_g     => tx_fifo_depth_g,
          tx_msg_fifo_depth_g => tx_msg_fifo_depth_g,
          max_send_g          => max_send_g,
          n_cfg_pages_g       => n_cfg_pages_g,
          n_time_slots_g      => n_time_slots_g,
          keep_slot_g         => keep_slot_g,
          n_extra_params_g    => n_extra_params_g,
          cfg_re_g            => cfg_re_g,
          cfg_we_g            => cfg_we_g,
          debug_width_g       => debug_width_g,
          n_agents_g          => n_agents_g,
          n_segments_g        => n_segments_g,
          separate_addr_g     => separate_addr_g)
        port map (
          clk_ip  => clk_ip,
          clk_noc => clk_noc,
          rst_n   => rst_n,

          agent_av_in     => av_ip_net,
          agent_comm_in   => comm_ip_net,
          agent_data_in   => data_ip_net,
          agent_we_in     => we_ip_net,
          agent_full_out  => full_net_ip,
          agent_one_p_out => one_p_net_ip,

          agent_av_out    => av_net_ip,
          agent_comm_out  => comm_net_ip,
          agent_data_out  => data_net_ip,
          agent_re_in     => re_ip_net,
          agent_empty_out => empty_net_ip,
          agent_one_d_out => one_d_net_ip);


      dct_to_hibi_1_12 : entity work.dct_to_hibi
        generic map (
          data_width_g   => data_width_g,
          comm_width_g   => comm_width_g,
          use_self_rel_g => use_self_rel_c,
          own_address_g  => hibi_addr_dct_c,
          rtm_address_g  => hibi_addr_cpu_rtm_c,
          dct_width_g    => DCT_inputw_co,
          quant_width_g  => QUANT_resultw_co,
          idct_width_g   => IDCT_resultw_co)
        port map (
          clk                 => clk_ip,
          rst_n               => rst_n,
          hibi_av_out         => av_ip_net(0),
          hibi_data_out       => data_ip_net(data_width_g-1 downto 0),
          hibi_comm_out       => comm_ip_net(comm_width_g-1 downto 0),
          hibi_we_out         => we_ip_net(0),
          hibi_re_out         => re_ip_net(0),
          hibi_av_in          => av_net_ip(0),
          hibi_data_in        => data_net_ip(data_width_g-1 downto 0),
          hibi_comm_in        => comm_net_ip(comm_width_g-1 downto 0),
          hibi_empty_in       => empty_net_ip(0),
          hibi_full_in        => full_net_ip(0),
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

      -- dctQidct_core
      dctQidct_core_1 : dctQidct_core
        port map (
          QP_in                 => QP,
          chroma_in             => chroma,
          clk                   => clk_ip,
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

      -- cpu emulator
      tb_dct_cpu_i : tb_dct_cpu
        generic map (
          data_width_g => data_width_g,
          comm_width_g => comm_width_g)
        port map (
          clk               => clk_ip,
          clk_dctqidct_fast => clk_ip,
          rst_n             => rst_n,
          data_in           => data_net_ip(2*data_width_g-1 downto data_width_g),
          comm_in           => comm_net_ip(2*comm_width_g-1 downto comm_width_g),
          av_in             => av_net_ip(1),
          re_out            => re_ip_net(1),
          empty_in          => empty_net_ip(1),
          data_out          => data_ip_net(2*data_width_g-1 downto data_width_g),
          comm_out          => comm_ip_net(2*comm_width_g-1 downto comm_width_g),
          av_out            => av_ip_net(1),
          we_out            => we_ip_net(1),
          full_in           => full_net_ip(1),
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

      
      
      
    end tb;
