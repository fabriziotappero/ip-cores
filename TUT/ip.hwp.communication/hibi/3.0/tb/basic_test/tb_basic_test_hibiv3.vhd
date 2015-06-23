-------------------------------------------------------------------------------
-- Title      : Basic tester for Hibi v3
-- Project    : 
-------------------------------------------------------------------------------
-- File       : basic_test_hibiv3.vhd
-- Author     : Lasse Lehtonen
-- Company    : 
-- Created    : 2011-09-29
-- Last update: 2012-03-08
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

entity tb_basic_test_hibiv3 is
end tb_basic_test_hibiv3;


architecture tb of tb_basic_test_hibiv3 is

  -----------------------------------------------------------------------------
  -- CONSTANTS
  -----------------------------------------------------------------------------
  -- System size
  constant n_agents_g   : integer := 2;
  constant n_segments_g : integer := 1;

  -- Values for HIBI generics
  -- a) signal and counter sizes
  constant id_width_g          : integer := 4;
  constant addr_width_g        : integer := 16;
  constant data_width_g        : integer := 16;
  constant comm_width_g        : integer := 5;
  constant counter_width_g     : integer := 8;
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
  constant arb_type_g          : integer := 3;
  constant max_send_g          : integer := 20;
  constant n_cfg_pages_g       : integer := 1;
  constant n_time_slots_g      : integer := 0;
  constant keep_slot_g         : integer := 0;
  constant n_extra_params_g    : integer := 1;
  constant cfg_re_g      : integer := 1;
  constant cfg_we_g      : integer := 1;
  constant debug_width_g : integer := 0;



  -- clock generation
  constant noc_cycle_time_c : time := 4 ns;
  constant ip_cycle_time_c  : time := 4 ns;

  -----------------------------------------------------------------------------
  -- SIGNALS
  -----------------------------------------------------------------------------
  signal clk_noc : std_logic := '1';
  signal clk_ip  : std_logic := '1';
  signal rst_n   : std_logic := '0';

  -- Sending, data goes IP -> net
  signal comm_ip_net   : std_logic_vector(n_agents_g*comm_width_g-1 downto 0)
    := (others => '0');
  signal data_ip_net   : std_logic_vector(n_agents_g*data_width_g-1 downto 0)
    := (others => '0');
  signal av_ip_net     : std_logic_vector(n_agents_g-1 downto 0)
    := (others => '0');
  signal we_ip_net     : std_logic_vector(n_agents_g-1 downto 0)
    := (others => '0');
  signal full_net_ip  : std_logic_vector(n_agents_g-1 downto 0)
    := (others => '0');
  signal one_p_net_ip : std_logic_vector(n_agents_g-1 downto 0)
    := (others => '0');

  -- Receiving, data goes net -> IP
  signal comm_net_ip  : std_logic_vector(n_agents_g*comm_width_g-1 downto 0)
    := (others => '0');
  signal data_net_ip  : std_logic_vector(n_agents_g*data_width_g-1 downto 0)
    := (others => '0');
  signal av_net_ip    : std_logic_vector(n_agents_g-1 downto 0)
    := (others => '0');
  signal re_ip_net     : std_logic_vector(n_agents_g-1 downto 0)
    := (others => '0');
  signal empty_net_ip : std_logic_vector(n_agents_g-1 downto 0)
    := (others => '0');
  signal one_d_net_ip : std_logic_vector(n_agents_g-1 downto 0)
    := (others => '0');
    
begin  -- tb


  clk_noc <= not clk_noc after noc_cycle_time_c;
  clk_ip  <= not clk_ip  after ip_cycle_time_c;
  rst_n   <= '1'         after 20 ns;


  -- Tested (=demonstrated) network
  i_hibiv3_r4_1: entity work.hibiv3_r4
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
      clk_ip          => clk_ip,
      clk_noc         => clk_noc,
      rst_n           => rst_n,

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

  
  -- Simple sender component
  basic_tester_tx_1 : entity work.basic_tester_tx
    generic map (
      conf_file_g  => "tx_file.txt",
      comm_width_g => 5,
      data_width_g => data_width_g)
    port map (
      clk            => clk_ip,
      rst_n          => rst_n,
      done_out       => open,
      agent_av_out   => av_ip_net(0),
      agent_data_out => data_ip_net(data_width_g-1 downto 0),
      agent_comm_out => comm_ip_net(comm_width_g-1 downto 0),
      agent_we_out   => we_ip_net(0),
      agent_full_in  => full_net_ip (0),
      agent_one_p_in => one_p_net_ip (0));

  
  -- Simple receiver component
  basic_tester_rx_1 : entity work.basic_tester_rx
    generic map (
      conf_file_g  => "rx_file.txt",
      comm_width_g => 5,
      data_width_g => data_width_g)
    port map (
      clk            => clk_ip,
      rst_n          => rst_n,
      done_out       => open,
      
      agent_av_in    => av_net_ip (1),
      agent_data_in  => data_net_ip (2*data_width_g-1 downto 1*data_width_g),
      agent_comm_in  => comm_net_ip (2*comm_width_g-1 downto 1*comm_width_g),
      agent_re_out   => re_ip_net(1),
      agent_empty_in => empty_net_ip (1),
      agent_one_d_in => one_d_net_ip (1));

end tb;
