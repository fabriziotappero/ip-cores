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
-- useful, but WITHOUT ANY WARRANTY; without even the implied
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
-- PURPOSE.  See the GNU Lesser General Public License for more
-- details.
--
-- You should have received a copy of the GNU Lesser General
-- Public License along with this source; if not, download it
-- from http://www.opencores.org/lgpl.shtml
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- File        : hibi_wrapper_r4.vhdl
-- Description : hibi bus wrapper. 
--               only one tx/rx fifo visible in the interface.
--               mux directs the data to right fifo depending on the command.
--               address is indicated by address valid-signal
-- Author      : Ari Kulmala
-- e-mail      : ari.kulmala@tut.fi
-- Design      : Do not use term design when you mean system
-- Date        : 16.8.2004
-- Modified    : 
-- 04.01.2005 AK Names changed.
-- 
--
-- 28.02.2005   ES cfg_rom_en_g removed, cfg_re and cfg_we added
-- 13.01.2006   AK finished mappings when either of fifos has depth of 0.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity hibi_wrapper_r4 is
generic (
    -- Note: n_   = number of,
    --       lte  = less than or equal,
    --       gte  = greater than or equal 

    -- Structural settings.
    --  All widths are given in bits
    addr_width_g    : integer := 32; -- lte data_width 
    data_width_g    : integer := 32;
    comm_width_g    : integer := 3;  -- practically always 3
    counter_width_g : integer := 7;  -- gte (n_agents, max_send...) 
    debug_width_g  : integer := 0;   -- for special monitors

    --  All FIFO depths are given in words
    --  Allowed values 0,2,3... words.
    --  Prefix msg refers to hi-prior data
    rx_fifo_depth_g     : integer := 5;
    tx_fifo_depth_g     : integer := 5;
    rx_msg_fifo_depth_g : integer := 5;
    tx_msg_fifo_depth_g : integer := 5;
    
    --  Clocking and synchronization
    -- fifo_sel: 0 synch multiclk,         1 basic GALS,
    --           2 Gray FIFO (depth=2^n!), 3 mixed clock pausible
    fifo_sel_g : integer := 0; -- use 0 for synchronous systems
    --  E.g. Synch_multiclk FIFOs must know the ratio of frequencies
    rel_agent_freq_g : integer := 1;
    rel_bus_freq_g   : integer := 1; 


    -- Functional: addressing settings
    addr_g        : integer := 46; -- unique for each wrapper
    inv_addr_en_g : integer := 0;  -- only for bridges
    multicast_en_g : integer := 0; -- enable special addressing
    
    -- Functional: arbitration
    --  arb_type 0 round-robin, 1 priority, 2 combined, 3 DAA.
        --  TDMA is enabled by setting n_time_slots > 0
    --  Ensure that all wrappers in a segment agree on arb_type,
    --  n_agents, and n_slots. Max_send can be wrapper-specific.
    n_agents_g       : integer := 4;  -- within one segment
    prior_g          : integer := 2;  -- lte n_agents
    max_send_g       : integer := 50; -- in words, 0 means unlimited
    n_time_slots_g   : integer := 0;  -- for TDMA
    arb_type_g       : integer := 0;
    keep_slot_g      : integer := 1;  -- for TDMA

    -- Func/Stuctural: (Run-time re)configuration memory
    id_g          : integer := 5;  -- used instead of addr in recfg
    id_width_g    : integer := 4;  -- gte(log2(id_g))
    base_id_g     : integer := 5;  -- only for bridges
    cfg_re_g      : integer := 0;  -- enable reading config
    cfg_we_g      : integer := 0;  -- enable writing config
    n_extra_params_g : integer := 0; -- app-specific registers
    --  Having multiple pages allows fast reconfig
    n_cfg_pages_g : integer := 1
    --  Note that cfg memory initialization is done with separate
    --  package if you have many time slots or configuration pages

    );
  port (
    bus_clk          : in std_logic;
    agent_clk        : in std_logic;
    -- pulsed clocks as used in pausible clock scheme (fifo 3)
    -- IF fifo 1 and fast synch is used, sync clocks is used as the
    -- HIBI synch clock 
    bus_sync_clk     : in std_logic;
    agent_sync_clk   : in std_logic;
    rst_n            : in std_logic;
    bus_comm_in      : in std_logic_vector (comm_width_g-1 downto 0);
    bus_data_in      : in std_logic_vector (data_width_g-1 downto 0);
    bus_full_in      : in std_logic;
    bus_lock_in      : in std_logic;
    bus_av_in        : in std_logic;

    agent_comm_in : in std_logic_vector (comm_width_g-1 downto 0);
    agent_data_in : in std_logic_vector (data_width_g-1 downto 0);
    agent_av_in   : in std_logic;
    agent_we_in   : in std_logic;
    agent_re_in   : in std_logic;

    bus_comm_out : out std_logic_vector (comm_width_g-1 downto 0);
    bus_data_out : out std_logic_vector (data_width_g-1 downto 0);
    bus_full_out : out std_logic;
    bus_lock_out : out std_logic;
    bus_av_out   : out std_logic;

    agent_comm_out  : out std_logic_vector (comm_width_g-1 downto 0);
    agent_data_out  : out std_logic_vector (data_width_g-1 downto 0);
    agent_av_out    : out std_logic;
    agent_full_out  : out std_logic;
    agent_one_p_out : out std_logic;
    agent_empty_out : out std_logic;
    agent_one_d_out : out std_logic
    
    -- synthesis translate_off
    -- pragma translate_off
    ;
    debug_out : out std_logic_vector(debug_width_g-1 downto 0);
    debug_in : in std_logic_vector(debug_width_g-1 downto 0)
    -- pragma translate_on
    -- synthesis translate_on
    );
end hibi_wrapper_r4;




architecture structural of hibi_wrapper_r4 is


  -- structure
  --                           hibi_wrapper_r4
  --              ########################################################
  --              #                                                      #
  -- ip_input  => #  => fifo_demux_wr => hibiv.2  # => bus_output
  --              #            (dw)                  #
  --              #                                                      #
  --              #                                                      #
  -- ip_output <= # <=  fifo_mux_rd <=  hibiv.2   # <= bus_input
  --              #           (mr)                  #
  --              #                                 #
  --              #                                 #
  --              ########################################################
  --
  --
  -- signal names  =>              xxx_mw_dw               xxx_dw_h
  --               <=              xxx_mr_dr               xxx_h_mr
  --               

  -- signals between fifo_demux_wr and hibi wrapper
  signal data_dw_h    : std_logic_vector (data_width_g-1 downto 0);
  signal comm_dw_h    : std_logic_vector (comm_width_g-1 downto 0);
  signal av_dw_h      : std_logic;
  signal we_0_dw_h    : std_logic;
  signal we_1_dw_h    : std_logic;
  signal full_0_h_dw  : std_logic;      --
  signal full_1_h_dw  : std_logic;
  signal one_p_0_h_dw : std_logic;
  signal one_p_1_h_dw : std_logic;

  -- signals between hibi wrapper and fifo_demux_wr
  signal data_0_h_mr  : std_logic_vector (data_width_g-1 downto 0);
  signal comm_0_h_mr  : std_logic_vector (comm_width_g-1 downto 0);
  signal data_1_h_mr  : std_logic_vector (data_width_g-1 downto 0);
  signal comm_1_h_mr  : std_logic_vector (comm_width_g-1 downto 0);
  signal av_0_h_mr    : std_logic;
  signal av_1_h_mr    : std_logic;
  signal re_0_mr_h    : std_logic;
  signal re_1_mr_h    : std_logic;
  signal empty_0_h_mr : std_logic;
  signal empty_1_h_mr : std_logic;
  signal one_d_0_h_mr : std_logic;
  signal one_d_1_h_mr : std_logic;

  -- takes addr and data sequentially and writes them
  -- into one of two fifos depending on command
  component fifo_demux_wr
    generic (
      data_width_g : integer := 0;
      comm_width_g : integer := 0
      );
    port (
      -- 13.04 fully asynchronous!
      data_in    : in  std_logic_vector (data_width_g-1 downto 0);
      av_in      : in  std_logic;
      comm_in    : in  std_logic_vector (comm_width_g-1 downto 0);
      we_in      : in  std_logic;
      one_p_out  : out std_logic;
      full_out   : out std_logic;
      -- data/comm/av conencted to both fifos
      -- distinction made with we!
      data_out   : out std_logic_vector (data_width_g-1 downto 0);
      comm_out   : out std_logic_vector (comm_width_g-1 downto 0);
      av_out     : out std_logic;
      we_0_out   : out std_logic;
      we_1_out   : out std_logic;
      full_0_in  : in  std_logic;
      full_1_in  : in  std_logic;
      one_p_0_in : in  std_logic;
      one_p_1_in : in  std_logic
      );
  end component;  --fifo_demux_wr;

  -- reads to fifos and
  -- writes addr and data sequentially forward depending on command
  component fifo_mux_rd
    generic (
      data_width_g : integer := 0;
      comm_width_g : integer := 0
      );
    port (
      clk   : in std_logic;
      rst_n : in std_logic;

      data_0_in  : in  std_logic_vector (data_width_g-1 downto 0);
      comm_0_in  : in  std_logic_vector (comm_width_g-1 downto 0);
      av_0_in    : in  std_logic;
      one_d_0_in : in  std_logic;
      empty_0_in : in  std_logic;
      re_0_out   : out std_logic;

      data_1_in  : in  std_logic_vector (data_width_g-1 downto 0);
      comm_1_in  : in  std_logic_vector (comm_width_g-1 downto 0);
      av_1_in    : in  std_logic;
      one_d_1_in : in  std_logic;
      empty_1_in : in  std_logic;
      re_1_out   : out std_logic;
      re_in      : in  std_logic;

      data_out  : out std_logic_vector (data_width_g-1 downto 0);
      comm_out  : out std_logic_vector (comm_width_g-1 downto 0);
      av_out    : out std_logic;
      one_d_out : out std_logic;
      empty_out : out std_logic
      );
  end component;  --fifo_mux_rd;
  
begin
  
  hibi_wra : entity work.hibi_wrapper_r1
    --hibi_wra : hibi_wrapper
    generic map(
      id_g      => id_g,
      base_id_g => base_id_g,

      id_width_g      => id_width_g,
      addr_width_g    => addr_width_g,
      data_width_g    => data_width_g,
      comm_width_g    => comm_width_g,
      counter_width_g => counter_width_g,

      rel_bus_freq_g   => rel_bus_freq_g,
      rel_agent_freq_g => rel_agent_freq_g,

      rx_fifo_depth_g     => rx_fifo_depth_g,
      rx_msg_fifo_depth_g => rx_msg_fifo_depth_g,
      tx_fifo_depth_g     => tx_fifo_depth_g,
      tx_msg_fifo_depth_g => tx_msg_fifo_depth_g,

      fifo_sel_g => fifo_sel_g,
      arb_type_g => arb_type_g,

      addr_g        => addr_g,
      prior_g       => prior_g,
      inv_addr_en_g => inv_addr_en_g,

      max_send_g       => max_send_g,
      n_agents_g       => n_agents_g,
      n_cfg_pages_g    => n_cfg_pages_g,
      n_time_slots_g   => n_time_slots_g,
      keep_slot_g      => keep_slot_g,
      n_extra_params_g => n_extra_params_g,
      multicast_en_g   => multicast_en_g,
      cfg_re_g         => cfg_re_g,
      cfg_we_g         => cfg_we_g,
      debug_width_g    => debug_width_g
      )
    port map(
      bus_clk          => bus_clk,
      agent_clk        => agent_clk,
      bus_sync_clk     => bus_sync_clk,
      agent_sync_clk   => agent_sync_clk,
      rst_n            => rst_n,

      bus_comm_in => bus_comm_in,
      bus_data_in => bus_data_in,
      bus_full_in => bus_full_in,
      bus_lock_in => bus_lock_in,
      bus_av_in   => bus_av_in,

      agent_av_in     => av_dw_h,
      agent_data_in   => data_dw_h,
      agent_comm_in   => comm_dw_h,
      agent_we_in     => we_1_dw_h,
      agent_full_out  => full_1_h_dw,
      agent_one_p_out => one_p_1_h_dw,

      agent_msg_av_in     => agent_av_in,
      agent_msg_data_in   => agent_data_in,
      agent_msg_comm_in   => agent_comm_in,
      agent_msg_we_in     => we_0_dw_h,
      agent_msg_full_out  => full_0_h_dw,
      agent_msg_one_p_out => one_p_0_h_dw,

      bus_av_out   => bus_av_out,
      bus_comm_out => bus_comm_out,
      bus_data_out => bus_data_out,
      bus_full_out => bus_full_out,
      bus_lock_out => bus_lock_out,

      agent_av_out    => av_1_h_mr,
      agent_data_out  => data_1_h_mr,
      agent_comm_out  => comm_1_h_mr,
      agent_re_in     => re_1_mr_h,
      agent_empty_out => empty_1_h_mr,
      agent_one_d_out => one_d_1_h_mr,

      agent_msg_av_out    => av_0_h_mr,
      agent_msg_data_out  => data_0_h_mr,
      agent_msg_comm_out  => comm_0_h_mr,
      agent_msg_re_in     => re_0_mr_h,
      agent_msg_empty_out => empty_0_h_mr,
      agent_msg_one_d_out => one_d_0_h_mr

      --synthesis translate_off
      ,
      debug_in => debug_in,
      debug_out => debug_out
      --synthesis translate_on
      );





  -- if-generate added,  04.05.2005 Es
  map_mux_rd : if rx_fifo_depth_g > 0 and rx_msg_fifo_depth_g > 0 generate

    -- reads to fifos and
    -- writes addr and data sequentially forward depending on command
    -- reads data from hibi wrapper.
    mr : fifo_mux_rd
      generic map(
        data_width_g => data_width_g,
        comm_width_g => comm_width_g
        )
      port map(
        clk   => agent_clk,
        rst_n => rst_n,

        av_0_in    => av_0_h_mr,
        data_0_in  => data_0_h_mr,
        comm_0_in  => comm_0_h_mr,
        one_d_0_in => one_d_0_h_mr,
        empty_0_in => empty_0_h_mr,
        re_0_out   => re_0_mr_h,

        av_1_in    => av_1_h_mr,
        data_1_in  => data_1_h_mr,
        comm_1_in  => comm_1_h_mr,
        one_d_1_in => one_d_1_h_mr,
        empty_1_in => empty_1_h_mr,
        re_1_out   => re_1_mr_h,
        re_in      => agent_re_in,

        av_out    => agent_av_out,
        data_out  => agent_data_out,
        comm_out  => agent_comm_out,
        one_d_out => agent_one_d_out,
        empty_out => agent_empty_out
        );

    -- takes addr and data sequentially and writes them
    -- into one of two fifos depending on command
    -- gets data from ip and writes it to hibi wrapper
    dw : fifo_demux_wr
      generic map(
        data_width_g => data_width_g,
        comm_width_g => comm_width_g
        )
      port map(
        -- 13.04 fully asynchronous!
        data_in    => agent_data_in,
        av_in      => agent_av_in,
        comm_in    => agent_comm_in,
        we_in      => agent_we_in,
        one_p_out  => agent_one_p_out,
        full_out   => agent_full_out,
        -- data/comm/av connected to both fifos
        -- distinction made with we!
        av_out     => av_dw_h,
        data_out   => data_dw_h,
        comm_out   => comm_dw_h,
        we_0_out   => we_0_dw_h,
        we_1_out   => we_1_dw_h,
        full_0_in  => full_0_h_dw,
        full_1_in  => full_1_h_dw,
        one_p_0_in => one_p_0_h_dw,
        one_p_1_in => one_p_1_h_dw
        );

  end generate map_mux_rd;

  not_map_fifo_low : if rx_fifo_depth_g = 0 generate

    -- now map the msg fifo signals straight to the output
    agent_av_out    <= av_0_h_mr;
    agent_data_out  <= data_0_h_mr;
    agent_comm_out  <= comm_0_h_mr;
    agent_one_d_out <= one_d_0_h_mr;
    agent_empty_out <= empty_0_h_mr;
    re_0_mr_h       <= agent_re_in;

    agent_full_out  <= full_0_h_dw;
    agent_one_p_out <= one_p_0_h_dw;
    av_dw_h         <= agent_av_in;
    data_dw_h       <= agent_data_in;
    comm_dw_h       <= agent_comm_in;
    we_0_dw_h       <= agent_we_in;

--    agent_av_out    <= av_0_h_mr or av_1_h_mr;
--    agent_data_out  <= data_0_h_mr or data_1_h_mr;
--    agent_comm_out  <= comm_0_h_mr or comm_1_h_mr;
--    agent_one_d_out <= one_d_0_h_mr or one_d_1_h_mr;
--    agent_empty_out <= empty_0_h_mr and empty_1_h_mr;  -- note : AND instead of OR

--    re_1_mr_h <= agent_re_in;

  end generate not_map_fifo_low;


  not_map_fifo_high : if rx_msg_fifo_depth_g = 0 generate

    -- now map the msg fifo signals straight to the output
    agent_av_out    <= av_1_h_mr;
    agent_data_out  <= data_1_h_mr;
    agent_comm_out  <= comm_1_h_mr;
    agent_one_d_out <= one_d_1_h_mr;
    agent_empty_out <= empty_1_h_mr;
    re_1_mr_h       <= agent_re_in;

    agent_full_out  <= full_1_h_dw;
    agent_one_p_out <= one_p_1_h_dw;
    av_dw_h         <= agent_av_in;
    data_dw_h       <= agent_data_in;
    comm_dw_h       <= agent_comm_in;
    we_1_dw_h       <= agent_we_in;
    
  end generate not_map_fifo_high;
  
end structural;
