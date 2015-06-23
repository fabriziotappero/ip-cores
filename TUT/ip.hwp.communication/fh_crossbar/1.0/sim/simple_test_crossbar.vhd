-------------------------------------------------------------------------------
-- Title      : Simple tester for crossbar
-- Project    : 
-------------------------------------------------------------------------------
-- File       : simple_test_crossbar.vhd
-- Author     : Lasse Lehtonen
-- Company    : 
-- Created    : 2011-08-12
-- Last update: 2011-08-15
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2011 
--
--  This file is part of Transaction Generator.
--
--  Transaction Generator is free software: you can redistribute it and/or modify
--  it under the terms of the Lesser GNU General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.
--
--  Transaction Generator is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  Lesser GNU General Public License for more details.
--
--  You should have received a copy of the Lesser GNU General Public License
--  along with Transaction Generator.  If not, see <http://www.gnu.org/licenses/>.
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2011-08-12  1.0      lehton87        Created
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity simple_test_crossbar is
end simple_test_crossbar;



architecture tb of simple_test_crossbar is

  -----------------------------------------------------------------------------
  -- CONSTANTS
  -----------------------------------------------------------------------------
  -- generics
  constant pkt_switch_en_c : integer := 1;
  constant n_ag_c          : integer := 6;
  constant stfwd_en_c      : integer := 0;
  constant data_width_c    : integer := 32;
  constant addr_width_c    : integer := 32;
  constant packet_length_c : integer := 6;
  constant tx_len_width_c  : integer := 8;
  constant timeout_c       : integer := 4;
  constant fill_packet_c   : integer := 0;
  constant lut_en_c        : integer := 0;
  constant net_type_c      : integer := 0;
  constant len_flit_en_c   : integer := 1;
  constant oaddr_flit_en_c : integer := 0;
  constant status_en_c     : integer := 0;
  constant fifo_depth_c    : integer := 8;
  constant net_freq_c      : integer := 1;
  constant ip_freq_c       : integer := 2;
  constant max_send_c      : integer := 0;  -- 0 = inf

  -- clock generation
  constant noc_cycle_time_c : time := 4 ns;
  constant ip_cycle_time_c  : time := 2 ns;

  -----------------------------------------------------------------------------
  -- SIGNALS
  -----------------------------------------------------------------------------
  signal clk_noc : std_logic := '1';
  signal clk_ip  : std_logic := '1';
  signal rst_n   : std_logic := '0';

  signal rx_av : std_logic_vector(n_ag_c-1 downto 0)
 := (others => '0');
  signal rx_data : std_logic_vector(n_ag_c*data_width_c-1 downto 0)
 := (others => '0');
  signal we : std_logic_vector(n_ag_c-1 downto 0)
 := (others => '0');
  signal txlen : std_logic_vector(n_ag_c*tx_len_width_c-1 downto 0)
 := (others => '0');
  signal full : std_logic_vector(n_ag_c-1 downto 0)
 := (others => '0');
  signal full_r : std_logic_vector(n_ag_c-1 downto 0)
 := (others => '0');
  signal rx_empty : std_logic_vector(n_ag_c-1 downto 0)
 := (others => '0');
  signal tx_av : std_logic_vector(n_ag_c-1 downto 0)
 := (others => '0');
  signal tx_data : std_logic_vector(n_ag_c*data_width_c-1 downto 0)
 := (others => '0');
  signal re : std_logic_vector(n_ag_c-1 downto 0)
 := (others => '0');
  signal tx_empty : std_logic_vector(n_ag_c-1 downto 0)
 := (others => '0');

  
begin  -- tb


  clk_noc <= not clk_noc after noc_cycle_time_c;
  clk_ip  <= not clk_ip  after ip_cycle_time_c;
  rst_n   <= '1'         after 20 ns;


  i_crossbar_with_pkt_codec_top : entity work.crossbar_with_pkt_codec_top
    generic map (
      pkt_switch_en_g => pkt_switch_en_c,
      n_ag_g          => n_ag_c,
      stfwd_en_g      => stfwd_en_c,
      data_width_g    => data_width_c,
      addr_width_g    => addr_width_c,
      packet_length_g => packet_length_c,
      tx_len_width_g  => tx_len_width_c,
      timeout_g       => timeout_c,
      fill_packet_g   => fill_packet_c,
      lut_en_g        => lut_en_c,
      len_flit_en_g   => len_flit_en_c,
      oaddr_flit_en_g => oaddr_flit_en_c,
      status_en_g     => status_en_c,
      max_send_g      => max_send_c,
      fifo_depth_g    => fifo_depth_c,
      net_freq_g      => net_freq_c,
      ip_freq_g       => ip_freq_c)
    port map (
      clk_net      => clk_noc,
      clk_ip       => clk_ip,
      rst_n        => rst_n,
      tx_av_in     => tx_av,
      tx_data_in   => tx_data,
      tx_we_in     => we,
      tx_txlen_in  => txlen,
      tx_full_out  => full,
      tx_empty_out => tx_empty,
      rx_av_out    => rx_av,
      rx_data_out  => rx_data,
      rx_re_in     => re,
      rx_empty_out => rx_empty);


  basic_test_tx_1 : entity work.basic_test_tx
    generic map (
      conf_file_g  => "tx_file.txt",
      comm_width_g => 2,
      data_width_g => data_width_c)
    port map (
      clk            => clk_ip,
      rst_n          => rst_n,
      done_out       => open,
      agent_av_out   => tx_av(0),
      agent_data_out => tx_data(data_width_c-1 downto 0),
      agent_comm_out => open,
      agent_we_out   => we(0),
      agent_full_in  => full(0),
      agent_one_p_in => '0');

  basic_test_rx_1 : entity work.basic_test_rx
    generic map (
      conf_file_g  => "rx_file.txt",
      comm_width_g => 2,
      data_width_g => data_width_c)
    port map (
      clk            => clk_ip,
      rst_n          => rst_n,
      done_out       => open,
      agent_av_in    => rx_av(5),
      agent_data_in  => rx_data(6*data_width_c-1 downto 5*data_width_c),
      agent_comm_in  => "00",
      agent_re_out   => re(5),
      agent_empty_in => rx_empty(5),
      agent_one_d_in => '0');

end tb;
