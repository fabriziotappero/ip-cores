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
-- File        : hibi_wrapper_r3.vhdl
-- Description : HIBI bus wrapper. 
--               Implementation can be chosen with generics
--               This is revision 3!
--                => r3 means that the IP interface uses 
--                   separate addr and data lines
--                   and separate data and message interfaces
--
--               NOTE! one_d_out and one_p_out do not work fully as expected,
--               since they're straight from the FIFO and full and empty are
--               formed in another blocks (addr_data_mux_write etc).
--               I suggest that they're removed from the interface.
-- Author      : Erno Salminen
-- e-mail      : erno.salminen@tut.fi
-- Design      : Do not use term design when you mean system
-- Date        : 28.10.2004
-- Modified    : 
--
-- 15.12.04     ES names changed
-- 28.02.2005   ES cfg_rom_en_g removed, cfg_re and cfg_we added
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity hibi_wrapper_r3 is

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
    bus_clk        : in std_logic;
    agent_clk      : in std_logic;
    -- pulsed clocks. used in pausible clock scheme
    bus_sync_clk   : in std_logic;
    agent_sync_clk : in std_logic;

    rst_n       : in std_logic;
    bus_comm_in : in std_logic_vector (comm_width_g-1 downto 0);
    bus_data_in : in std_logic_vector (data_width_g-1 downto 0);
    bus_full_in : in std_logic;
    bus_Lock_in : in std_logic;
    bus_av_in   : in std_logic;

    bus_comm_out : out std_logic_vector (comm_width_g-1 downto 0);
    bus_data_out : out std_logic_vector (data_width_g-1 downto 0);
    bus_full_out : out std_logic;
    bus_Lock_out : out std_logic;
    bus_av_out   : out std_logic;

    agent_comm_in   : in  std_logic_vector (comm_width_g-1 downto 0);
    agent_data_in   : in  std_logic_vector (data_width_g-1 downto 0);
    agent_addr_in   : in  std_logic_vector (data_width_g-1 downto 0);
    agent_we_in     : in  std_logic;
    agent_re_in     : in  std_logic;

    agent_addr_out  : out std_logic_vector (data_width_g-1 downto 0);
    agent_data_out  : out std_logic_vector (data_width_g-1 downto 0);
    agent_comm_out  : out std_logic_vector (comm_width_g-1 downto 0);
    agent_empty_out : out std_logic;
    agent_full_out  : out std_logic;
    agent_one_p_out : out std_logic;
    agent_one_d_out : out std_logic;    -- is this used??
    
    agent_msg_addr_in   : in  std_logic_vector (data_width_g-1 downto 0);
    agent_msg_data_in   : in  std_logic_vector (data_width_g-1 downto 0);
    agent_msg_comm_in   : in  std_logic_vector (comm_width_g-1 downto 0);
    agent_msg_we_in     : in  std_logic;
    agent_msg_re_in     : in  std_logic;
    
    agent_msg_full_out  : out std_logic;
    agent_msg_one_p_out : out std_logic;
    agent_msg_addr_out  : out std_logic_vector (data_width_g-1 downto 0);
    agent_msg_data_out  : out std_logic_vector (data_width_g-1 downto 0);
    agent_msg_comm_out  : out std_logic_vector (comm_width_g-1 downto 0);
    agent_msg_empty_out : out std_logic;
    agent_msg_one_d_out : out std_logic  -- is this used??
    -- synthesis translate_off 
    ;

    debug_out : out std_logic_vector(debug_width_g-1 downto 0);
    debug_in : in std_logic_vector(debug_width_g-1 downto 0)
    -- synthesis translate_on    
    );
end hibi_wrapper_r3;




architecture structural_ultimate of hibi_wrapper_r3 is


  -- structure
  --                           hibi_wrapper_r3
  --         ##########################################################
  --         #                                 #             #
  --      in_input                             #          bus_output
  --         #                                 #             #
  -- ip      => 2x addr_data_mux_write        ==> hibiv.2    =>  bus
  --         =>          (mw, mmw)            ==>            #
  --         #                                 #             #
  --         #                                 #             #
  --     ip_output                             #         bus_input
  --         #                                 #             #
  -- ip     <= 2x addr_data_demux_read        <==  hibiv.2  <=   bus
  --        <=        (dr, mdr)               <==            #
  --         #                                 #             #
  --         ##########################################################
  --
  --
  -- signal names  =>              XXX_mw_h, XXX_mmw_h              
  --               <=              XXX_h_mr, XXX_h_mmr
  --               



  -- Signals between addr_data_mux_write and hibi
  signal av_mw_h    : std_logic;
  signal data_mw_h  : std_logic_vector (data_width_g-1 downto 0);
  signal comm_mw_h  : std_logic_vector (comm_width_g-1 downto 0);
  signal we_mw_h    : std_logic;
  signal full_h_mw  : std_logic;
  signal one_p_h_mw : std_logic;

  signal av_mmw_h    : std_logic;
  signal data_mmw_h  : std_logic_vector (data_width_g-1 downto 0);
  signal comm_mmw_h  : std_logic_vector (comm_width_g-1 downto 0);
  signal we_mmw_h    : std_logic;
  signal full_h_mmw  : std_logic;
  signal one_p_h_mmw : std_logic;


  -- Signals between fifo_mux_read and addr_data_demux_read 
  signal av_h_dr    : std_logic;
  signal data_h_dr  : std_logic_vector (data_width_g-1 downto 0);
  signal comm_h_dr  : std_logic_vector (comm_width_g-1 downto 0);
  signal re_dr_h    : std_logic;
  signal empty_h_dr : std_logic;
  signal one_d_h_dr : std_logic;

  signal av_h_mdr    : std_logic;
  signal data_h_mdr  : std_logic_vector (data_width_g-1 downto 0);
  signal comm_h_mdr  : std_logic_vector (comm_width_g-1 downto 0);
  signal re_mdr_h    : std_logic;
  signal empty_h_mdr : std_logic;
  signal one_d_h_mdr : std_logic;


  -- Takes addr and data in parallel and muxes them into one signal
  -- This way the IP's designed for Hibi v1 can used with Hibi v2
  component addr_data_mux_write
    generic (
      data_width_g : integer := 0;
      addr_width_g : integer := 0;
      comm_width_g : integer := 0
      );
    port (
      clk   : in std_logic;
      rst_n : in std_logic;

      data_in   : in  std_logic_vector (data_width_g-1 downto 0);
      addr_in   : in  std_logic_vector (addr_width_g-1 downto 0);
      comm_in   : in  std_logic_vector (comm_width_g-1 downto 0);
      we_in     : in  std_logic;
      full_out  : out std_logic;
      one_p_out : out std_logic;

      av_out   : out std_logic;
      data_out : out std_logic_vector (data_width_g-1 downto 0);
      comm_out : out std_logic_vector (comm_width_g-1 downto 0);
      we_out   : out std_logic;
      full_in  : in  std_logic;
      one_p_in : in  std_logic
      );
  end component;  --addr_data_mux_write;

  -- Takes addr and data separately and puts them into separate signals
  -- This way the IP's designed for Hibi v1 can used with Hibi v2
  component addr_data_demux_read
    generic (
      data_width_g : integer := 0;
      addr_width_g : integer := 0;
      comm_width_g : integer := 0
      );
    port (
      clk   : in std_logic;
      rst_n : in std_logic;

      re_out   : out std_logic;
      av_in    : in  std_logic;
      data_in  : in  std_logic_vector (data_width_g-1 downto 0);
      comm_in  : in  std_logic_vector (comm_width_g-1 downto 0);
      empty_in : in  std_logic;
      --one_d_in  : in  std_logic;

      re_in     : in  std_logic;
      addr_out  : out std_logic_vector (addr_width_g-1 downto 0);
      data_out  : out std_logic_vector (data_width_g-1 downto 0);
      comm_out  : out std_logic_vector (comm_width_g-1 downto 0);
      empty_out : out std_logic
      --one_d_out : out std_logic
      );
  end component;  --addr_data_demux_read;


  
begin

  hibi_wra : entity work.hibi_wrapper_r1
    generic map(
      id_g      => id_g,
      base_id_g => base_id_g,

      id_width_g      => id_width_g,
      addr_width_g    => addr_width_g,  -- in bits!
      data_width_g    => data_width_g,
      comm_width_g    => comm_width_g,
      counter_width_g => counter_width_g,

      rel_agent_freq_g => rel_agent_freq_g,
      rel_bus_freq_g   => rel_bus_freq_g,

      rx_fifo_depth_g     => rx_fifo_depth_g,
      rx_msg_fifo_depth_g => rx_msg_fifo_depth_g,
      tx_fifo_depth_g     => tx_fifo_depth_g,
      tx_msg_fifo_depth_g => tx_msg_fifo_depth_g,

      arb_type_g    => arb_type_g,
      fifo_sel_g    => fifo_sel_g,
      
      addr_g        => addr_g,
      prior_g       => prior_g,
      inv_addr_en_g => inv_addr_en_g,

      max_send_g       => max_send_g,
      n_agents_g       => n_agents_g,
      n_cfg_pages_g    => n_cfg_pages_g,
      n_time_slots_g   => n_time_slots_g,
      n_extra_params_g => n_extra_params_g,
      multicast_en_g   => multicast_en_g,
      cfg_re_g         => cfg_re_g,
      cfg_we_g         => cfg_we_g,
      debug_width_g => debug_width_g

      )
    port map(
      bus_clk        => bus_clk,
      agent_clk      => agent_clk,
      bus_sync_clk   => bus_sync_clk,
      agent_sync_clk => agent_sync_clk,
      rst_n          => rst_n,

      bus_av_in   => bus_av_in,
      bus_data_in => bus_data_in,
      bus_comm_in => bus_comm_in,
      bus_full_in => bus_full_in,
      bus_Lock_in => bus_Lock_in,

      agent_av_in     => av_mw_h,
      agent_comm_in   => comm_mw_h,
      agent_data_in   => data_mw_h,
      agent_we_in     => we_mw_h,
      agent_full_out  => full_h_mw,
      agent_one_p_out => one_p_h_mw,


      agent_msg_av_in     => av_mmw_h,
      agent_msg_data_in   => data_mmw_h,
      agent_msg_comm_in   => comm_mmw_h,
      agent_msg_we_in     => we_mmw_h,
      agent_msg_full_out  => full_h_mmw,
      agent_msg_one_p_out => one_p_h_mmw,

      bus_av_out   => bus_av_out,
      bus_comm_out => bus_comm_out,
      bus_data_out => bus_data_out,
      bus_full_out => bus_full_out,
      bus_Lock_out => bus_Lock_out,

      agent_re_in     => re_dr_h,
      agent_av_out    => av_h_dr,
      agent_data_out  => data_h_dr,
      agent_comm_out  => comm_h_dr,
      agent_empty_out => empty_h_dr,
      agent_one_d_out => one_d_h_dr,

      agent_msg_av_out    => av_h_mdr,
      agent_msg_re_in     => re_mdr_h,
      agent_msg_data_out  => data_h_mdr,
      agent_msg_comm_out  => comm_h_mdr,
      agent_msg_empty_out => empty_h_mdr,
      agent_msg_one_d_out => one_d_h_mdr
      --synthesis translate_off
      ,
      debug_in => debug_in,
      debug_out => debug_out
      --synthesis translate_on      
      );

  agent_one_d_out     <= one_d_h_dr;
  agent_msg_one_d_out <= one_d_h_mdr;

  -- Takes addr and data in parallel and muxes them into one signal
  -- This way the IP's designed for Hibi v1 can used with Hibi v2
  -- IP writes data to this block
  mw : addr_data_mux_write
    generic map(
      data_width_g => data_width_g,
      addr_width_g => addr_width_g,
      comm_width_g => comm_width_g
      )
    port map(
      clk   => agent_clk,
      rst_n => rst_n,

      addr_in   => agent_addr_in,
      data_in   => agent_data_in,
      comm_in   => agent_comm_in,
      we_in     => agent_we_in,
      full_out  => agent_full_out,
      one_p_out => agent_one_p_out,

      av_out   => av_mw_h,
      data_out => data_mw_h,
      comm_out => comm_mw_h,
      we_out   => we_mw_h,
      full_in  => full_h_mw,
      one_p_in => one_p_h_mw
      );

  
  mmw : addr_data_mux_write
    generic map(
      data_width_g => data_width_g,
      addr_width_g => addr_width_g,
      comm_width_g => comm_width_g
      )
    port map(
      clk   => agent_clk,
      rst_n => rst_n,

      addr_in   => agent_msg_addr_in,
      data_in   => agent_msg_data_in,
      comm_in   => agent_msg_comm_in,
      we_in     => agent_msg_we_in,
      full_out  => agent_msg_full_out,
      one_p_out => agent_msg_one_p_out,

      av_out   => av_mmw_h,
      data_out => data_mmw_h,
      comm_out => comm_mmw_h,
      we_out   => we_mmw_h,
      full_in  => full_h_mmw,
      one_p_in => one_p_h_mmw
      );

  -- Takes addr and data separately and puts them into separate signals
  -- This way the IP's designed for Hibi v1 can used with Hibi v2
  -- IP reads data from this block
  dr : addr_data_demux_read
    generic map(
      data_width_g => data_width_g,
      addr_width_g => addr_width_g,
      comm_width_g => comm_width_g
      )
    port map(
      clk   => agent_clk,
      rst_n => rst_n,

      re_out   => re_dr_h,
      av_in    => av_h_dr,
      data_in  => data_h_dr,
      comm_in  => comm_h_dr,
      empty_in => empty_h_dr,
      --      one_d_in  => one_d_h_dr,

      re_in     => agent_re_in,
      addr_out  => agent_addr_out,
      data_out  => agent_data_out,
      comm_out  => agent_comm_out,
      empty_out => agent_empty_out
      --      one_d_out => agent_one_p_out,
      );


  mdr : addr_data_demux_read
    generic map(
      data_width_g => data_width_g,
      addr_width_g => addr_width_g,
      comm_width_g => comm_width_g
      )
    port map(
      clk   => agent_clk,
      rst_n => rst_n,

      re_out   => re_mdr_h,
      av_in    => av_h_mdr,
      data_in  => data_h_mdr,
      comm_in  => comm_h_mdr,
      empty_in => empty_h_mdr,
      --      one_d_in  => one_d_h_mdr,

      re_in     => agent_msg_re_in,
      addr_out  => agent_msg_addr_out,
      data_out  => agent_msg_data_out,
      comm_out  => agent_msg_comm_out,
      empty_out => agent_msg_empty_out
      --      one_d_out => agent_msg_one_p_out,
      );



end structural_ultimate;
