-------------------------------------------------------------------------------
-- Title      : HIBI Receiver block
-- Project    : HIBI
-------------------------------------------------------------------------------
-- File       : receiver.vhd
-- Authors    : Vesa Lahtinen,
--              Erno Salminen,
--              Lasse Lehtonen
-- Company    : Tampere University of Technology
-- Created    :
-- Last update: 2011-11-28
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Receive side structural block
--
-- Contains addr_decoder and rx_control
--
-------------------------------------------------------------------------------
-- Copyright (c) 2010 Tampere University of Technology
--
-- 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
--
-- 2001-04-01  1.0      VL      Created
-- 2004-2005            ege     Many changes
-- 2010-10-15           ase     Modified for new addr_decoder and rx_control
-------------------------------------------------------------------------------
-- Funbase IP library Copyright (C) 2011 TUT Department of Computer Systems
--
-- This file is part of HIBI
--
-- This source file may be used and distributed without
-- restriction provided that this copyright statement is not
-- removed from the file and that any derivative work contains
-- the original copyright notice and the associated disclaimer.
--
-- This source file is free software; you can redistribute it
-- and/or modify it under the terms of the GNU Lesser General
-- Public License as published by the Free Software Foundation;
-- either version 2.1 of the License, or (at your option) any
-- later version.
--
-- This source is distributed in the hope that it will be
-- useful, but WITHOUT ANY WARRANTY; without even the implied
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
-- PURPOSE.  See the GNU Lesser General Public License for more
-- details.
--
-- You should have received a copy of the GNU Lesser General
-- Public License along with this source; if not, download it
-- from http://www.opencores.org/lgpl.shtml
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.hibiv3_pkg.all;

entity receiver is
  generic (
    id_g             : integer;
    id_min_g         : integer := 0;    -- Only for bridges, zero for others!
    id_max_g         : integer := 0;    -- Only for bridges, zero for others!
    addr_base_g      : integer;
    addr_limit_g     : integer := 0;
    id_width_g       : integer;
    data_width_g     : integer;
    addr_width_g     : integer;
    cfg_addr_width_g : integer;
    cfg_re_g         : integer;
    cfg_we_g         : integer;
    inv_addr_en_g    : integer;
    separate_addr_g  : integer := 0
    );
  port (
    clk   : in std_logic;
    rst_n : in std_logic;

    av_in         : in std_logic;
    data_in       : in std_logic_vector(data_width_g-1 downto 0);
    comm_in       : in std_logic_vector(comm_width_c-1 downto 0);
    cfg_rd_rdy_in : in std_logic;

    av_0_out   : out std_logic;
    data_0_out : out std_logic_vector(data_width_g-1 downto 0);
    comm_0_out : out std_logic_vector(comm_width_c-1 downto 0);
    we_0_out   : out std_logic;
    full_0_in  : in  std_logic;
    one_p_0_in : in  std_logic;

    av_1_out   : out std_logic;
    data_1_out : out std_logic_vector(data_width_g-1 downto 0);
    comm_1_out : out std_logic_vector(comm_width_c-1 downto 0);
    we_1_out   : out std_logic;
    full_1_in  : in  std_logic;
    one_p_1_in : in  std_logic;

    bus_full_in : in std_logic;

    cfg_we_out       : out std_logic;
    cfg_re_out       : out std_logic;
    cfg_data_out     : out std_logic_vector
    (data_width_g-1-(separate_addr_g*addr_width_g) downto 0);
    cfg_addr_out     : out std_logic_vector(cfg_addr_width_g-1 downto 0);
    cfg_ret_addr_out : out std_logic_vector(addr_width_g-1 downto 0);
    full_out         : out std_logic
    );
end receiver;

architecture structural of receiver is

  component addr_decoder is
    generic (
      data_width_g    : integer;
      addr_width_g    : integer;
      id_width_g      : integer;
      id_g            : integer;
      id_min_g        : integer;
      id_max_g        : integer;
      addr_base_g     : integer;
      addr_limit_g    : integer;
      invert_addr_g   : integer;
      cfg_re_g        : integer;
      cfg_we_g        : integer;
      separate_addr_g : integer);
    port (
      clk                  : in  std_logic;
      rst_n                : in  std_logic;
      av_in                : in  std_logic;
      addr_in              : in  std_logic_vector(addr_width_g-1 downto 0);
      comm_in              : in  std_logic_vector(comm_width_c-1 downto 0);
      bus_full_in          : in  std_logic;
      addr_match_out       : out std_logic;
      id_match_out         : out std_logic;
      norm_cmd_out         : out std_logic;
      msg_cmd_out          : out std_logic;
      conf_re_cmd_out      : out std_logic;
      conf_we_cmd_out      : out std_logic;
      excl_lock_cmd_out    : out std_logic;
      excl_data_cmd_out    : out std_logic;
      excl_release_cmd_out : out std_logic);
  end component addr_decoder;

  component rx_control is
    generic (
      data_width_g     : integer;
      addr_width_g     : integer;
      id_width_g       : integer;
      cfg_addr_width_g : integer;
      cfg_re_g         : integer;
      cfg_we_g         : integer;
      separate_addr_g  : integer;
      is_bridge_g      : integer);
    port (
      clk      : in  std_logic;
      rst_n    : in  std_logic;
      av_in    : in  std_logic;
      data_in  : in  std_logic_vector(data_width_g-1 downto 0);
      comm_in  : in  std_logic_vector(comm_width_c-1 downto 0);
      full_out : out std_logic;

      data_0_out : out std_logic_vector(data_width_g-1 downto 0);
      comm_0_out : out std_logic_vector(comm_width_c-1 downto 0);
      av_0_out   : out std_logic;
      we_0_out   : out std_logic;
      full_0_in  : in  std_logic;
      one_p_0_in : in  std_logic;

      data_1_out : out std_logic_vector(data_width_g-1 downto 0);
      comm_1_out : out std_logic_vector(comm_width_c-1 downto 0);
      av_1_out   : out std_logic;
      we_1_out   : out std_logic;
      full_1_in  : in  std_logic;
      one_p_1_in : in  std_logic;

      addr_match_in       : in  std_logic;
      id_match_in         : in  std_logic;
      norm_cmd_in         : in  std_logic;
      msg_cmd_in          : in  std_logic;
      conf_re_cmd_in      : in  std_logic;
      conf_we_cmd_in      : in  std_logic;
      excl_lock_cmd_in    : in  std_logic;
      excl_data_cmd_in    : in  std_logic;
      excl_release_cmd_in : in  std_logic;
      cfg_rd_rdy_in       : in  std_logic;
      cfg_we_out          : out std_logic;
      cfg_re_out          : out std_logic;
      cfg_addr_out        : out std_logic_vector(cfg_addr_width_g-1 downto 0);
      cfg_data_out        : out std_logic_vector
      (data_width_g-1-(separate_addr_g*addr_width_g) downto 0);
      cfg_ret_addr_out    : out std_logic_vector(addr_width_g-1 downto 0));
  end component rx_control;

  function amIbridge (
    constant id_max : integer)
    return integer is
  begin  -- function amIbridge
    if id_max /= 0 then
      return 1;
    else
      return 0;
    end if;
  end function amIbridge;

  -- only bridges if have id_ranges
  constant iAmBridge_c : integer := amIbridge(id_max_g);

  signal addr_match_dc_rx       : std_logic;
  signal id_match_dc_rx         : std_logic;
  signal norm_cmd_dc_rx         : std_logic;
  signal msg_cmd_dc_rx          : std_logic;
  signal conf_re_cmd_dc_rx      : std_logic;
  signal conf_we_cmd_dc_rx      : std_logic;
  signal excl_lock_cmd_dc_rx    : std_logic;
  signal excl_data_cmd_dc_rx    : std_logic;
  signal excl_release_cmd_dc_rx : std_logic;
  

begin  -- structural
  

  addr_decoder_1 : addr_decoder
    generic map (
      data_width_g    => data_width_g,
      addr_width_g    => addr_width_g,
      id_width_g      => id_width_g,
      id_g            => id_g,
      id_min_g        => id_min_g,
      id_max_g        => id_max_g,
      addr_base_g     => addr_base_g,
      addr_limit_g    => addr_limit_g,
      invert_addr_g   => inv_addr_en_g,
      cfg_re_g        => cfg_re_g,
      cfg_we_g        => cfg_we_g,
      separate_addr_g => separate_addr_g)
    port map (
      clk                  => clk,
      rst_n                => rst_n,
      av_in                => av_in,
      addr_in              => data_in
      (addr_width_g-1+(separate_addr_g*(data_width_g-addr_width_g)) downto
       separate_addr_g*(data_width_g-addr_width_g)),
      comm_in              => comm_in,
      bus_full_in          => bus_full_in,
      addr_match_out       => addr_match_dc_rx,
      id_match_out         => id_match_dc_rx,
      norm_cmd_out         => norm_cmd_dc_rx,
      msg_cmd_out          => msg_cmd_dc_rx,
      conf_re_cmd_out      => conf_re_cmd_dc_rx,
      conf_we_cmd_out      => conf_we_cmd_dc_rx,
      excl_lock_cmd_out    => excl_lock_cmd_dc_rx,
      excl_data_cmd_out    => excl_data_cmd_dc_rx,
      excl_release_cmd_out => excl_release_cmd_dc_rx);


  rx_control_1 : rx_control
    generic map (
      data_width_g     => data_width_g,
      addr_width_g     => addr_width_g,
      id_width_g       => id_width_g,
      cfg_addr_width_g => cfg_addr_width_g,
      cfg_re_g         => cfg_re_g,
      cfg_we_g         => cfg_we_g,
      separate_addr_g  => separate_addr_g,
      is_bridge_g      => iAmBridge_c)
    port map (
      clk      => clk,
      rst_n    => rst_n,
      av_in    => av_in,
      data_in  => data_in,
      comm_in  => comm_in,
      full_out => full_out,

      data_0_out => data_0_out,
      comm_0_out => comm_0_out,
      av_0_out   => av_0_out,
      we_0_out   => we_0_out,
      full_0_in  => full_0_in,
      one_p_0_in => one_p_0_in,

      data_1_out => data_1_out,
      comm_1_out => comm_1_out,
      av_1_out   => av_1_out,
      we_1_out   => we_1_out,
      full_1_in  => full_1_in,
      one_p_1_in => one_p_1_in,

      addr_match_in       => addr_match_dc_rx,
      id_match_in         => id_match_dc_rx,
      norm_cmd_in         => norm_cmd_dc_rx,
      msg_cmd_in          => msg_cmd_dc_rx,
      conf_re_cmd_in      => conf_re_cmd_dc_rx,
      conf_we_cmd_in      => conf_we_cmd_dc_rx,
      excl_lock_cmd_in    => excl_lock_cmd_dc_rx,
      excl_data_cmd_in    => excl_data_cmd_dc_rx,
      excl_release_cmd_in => excl_release_cmd_dc_rx,
      cfg_rd_rdy_in       => cfg_rd_rdy_in,
      cfg_we_out          => cfg_we_out,
      cfg_re_out          => cfg_re_out,
      cfg_addr_out        => cfg_addr_out,
      cfg_data_out        => cfg_data_out,
      cfg_ret_addr_out    => cfg_ret_addr_out);

end structural;
