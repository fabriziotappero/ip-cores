-------------------------------------------------------------------------------
-- Title      : ring toplevel with packet encoder-decoders.
-- Project    : 
-------------------------------------------------------------------------------
-- File       : ring_with_pkt_codec_top.vhd
-- Author     : Antti Alhonen
-- Company    : 
-- Last update: 2011-08-22
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2009/08/07  1.0      alhonena        Created
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Copyright (c) 2011 Tampere University of Technology
-------------------------------------------------------------------------------
--  This file is part of Transaction Generator.
--
--  Transaction Generator is free software: you can redistribute it and/or
--  modify it under the terms of the Lesser GNU General Public License as
--  published by the Free Software Foundation, either version 3 of the License,
--  or (at your option) any later version.
--
--  Transaction Generator is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  Lesser GNU General Public License for more details.
--
--  You should have received a copy of the Lesser GNU General Public License
--  along with Transaction Generator.  If not, see
--  <http://www.gnu.org/licenses/>.
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

entity ring_with_pkt_codec_top is

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
    clk_net : in std_logic;
    clk_ip  : in std_logic;
    rst_n   : in std_logic;

    -- Data coming from IP to network
    tx_av_in     : in  std_logic_vector (n_ag_g-1 downto 0);
    tx_data_in   : in  std_logic_vector (n_ag_g * data_width_g -1 downto 0);
    tx_we_in     : in  std_logic_vector (n_ag_g-1 downto 0);
    tx_txlen_in  : in  std_logic_vector (n_ag_g * tx_len_width_g -1 downto 0);
    tx_full_out  : out std_logic_vector (n_ag_g-1 downto 0);
    tx_empty_out : out std_logic_vector (n_ag_g-1 downto 0);  -- not needed in most cases.

    -- Data going from network to IP
    rx_av_out    : out std_logic_vector (n_ag_g-1 downto 0);
    rx_data_out  : out std_logic_vector (n_ag_g * data_width_g -1 downto 0);
    rx_re_in     : in  std_logic_vector (n_ag_g-1 downto 0);
    rx_empty_out : out std_logic_vector (n_ag_g-1 downto 0)

    );

end ring_with_pkt_codec_top;

architecture structural of ring_with_pkt_codec_top is

  component enc_dec_1d
    generic (
      n_ag_g            :     integer;
      wait_empty_fifo_g :     integer;
      data_width_g      :     integer;
      addr_width_g      :     integer;
      packet_length_g   :     integer;
      tx_len_width_g    :     integer;
      timeout_g         :     integer;
      fill_packet_g     :     integer;
      lut_en_g          :     integer;
      net_type_g        :     integer;
      len_flit_en_g     :     integer;
      oaddr_flit_en_g   :     integer;
      status_en_g       :     integer);
    port (
      Clk               : in  std_logic;
      Rst_n             : in  std_logic;
      av_ip_enc_in      : in  std_logic_vector (n_ag_g-1 downto 0);
      data_ip_enc_in    : in  std_logic_vector (n_ag_g * data_width_g -1 downto 0);
      we_ip_enc_in      : in  std_logic_vector (n_ag_g-1 downto 0);
      len_ip_enc_in     : in  std_logic_vector (n_ag_g*tx_len_width_g-1 downto 0);
      full_enc_ip_out   : out std_logic_vector (n_ag_g-1 downto 0);
      empty_enc_ip_out  : out std_logic_vector (n_ag_g-1 downto 0);
      av_enc_net_out    : out std_logic_vector (n_ag_g-1 downto 0);
      data_enc_net_out  : out std_logic_vector (n_ag_g * data_width_g -1 downto 0);
      we_enc_net_out    : out std_logic_vector (n_ag_g-1 downto 0);
      full_net_enc_in   : in  std_logic_vector (n_ag_g-1 downto 0);
      empty_net_enc_in  : in  std_logic_vector (n_ag_g-1 downto 0);
      data_net_dec_in   : in  std_logic_vector (n_ag_g * data_width_g -1 downto 0);
      re_dec_net_out    : out std_logic_vector (n_ag_g-1 downto 0);
      full_net_dec_in   : in  std_logic_vector (n_ag_g-1 downto 0);
      empty_net_dec_in  : in  std_logic_vector (n_ag_g-1 downto 0);
      av_dec_ip_out     : out std_logic_vector (n_ag_g-1 downto 0);
      data_dec_ip_out   : out std_logic_vector (n_ag_g * data_width_g -1 downto 0);
      re_ip_dec_in      : in  std_logic_vector (n_ag_g-1 downto 0);
      empty_dec_ip_out  : out std_logic_vector (n_ag_g-1 downto 0));
  end component;

  component ring
    generic (
      nbr_of_routers_g :     integer;
      diag_en_g        :     integer;
      data_width_g     :     integer;
      stfwd_en_g       :     integer;
      pkt_len_g        :     integer;
      len_flit_en_g    :     integer;
      oaddr_flit_en_g  :     integer;
      fifo_depth_g     :     integer;
      net_freq_g       :     integer;
      ip_freq_g        :     integer);
    port (
      clk_net          : in  std_logic;
      clk_ip           : in  std_logic;
      rst_n            : in  std_logic;
      tx_data_in       : in  std_logic_vector( nbr_of_routers_g * data_width_g-1 downto 0 );
      tx_we_in         : in  std_logic_vector ( nbr_of_routers_g - 1 downto 0 );
      tx_empty_out     : out std_logic_vector ( nbr_of_routers_g - 1 downto 0 );
      tx_full_out      : out std_logic_vector ( nbr_of_routers_g - 1 downto 0 );
      rx_data_out      : out std_logic_vector( nbr_of_routers_g*data_width_g-1 downto 0 );
      rx_re_in         : in  std_logic_vector (nbr_of_routers_g-1 downto 0);
      rx_empty_out     : out std_logic_vector (nbr_of_routers_g-1 downto 0);
      rx_full_out      : out std_logic_vector (nbr_of_routers_g-1 downto 0));
  end component;

  signal av_enc_net    : std_logic_vector (n_ag_g-1 downto 0);
  signal data_enc_net  : std_logic_vector (n_ag_g * data_width_g -1 downto 0);
  signal we_enc_net    : std_logic_vector (n_ag_g-1 downto 0);
  signal full_net_enc  : std_logic_vector (n_ag_g-1 downto 0);
  signal empty_net_enc : std_logic_vector (n_ag_g-1 downto 0);
  signal data_net_dec  : std_logic_vector (n_ag_g * data_width_g -1 downto 0);
  signal re_dec_net    : std_logic_vector (n_ag_g-1 downto 0);
  signal full_net_dec  : std_logic_vector (n_ag_g-1 downto 0);
  signal empty_net_dec : std_logic_vector (n_ag_g-1 downto 0);

begin  -- structural

  enc_dec : enc_dec_1d
    generic map (
      n_ag_g            => n_ag_g,
      wait_empty_fifo_g => stfwd_en_g,
      data_width_g      => data_width_g,
      addr_width_g      => addr_width_g,
      packet_length_g   => packet_length_g,
      tx_len_width_g    => tx_len_width_g,
      timeout_g         => timeout_g,
      fill_packet_g     => fill_packet_g,
      lut_en_g          => lut_en_g,
      net_type_g        => 1,           -- 1 = ring
      len_flit_en_g     => len_flit_en_g,
      oaddr_flit_en_g   => oaddr_flit_en_g,
      status_en_g       => status_en_g
      )
    port map (
      Clk               => clk_ip,
      Rst_n             => rst_n,
      av_ip_enc_in      => tx_av_in,
      data_ip_enc_in    => tx_data_in,
      we_ip_enc_in      => tx_we_in,
      len_ip_enc_in     => tx_txlen_in,
      full_enc_ip_out   => tx_full_out,
      empty_enc_ip_out  => tx_empty_out,
      av_enc_net_out    => av_enc_net,
      data_enc_net_out  => data_enc_net,
      we_enc_net_out    => we_enc_net,
      full_net_enc_in   => full_net_enc,
      empty_net_enc_in  => empty_net_enc,
      data_net_dec_in   => data_net_dec,
      re_dec_net_out    => re_dec_net,
      full_net_dec_in   => full_net_dec,
      empty_net_dec_in  => empty_net_dec,
      av_dec_ip_out     => rx_av_out,
      data_dec_ip_out   => rx_data_out,
      re_ip_dec_in      => rx_re_in,
      empty_dec_ip_out  => rx_empty_out
      );

  ringen : ring
    generic map (
      nbr_of_routers_g => n_ag_g,
      diag_en_g        => diag_en_g,
      data_width_g     => data_width_g,
      stfwd_en_g       => stfwd_en_g,
      pkt_len_g        => packet_length_g,
      len_flit_en_g    => len_flit_en_g,
      oaddr_flit_en_g  => oaddr_flit_en_g,
      fifo_depth_g     => fifo_depth_g,
      net_freq_g       => ring_freq_g,
      ip_freq_g        => ip_freq_g
      )
    port map (
      clk_net          => clk_net,
      clk_ip           => clk_ip,
      rst_n            => rst_n,
      tx_data_in       => data_enc_net,
      tx_we_in         => we_enc_net,
      tx_empty_out     => empty_net_enc,
      tx_full_out      => full_net_enc,
      rx_data_out      => data_net_dec,
      rx_re_in         => re_dec_net,
      rx_empty_out     => empty_net_dec,
      rx_full_out      => full_net_dec);

end structural;
