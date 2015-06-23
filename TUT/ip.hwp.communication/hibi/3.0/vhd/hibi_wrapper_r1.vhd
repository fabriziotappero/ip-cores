-------------------------------------------------------------------------------
-- File        : hibi_wrapper.vhdl
-- Description : A wrapper component to interconnect resources in
--               System-on-chips.
--               Interface revision r1 is the 'base' for all HIBI wrappers:
--                - separate IP interface for regular and hi-prior data
--                - IP writes/gets addr and data sequentially
--               Implementation can be chosen with generics.
-- Author      : Erno Salminen
-- Project     : Nocbench &  Funbase
-- Design      : 
-- Date        : 01.04.2011 (nased on HIBI v.2)
-- Modified    : 
--
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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.hibiv3_pkg.all;



entity hibi_wrapper_r1 is
  generic (
    -- Note: n_   = number of,
    --       lte  = less than or equal,
    --       gte  = greater than or equal 

    -- Structural settings.
    --  All widths are given in bits
    addr_width_g    : integer;
    data_width_g    : integer;
    comm_width_g    : integer;
    counter_width_g : integer;          -- gte (n_agents, max_send...) 
    debug_width_g   : integer := 0;     -- for special monitors

    --  All FIFO depths are given in words
    --  Allowed values 0,2,3... words.
    --  Prefix msg refers to hi-prior data
    rx_fifo_depth_g     : integer := 5;
    tx_fifo_depth_g     : integer := 5;
    rx_msg_fifo_depth_g : integer := 5;
    tx_msg_fifo_depth_g : integer := 5;

    --  Clocking and synchronization
    -- fifo_sel: 0 synch multiclk,        1 basic GALS,
    --           2 Gray FIFO (depth=2^n), 3 mixed clock pausible
    fifo_sel_g       : integer := 0;    -- use 0 for synchronous systems
    --  E.g. Synch_multiclk FIFOs must know the ratio of frequencies
    rel_agent_freq_g : integer := 1;
    rel_bus_freq_g   : integer := 1;


    -- Functional: addressing settings
    addr_g        : integer := 46;      -- unique for each wrapper
    inv_addr_en_g : integer := 0;       -- only for bridges


    -- Functional: arbitration
    --  arb_type=0 round-robin, 1 priority, 2 combined, 3 DAA.
    --  TDMA is enabled by setting n_time_slots > 0
    --  Ensure that all wrappers in a segment agree on arb_type,
    --  n_agents, and n_slots. Max_send can be wrapper-specific.
    arb_type_g     : integer := 0;      -- select 0-3
    n_agents_g     : integer := 4;      -- within one segment
    prior_g        : integer := 2;      -- lte n_agents
    max_send_g     : integer := 50;     -- in words, 0 means unlimited
    n_time_slots_g : integer := 0;      -- for TDMA
    keep_slot_g    : integer := 1;      -- for TDMA

    -- Func/Stuctural: (Run-time re)configuration memory
    id_g             : integer := 5;    -- used instead of addr in recfg
    id_width_g       : integer := 4;    -- gte(log2(id_g))
    cfg_re_g         : integer := 0;    -- enable reading config
    cfg_we_g         : integer := 0;    -- enable writing config
    n_extra_params_g : integer := 0;    -- app-specific registers
    n_cfg_pages_g    : integer := 1;    -- multiple pages allows fast reconfig
    --  Note that cfg memory initialization is done with separate
    --  package if you have many time slots or configuration pages


    -- NEW for HIBI v.3
    id_min_g        : integer := 0;  -- Only for bridges+cfg, zero for others!
    id_max_g        : integer := 0;  -- Only for bridges+cfg, zero for others!
    addr_limit_g    : integer := 0;     -- Uppermost addr of a wrapper/bridge
    separate_addr_g : integer := 0      -- Transmits addr in parallel with data

    );

  port (
    bus_clk        : in std_logic;
    agent_clk      : in std_logic;
    -- pulsed clocks as used in pausible clock scheme
    -- IF fifo 1 and fast synch is used, sync clocks is used as the
    -- HIBI synch clock
    bus_sync_clk   : in std_logic;
    agent_sync_clk : in std_logic;
    rst_n          : in std_logic;

    bus_av_in   : in std_logic;
    bus_data_in : in std_logic_vector (data_width_g-1 downto 0);
    bus_comm_in : in std_logic_vector (comm_width_g-1 downto 0);
    bus_full_in : in std_logic;
    bus_lock_in : in std_logic;

    agent_av_in     : in  std_logic;
    agent_data_in   : in  std_logic_vector (data_width_g-1 downto 0);
    agent_comm_in   : in  std_logic_vector (comm_width_g-1 downto 0);
    agent_we_in     : in  std_logic;
    agent_full_out  : out std_logic;
    agent_one_p_out : out std_logic;

    agent_msg_av_in   : in std_logic;
    agent_msg_data_in : in std_logic_vector (data_width_g-1 downto 0);
    agent_msg_comm_in : in std_logic_vector (comm_width_g-1 downto 0);
    agent_msg_we_in   : in std_logic;
    agent_msg_re_in   : in std_logic;

    bus_av_out   : out std_logic;
    bus_data_out : out std_logic_vector (data_width_g-1 downto 0);
    bus_comm_out : out std_logic_vector (comm_width_g-1 downto 0);
    bus_lock_out : out std_logic;
    bus_full_out : out std_logic;

    agent_av_out    : out std_logic;
    agent_data_out  : out std_logic_vector (data_width_g-1 downto 0);
    agent_comm_out  : out std_logic_vector (comm_width_g-1 downto 0);
    agent_empty_out : out std_logic;
    agent_one_d_out : out std_logic;
    agent_re_in     : in  std_logic;


    agent_msg_av_out    : out std_logic;
    agent_msg_data_out  : out std_logic_vector (data_width_g-1 downto 0);
    agent_msg_comm_out  : out std_logic_vector (comm_width_g-1 downto 0);
    agent_msg_empty_out : out std_logic;
    agent_msg_one_d_out : out std_logic;
    agent_msg_full_out  : out std_logic;
    agent_msg_one_p_out : out std_logic

    -- synthesis translate_off 
;
    debug_out : out std_logic_vector(debug_width_g-1 downto 0);
    debug_in  : in  std_logic_vector(debug_width_g-1 downto 0)
    -- synthesis translate_on

    );
end hibi_wrapper_r1;




architecture structural of hibi_wrapper_r1 is

  -- Structure
  -- 1. Control logic for both transmitting (tx) and receiving (rx).
  -- 2. FIFOs for tx and rx. Actually, there can be 2 FIFOs in each direction:
  --    for regular and high-priority data.
  -- IP connects to the FIFOS.
  -- Controllers are between FIFOs and the bus. Controllers are connected
  -- together for configuring and reading the config.

  component transmitter is
    generic (
      id_g             : integer;
      addr_g           : integer;
      id_width_g       : integer;
      data_width_g     : integer;
      addr_width_g     : integer;
      comm_width_g     : integer;
      counter_width_g  : integer;
      cfg_addr_width_g : integer;
      prior_g          : integer;
      inv_addr_en_g    : integer;
      max_send_g       : integer;
      arb_type_g       : integer;
      n_agents_g       : integer;
      n_cfg_pages_g    : integer;
      n_time_slots_g   : integer;
      keep_slot_g      : integer;
      n_extra_params_g : integer;
      cfg_we_g         : integer;
      cfg_re_g         : integer;
      separate_addr_g  : integer;
      debug_width_g    : integer);
    port (
      clk             : in  std_logic;
      rst_n           : in  std_logic;
      lock_in         : in  std_logic;
      full_in         : in  std_logic;
      cfg_data_in     : in  std_logic_vector
      (data_width_g-1-(separate_addr_g*addr_width_g) downto 0);
      cfg_addr_in     : in  std_logic_vector(cfg_addr_width_g -1 downto 0);
      cfg_ret_addr_in : in  std_logic_vector(addr_width_g -1 downto 0);
      cfg_re_in       : in  std_logic;
      cfg_we_in       : in  std_logic;
      av_in           : in  std_logic;
      data_in         : in  std_logic_vector(data_width_g-1 downto 0);
      comm_in         : in  std_logic_vector(comm_width_g-1 downto 0);
      empty_in        : in  std_logic;
      one_d_in        : in  std_logic;
      av_out          : out std_logic;
      data_out        : out std_logic_vector(data_width_g-1 downto 0);
      comm_out        : out std_logic_vector(comm_width_g-1 downto 0);
      lock_out        : out std_logic;
      cfg_rd_rdy_out  : out std_logic;
      re_out          : out std_logic
      -- synthesis translate_off
;
      debug_out       : out std_logic_vector(debug_width_g-1 downto 0);
      debug_in        : in  std_logic_vector(debug_width_g-1 downto 0)
      -- synthesis translate_on
      );
  end component transmitter;


  component double_fifo_mux_rd
    generic (
      fifo_sel_g      : integer;
      re_freq_g       : integer;
      we_freq_g       : integer;
      depth_0_g       : integer;
      depth_1_g       : integer;
      data_width_g    : integer;
      debug_width_g   : integer;
      comm_width_g    : integer;
      separate_addr_g : integer
      );
    port (
      clk_re     : in std_logic;
      clk_we     : in std_logic;
      clk_re_pls : in std_logic;
      clk_we_pls : in std_logic;
      rst_n      : in std_logic;

      av_0_in     : in  std_logic;
      data_0_in   : in  std_logic_vector (data_width_g-1 downto 0);
      comm_0_in   : in  std_logic_vector (comm_width_g-1 downto 0);
      we_0_in     : in  std_logic;
      one_p_0_out : out std_logic;
      full_0_out  : out std_logic;

      av_1_in     : in  std_logic;
      data_1_in   : in  std_logic_vector (data_width_g-1 downto 0);
      comm_1_in   : in  std_logic_vector (comm_width_g-1 downto 0);
      we_1_in     : in  std_logic;
      full_1_out  : out std_logic;
      one_p_1_out : out std_logic;

      re_in     : in  std_logic;
      av_out    : out std_logic;
      data_out  : out std_logic_vector (data_width_g-1 downto 0);
      comm_out  : out std_logic_vector (comm_width_g-1 downto 0);
      empty_out : out std_logic;
      one_d_out : out std_logic;
      debug_out : out std_logic_vector(debug_width_g downto 0)
      );
  end component double_fifo_mux_rd;



  component receiver
    generic (
      id_g             : integer;
      id_min_g         : integer := 0;  -- Only for bridges, zero for others!
      id_max_g         : integer := 0;  -- Only for bridges, zero for others!
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
      clk           : in std_logic;
      rst_n         : in std_logic;
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

      bus_full_in      : in  std_logic;
      cfg_we_out       : out std_logic;
      cfg_re_out       : out std_logic;
      cfg_data_out     : out std_logic_vector
      (data_width_g-1-(separate_addr_g*addr_width_g) downto 0);
      cfg_addr_out     : out std_logic_vector(cfg_addr_width_g -1 downto 0);
      cfg_ret_addr_out : out std_logic_vector(addr_width_g -1 downto 0);
      full_out         : out std_logic
      );
  end component receiver;



  component double_fifo_demux_wr
    generic (
      fifo_sel_g    : integer;
      re_freq_g     : integer;
      we_freq_g     : integer;
      depth_0_g     : integer;
      depth_1_g     : integer;
      data_width_g  : integer;
      debug_width_g : integer;
      comm_width_g  : integer
      );
    port (
      clk_re     : in std_logic;
      clk_we     : in std_logic;
      clk_re_pls : in std_logic;
      clk_we_pls : in std_logic;
      rst_n      : in std_logic;

      av_0_in     : in  std_logic;
      data_0_in   : in  std_logic_vector (data_width_g-1 downto 0);
      comm_0_in   : in  std_logic_vector (comm_width_g-1 downto 0);
      we_0_in     : in  std_logic;
      one_p_0_out : out std_logic;
      full_0_out  : out std_logic;

      av_1_in     : in  std_logic;
      data_1_in   : in  std_logic_vector (data_width_g-1 downto 0);
      comm_1_in   : in  std_logic_vector (comm_width_g-1 downto 0);
      we_1_in     : in  std_logic;
      one_p_1_out : out std_logic;
      full_1_out  : out std_logic;

      re_0_in     : in  std_logic;
      av_0_out    : out std_logic;
      data_0_out  : out std_logic_vector (data_width_g-1 downto 0);
      comm_0_out  : out std_logic_vector (comm_width_g-1 downto 0);
      empty_0_out : out std_logic;
      one_d_0_out : out std_logic;

      re_1_in     : in  std_logic;
      av_1_out    : out std_logic;
      data_1_out  : out std_logic_vector (data_width_g-1 downto 0);
      comm_1_out  : out std_logic_vector (comm_width_g-1 downto 0);
      empty_1_out : out std_logic;
      one_d_1_out : out std_logic;
      debug_out   : out std_logic_vector(debug_width_g downto 0)
      );
  end component double_fifo_demux_wr;


  -- Calculate minimum of 1 and "value"
  -- Required for reserving signals for tslots ans extra_params
  -- (Design compiler does not handle empty arrays (e.g. 0 downto -1),
  -- Precision handles them well)
  function max_with_1 (
    constant value : integer)    return integer  is
  begin  -- max_with_1
    if value = 0 then
      return 1;
    else
      return value;
    end if;
  end max_with_1;

  function log2 (
    constant value : integer)    return integer is

    variable temp    : integer := 1;
    variable counter : integer := 0;
  begin  -- log2
    temp    := 1;
    counter := 0;
    for i in 0 to 31 loop
      if temp < value then
        temp    := temp*2;
        counter := counter+1;
      end if;
    end loop;

    return counter;
  end log2;


  -- Calculate the maximum size of configuration
  -- memory page. There are 8 parameters and  address,
  -- each time slots requires 3 parameters (start, stop, owner),
  -- and there may be some application specific extra parameters as well.

  -- E.g. if n_time_slots_g = n_extra_params_g=1
  -- then page_size_c= (8+1)+(1*3)+1= 13 parameters
  constant n_time_slots_tmp_c   : integer := max_with_1 (n_time_slots_g);
  constant n_extra_params_tmp_c : integer := max_with_1 (n_extra_params_g);

  constant page_size_c : integer := 8 + 1 + (n_time_slots_tmp_c * 3)
                                    + n_extra_params_tmp_c;

  constant page_addr_width_c  : integer := log2 (page_size_c);
  constant param_addr_width_c : integer := log2 (n_cfg_pages_g) +1;
  constant cfg_addr_width_c   : integer := param_addr_width_c
                                           + page_addr_width_c;

  -- These dbg signals can be viewed from Modelsim to check above
  -- calculations manually
  signal pag   : integer := page_addr_width_c;
  signal par   : integer := param_addr_width_c;
  signal cfg_a : integer := cfg_addr_width_c;


  -- Signals (Conf. mem => ) Transmitter => Receiver
  -- signal cfg_rom_en_tx_rx : std_logic;
  -- signal id_tx_rx         : std_logic_vector ( id_width_g-1 downto 0);
  -- signal base_id_tx_rx    : std_logic_vector ( id_width_g -1 downto 0);
  -- signal base_addr_tx_rx  : std_logic_vector ( addr_width_g -1 downto 0);

  -- Tx-fifo => Tx
  signal av_fifo_tx    : std_logic;
  signal data_fifo_tx  : std_logic_vector (data_width_g-1 downto 0);
  signal comm_fifo_tx  : std_logic_vector (comm_width_g-1 downto 0);
  signal re_tx_fifo    : std_logic;
  signal empty_fifo_tx : std_logic;
  signal one_d_fifo_tx : std_logic;

  -- Rx => Rx-fifo
  signal av_0_rx_fifo    : std_logic;
  signal data_0_rx_fifo  : std_logic_vector (data_width_g-1 downto 0);
  signal comm_0_rx_fifo  : std_logic_vector (comm_width_g-1 downto 0);
  signal we_0_rx_fifo    : std_logic;
  signal full_0_fifo_rx  : std_logic;
  signal one_0_p_fifo_rx : std_logic;

  signal av_1_rx_fifo    : std_logic;
  signal data_1_rx_fifo  : std_logic_vector (data_width_g-1 downto 0);
  signal comm_1_rx_fifo  : std_logic_vector (comm_width_g-1 downto 0);
  signal we_1_rx_fifo    : std_logic;
  signal full_1_fifo_rx  : std_logic;
  signal one_1_p_fifo_rx : std_logic;

  -- Tx => Rx
  signal cfg_rd_rdy_tx_rx : std_logic;

  -- Signals Receiver => Transmitter
  signal cfg_addr_rx_tx : std_logic_vector(cfg_addr_width_c -1 downto 0);
  signal cfg_data_rx_tx :
    std_logic_vector (data_width_g-1-(separate_addr_g*addr_width_g) downto 0);
  signal cfg_ret_addr_rx_tx : std_logic_vector(addr_width_g -1 downto 0);
  signal cfg_re_rx_tx       : std_logic;
  signal cfg_we_rx_tx       : std_logic;
  
  
begin  -- structural_muxed_tx_fifos

  --
  -- Transmission from IP to bus
  --

  tx_unit : transmitter
    -- tx_unit : entity work.transmitter
    generic map(
      data_width_g    => data_width_g,
      addr_width_g    => addr_width_g,
      comm_width_g    => comm_width_g,
      counter_width_g => counter_width_g,

      id_g       => id_g,
      id_width_g => id_width_g,

      addr_g        => addr_g,
      prior_g       => prior_g,
      inv_addr_en_g => inv_addr_en_g,
      max_send_g    => max_send_g,

      cfg_addr_width_g => cfg_addr_width_c,
      -- page_addr_width_g  => page_addr_width_g,
      -- param_addr_width_g => param_addr_width_g,

      arb_type_g       => arb_type_g,
      n_agents_g       => n_agents_g,
      n_cfg_pages_g    => n_cfg_pages_g,
      n_time_slots_g   => n_time_slots_g,
      keep_slot_g      => keep_slot_g,
      n_extra_params_g => n_extra_params_g,
      cfg_re_g         => cfg_re_g,
      cfg_we_g         => cfg_we_g,
      separate_addr_g  => separate_addr_g,
      debug_width_g    => debug_width_g
      )
    port map(
      clk   => bus_clk,
      rst_n => rst_n,

      -- from bus
      lock_in => bus_lock_in,
      full_in => bus_full_in,

      -- from rx
      cfg_data_in     => cfg_data_rx_tx,
      cfg_addr_in     => cfg_addr_rx_tx,
      cfg_ret_addr_in => cfg_ret_addr_rx_tx,
      cfg_re_in       => cfg_re_rx_tx,
      cfg_we_in       => cfg_we_rx_tx,

      -- from fifo
      av_in    => av_fifo_tx,
      data_in  => data_fifo_tx,
      comm_in  => comm_fifo_tx,
      empty_in => empty_fifo_tx,
      one_d_in => one_d_fifo_tx,

      --  to bus
      data_out => bus_data_out,
      comm_out => bus_comm_out,
      av_out   => bus_av_out,
      lock_out => bus_lock_out,

      -- to rx
      cfg_rd_rdy_out => cfg_rd_rdy_tx_rx,
      --id_out          => id_tx_rx,
      --base_id_out     => base_id_tx_rx,
      --base_addr_out   => base_addr_tx_rx,
      --inv_addr_en_out => cfg_rom_en_tx_rx,

      -- to fifo
      re_out => re_tx_fifo

      -- synthesis translate_off
      -- pragma synthesis_off
      -- pragma translate_off
      ,
      debug_in  => debug_in,
      debug_out => debug_out
      -- pragma translate_on
      -- pragma synthesis_on
      -- synthesis translate_on
      );



  
  tx_fifo_mux : double_fifo_mux_rd
    generic map(
      fifo_sel_g      => fifo_sel_g,
      re_freq_g       => rel_bus_freq_g,
      we_freq_g       => rel_agent_freq_g,
      depth_0_g       => tx_msg_fifo_depth_g,
      depth_1_g       => tx_fifo_depth_g,
      data_width_g    => data_width_g,
      debug_width_g   => 0,
      comm_width_g    => comm_width_g,
      separate_addr_g => separate_addr_g
      )
    port map(
      -- re bus side, we agent side
      clk_re     => bus_clk,
      clk_we     => agent_clk,
      clk_re_pls => bus_sync_clk,
      clk_we_pls => agent_sync_clk,
      rst_n      => rst_n,

      av_0_in     => agent_msg_av_in,
      data_0_in   => agent_msg_data_in,
      comm_0_in   => agent_msg_comm_in,
      we_0_in     => agent_msg_we_in,
      one_p_0_out => agent_msg_one_p_out,
      full_0_out  => agent_msg_full_out,

      data_1_in   => agent_data_in,
      comm_1_in   => agent_comm_in,
      av_1_in     => agent_av_in,
      we_1_in     => agent_we_in,
      one_p_1_out => agent_one_p_out,
      full_1_out  => agent_full_out,

      re_in     => re_tx_fifo,
      data_out  => data_fifo_tx,
      comm_out  => comm_fifo_tx,
      av_out    => av_fifo_tx,
      empty_out => empty_fifo_tx,
      one_d_out => one_d_fifo_tx
      );


  --
  -- Reception: from bus to IP
  --

  rx_unit : receiver
    -- rx_unit : entity work.receiver
    generic map(
      id_g             => id_g,
      id_min_g         => id_min_g,
      id_max_g         => id_max_g,
      id_width_g       => id_width_g,
      addr_base_g      => addr_g,
      addr_limit_g     => addr_limit_g,
      data_width_g     => data_width_g,
      addr_width_g     => addr_width_g,
      cfg_addr_width_g => cfg_addr_width_c,
      cfg_re_g         => cfg_re_g,
      cfg_we_g         => cfg_we_g,
      inv_addr_en_g    => inv_addr_en_g,
      separate_addr_g  => separate_addr_g
      )
    port map(
      clk   => bus_clk,
      rst_n => rst_n,

      av_in         => bus_av_in,
      data_in       => bus_data_in,
      comm_in       => bus_comm_in,
      cfg_rd_rdy_in => cfg_rd_rdy_tx_rx,

      --id_in          => id_tx_rx,
      --base_addr_in   => base_addr_tx_rx,
      --inv_addr_en_in => cfg_rom_en_tx_rx,

      av_0_out   => av_0_rx_fifo,
      data_0_out => data_0_rx_fifo,
      comm_0_out => comm_0_rx_fifo,
      we_0_out   => we_0_rx_fifo,
      full_0_in  => full_0_fifo_rx,
      one_p_0_in => one_0_p_fifo_rx,

      av_1_out   => av_1_rx_fifo,
      data_1_out => data_1_rx_fifo,
      comm_1_out => comm_1_rx_fifo,
      we_1_out   => we_1_rx_fifo,
      full_1_in  => full_1_fifo_rx,
      one_p_1_in => one_1_p_fifo_rx,

      bus_full_in      => bus_full_in,
      cfg_addr_out     => cfg_addr_rx_tx,
      cfg_data_out     => cfg_data_rx_tx,
      cfg_ret_addr_out => cfg_ret_addr_rx_tx,
      cfg_we_out       => cfg_we_rx_tx,
      cfg_re_out       => cfg_re_rx_tx,
      full_out         => bus_full_out
      );


  
  rx_fifo_mux : double_fifo_demux_wr
    generic map(
      fifo_sel_g    => fifo_sel_g,
      re_freq_g     => rel_agent_freq_g,
      we_freq_g     => rel_bus_freq_g,
      depth_0_g     => rx_msg_fifo_depth_g,
      depth_1_g     => rx_fifo_depth_g,
      data_width_g  => data_width_g,
      debug_width_g => 0,
      comm_width_g  => comm_width_g
      )
    port map(
      -- re is handled by agent side, we by bus side
      clk_re     => agent_clk,
      clk_we     => bus_clk,
      clk_re_pls => agent_sync_clk,
      clk_we_pls => bus_sync_clk,
      rst_n      => rst_n,

      av_0_in     => av_0_rx_fifo,
      data_0_in   => data_0_rx_fifo,
      comm_0_in   => comm_0_rx_fifo,
      we_0_in     => we_0_rx_fifo,
      full_0_out  => full_0_fifo_rx,
      one_p_0_out => one_0_p_fifo_rx,

      av_1_in     => av_1_rx_fifo,
      data_1_in   => data_1_rx_fifo,
      comm_1_in   => comm_1_rx_fifo,
      we_1_in     => we_1_rx_fifo,
      full_1_out  => full_1_fifo_rx,
      one_p_1_out => one_1_p_fifo_rx,

      re_0_in     => agent_msg_re_in,
      av_0_out    => agent_msg_av_out,
      data_0_out  => agent_msg_data_out,
      comm_0_out  => agent_msg_comm_out,
      empty_0_out => agent_msg_empty_out,
      one_d_0_out => agent_msg_one_d_out,

      re_1_in     => agent_re_in,
      av_1_out    => agent_av_out,
      data_1_out  => agent_data_out,
      comm_1_out  => agent_comm_out,
      empty_1_out => agent_empty_out,
      one_d_1_out => agent_one_d_out
      );





end structural;
