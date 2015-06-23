-------------------------------------------------------------------------------
-- Funbase IP library Copyright (C) 2011 TUT Department of Computer Systems
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
-- useful, but WITHOUT ANY WARRANTY; without even the impliedlk
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
-- PURPOSE.  See the GNU Lesser General Public License for more
-- details.
--
-- You should have received a copy of the GNU Lesser General
-- Public License along with this source; if not, download it
-- from http://www.opencores.org/lgpl.shtml
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- file        : hibi_segment_small.vhd
-- description : hibi bus for connecting eight nioses, this time
--               using hibi_wrapper_r4 (only one fifo interface)
-- author      : Tapio Koskinen
-- date        : 29.9.2008
-- modified    : 
-- 29.09.2008  tko modified from Ari Kulmala's eight_hibi_r4_and_radio.vhdl
-- 2012-03-16 ES Beautified lots of things, e.g. indexing starts now from 0 
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity hibi_segment_small is
  generic (
    data_width_g          : integer := 32;
    counter_width_g       : integer := 16;
    addr_width_g          : integer := 32;
    comm_width_g          : integer := 5;

    number_of_r4_agents_g : integer := 3;  -- 1-3
    number_of_r3_agents_g : integer := 0;  -- 0-1

    -- max sends
    agent_max_send_0_g  : integer := 200;
    agent_max_send_1_g  : integer := 200;
    agent_max_send_2_g  : integer := 200;
    agent_max_send_16_g : integer := 200
    );

  port (
    clk_in   : in std_logic;
    rst_n_in : in std_logic;

    -- Debug signals for bus monitoring purposes
    debug_bus_full_out : out std_logic;
    debug_bus_comm_out : out std_logic_vector (comm_width_g-1 downto 0);
    debug_bus_av_out   : out std_logic;

    -- terminal 0 (type r4)
    agent_av_in_0     : in  std_logic;
    agent_data_in_0   : in  std_logic_vector (data_width_g-1 downto 0);
    agent_comm_in_0   : in  std_logic_vector (comm_width_g-1 downto 0);
    agent_we_in_0     : in  std_logic;
    agent_full_out_0  : out std_logic;
    agent_one_p_out_0 : out std_logic;

    agent_av_out_0    : out std_logic;
    agent_data_out_0  : out std_logic_vector (data_width_g-1 downto 0);
    agent_comm_out_0  : out std_logic_vector (comm_width_g-1 downto 0);
    agent_re_in_0     : in  std_logic;
    agent_empty_out_0 : out std_logic;
    agent_one_d_out_0 : out std_logic;

    -- terminal 1 (type r4)
    agent_av_in_1     : in  std_logic;
    agent_data_in_1   : in  std_logic_vector (data_width_g-1 downto 0);
    agent_comm_in_1   : in  std_logic_vector (comm_width_g-1 downto 0);
    agent_we_in_1     : in  std_logic;
    agent_full_out_1  : out std_logic;
    agent_one_p_out_1 : out std_logic;

    agent_av_out_1    : out std_logic;
    agent_data_out_1  : out std_logic_vector (data_width_g-1 downto 0);
    agent_comm_out_1  : out std_logic_vector (comm_width_g-1 downto 0);
    agent_re_in_1     : in  std_logic;
    agent_empty_out_1 : out std_logic;
    agent_one_d_out_1 : out std_logic;

    -- terminal 2 (type r4)
    agent_av_in_2     : in  std_logic;
    agent_data_in_2   : in  std_logic_vector (data_width_g-1 downto 0);
    agent_comm_in_2   : in  std_logic_vector (comm_width_g-1 downto 0);
    agent_we_in_2     : in  std_logic;
    agent_full_out_2  : out std_logic;
    agent_one_p_out_2 : out std_logic;

    agent_av_out_2    : out std_logic;
    agent_data_out_2  : out std_logic_vector (data_width_g-1 downto 0);
    agent_comm_out_2  : out std_logic_vector (comm_width_g-1 downto 0);
    agent_re_in_2     : in  std_logic;
    agent_empty_out_2 : out std_logic;
    agent_one_d_out_2 : out std_logic;


    -- terminal 17 (type r3)
    agent_addr_in_16   : in  std_logic_vector (data_width_g-1 downto 0);
    agent_data_in_16   : in  std_logic_vector (data_width_g-1 downto 0);
    agent_comm_in_16   : in  std_logic_vector (comm_width_g-1 downto 0);
    agent_we_in_16     : in  std_logic;
    agent_full_out_16  : out std_logic;
    agent_one_p_out_16 : out std_logic;

    agent_addr_out_16  : out std_logic_vector (data_width_g-1 downto 0);
    agent_data_out_16  : out std_logic_vector (data_width_g-1 downto 0);
    agent_comm_out_16  : out std_logic_vector (comm_width_g-1 downto 0);
    agent_re_in_16     : in  std_logic;
    agent_empty_out_16 : out std_logic;
    agent_one_d_out_16 : out std_logic;

    agent_msg_addr_in_16   : in  std_logic_vector (data_width_g-1 downto 0);
    agent_msg_data_in_16   : in  std_logic_vector (data_width_g-1 downto 0);
    agent_msg_comm_in_16   : in  std_logic_vector (comm_width_g-1 downto 0);
    agent_msg_we_in_16     : in  std_logic;
    agent_msg_full_out_16  : out std_logic;
    agent_msg_one_p_out_16 : out std_logic;

    agent_msg_addr_out_16  : out std_logic_vector (data_width_g-1 downto 0);
    agent_msg_data_out_16  : out std_logic_vector (data_width_g-1 downto 0);
    agent_msg_comm_out_16  : out std_logic_vector (comm_width_g-1 downto 0);
    agent_msg_re_in_16     : in  std_logic;
    agent_msg_empty_out_16 : out std_logic;
    agent_msg_one_d_out_16 : out std_logic
    );
end hibi_segment_small;

architecture structural of hibi_segment_small is


  type data_vec_array is array (0 to 8) of std_logic_vector (data_width_g-1 downto 0);
  type addr_array is array (0 to 16) of integer;
  constant addr_c : addr_array := (16#01000000#, 16#03000000#, 16#05000000#, 16#07000000#,
                                   16#09000000#, 16#0b000000#, 16#0d000000#, 16#0f000000#,
                                   16#11000000#, 16#13000000#, 16#15000000#, 16#17000000#,
                                   16#19000000#, 16#1b000000#, 16#1d000000#, 16#1f000000#,
                                   16#29000000#);
  constant fifo_depths_c     : addr_array := (8, 8, 8, 8,
                                              8, 8, 8, 8,
                                              8, 8, 8, 8,
                                              8, 8, 8, 8, 8);

  constant msg_fifo_depths_c : addr_array := (8, 8, 8, 8,
                                              8, 8, 8, 8,
                                              8, 8, 8, 8,
                                              8, 8, 8, 8, 8);

  constant id_width_c : integer := 5;

  
  component hibi_wrapper_r4
    generic (
      id_g : integer := 5;
      --base_id_g : integer := 5;

      id_width_g      : integer := 4;
      addr_width_g    : integer := 32;  -- in bits!
      data_width_g    : integer := 32;
      comm_width_g    : integer := 5;
      counter_width_g : integer := 8;

      rel_agent_freq_g : integer := 1;
      rel_bus_freq_g   : integer := 1;

      -- 0 synch multiclk, 1 basic GALS,
      -- 2 Gray FIFO (depth=2^n!), 3 mixed clock pausible
      fifo_sel_g : integer := 0;


      rx_fifo_depth_g     : integer := 5;
      rx_msg_fifo_depth_g : integer := 5;
      tx_fifo_depth_g     : integer := 5;
      tx_msg_fifo_depth_g : integer := 5;

      arb_type_g : integer := 0;

      addr_g        : integer := 46;
      addr_limit_g  : integer;
      prior_g       : integer := 2;
      inv_addr_en_g : integer := 0;
      max_send_g    : integer := 50;

      n_agents_g       : integer := 4;
      n_cfg_pages_g    : integer := 1;
      n_time_slots_g   : integer := 0;
      n_extra_params_g : integer := 0;

      cfg_re_g         : integer := 0;
      cfg_we_g         : integer := 0;
      debug_width_g    : integer := 0 
      );
    port (
      bus_clk        : in std_logic;
      agent_clk      : in std_logic;
      bus_sync_clk   : in std_logic;
      agent_sync_clk : in std_logic;
      rst_n          : in std_logic;

      bus_av_in      : in std_logic;
      bus_data_in    : in std_logic_vector (data_width_g-1 downto 0);
      bus_comm_in    : in std_logic_vector (comm_width_g-1 downto 0);
      bus_lock_in    : in std_logic;
      bus_full_in    : in std_logic;

      agent_av_in     : in  std_logic;
      agent_data_in   : in  std_logic_vector (data_width_g-1 downto 0);
      agent_comm_in   : in  std_logic_vector (comm_width_g-1 downto 0);
      agent_we_in     : in  std_logic;
      agent_full_out  : out std_logic;
      agent_one_p_out : out std_logic;

      bus_av_out   : out std_logic;
      bus_data_out : out std_logic_vector (data_width_g-1 downto 0);
      bus_comm_out : out std_logic_vector (comm_width_g-1 downto 0);
      bus_lock_out : out std_logic;
      bus_full_out : out std_logic;

      agent_av_out    : out std_logic;
      agent_data_out  : out std_logic_vector (data_width_g-1 downto 0);
      agent_comm_out  : out std_logic_vector (comm_width_g-1 downto 0);
      agent_re_in     : in  std_logic;
      agent_empty_out : out std_logic;
      agent_one_d_out : out std_logic
      -- synthesis translate_off
      -- pragma translate_off
;
      debug_out : out std_logic_vector (debug_width_g-1 downto 0);
      debug_in  : in  std_logic_vector (debug_width_g-1 downto 0)
      -- pragma translate_on
      -- synthesis translate_on
      );
  end component;  -- hibi_wrapper_r4;

  component hibi_wrapper_r3 is
    generic (
      id_g : integer := 5;

      id_width_g      : integer := 4;
      addr_width_g    : integer := 32;  -- in bits!
      data_width_g    : integer := 32;
      comm_width_g    : integer := 5;
      counter_width_g : integer := 8;

      rx_fifo_depth_g     : integer := 5;
      rx_msg_fifo_depth_g : integer := 5;
      tx_fifo_depth_g     : integer := 5;
      tx_msg_fifo_depth_g : integer := 5;
      rel_agent_freq_g    : integer := 1;
      rel_bus_freq_g      : integer := 1;
      -- 0 synch multiclk, 1 basic GALS,
      -- 2 Gray FIFO (depth=2^n!), 3 mixed clock pausible
      fifo_sel_g          : integer := 0;

      addr_g        : integer := 46;
      addr_limit_g  : integer;
      prior_g       : integer := 2;
      inv_addr_en_g : integer := 0;
      max_send_g    : integer := 50;

      arb_type_g : integer := 0;

      n_agents_g       : integer := 4;
      n_cfg_pages_g    : integer := 1;
      n_time_slots_g   : integer := 0;
      n_extra_params_g : integer := 0;

      cfg_re_g         : integer := 0;
      cfg_we_g         : integer := 0;
      debug_width_g    : integer := 0

      );

    port (
      bus_clk        : in std_logic;
      agent_clk      : in std_logic;
      bus_sync_clk   : in std_logic;
      agent_sync_clk : in std_logic;
      rst_n          : in std_logic;

      bus_av_in      : in std_logic;
      bus_data_in    : in std_logic_vector (data_width_g-1 downto 0);
      bus_comm_in    : in std_logic_vector (comm_width_g-1 downto 0);
      bus_lock_in    : in std_logic;
      bus_full_in    : in std_logic;

      agent_comm_in   : in  std_logic_vector (comm_width_g-1 downto 0);
      agent_data_in   : in  std_logic_vector (data_width_g-1 downto 0);
      agent_addr_in   : in  std_logic_vector (data_width_g-1 downto 0);
      agent_we_in     : in  std_logic;
      agent_full_out  : out std_logic;
      agent_one_p_out : out std_logic;

      agent_msg_addr_in   : in  std_logic_vector (data_width_g-1 downto 0);
      agent_msg_data_in   : in  std_logic_vector (data_width_g-1 downto 0);
      agent_msg_comm_in   : in  std_logic_vector (comm_width_g-1 downto 0);
      agent_msg_we_in     : in  std_logic;
      agent_msg_full_out  : out std_logic;
      agent_msg_one_p_out : out std_logic;

      bus_av_out   : out std_logic;
      bus_data_out : out std_logic_vector (data_width_g-1 downto 0);
      bus_comm_out : out std_logic_vector (comm_width_g-1 downto 0);
      bus_lock_out : out std_logic;
      bus_full_out : out std_logic;

      agent_addr_out  : out std_logic_vector (data_width_g-1 downto 0);
      agent_data_out  : out std_logic_vector (data_width_g-1 downto 0);
      agent_comm_out  : out std_logic_vector (comm_width_g-1 downto 0);
      agent_empty_out : out std_logic;
      agent_re_in     : in  std_logic;
      agent_one_d_out : out std_logic;

      agent_msg_addr_out  : out std_logic_vector (data_width_g-1 downto 0);
      agent_msg_data_out  : out std_logic_vector (data_width_g-1 downto 0);
      agent_msg_comm_out  : out std_logic_vector (comm_width_g-1 downto 0);
      agent_msg_re_in     : in  std_logic;
      agent_msg_empty_out : out std_logic;
      agent_msg_one_d_out : out std_logic
      );
  end component;

  -- From wrappers to OR
  signal bus_av_out_0   : std_logic;
  signal bus_data_out_0 : std_logic_vector (data_width_g-1 downto 0);
  signal bus_comm_out_0 : std_logic_vector (comm_width_g-1 downto 0);
  signal bus_lock_out_0 : std_logic;
  signal bus_full_out_0 : std_logic;

  signal bus_av_out_1   : std_logic;
  signal bus_data_out_1 : std_logic_vector (data_width_g-1 downto 0);
  signal bus_comm_out_1 : std_logic_vector (comm_width_g-1 downto 0);
  signal bus_lock_out_1 : std_logic;
  signal bus_full_out_1 : std_logic;

  signal bus_av_out_2   : std_logic;
  signal bus_data_out_2 : std_logic_vector (data_width_g-1 downto 0);
  signal bus_comm_out_2 : std_logic_vector (comm_width_g-1 downto 0);
  signal bus_lock_out_2 : std_logic;
  signal bus_full_out_2 : std_logic;

  signal bus_av_out_16   : std_logic;
  signal bus_data_out_16 : std_logic_vector (data_width_g-1 downto 0);
  signal bus_comm_out_16 : std_logic_vector (comm_width_g-1 downto 0);
  signal bus_lock_out_16 : std_logic;
  signal bus_full_out_16 : std_logic;

  -- From OR to wrappers
  signal bus_data_in     : std_logic_vector (data_width_g-1 downto 0);
  signal bus_comm_in     : std_logic_vector (comm_width_g-1 downto 0);
  signal bus_av_in       : std_logic;
  signal bus_lock_in     : std_logic;
  signal bus_full_in     : std_logic;

begin  -- structural


  a0 : if number_of_r4_agents_g > 0 generate
    
    agent_0 : hibi_wrapper_r4
      generic map (
        id_g                => 4,

        id_width_g          => id_width_c,
        addr_width_g        => addr_width_g,
        data_width_g        => data_width_g,
        comm_width_g        => comm_width_g,
        counter_width_g     => counter_width_g,
        
        rx_fifo_depth_g     => fifo_depths_c(3),
        rx_msg_fifo_depth_g => msg_fifo_depths_c(3),
        tx_fifo_depth_g     => fifo_depths_c(3),
        tx_msg_fifo_depth_g => msg_fifo_depths_c(3),
        addr_g              => addr_c(0),
        addr_limit_g        => addr_c(1)-1,

        prior_g             => 1,
        inv_addr_en_g       => 0,
        max_send_g          => agent_max_send_0_g,
        n_agents_g          => number_of_r4_agents_g + number_of_r3_agents_g,
        n_cfg_pages_g       => 1,
        n_time_slots_g      => 0,
        n_extra_params_g    => 0

        )
      port map (
        bus_clk        => clk_in,
        agent_clk      => clk_in,
        bus_sync_clk   => clk_in,
        agent_sync_clk => clk_in,
        rst_n          => rst_n_in,
        
        bus_av_in      => bus_av_in,
        bus_data_in    => bus_data_in,
        bus_comm_in    => bus_comm_in,
        bus_lock_in    => bus_lock_in,
        bus_full_in    => bus_full_in,

        bus_av_out     => bus_av_out_0,
        bus_comm_out   => bus_comm_out_0,
        bus_data_out   => bus_data_out_0,
        bus_lock_out   => bus_lock_out_0,
        bus_full_out   => bus_full_out_0,

        agent_av_in     => agent_av_in_0,
        agent_comm_in   => agent_comm_in_0,
        agent_data_in   => agent_data_in_0,
        agent_we_in     => agent_we_in_0,
        agent_full_out  => agent_full_out_0,
        agent_one_p_out => agent_one_p_out_0,
        
        agent_av_out    => agent_av_out_0,
        agent_comm_out  => agent_comm_out_0,
        agent_data_out  => agent_data_out_0,
        agent_re_in     => agent_re_in_0,
        agent_empty_out => agent_empty_out_0,
        agent_one_d_out => agent_one_d_out_0

        -- synthesis translate_off
        -- pragma translate_off
        ,
        debug_out       => open,
        debug_in        => (others => '0')
        -- pragma translate_on
        -- synthesis translate_on
        );
  end generate a0;


  a1 : if number_of_r4_agents_g > 1 generate
    
    agent_1 : hibi_wrapper_r4
      generic map (
        id_g                => 1,

        id_width_g          => id_width_c,
        addr_width_g        => addr_width_g,
        data_width_g        => data_width_g,
        comm_width_g        => comm_width_g,
        counter_width_g     => counter_width_g,

        rx_fifo_depth_g     => fifo_depths_c(1),
        rx_msg_fifo_depth_g => msg_fifo_depths_c(1),
        tx_fifo_depth_g     => fifo_depths_c(1),
        tx_msg_fifo_depth_g => msg_fifo_depths_c(1),
        addr_g              => addr_c(1),
        addr_limit_g        => addr_c(2)-1,
        prior_g             => 1,

        inv_addr_en_g       => 0,
        max_send_g          => agent_max_send_1_g,
        n_agents_g          => number_of_r4_agents_g + number_of_r3_agents_g,
        n_cfg_pages_g       => 1,
        n_time_slots_g      => 0,
        n_extra_params_g    => 0,

        debug_width_g       => 0
        )
      port map (
        bus_clk        => clk_in,
        agent_clk      => clk_in,
        bus_sync_clk   => clk_in,
        agent_sync_clk => clk_in,
        rst_n          => rst_n_in,

        bus_av_in      => bus_av_in,
        bus_comm_in    => bus_comm_in,
        bus_data_in    => bus_data_in,
        bus_full_in    => bus_full_in,
        bus_lock_in    => bus_lock_in,

        bus_av_out     => bus_av_out_1,
        bus_data_out   => bus_data_out_1,
        bus_comm_out   => bus_comm_out_1,
        bus_full_out   => bus_full_out_1,
        bus_lock_out   => bus_lock_out_1,

        agent_av_in     => agent_av_in_1,
        agent_comm_in   => agent_comm_in_1,
        agent_data_in   => agent_data_in_1,
        agent_we_in     => agent_we_in_1,
        agent_full_out  => agent_full_out_1,
        agent_one_p_out => agent_one_p_out_1,

        agent_av_out    => agent_av_out_1,
        agent_data_out  => agent_data_out_1,
        agent_comm_out  => agent_comm_out_1,
        agent_re_in     => agent_re_in_1,
        agent_empty_out => agent_empty_out_1,
        agent_one_d_out => agent_one_d_out_1
        
        -- synthesis translate_off
        -- pragma translate_off
        ,
        debug_out       => open,
        debug_in        => (others => '0')
        -- pragma translate_on
        -- synthesis translate_on
        );
  end generate a1;

  a2 : if number_of_r4_agents_g > 2 generate
    
    agent_2 : hibi_wrapper_r4
      generic map (
        id_g                => 2,

        id_width_g          => id_width_c,
        addr_width_g        => addr_width_g,
        data_width_g        => data_width_g,
        comm_width_g        => comm_width_g,
        counter_width_g     => counter_width_g,

        rx_fifo_depth_g     => fifo_depths_c(2),
        rx_msg_fifo_depth_g => msg_fifo_depths_c(2),
        tx_fifo_depth_g     => fifo_depths_c(2),
        tx_msg_fifo_depth_g => msg_fifo_depths_c(2),
        addr_g              => addr_c(2),
        addr_limit_g        => addr_c(3)-1,
        prior_g             => 2,

        inv_addr_en_g       => 0,
        max_send_g          => agent_max_send_2_g,
        n_agents_g          => number_of_r4_agents_g + number_of_r3_agents_g,
        n_cfg_pages_g       => 1,
        n_time_slots_g      => 0,
        n_extra_params_g    => 0

        )
      port map (
        bus_clk        => clk_in,
        agent_clk      => clk_in,
        bus_sync_clk   => clk_in,
        agent_sync_clk => clk_in,
        rst_n          => rst_n_in,

        
        bus_av_in      => bus_av_in,
        bus_comm_in    => bus_comm_in,
        bus_data_in    => bus_data_in,
        bus_full_in    => bus_full_in,
        bus_lock_in    => bus_lock_in,

        bus_av_out     => bus_av_out_2,
        bus_data_out   => bus_data_out_2,
        bus_comm_out   => bus_comm_out_2,
        bus_full_out   => bus_full_out_2,
        bus_lock_out   => bus_lock_out_2,

        agent_av_in     => agent_av_in_2,
        agent_data_in   => agent_data_in_2,
        agent_comm_in   => agent_comm_in_2,
        agent_we_in     => agent_we_in_2,
        agent_full_out  => agent_full_out_2,
        agent_one_p_out => agent_one_p_out_2,

        agent_av_out    => agent_av_out_2,
        agent_comm_out  => agent_comm_out_2,
        agent_data_out  => agent_data_out_2,
        agent_re_in     => agent_re_in_2,
        agent_empty_out => agent_empty_out_2,
        agent_one_d_out => agent_one_d_out_2
        -- synthesis translate_off
        -- pragma translate_off
        ,
        debug_out       => open,
        debug_in        => (others => '0')
        -- pragma translate_on
        -- synthesis translate_on
        );
  end generate a2;

  a17 : if number_of_r3_agents_g > 0 generate
    
    agent_16 : hibi_wrapper_r3
      generic map (
        id_g                => 3,

        id_width_g          => id_width_c,
        addr_width_g        => addr_width_g,
        data_width_g        => data_width_g,
        comm_width_g        => comm_width_g,
        counter_width_g     => counter_width_g,
        
        rx_fifo_depth_g     => fifo_depths_c(16),
        rx_msg_fifo_depth_g => msg_fifo_depths_c(16),
        tx_fifo_depth_g     => fifo_depths_c(16),
        tx_msg_fifo_depth_g => msg_fifo_depths_c(16),
        addr_g              => addr_c (15),  
        addr_limit_g        => addr_c (16) -1,
        prior_g             => number_of_r4_agents_g + 1,  -- to prevent empty priority numbers.

        inv_addr_en_g       => 0,
        max_send_g          => agent_max_send_16_g,
        n_agents_g          => number_of_r4_agents_g + number_of_r3_agents_g,
        n_cfg_pages_g       => 1,
        n_time_slots_g      => 0,
        n_extra_params_g    => 0

        )
      port map (
        bus_clk        => clk_in,
        agent_clk      => clk_in,
        bus_sync_clk   => clk_in,
        agent_sync_clk => clk_in,
        rst_n          => rst_n_in,
        
        bus_av_in      => bus_av_in,
        bus_data_in    => bus_data_in,
        bus_comm_in    => bus_comm_in,
        bus_lock_in    => bus_lock_in,
        bus_full_in    => bus_full_in,

        bus_av_out     => bus_av_out_16,
        bus_comm_out   => bus_comm_out_16,
        bus_data_out   => bus_data_out_16,
        bus_lock_out   => bus_lock_out_16,
        bus_full_out   => bus_full_out_16,

        agent_addr_in   => agent_addr_in_16,
        agent_data_in   => agent_data_in_16,
        agent_comm_in   => agent_comm_in_16,
        agent_we_in     => agent_we_in_16,
        agent_full_out  => agent_full_out_16,
        agent_one_p_out => agent_one_p_out_16,

        agent_addr_out  => agent_addr_out_16,
        agent_data_out  => agent_data_out_16,
        agent_comm_out  => agent_comm_out_16,
        agent_re_in     => agent_re_in_16,
        agent_empty_out => agent_empty_out_16,
        agent_one_d_out => agent_one_d_out_16,

        agent_msg_addr_in   => agent_msg_addr_in_16,        
        agent_msg_data_in   => agent_msg_data_in_16,
        agent_msg_comm_in   => agent_msg_comm_in_16,
        agent_msg_we_in     => agent_msg_we_in_16,
        agent_msg_full_out  => agent_msg_full_out_16,
        agent_msg_one_p_out => agent_msg_one_p_out_16,
        
        agent_msg_addr_out  => agent_msg_addr_out_16,
        agent_msg_data_out  => agent_msg_data_out_16,
        agent_msg_comm_out  => agent_msg_comm_out_16,
        agent_msg_re_in     => agent_msg_re_in_16,
        agent_msg_empty_out => agent_msg_empty_out_16,
        agent_msg_one_d_out => agent_msg_one_d_out_16
        );
  end generate a17;

  -- no wrappers
  s0 : if number_of_r4_agents_g < 1 generate
    bus_av_out_0     <= '0';
    bus_data_out_0   <= (others => '0');
    bus_comm_out_0   <= (others => '0');
    bus_lock_out_0   <= '0';
    bus_full_out_0   <= '0';
    
    agent_data_out_0 <= (others => '0');
  end generate s0;

  -- only one wrapper
  s1 : if number_of_r4_agents_g < 2 generate
    bus_av_out_1     <= '0';
    bus_data_out_1   <= (others => '0');
    bus_comm_out_1   <= (others => '0');
    bus_lock_out_1   <= '0';
    bus_full_out_1   <= '0';
    
    agent_data_out_1 <= (others => '0');
  end generate s1;

  s2 : if number_of_r4_agents_g < 3 generate
    bus_av_out_2     <= '0';
    bus_data_out_2   <= (others => '0');
    bus_comm_out_2   <= (others => '0');
    bus_lock_out_2   <= '0';
    bus_full_out_2   <= '0';
    
    agent_data_out_2 <= (others => '0');
  end generate s2;

  s17 : if number_of_r3_agents_g < 1 generate
    bus_av_out_16         <= '0';
    bus_data_out_16       <= (others => '0');
    bus_comm_out_16       <= (others => '0');
    bus_lock_out_16       <= '0';
    bus_full_out_16       <= '0';
    
    agent_msg_data_out_16 <= (others => '0');
  end generate s17;

  -- continuous assignments
  bus_av_in   <= bus_av_out_0   or bus_av_out_1   or bus_av_out_2   or bus_av_out_16;
  bus_data_in <= bus_data_out_0 or bus_data_out_1 or bus_data_out_2 or bus_data_out_16;
  bus_comm_in <= bus_comm_out_0 or bus_comm_out_1 or bus_comm_out_2 or bus_comm_out_16;
  bus_lock_in <= bus_lock_out_0 or bus_lock_out_1 or bus_lock_out_2 or bus_lock_out_16;
  bus_full_in <= bus_full_out_0 or bus_full_out_1 or bus_full_out_2 or bus_full_out_16;

  -- Debug signals OUT
  debug_bus_av_out   <= bus_av_in;
  debug_bus_comm_out <= bus_comm_in;
  debug_bus_full_out <= bus_full_in;

  
end structural;

