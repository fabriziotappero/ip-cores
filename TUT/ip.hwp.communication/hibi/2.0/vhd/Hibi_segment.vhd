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
-- file        : eight_hibi_r4_and_radio.vhdl
-- description : hibi bus for connecting eight nioses, this time
--               using hibi_wrapper_r4 (only one fifo interface)
-- author      : ari kulmala
-- date        : 24.6.2004
-- modified    : 
-- 16.09.2004  ak number of agents-generic
-- 28.09.2004  ak msg_fifo_depths-table (2x.9.), max_send_c
-- 05.01.2004  ak naming according to the new scheme
-- 03.02.2006  tar doubled the number of possible r4 interfaces
-- 29.09.2008  tko added interfaces for 5 new r1/r3 wrappers, uses some arrays
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--use work.hibiv2_pkg.all;                -- hibi v2 commands

entity hibi_segment_small is
  generic (
    data_width_g           : integer := 32;
    counter_width_g        : integer := 16;
    addr_width_g           : integer := 32;
    comm_width_g           : integer := 3;
    id_width_g             : integer := 5;
    number_of_r4_agents_g  : integer := 16;   -- 1-16
    number_of_r3_agents_g  : integer := 1;   -- 0-1
    -- priorities
    agent_priority_1_g : INTEGER := 1;
    agent_priority_2_g : INTEGER := 2;
    agent_priority_3_g : INTEGER := 3;
    agent_priority_4_g : INTEGER := 4;
    agent_priority_5_g : INTEGER := 5;
    agent_priority_6_g : INTEGER := 6;
    agent_priority_7_g : INTEGER := 7;
    agent_priority_8_g : INTEGER := 8;
    agent_priority_9_g : INTEGER := 9;
    agent_priority_10_g : INTEGER := 10;
    agent_priority_11_g : INTEGER := 11;
    agent_priority_12_g : INTEGER := 12;
    agent_priority_13_g : INTEGER := 13;
    agent_priority_14_g : INTEGER := 14;
    agent_priority_15_g : INTEGER := 15;
    agent_priority_16_g : INTEGER := 16;
    agent_priority_17_g : INTEGER := 17; -- not in use
    -- base ids (not used)
    agent_base_id_1_g : INTEGER := 0;
    agent_base_id_2_g : INTEGER := 0;
    agent_base_id_3_g : INTEGER := 0; 
    agent_base_id_4_g : INTEGER := 0;
    agent_base_id_5_g : INTEGER := 0;
    agent_base_id_6_g : INTEGER := 0;
    agent_base_id_7_g : INTEGER := 0;
    agent_base_id_8_g : INTEGER := 0;
    agent_base_id_9_g : INTEGER := 0;
    agent_base_id_10_g : INTEGER := 0;
    agent_base_id_11_g : INTEGER := 0; 
    agent_base_id_12_g : INTEGER := 0;
    agent_base_id_13_g : INTEGER := 0;
    agent_base_id_14_g : INTEGER := 0;
    agent_base_id_15_g : INTEGER := 0;
    agent_base_id_16_g : INTEGER := 0;
    agent_base_id_17_g : INTEGER := 0;
    -- max sends
    agent_max_send_1_g : INTEGER := 200;
    agent_max_send_2_g : INTEGER := 200;
    agent_max_send_3_g : INTEGER := 200;
    agent_max_send_4_g : INTEGER := 200;
    agent_max_send_5_g : INTEGER := 200;
    agent_max_send_6_g : INTEGER := 200;
    agent_max_send_7_g : INTEGER := 200;
    agent_max_send_8_g : INTEGER := 200;
    agent_max_send_9_g : INTEGER := 200;
    agent_max_send_10_g : INTEGER := 200;
    agent_max_send_11_g : INTEGER := 200;
    agent_max_send_12_g : INTEGER := 200;
    agent_max_send_13_g : INTEGER := 200;
    agent_max_send_14_g : INTEGER := 200;
    agent_max_send_15_g : INTEGER := 200;
    agent_max_send_16_g : INTEGER := 200;
    agent_max_send_17_g : INTEGER := 200
  );

  port (
    clk   : in std_logic;
    rst_n : in std_logic;
    -- Debug signals for bus monitoring purposes
    debug_bus_full_out : OUT STD_LOGIC;
    debug_bus_comm_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    debug_bus_av_out   : OUT STD_LOGIC;
    
    -- nios_1 ports -- 
    agent_comm_in_1   : in  std_logic_vector (comm_width_g-1 downto 0);
    agent_data_in_1   : in  std_logic_vector(data_width_g-1 downto 0);
    agent_av_in_1     : in  std_logic;
    agent_we_in_1     : in  std_logic;
    agent_re_in_1     : in  std_logic;
    agent_comm_out_1  : out std_logic_vector (comm_width_g-1 downto 0);
    agent_data_out_1  : out std_logic_vector(data_width_g-1 downto 0);
    agent_av_out_1    : out std_logic;
    agent_full_out_1  : out std_logic;
    agent_one_p_out_1 : out std_logic;
    agent_empty_out_1 : out std_logic;
    agent_one_d_out_1 : out std_logic;

    -- nios_2 ports -- 

    agent_comm_in_2   : in  std_logic_vector (comm_width_g-1 downto 0);  --13.03.03 command_type;
    agent_data_in_2   : in  std_logic_vector(data_width_g-1 downto 0);
    agent_av_in_2     : in  std_logic;
    agent_we_in_2     : in  std_logic;
    agent_re_in_2     : in  std_logic;
    agent_comm_out_2  : out std_logic_vector (comm_width_g-1 downto 0);  --13.03.03 command_type;
    agent_data_out_2  : out std_logic_vector(data_width_g-1 downto 0);
    agent_av_out_2    : out std_logic;
    agent_full_out_2  : out std_logic;
    agent_one_p_out_2 : out std_logic;
    agent_empty_out_2 : out std_logic;
    agent_one_d_out_2 : out std_logic;

    -- nios_3 ports -- 
    agent_comm_in_3   : in  std_logic_vector (comm_width_g-1 downto 0);
    agent_data_in_3   : in  std_logic_vector(data_width_g-1 downto 0);
    agent_av_in_3     : in  std_logic;
    agent_we_in_3     : in  std_logic;
    agent_re_in_3     : in  std_logic;
    agent_comm_out_3  : out std_logic_vector (comm_width_g-1 downto 0);
    agent_data_out_3  : out std_logic_vector(data_width_g-1 downto 0);
    agent_av_out_3    : out std_logic;
    agent_full_out_3  : out std_logic;
    agent_one_p_out_3 : out std_logic;
    agent_empty_out_3 : out std_logic;
    agent_one_d_out_3 : out std_logic;

    -- nios_4 ports -- 
    agent_comm_in_4   : in  std_logic_vector (comm_width_g-1 downto 0);
    agent_data_in_4   : in  std_logic_vector(data_width_g-1 downto 0);
    agent_av_in_4     : in  std_logic;
    agent_we_in_4     : in  std_logic;
    agent_re_in_4     : in  std_logic;
    agent_comm_out_4  : out std_logic_vector (comm_width_g-1 downto 0);
    agent_data_out_4  : out std_logic_vector(data_width_g-1 downto 0);
    agent_av_out_4    : out std_logic;
    agent_full_out_4  : out std_logic;
    agent_one_p_out_4 : out std_logic;
    agent_empty_out_4 : out std_logic;
    agent_one_d_out_4 : out std_logic;

    -- nios_5 ports -- 
    agent_comm_in_5   : in  std_logic_vector (comm_width_g-1 downto 0);
    agent_data_in_5   : in  std_logic_vector(data_width_g-1 downto 0);
    agent_av_in_5     : in  std_logic;
    agent_we_in_5     : in  std_logic;
    agent_re_in_5     : in  std_logic;
    agent_comm_out_5  : out std_logic_vector (comm_width_g-1 downto 0);
    agent_data_out_5  : out std_logic_vector(data_width_g-1 downto 0);
    agent_av_out_5    : out std_logic;
    agent_full_out_5  : out std_logic;
    agent_one_p_out_5 : out std_logic;
    agent_empty_out_5 : out std_logic;
    agent_one_d_out_5 : out std_logic;

    -- nios_6 ports -- 
    agent_comm_in_6   : in  std_logic_vector (comm_width_g-1 downto 0);
    agent_data_in_6   : in  std_logic_vector(data_width_g-1 downto 0);
    agent_av_in_6     : in  std_logic;
    agent_we_in_6     : in  std_logic;
    agent_re_in_6     : in  std_logic;
    agent_comm_out_6  : out std_logic_vector (comm_width_g-1 downto 0);
    agent_data_out_6  : out std_logic_vector(data_width_g-1 downto 0);
    agent_av_out_6    : out std_logic;
    agent_full_out_6  : out std_logic;
    agent_one_p_out_6 : out std_logic;
    agent_empty_out_6 : out std_logic;
    agent_one_d_out_6 : out std_logic;

    -- nios_7 ports -- 
    agent_comm_in_7   : in  std_logic_vector (comm_width_g-1 downto 0);
    agent_data_in_7   : in  std_logic_vector(data_width_g-1 downto 0);
    agent_av_in_7     : in  std_logic;
    agent_we_in_7     : in  std_logic;
    agent_re_in_7     : in  std_logic;
    agent_comm_out_7  : out std_logic_vector (comm_width_g-1 downto 0);
    agent_data_out_7  : out std_logic_vector(data_width_g-1 downto 0);
    agent_av_out_7    : out std_logic;
    agent_full_out_7  : out std_logic;
    agent_one_p_out_7 : out std_logic;
    agent_empty_out_7 : out std_logic;
    agent_one_d_out_7 : out std_logic;

    -- nios_8 ports -- 
    agent_comm_in_8   : in  std_logic_vector (comm_width_g-1 downto 0);
    agent_data_in_8   : in  std_logic_vector(data_width_g-1 downto 0);
    agent_av_in_8     : in  std_logic;
    agent_we_in_8     : in  std_logic;
    agent_re_in_8     : in  std_logic;
    agent_comm_out_8  : out std_logic_vector (comm_width_g-1 downto 0);
    agent_data_out_8  : out std_logic_vector(data_width_g-1 downto 0);
    agent_av_out_8    : out std_logic;
    agent_full_out_8  : out std_logic;
    agent_one_p_out_8 : out std_logic;
    agent_empty_out_8 : out std_logic;
    agent_one_d_out_8 : out std_logic;

    -- nios_9 ports -- 
    agent_comm_in_9   : in  std_logic_vector (comm_width_g-1 downto 0);
    agent_data_in_9   : in  std_logic_vector(data_width_g-1 downto 0);
    agent_av_in_9     : in  std_logic;
    agent_we_in_9     : in  std_logic;
    agent_re_in_9     : in  std_logic;
    agent_comm_out_9  : out std_logic_vector (comm_width_g-1 downto 0);
    agent_data_out_9  : out std_logic_vector(data_width_g-1 downto 0);
    agent_av_out_9    : out std_logic;
    agent_full_out_9  : out std_logic;
    agent_one_p_out_9 : out std_logic;
    agent_empty_out_9 : out std_logic;
    agent_one_d_out_9 : out std_logic;

    -- nios_10 ports -- 
    agent_comm_in_10   : in  std_logic_vector (comm_width_g-1 downto 0);
    agent_data_in_10   : in  std_logic_vector(data_width_g-1 downto 0);
    agent_av_in_10     : in  std_logic;
    agent_we_in_10     : in  std_logic;
    agent_re_in_10     : in  std_logic;
    agent_comm_out_10  : out std_logic_vector (comm_width_g-1 downto 0);
    agent_data_out_10  : out std_logic_vector(data_width_g-1 downto 0);
    agent_av_out_10    : out std_logic;
    agent_full_out_10  : out std_logic;
    agent_one_p_out_10 : out std_logic;
    agent_empty_out_10 : out std_logic;
    agent_one_d_out_10 : out std_logic;

    -- nios_11 ports -- 
    agent_comm_in_11   : in  std_logic_vector (comm_width_g-1 downto 0);
    agent_data_in_11   : in  std_logic_vector(data_width_g-1 downto 0);
    agent_av_in_11     : in  std_logic;
    agent_we_in_11     : in  std_logic;
    agent_re_in_11     : in  std_logic;
    agent_comm_out_11  : out std_logic_vector (comm_width_g-1 downto 0);
    agent_data_out_11  : out std_logic_vector(data_width_g-1 downto 0);
    agent_av_out_11    : out std_logic;
    agent_full_out_11  : out std_logic;
    agent_one_p_out_11 : out std_logic;
    agent_empty_out_11 : out std_logic;
    agent_one_d_out_11 : out std_logic;

    -- nios_12 ports -- 
    agent_comm_in_12   : in  std_logic_vector (comm_width_g-1 downto 0);
    agent_data_in_12   : in  std_logic_vector(data_width_g-1 downto 0);
    agent_av_in_12     : in  std_logic;
    agent_we_in_12     : in  std_logic;
    agent_re_in_12     : in  std_logic;
    agent_comm_out_12  : out std_logic_vector (comm_width_g-1 downto 0);
    agent_data_out_12  : out std_logic_vector(data_width_g-1 downto 0);
    agent_av_out_12    : out std_logic;
    agent_full_out_12  : out std_logic;
    agent_one_p_out_12 : out std_logic;
    agent_empty_out_12 : out std_logic;
    agent_one_d_out_12 : out std_logic;

    -- nios_13 ports -- 
    agent_comm_in_13   : in  std_logic_vector (comm_width_g-1 downto 0);
    agent_data_in_13   : in  std_logic_vector(data_width_g-1 downto 0);
    agent_av_in_13     : in  std_logic;
    agent_we_in_13     : in  std_logic;
    agent_re_in_13     : in  std_logic;
    agent_comm_out_13  : out std_logic_vector (comm_width_g-1 downto 0);
    agent_data_out_13  : out std_logic_vector(data_width_g-1 downto 0);
    agent_av_out_13    : out std_logic;
    agent_full_out_13  : out std_logic;
    agent_one_p_out_13 : out std_logic;
    agent_empty_out_13 : out std_logic;
    agent_one_d_out_13 : out std_logic;

    -- nios_14 ports -- 
    agent_comm_in_14   : in  std_logic_vector (comm_width_g-1 downto 0);
    agent_data_in_14   : in  std_logic_vector(data_width_g-1 downto 0);
    agent_av_in_14     : in  std_logic;
    agent_we_in_14     : in  std_logic;
    agent_re_in_14     : in  std_logic;
    agent_comm_out_14  : out std_logic_vector (comm_width_g-1 downto 0);
    agent_data_out_14  : out std_logic_vector(data_width_g-1 downto 0);
    agent_av_out_14    : out std_logic;
    agent_full_out_14  : out std_logic;
    agent_one_p_out_14 : out std_logic;
    agent_empty_out_14 : out std_logic;
    agent_one_d_out_14 : out std_logic;

    -- nios_15 ports -- 
    agent_comm_in_15   : in  std_logic_vector (comm_width_g-1 downto 0);
    agent_data_in_15   : in  std_logic_vector(data_width_g-1 downto 0);
    agent_av_in_15     : in  std_logic;
    agent_we_in_15     : in  std_logic;
    agent_re_in_15     : in  std_logic;
    agent_comm_out_15  : out std_logic_vector (comm_width_g-1 downto 0);
    agent_data_out_15  : out std_logic_vector(data_width_g-1 downto 0);
    agent_av_out_15    : out std_logic;
    agent_full_out_15  : out std_logic;
    agent_one_p_out_15 : out std_logic;
    agent_empty_out_15 : out std_logic;
    agent_one_d_out_15 : out std_logic;

    -- nios_16 ports -- 
    agent_comm_in_16   : in  std_logic_vector (comm_width_g-1 downto 0);
    agent_data_in_16   : in  std_logic_vector(data_width_g-1 downto 0);
    agent_av_in_16     : in  std_logic;
    agent_we_in_16     : in  std_logic;
    agent_re_in_16     : in  std_logic;
    agent_comm_out_16  : out std_logic_vector (comm_width_g-1 downto 0);
    agent_data_out_16  : out std_logic_vector(data_width_g-1 downto 0);
    agent_av_out_16    : out std_logic;
    agent_full_out_16  : out std_logic;
    agent_one_p_out_16 : out std_logic;
    agent_empty_out_16 : out std_logic;
    agent_one_d_out_16 : out std_logic;
    
    -- nios_17 ports -- 
    agent_addr_in_17   : in  std_logic_vector (data_width_g-1 downto 0);
    agent_addr_out_17  : out std_logic_vector (data_width_g-1 downto 0);
    agent_comm_in_17   : in  std_logic_vector (comm_width_g-1 downto 0);
    agent_data_in_17   : in  std_logic_vector(data_width_g-1 downto 0);
    agent_we_in_17     : in  std_logic;
    agent_re_in_17     : in  std_logic;
    agent_comm_out_17  : out std_logic_vector (comm_width_g-1 downto 0);
    agent_data_out_17  : out std_logic_vector(data_width_g-1 downto 0);
    agent_full_out_17  : out std_logic;
    agent_one_p_out_17 : out std_logic;
    agent_empty_out_17 : out std_logic;
    agent_one_d_out_17 : out std_logic;
    agent_msg_addr_in_17   : in  std_logic_vector (data_width_g-1 downto 0);
    agent_msg_addr_out_17  : out std_logic_vector (data_width_g-1 downto 0);
    agent_msg_data_in_17   : in std_logic_vector (data_width_g-1 downto 0);
    agent_msg_comm_in_17   : in std_logic_vector (comm_width_g-1 downto 0);
    agent_msg_we_in_17     : in std_logic;
    agent_msg_re_in_17     : in std_logic;
    agent_msg_data_out_17  : out std_logic_vector (data_width_g-1 downto 0);
    agent_msg_comm_out_17  : out std_logic_vector (comm_width_g-1 downto 0);
    agent_msg_empty_out_17 : out std_logic;
    agent_msg_one_d_out_17 : out std_logic;
    agent_msg_full_out_17  : out std_logic;
    agent_msg_one_p_out_17 : out std_logic
    
    );
end hibi_segment_small;

architecture structural of hibi_segment_small is

  -- type     addr_array is array (1 to 8) of integer;
  -- constant addresses : addr_array := (agent_address_1_g, agent_address_2_g, agent_address_3_g, agent_address_4_g, agent_address_5_g, agent_address_6_g, agent_address_7_g, agent_address_8_g);
  
  
  -- constant rx_data_fifo_depths_c     : addr_array := (agent_rx_data_fifo_1_g, agent_rx_data_fifo_2_g, agent_rx_data_fifo_3_g, agent_rx_data_fifo_4_g, agent_rx_data_fifo_5_g, agent_rx_data_fifo_6_g, agent_rx_data_fifo_7_g, agent_rx_data_fifo_8_g);

  -- constant tx_data_fifo_depths_c     : addr_array := (agent_tx_data_fifo_1_g, agent_tx_data_fifo_2_g, agent_tx_data_fifo_3_g, agent_tx_data_fifo_4_g, agent_tx_data_fifo_5_g, agent_tx_data_fifo_6_g, agent_tx_data_fifo_7_g, agent_tx_data_fifo_8_g);
  -- constant rx_msg_fifo_depths_c : addr_array := (agent_rx_msg_fifo_1_g, agent_rx_msg_fifo_2_g, agent_rx_msg_fifo_3_g, agent_rx_msg_fifo_4_g, agent_rx_msg_fifo_5_g, agent_rx_msg_fifo_6_g, agent_rx_msg_fifo_7_g, agent_rx_msg_fifo_8_g);
  -- constant tx_msg_fifo_depths_c : addr_array := (agent_tx_msg_fifo_1_g, agent_tx_msg_fifo_2_g, agent_tx_msg_fifo_3_g, agent_tx_msg_fifo_4_g, agent_tx_msg_fifo_5_g, agent_tx_msg_fifo_6_g, agent_tx_msg_fifo_7_g, agent_tx_msg_fifo_8_g);
  -- constant max_sends_c     : addr_array := ();
  
  constant max_send_c : integer := 512;
  
component hibi_wrapper_r4
    generic (
      id_g      : integer := 5;
      base_id_g : integer := 5;

      id_width_g      : integer := 4;
      addr_width_g    : integer := 32;  -- in bits!
      data_width_g    : integer := 32;
      comm_width_g    : integer := 3;
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
      prior_g       : integer := 2;
      inv_addr_en_g : integer := 0;
      max_send_g    : integer := 50;

      n_agents_g       : integer := 4;
      n_cfg_pages_g    : integer := 1;
      n_time_slots_g   : integer := 0;
      n_extra_params_g : integer := 0;
      multicast_en_g   : integer := 0;  -- 28.02.05
      cfg_re_g         : integer := 0;  -- 28.02.05
      cfg_we_g         : integer := 0;   -- 28.02.05
      debug_width_g    : integer := 0  -- 13.04.2007 AK
      );
    port (
      bus_clk        : in std_logic;
      agent_clk      : in std_logic;
      bus_sync_clk   : in std_logic;
      agent_sync_clk : in std_logic;
      rst_n          : in std_logic;
      bus_comm_in    : in std_logic_vector (comm_width_g-1 downto 0);
      bus_data_in    : in std_logic_vector (data_width_g-1 downto 0);
      bus_full_in    : in std_logic;
      bus_lock_in    : in std_logic;
      bus_av_in      : in std_logic;

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
  end component;  -- hibi_wrapper_r4;
  
  component hibi_wrapper_r3 is
    generic (
      id_g      : integer := 5;
      base_id_g : integer := 5;

      id_width_g      : integer := 4;
      addr_width_g    : integer := 32;    -- in bits!
      data_width_g    : integer := 32;
      comm_width_g    : integer := 3;
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
      prior_g       : integer := 2;
      inv_addr_en_g : integer := 0;
      max_send_g    : integer := 50;

      arb_type_g : integer := 0;

      n_agents_g       : integer := 4;
      n_cfg_pages_g    : integer := 1;
      n_time_slots_g   : integer := 0;
      n_extra_params_g : integer := 0;
      multicast_en_g   : integer := 0;    -- 28.02.05
      cfg_re_g         : integer := 0;
      cfg_we_g         : integer := 0;
      debug_width_g : integer := 0

    );

    port (
      bus_clk     : in std_logic;
      agent_clk   : in std_logic;
      bus_sync_clk   : in std_logic;
      agent_sync_clk : in std_logic;
      rst_n       : in std_logic;
      bus_comm_in : in std_logic_vector (comm_width_g-1 downto 0);
      bus_data_in : in std_logic_vector (data_width_g-1 downto 0);
      bus_full_in : in std_logic;
      bus_Lock_in : in std_logic;
      bus_av_in   : in std_logic;

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

      bus_comm_out : out std_logic_vector (comm_width_g-1 downto 0);
      bus_data_out : out std_logic_vector (data_width_g-1 downto 0);
      bus_full_out : out std_logic;
      bus_Lock_out : out std_logic;
      bus_av_out   : out std_logic;

      agent_re_in     : in  std_logic;
      agent_addr_out  : out std_logic_vector (data_width_g-1 downto 0);
      agent_data_out  : out std_logic_vector (data_width_g-1 downto 0);
      agent_comm_out  : out std_logic_vector (comm_width_g-1 downto 0);
      agent_empty_out : out std_logic;
      agent_one_d_out : out std_logic;    -- is this used??

      agent_msg_re_in     : in  std_logic;
      agent_msg_addr_out  : out std_logic_vector (data_width_g-1 downto 0);
      agent_msg_data_out  : out std_logic_vector (data_width_g-1 downto 0);
      agent_msg_comm_out  : out std_logic_vector (comm_width_g-1 downto 0);
      agent_msg_empty_out : out std_logic;
      agent_msg_one_d_out : out std_logic  -- is this used??
    );
  end component;

  
  
  -- constants
  -- komennot
  constant idle : integer := 0;
  constant wc   : integer := 1;         --write conf
  constant wd   : integer := 2;         --write data
  constant wm   : integer := 3;         --write msg
  constant rd   : integer := 4;         --read rq data
  constant rc   : integer := 5;         --read rq conf
  constant md   : integer := 6;         --multicast data
  constant mm   : integer := 7;         --mutlicast msg

  -- av  => osoite / data
  -- msg_or_data => data / viesti
  constant a : integer := 1;
  constant d : integer := 0;
  constant m : integer := 1;
  type     data_vec_array is array (1 to 8) of std_logic_vector (data_width_g-1 downto 0);
  
  type     addr_array is array (1 to 17) of integer;
  constant addr_c : addr_array := (16#01000000#, 16#03000000#, 16#05000000#, 16#07000000#, 16#09000000#, 16#0b000000#, 16#0d000000#, 16#0f000000#,
                                   16#11000000#, 16#13000000#, 16#15000000#, 16#17000000#, 16#19000000#, 16#1b000000#, 16#1d000000#, 16#1f000000#,
                                   16#29000000#);
  constant fifo_depths_c     : addr_array := (20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20);
  constant msg_fifo_depths_c : addr_array := (0, 0, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20);


  signal bus_data_out_1 : std_logic_vector (data_width_g-1 downto 0);
  signal bus_comm_out_1 : std_logic_vector (comm_width_g-1 downto 0);
  signal bus_lock_out_1 : std_logic;
  signal bus_av_out_1   : std_logic;
  signal bus_full_out_1 : std_logic;
  signal bus_data_out_2 : std_logic_vector (data_width_g-1 downto 0);
  signal bus_comm_out_2 : std_logic_vector (comm_width_g-1 downto 0);
  signal bus_lock_out_2 : std_logic;
  signal bus_av_out_2   : std_logic;
  signal bus_full_out_2 : std_logic;
  signal bus_data_out_3 : std_logic_vector (data_width_g-1 downto 0);
  signal bus_comm_out_3 : std_logic_vector (comm_width_g-1 downto 0);
  signal bus_lock_out_3 : std_logic;
  signal bus_av_out_3   : std_logic;
  signal bus_full_out_3 : std_logic;
  signal bus_data_out_4 : std_logic_vector (data_width_g-1 downto 0);
  signal bus_comm_out_4 : std_logic_vector (comm_width_g-1 downto 0);
  signal bus_lock_out_4 : std_logic;
  signal bus_av_out_4   : std_logic;
  signal bus_full_out_4 : std_logic;
  signal bus_data_out_5 : std_logic_vector (data_width_g-1 downto 0);
  signal bus_comm_out_5 : std_logic_vector (comm_width_g-1 downto 0);
  signal bus_lock_out_5 : std_logic;
  signal bus_av_out_5   : std_logic;
  signal bus_full_out_5 : std_logic;
  signal bus_data_out_6 : std_logic_vector (data_width_g-1 downto 0);
  signal bus_comm_out_6 : std_logic_vector (comm_width_g-1 downto 0);
  signal bus_lock_out_6 : std_logic;
  signal bus_av_out_6   : std_logic;
  signal bus_full_out_6 : std_logic;
  signal bus_data_out_7 : std_logic_vector (data_width_g-1 downto 0);
  signal bus_comm_out_7 : std_logic_vector (comm_width_g-1 downto 0);
  signal bus_lock_out_7 : std_logic;
  signal bus_av_out_7   : std_logic;
  signal bus_full_out_7 : std_logic;
  signal bus_data_out_8 : std_logic_vector (data_width_g-1 downto 0);
  signal bus_comm_out_8 : std_logic_vector (comm_width_g-1 downto 0);
  signal bus_lock_out_8 : std_logic;
  signal bus_av_out_8   : std_logic;
  signal bus_full_out_8 : std_logic;
  signal bus_data_out_9 : std_logic_vector (data_width_g-1 downto 0);
  signal bus_comm_out_9 : std_logic_vector (comm_width_g-1 downto 0);
  signal bus_lock_out_9 : std_logic;
  signal bus_av_out_9   : std_logic;
  signal bus_full_out_9 : std_logic;
  signal bus_data_out_10 : std_logic_vector (data_width_g-1 downto 0);
  signal bus_comm_out_10 : std_logic_vector (comm_width_g-1 downto 0);
  signal bus_lock_out_10 : std_logic;
  signal bus_av_out_10   : std_logic;
  signal bus_full_out_10 : std_logic;
  signal bus_data_out_11 : std_logic_vector (data_width_g-1 downto 0);
  signal bus_comm_out_11 : std_logic_vector (comm_width_g-1 downto 0);
  signal bus_lock_out_11 : std_logic;
  signal bus_av_out_11   : std_logic;
  signal bus_full_out_11 : std_logic;
  signal bus_data_out_12 : std_logic_vector (data_width_g-1 downto 0);
  signal bus_comm_out_12 : std_logic_vector (comm_width_g-1 downto 0);
  signal bus_lock_out_12 : std_logic;
  signal bus_av_out_12   : std_logic;
  signal bus_full_out_12 : std_logic;
  signal bus_data_out_13 : std_logic_vector (data_width_g-1 downto 0);
  signal bus_comm_out_13 : std_logic_vector (comm_width_g-1 downto 0);
  signal bus_lock_out_13 : std_logic;
  signal bus_av_out_13   : std_logic;
  signal bus_full_out_13 : std_logic;
  signal bus_data_out_14 : std_logic_vector (data_width_g-1 downto 0);
  signal bus_comm_out_14 : std_logic_vector (comm_width_g-1 downto 0);
  signal bus_lock_out_14 : std_logic;
  signal bus_av_out_14   : std_logic;
  signal bus_full_out_14 : std_logic;
  signal bus_data_out_15 : std_logic_vector (data_width_g-1 downto 0);
  signal bus_comm_out_15 : std_logic_vector (comm_width_g-1 downto 0);
  signal bus_lock_out_15 : std_logic;
  signal bus_av_out_15   : std_logic;
  signal bus_full_out_15 : std_logic;
  signal bus_data_out_16 : std_logic_vector (data_width_g-1 downto 0);
  signal bus_comm_out_16 : std_logic_vector (comm_width_g-1 downto 0);
  signal bus_lock_out_16 : std_logic;
  signal bus_av_out_16   : std_logic;
  signal bus_full_out_16 : std_logic;
  signal bus_data_out_17 : std_logic_vector (data_width_g-1 downto 0);
  signal bus_comm_out_17 : std_logic_vector (comm_width_g-1 downto 0);
  signal bus_lock_out_17 : std_logic;
  signal bus_av_out_17   : std_logic;
  signal bus_full_out_17 : std_logic;
  signal bus_data_in    : std_logic_vector (data_width_g-1 downto 0);
  signal bus_comm_in    : std_logic_vector (comm_width_g-1 downto 0);
  signal bus_av_in      : std_logic;
  signal bus_lock_in    : std_logic;
  signal bus_full_in    : std_logic;

  
  
begin  -- structural
  
  a1 : if number_of_r4_agents_g > 0 generate
    
    agent_1 : hibi_wrapper_r4
      generic map (
        id_g                => 1,
        base_id_g           => 2**id_width_g-1,
        id_width_g          => id_width_g,
        addr_width_g        => addr_width_g,
        data_width_g        => data_width_g,
        comm_width_g        => comm_width_g,
        counter_width_g     => counter_width_g,
        rx_fifo_depth_g     => fifo_depths_c(1),
        rx_msg_fifo_depth_g => msg_fifo_depths_c(1),
        tx_fifo_depth_g     => fifo_depths_c(1),
        tx_msg_fifo_depth_g => msg_fifo_depths_c(1),
        addr_g              => addr_c(1),
        prior_g             => 1,
        inv_addr_en_g       => 0,
        max_send_g          => agent_max_send_1_g,
        n_agents_g          => number_of_r4_agents_g + number_of_r3_agents_g,
        n_cfg_pages_g       => 1,
        n_time_slots_g      => 0,
        n_extra_params_g    => 0,
        -- cfg_rom_en_g        => 1
        debug_width_g       => 0
        )
      port map (
        bus_clk      => clk,
        agent_clk    => clk,
        bus_sync_clk => clk,
        agent_sync_clk => clk,
        rst_n        => rst_n,
        bus_comm_in  => bus_comm_in,
        bus_comm_out => bus_comm_out_1,
        bus_data_in  => bus_data_in,
        bus_data_out => bus_data_out_1,
        bus_full_in  => bus_full_in,
        bus_full_out => bus_full_out_1,
        bus_lock_in  => bus_lock_in,
        bus_lock_out => bus_lock_out_1,
        bus_av_in    => bus_av_in,
        bus_av_out   => bus_av_out_1,

        agent_comm_in   => agent_comm_in_1,
        agent_comm_out  => agent_comm_out_1,
        agent_data_in   => agent_data_in_1,
        agent_data_out  => agent_data_out_1,
        agent_av_in     => agent_av_in_1,
        agent_av_out    => agent_av_out_1,
        agent_full_out  => agent_full_out_1,
        agent_one_p_out => agent_one_p_out_1,
        agent_we_in     => agent_we_in_1,
        agent_empty_out => agent_empty_out_1,
        agent_one_d_out => agent_one_d_out_1,
        agent_re_in     => agent_re_in_1
        -- synthesis translate_off
        -- pragma translate_off
        ,
        debug_out => open,
        debug_in => (others => '0')
        -- pragma translate_on
        -- synthesis translate_on
        );
  end generate a1;

  a2 : if number_of_r4_agents_g > 1 generate
    
    agent_2 : hibi_wrapper_r4
      generic map (
        id_g                => 3,
        base_id_g           => 2**id_width_g-1,
        id_width_g          => id_width_g,
        addr_width_g        => addr_width_g,
        data_width_g        => data_width_g,
        comm_width_g        => comm_width_g,
        counter_width_g     => counter_width_g,
        rx_fifo_depth_g     => fifo_depths_c(2),
        rx_msg_fifo_depth_g => msg_fifo_depths_c(2),
        tx_fifo_depth_g     => fifo_depths_c(2),
        tx_msg_fifo_depth_g => msg_fifo_depths_c(2),
        addr_g              => addr_c(2),
        prior_g             => agent_priority_2_g,
        inv_addr_en_g       => 0,
        max_send_g          => agent_max_send_2_g,
        n_agents_g          => number_of_r4_agents_g + number_of_r3_agents_g,
        n_cfg_pages_g       => 1,
        n_time_slots_g      => 0,
        n_extra_params_g    => 0
        -- cfg_rom_en_g        => 1
        )
      port map (
        bus_clk      => clk,
        agent_clk    => clk,
        bus_sync_clk => clk,
        agent_sync_clk => clk,
        rst_n        => rst_n,
        bus_comm_in  => bus_comm_in,
        bus_comm_out => bus_comm_out_2,
        bus_data_in  => bus_data_in,
        bus_data_out => bus_data_out_2,
        bus_full_in  => bus_full_in,
        bus_full_out => bus_full_out_2,
        bus_lock_in  => bus_lock_in,
        bus_lock_out => bus_lock_out_2,
        bus_av_in    => bus_av_in,
        bus_av_out   => bus_av_out_2,

        agent_comm_in   => agent_comm_in_2,
        agent_comm_out  => agent_comm_out_2,
        agent_data_in   => agent_data_in_2,
        agent_data_out  => agent_data_out_2,
        agent_av_in     => agent_av_in_2,
        agent_av_out    => agent_av_out_2,
        agent_full_out  => agent_full_out_2,
        agent_one_p_out => agent_one_p_out_2,
        agent_we_in     => agent_we_in_2,
        agent_empty_out => agent_empty_out_2,
        agent_one_d_out => agent_one_d_out_2,
        agent_re_in     => agent_re_in_2
        -- synthesis translate_off
        -- pragma translate_off
        ,
        debug_out => open,
        debug_in => (others => '0')
        -- pragma translate_on
        -- synthesis translate_on
        );
  end generate a2;


  a3 : if number_of_r4_agents_g > 2 generate
    
    agent_3 : hibi_wrapper_r4
      generic map (
        id_g                => 4,
        base_id_g           => 2**id_width_g-1,
        id_width_g          => id_width_g,
        addr_width_g        => addr_width_g,
        data_width_g        => data_width_g,
        comm_width_g        => comm_width_g,
        counter_width_g     => counter_width_g,
        rx_fifo_depth_g     => fifo_depths_c(3),
        rx_msg_fifo_depth_g => msg_fifo_depths_c(3),
        tx_fifo_depth_g     => fifo_depths_c(3),
        tx_msg_fifo_depth_g => msg_fifo_depths_c(3),
        addr_g              => addr_c(3),
        prior_g             => agent_priority_3_g,
        inv_addr_en_g       => 0,
        max_send_g          => agent_max_send_3_g,
        n_agents_g          => number_of_r4_agents_g + number_of_r3_agents_g,
        n_cfg_pages_g       => 1,
        n_time_slots_g      => 0,
        n_extra_params_g    => 0
        -- cfg_rom_en_g        => 1
        )
      port map (
        bus_clk      => clk,
        agent_clk    => clk,
        bus_sync_clk => clk,
        agent_sync_clk => clk,
        rst_n        => rst_n,
        bus_comm_in  => bus_comm_in,
        bus_comm_out => bus_comm_out_3,
        bus_data_in  => bus_data_in,
        bus_data_out => bus_data_out_3,
        bus_full_in  => bus_full_in,
        bus_full_out => bus_full_out_3,
        bus_lock_in  => bus_lock_in,
        bus_lock_out => bus_lock_out_3,
        bus_av_in    => bus_av_in,
        bus_av_out   => bus_av_out_3,

        agent_comm_in   => agent_comm_in_3,
        agent_comm_out  => agent_comm_out_3,
        agent_data_in   => agent_data_in_3,
        agent_data_out  => agent_data_out_3,
        agent_av_in     => agent_av_in_3,
        agent_av_out    => agent_av_out_3,
        agent_full_out  => agent_full_out_3,
        agent_one_p_out => agent_one_p_out_3,
        agent_we_in     => agent_we_in_3,
        agent_empty_out => agent_empty_out_3,
        agent_one_d_out => agent_one_d_out_3,
        agent_re_in     => agent_re_in_3
        -- synthesis translate_off
        -- pragma translate_off
        ,
        debug_out => open,
        debug_in => (others => '0')
        -- pragma translate_on
        -- synthesis translate_on
        );
  end generate a3;
  a4 : if number_of_r4_agents_g > 3 generate
    
    agent_4 : hibi_wrapper_r4
      generic map (
        id_g                => 5,
        base_id_g           => 2**id_width_g-1,
        id_width_g          => id_width_g,
        addr_width_g        => addr_width_g,
        data_width_g        => data_width_g,
        comm_width_g        => comm_width_g,
        counter_width_g     => counter_width_g,
        rx_fifo_depth_g     => fifo_depths_c(4),
        rx_msg_fifo_depth_g => msg_fifo_depths_c(4),
        tx_fifo_depth_g     => fifo_depths_c(4),
        tx_msg_fifo_depth_g => msg_fifo_depths_c(4),
        addr_g              => addr_c(4),
        prior_g             => agent_priority_4_g,
        inv_addr_en_g       => 0,
        max_send_g          => agent_max_send_4_g,
        n_agents_g          => number_of_r4_agents_g + number_of_r3_agents_g,
        n_cfg_pages_g       => 1,
        n_time_slots_g      => 0,
        n_extra_params_g    => 0
        -- cfg_rom_en_g        => 1
        )
      port map (
        bus_clk      => clk,
        agent_clk    => clk,
        bus_sync_clk => clk,
        agent_sync_clk => clk,
        rst_n        => rst_n,
        bus_comm_in  => bus_comm_in,
        bus_comm_out => bus_comm_out_4,
        bus_data_in  => bus_data_in,
        bus_data_out => bus_data_out_4,
        bus_full_in  => bus_full_in,
        bus_full_out => bus_full_out_4,
        bus_lock_in  => bus_lock_in,
        bus_lock_out => bus_lock_out_4,
        bus_av_in    => bus_av_in,
        bus_av_out   => bus_av_out_4,

        agent_comm_in   => agent_comm_in_4,
        agent_comm_out  => agent_comm_out_4,
        agent_data_in   => agent_data_in_4,
        agent_data_out  => agent_data_out_4,
        agent_av_in     => agent_av_in_4,
        agent_av_out    => agent_av_out_4,
        agent_full_out  => agent_full_out_4,
        agent_one_p_out => agent_one_p_out_4,
        agent_we_in     => agent_we_in_4,
        agent_empty_out => agent_empty_out_4,
        agent_one_d_out => agent_one_d_out_4,
        agent_re_in     => agent_re_in_4
        -- synthesis translate_off
        -- pragma translate_off
        ,
        debug_out => open,
        debug_in => (others => '0')
        -- pragma translate_on
        -- synthesis translate_on
        );
  end generate a4;

  a5 : if number_of_r4_agents_g > 4 generate
    
    agent_5 : hibi_wrapper_r4
      generic map (
        id_g                => 6,
        base_id_g           => 2**id_width_g-1,
        id_width_g          => id_width_g,
        addr_width_g        => addr_width_g,
        data_width_g        => data_width_g,
        comm_width_g        => comm_width_g,
        counter_width_g     => counter_width_g,
        rx_fifo_depth_g     => fifo_depths_c(5),
        rx_msg_fifo_depth_g => msg_fifo_depths_c(5),
        tx_fifo_depth_g     => fifo_depths_c(5),
        tx_msg_fifo_depth_g => msg_fifo_depths_c(5),
        addr_g              => addr_c(5),
        prior_g             => agent_priority_5_g,
        inv_addr_en_g       => 0,
        max_send_g          => agent_max_send_5_g,
        n_agents_g          => number_of_r4_agents_g + number_of_r3_agents_g,
        n_cfg_pages_g       => 1,
        n_time_slots_g      => 0,
        n_extra_params_g    => 0
        -- cfg_rom_en_g        => 1
        )
      port map (
        bus_clk      => clk,
        agent_clk    => clk,
        bus_sync_clk => clk,
        agent_sync_clk => clk,
        rst_n        => rst_n,
        bus_comm_in  => bus_comm_in,
        bus_comm_out => bus_comm_out_5,
        bus_data_in  => bus_data_in,
        bus_data_out => bus_data_out_5,
        bus_full_in  => bus_full_in,
        bus_full_out => bus_full_out_5,
        bus_lock_in  => bus_lock_in,
        bus_lock_out => bus_lock_out_5,
        bus_av_in    => bus_av_in,
        bus_av_out   => bus_av_out_5,

        agent_comm_in   => agent_comm_in_5,
        agent_comm_out  => agent_comm_out_5,
        agent_data_in   => agent_data_in_5,
        agent_data_out  => agent_data_out_5,
        agent_av_in     => agent_av_in_5,
        agent_av_out    => agent_av_out_5,
        agent_full_out  => agent_full_out_5,
        agent_one_p_out => agent_one_p_out_5,
        agent_we_in     => agent_we_in_5,
        agent_empty_out => agent_empty_out_5,
        agent_one_d_out => agent_one_d_out_5,
        agent_re_in     => agent_re_in_5
        -- synthesis translate_off
        -- pragma translate_off
        ,
        debug_out => open,
        debug_in => (others => '0')
        -- pragma translate_on
        -- synthesis translate_on
        );
  end generate a5;

  a6 : if number_of_r4_agents_g > 5 generate
    
    agent_6 : hibi_wrapper_r4
      generic map (
        id_g                => 7,
        base_id_g           => 2**id_width_g-1,
        id_width_g          => id_width_g,
        addr_width_g        => addr_width_g,
        data_width_g        => data_width_g,
        comm_width_g        => comm_width_g,
        counter_width_g     => counter_width_g,
        rx_fifo_depth_g     => fifo_depths_c(6),
        rx_msg_fifo_depth_g => msg_fifo_depths_c(6),
        tx_fifo_depth_g     => fifo_depths_c(6),
        tx_msg_fifo_depth_g => msg_fifo_depths_c(6),
        addr_g              => addr_c(6),
        prior_g             => agent_priority_6_g,
        inv_addr_en_g       => 0,
        max_send_g          => agent_max_send_6_g,
        n_agents_g          => number_of_r4_agents_g + number_of_r3_agents_g,
        n_cfg_pages_g       => 1,
        n_time_slots_g      => 0,
        n_extra_params_g    => 0
        -- cfg_rom_en_g        => 1
        )
      port map (
        bus_clk      => clk,
        agent_clk    => clk,
        bus_sync_clk => clk,
        agent_sync_clk => clk,
        rst_n        => rst_n,
        bus_comm_in  => bus_comm_in,
        bus_comm_out => bus_comm_out_6,
        bus_data_in  => bus_data_in,
        bus_data_out => bus_data_out_6,
        bus_full_in  => bus_full_in,
        bus_full_out => bus_full_out_6,
        bus_lock_in  => bus_lock_in,
        bus_lock_out => bus_lock_out_6,
        bus_av_in    => bus_av_in,
        bus_av_out   => bus_av_out_6,

        agent_comm_in   => agent_comm_in_6,
        agent_comm_out  => agent_comm_out_6,
        agent_data_in   => agent_data_in_6,
        agent_data_out  => agent_data_out_6,
        agent_av_in     => agent_av_in_6,
        agent_av_out    => agent_av_out_6,
        agent_full_out  => agent_full_out_6,
        agent_one_p_out => agent_one_p_out_6,
        agent_we_in     => agent_we_in_6,
        agent_empty_out => agent_empty_out_6,
        agent_one_d_out => agent_one_d_out_6,
        agent_re_in     => agent_re_in_6
        -- synthesis translate_off
        -- pragma translate_off
        ,
        debug_out => open,
        debug_in => (others => '0')
        -- pragma translate_on
        -- synthesis translate_on
        );
  end generate a6;
  a7 : if number_of_r4_agents_g > 6 generate
    
    agent_7 : hibi_wrapper_r4
      generic map (
        id_g                => 8,
        base_id_g           => 2**id_width_g-1,
        id_width_g          => id_width_g,
        addr_width_g        => addr_width_g,
        data_width_g        => data_width_g,
        comm_width_g        => comm_width_g,
        counter_width_g     => counter_width_g,
        rx_fifo_depth_g     => fifo_depths_c(7),
        rx_msg_fifo_depth_g => msg_fifo_depths_c(7),
        tx_fifo_depth_g     => fifo_depths_c(7),
        tx_msg_fifo_depth_g => msg_fifo_depths_c(7),
        addr_g              => addr_c(7),
        prior_g             => agent_priority_7_g,
        inv_addr_en_g       => 0,
        max_send_g          => agent_max_send_7_g,
        n_agents_g          => number_of_r4_agents_g + number_of_r3_agents_g,
        n_cfg_pages_g       => 1,
        n_time_slots_g      => 0,
        n_extra_params_g    => 0
        -- cfg_rom_en_g        => 1
        )
      port map (
        bus_clk      => clk,
        agent_clk    => clk,
        bus_sync_clk => clk,
        agent_sync_clk => clk,
        rst_n        => rst_n,
        bus_comm_in  => bus_comm_in,
        bus_comm_out => bus_comm_out_7,
        bus_data_in  => bus_data_in,
        bus_data_out => bus_data_out_7,
        bus_full_in  => bus_full_in,
        bus_full_out => bus_full_out_7,
        bus_lock_in  => bus_lock_in,
        bus_lock_out => bus_lock_out_7,
        bus_av_in    => bus_av_in,
        bus_av_out   => bus_av_out_7,

        agent_comm_in   => agent_comm_in_7,
        agent_comm_out  => agent_comm_out_7,
        agent_data_in   => agent_data_in_7,
        agent_data_out  => agent_data_out_7,
        agent_av_in     => agent_av_in_7,
        agent_av_out    => agent_av_out_7,
        agent_full_out  => agent_full_out_7,
        agent_one_p_out => agent_one_p_out_7,
        agent_we_in     => agent_we_in_7,
        agent_empty_out => agent_empty_out_7,
        agent_one_d_out => agent_one_d_out_7,
        agent_re_in     => agent_re_in_7
        -- synthesis translate_off
        -- pragma translate_off
        ,
        debug_out => open,
        debug_in => (others => '0')
        -- pragma translate_on
        -- synthesis translate_on
        );

  end generate a7;

  a8 : if number_of_r4_agents_g > 7 generate
    
    agent_8 : hibi_wrapper_r4
      generic map (
        id_g                => 9,
        base_id_g           => 2**id_width_g-1,
        id_width_g          => id_width_g,
        addr_width_g        => addr_width_g,
        data_width_g        => data_width_g,
        comm_width_g        => comm_width_g,
        counter_width_g     => counter_width_g,
        rx_fifo_depth_g     => fifo_depths_c(8),
        rx_msg_fifo_depth_g => msg_fifo_depths_c(8),
        tx_fifo_depth_g     => fifo_depths_c(8),
        tx_msg_fifo_depth_g => msg_fifo_depths_c(8),
        addr_g              => addr_c(8),
        prior_g             => agent_priority_8_g,
        inv_addr_en_g       => 0,
        max_send_g          => agent_max_send_8_g,
        n_agents_g          => number_of_r4_agents_g + number_of_r3_agents_g,
        n_cfg_pages_g       => 1,
        n_time_slots_g      => 0,
        n_extra_params_g    => 0
        -- cfg_rom_en_g        => 1
        )
      port map (
        bus_clk      => clk,
        agent_clk    => clk,
        bus_sync_clk => clk,
        agent_sync_clk => clk,
        rst_n        => rst_n,
        bus_comm_in  => bus_comm_in,
        bus_comm_out => bus_comm_out_8,
        bus_data_in  => bus_data_in,
        bus_data_out => bus_data_out_8,
        bus_full_in  => bus_full_in,
        bus_full_out => bus_full_out_8,
        bus_lock_in  => bus_lock_in,
        bus_lock_out => bus_lock_out_8,
        bus_av_in    => bus_av_in,
        bus_av_out   => bus_av_out_8,

        agent_comm_in   => agent_comm_in_8,
        agent_comm_out  => agent_comm_out_8,
        agent_data_in   => agent_data_in_8,
        agent_data_out  => agent_data_out_8,
        agent_av_in     => agent_av_in_8,
        agent_av_out    => agent_av_out_8,
        agent_full_out  => agent_full_out_8,
        agent_one_p_out => agent_one_p_out_8,
        agent_we_in     => agent_we_in_8,
        agent_empty_out => agent_empty_out_8,
        agent_one_d_out => agent_one_d_out_8,
        agent_re_in     => agent_re_in_8
        -- synthesis translate_off
        -- pragma translate_off
        ,
        debug_out => open,
        debug_in => (others => '0')
        -- pragma translate_on
        -- synthesis translate_on
        );
  end generate a8;
  

  a9 : if number_of_r4_agents_g > 8 generate
    
    agent_9 : hibi_wrapper_r4
      generic map (
        id_g                => 10,
        base_id_g           => 2**id_width_g-1,
        id_width_g          => id_width_g,
        addr_width_g        => addr_width_g,
        data_width_g        => data_width_g,
        comm_width_g        => comm_width_g,
        counter_width_g     => counter_width_g,
        rx_fifo_depth_g     => fifo_depths_c(9),
        rx_msg_fifo_depth_g => msg_fifo_depths_c(9),
        tx_fifo_depth_g     => fifo_depths_c(9),
        tx_msg_fifo_depth_g => msg_fifo_depths_c(9),
        addr_g              => addr_c(9),
        prior_g             => agent_priority_9_g,
        inv_addr_en_g       => 0,
        max_send_g          => agent_max_send_9_g,
        n_agents_g          => number_of_r4_agents_g + number_of_r3_agents_g,
        n_cfg_pages_g       => 1,
        n_time_slots_g      => 0,
        n_extra_params_g    => 0
        -- cfg_rom_en_g        => 1
        )
      port map (
        bus_clk      => clk,
        agent_clk    => clk,
        bus_sync_clk => clk,
        agent_sync_clk => clk,
        rst_n        => rst_n,
        bus_comm_in  => bus_comm_in,
        bus_comm_out => bus_comm_out_9,
        bus_data_in  => bus_data_in,
        bus_data_out => bus_data_out_9,
        bus_full_in  => bus_full_in,
        bus_full_out => bus_full_out_9,
        bus_lock_in  => bus_lock_in,
        bus_lock_out => bus_lock_out_9,
        bus_av_in    => bus_av_in,
        bus_av_out   => bus_av_out_9,

        agent_comm_in   => agent_comm_in_9,
        agent_comm_out  => agent_comm_out_9,
        agent_data_in   => agent_data_in_9,
        agent_data_out  => agent_data_out_9,
        agent_av_in     => agent_av_in_9,
        agent_av_out    => agent_av_out_9,
        agent_full_out  => agent_full_out_9,
        agent_one_p_out => agent_one_p_out_9,
        agent_we_in     => agent_we_in_9,
        agent_empty_out => agent_empty_out_9,
        agent_one_d_out => agent_one_d_out_9,
        agent_re_in     => agent_re_in_9
        -- synthesis translate_off
        -- pragma translate_off
        ,
        debug_out => open,
        debug_in => (others => '0')
        -- pragma translate_on
        -- synthesis translate_on
        );
  end generate a9;
  

  a10 : if number_of_r4_agents_g > 9 generate
    
    agent_10 : hibi_wrapper_r4
      generic map (
        id_g                => 11,
        base_id_g           => 2**id_width_g-1,
        id_width_g          => id_width_g,
        addr_width_g        => addr_width_g,
        data_width_g        => data_width_g,
        comm_width_g        => comm_width_g,
        counter_width_g     => counter_width_g,
        rx_fifo_depth_g     => fifo_depths_c(10),
        rx_msg_fifo_depth_g => msg_fifo_depths_c(10),
        tx_fifo_depth_g     => fifo_depths_c(10),
        tx_msg_fifo_depth_g => msg_fifo_depths_c(10),
        addr_g              => addr_c(10),
        prior_g             => agent_priority_10_g,
        inv_addr_en_g       => 0,
        max_send_g          => agent_max_send_10_g,
        n_agents_g          => number_of_r4_agents_g + number_of_r3_agents_g,
        n_cfg_pages_g       => 1,
        n_time_slots_g      => 0,
        n_extra_params_g    => 0
        -- cfg_rom_en_g        => 1
        )
      port map (
        bus_clk      => clk,
        agent_clk    => clk,
        bus_sync_clk => clk,
        agent_sync_clk => clk,
        rst_n        => rst_n,
        bus_comm_in  => bus_comm_in,
        bus_comm_out => bus_comm_out_10,
        bus_data_in  => bus_data_in,
        bus_data_out => bus_data_out_10,
        bus_full_in  => bus_full_in,
        bus_full_out => bus_full_out_10,
        bus_lock_in  => bus_lock_in,
        bus_lock_out => bus_lock_out_10,
        bus_av_in    => bus_av_in,
        bus_av_out   => bus_av_out_10,

        agent_comm_in   => agent_comm_in_10,
        agent_comm_out  => agent_comm_out_10,
        agent_data_in   => agent_data_in_10,
        agent_data_out  => agent_data_out_10,
        agent_av_in     => agent_av_in_10,
        agent_av_out    => agent_av_out_10,
        agent_full_out  => agent_full_out_10,
        agent_one_p_out => agent_one_p_out_10,
        agent_we_in     => agent_we_in_10,
        agent_empty_out => agent_empty_out_10,
        agent_one_d_out => agent_one_d_out_10,
        agent_re_in     => agent_re_in_10
        -- synthesis translate_off
        -- pragma translate_off
        ,
        debug_out => open,
        debug_in => (others => '0')
        -- pragma translate_on
        -- synthesis translate_on
        );
  end generate a10;
  

  a11 : if number_of_r4_agents_g > 10 generate
    
    agent_11 : hibi_wrapper_r4
      generic map (
        id_g                => 12,
        base_id_g           => 2**id_width_g-1,
        id_width_g          => id_width_g,
        addr_width_g        => addr_width_g,
        data_width_g        => data_width_g,
        comm_width_g        => comm_width_g,
        counter_width_g     => counter_width_g,
        rx_fifo_depth_g     => fifo_depths_c(11),
        rx_msg_fifo_depth_g => msg_fifo_depths_c(11),
        tx_fifo_depth_g     => fifo_depths_c(11),
        tx_msg_fifo_depth_g => msg_fifo_depths_c(11),
        addr_g              => addr_c(11),
        prior_g             => agent_priority_11_g,
        inv_addr_en_g       => 0,
        max_send_g          => agent_max_send_11_g,
        n_agents_g          => number_of_r4_agents_g + number_of_r3_agents_g,
        n_cfg_pages_g       => 1,
        n_time_slots_g      => 0,
        n_extra_params_g    => 0
        -- cfg_rom_en_g        => 1
        )
      port map (
        bus_clk      => clk,
        agent_clk    => clk,
        bus_sync_clk => clk,
        agent_sync_clk => clk,
        rst_n        => rst_n,
        bus_comm_in  => bus_comm_in,
        bus_comm_out => bus_comm_out_11,
        bus_data_in  => bus_data_in,
        bus_data_out => bus_data_out_11,
        bus_full_in  => bus_full_in,
        bus_full_out => bus_full_out_11,
        bus_lock_in  => bus_lock_in,
        bus_lock_out => bus_lock_out_11,
        bus_av_in    => bus_av_in,
        bus_av_out   => bus_av_out_11,

        agent_comm_in   => agent_comm_in_11,
        agent_comm_out  => agent_comm_out_11,
        agent_data_in   => agent_data_in_11,
        agent_data_out  => agent_data_out_11,
        agent_av_in     => agent_av_in_11,
        agent_av_out    => agent_av_out_11,
        agent_full_out  => agent_full_out_11,
        agent_one_p_out => agent_one_p_out_11,
        agent_we_in     => agent_we_in_11,
        agent_empty_out => agent_empty_out_11,
        agent_one_d_out => agent_one_d_out_11,
        agent_re_in     => agent_re_in_11
        -- synthesis translate_off
        -- pragma translate_off
        ,
        debug_out => open,
        debug_in => (others => '0')
        -- pragma translate_on
        -- synthesis translate_on
        );
  end generate a11;
  

  a12 : if number_of_r4_agents_g > 11 generate
    
    agent_12 : hibi_wrapper_r4
      generic map (
        id_g                => 13,
        base_id_g           => 2**id_width_g-1,
        id_width_g          => id_width_g,
        addr_width_g        => addr_width_g,
        data_width_g        => data_width_g,
        comm_width_g        => comm_width_g,
        counter_width_g     => counter_width_g,
        rx_fifo_depth_g     => fifo_depths_c(12),
        rx_msg_fifo_depth_g => msg_fifo_depths_c(12),
        tx_fifo_depth_g     => fifo_depths_c(12),
        tx_msg_fifo_depth_g => msg_fifo_depths_c(12),
        addr_g              => addr_c(12),
        prior_g             => agent_priority_12_g,
        inv_addr_en_g       => 0,
        max_send_g          => agent_max_send_12_g,
        n_agents_g          => number_of_r4_agents_g + number_of_r3_agents_g,
        n_cfg_pages_g       => 1,
        n_time_slots_g      => 0,
        n_extra_params_g    => 0
        -- cfg_rom_en_g        => 1
        )
      port map (
        bus_clk      => clk,
        agent_clk    => clk,
        bus_sync_clk => clk,
        agent_sync_clk => clk,
        rst_n        => rst_n,
        bus_comm_in  => bus_comm_in,
        bus_comm_out => bus_comm_out_12,
        bus_data_in  => bus_data_in,
        bus_data_out => bus_data_out_12,
        bus_full_in  => bus_full_in,
        bus_full_out => bus_full_out_12,
        bus_lock_in  => bus_lock_in,
        bus_lock_out => bus_lock_out_12,
        bus_av_in    => bus_av_in,
        bus_av_out   => bus_av_out_12,

        agent_comm_in   => agent_comm_in_12,
        agent_comm_out  => agent_comm_out_12,
        agent_data_in   => agent_data_in_12,
        agent_data_out  => agent_data_out_12,
        agent_av_in     => agent_av_in_12,
        agent_av_out    => agent_av_out_12,
        agent_full_out  => agent_full_out_12,
        agent_one_p_out => agent_one_p_out_12,
        agent_we_in     => agent_we_in_12,
        agent_empty_out => agent_empty_out_12,
        agent_one_d_out => agent_one_d_out_12,
        agent_re_in     => agent_re_in_12
        -- synthesis translate_off
        -- pragma translate_off
        ,
        debug_out => open,
        debug_in => (others => '0')
        -- pragma translate_on
        -- synthesis translate_on
        );
  end generate a12;

  a13 : if number_of_r4_agents_g > 12 generate
    
    agent_13 : hibi_wrapper_r4
      generic map (
        id_g                => 14,
        base_id_g           => 2**id_width_g-1,
        id_width_g          => id_width_g,
        addr_width_g        => addr_width_g,
        data_width_g        => data_width_g,
        comm_width_g        => comm_width_g,
        counter_width_g     => counter_width_g,
        rx_fifo_depth_g     => fifo_depths_c(13),
        rx_msg_fifo_depth_g => msg_fifo_depths_c(13),
        tx_fifo_depth_g     => fifo_depths_c(13),
        tx_msg_fifo_depth_g => msg_fifo_depths_c(13),
        addr_g              => addr_c(13),
        prior_g             => agent_priority_13_g,
        inv_addr_en_g       => 0,
        max_send_g          => agent_max_send_13_g,
        n_agents_g          => number_of_r4_agents_g + number_of_r3_agents_g,
        n_cfg_pages_g       => 1,
        n_time_slots_g      => 0,
        n_extra_params_g    => 0
        -- cfg_rom_en_g        => 1
        )
      port map (
        bus_clk      => clk,
        agent_clk    => clk,
        bus_sync_clk => clk,
        agent_sync_clk => clk,
        rst_n        => rst_n,
        bus_comm_in  => bus_comm_in,
        bus_comm_out => bus_comm_out_13,
        bus_data_in  => bus_data_in,
        bus_data_out => bus_data_out_13,
        bus_full_in  => bus_full_in,
        bus_full_out => bus_full_out_13,
        bus_lock_in  => bus_lock_in,
        bus_lock_out => bus_lock_out_13,
        bus_av_in    => bus_av_in,
        bus_av_out   => bus_av_out_13,

        agent_comm_in   => agent_comm_in_13,
        agent_comm_out  => agent_comm_out_13,
        agent_data_in   => agent_data_in_13,
        agent_data_out  => agent_data_out_13,
        agent_av_in     => agent_av_in_13,
        agent_av_out    => agent_av_out_13,
        agent_full_out  => agent_full_out_13,
        agent_one_p_out => agent_one_p_out_13,
        agent_we_in     => agent_we_in_13,
        agent_empty_out => agent_empty_out_13,
        agent_one_d_out => agent_one_d_out_13,
        agent_re_in     => agent_re_in_13
        -- synthesis translate_off
        -- pragma translate_off
        ,
        debug_out => open,
        debug_in => (others => '0')
        -- pragma translate_on
        -- synthesis translate_on
        );
  end generate a13;
  

  a14 : if number_of_r4_agents_g > 13 generate
    
    agent_14 : hibi_wrapper_r4
      generic map (
        id_g                => 15,
        base_id_g           => 2**id_width_g-1,
        id_width_g          => id_width_g,
        addr_width_g        => addr_width_g,
        data_width_g        => data_width_g,
        comm_width_g        => comm_width_g,
        counter_width_g     => counter_width_g,
        rx_fifo_depth_g     => fifo_depths_c(14),
        rx_msg_fifo_depth_g => msg_fifo_depths_c(14),
        tx_fifo_depth_g     => fifo_depths_c(14),
        tx_msg_fifo_depth_g => msg_fifo_depths_c(14),
        addr_g              => addr_c(14),
        prior_g             => agent_priority_14_g,
        inv_addr_en_g       => 0,
        max_send_g          => agent_max_send_14_g,
        n_agents_g          => number_of_r4_agents_g + number_of_r3_agents_g,
        n_cfg_pages_g       => 1,
        n_time_slots_g      => 0,
        n_extra_params_g    => 0
        -- cfg_rom_en_g        => 1
        )
      port map (
        bus_clk      => clk,
        agent_clk    => clk,
        bus_sync_clk => clk,
        agent_sync_clk => clk,
        rst_n        => rst_n,
        bus_comm_in  => bus_comm_in,
        bus_comm_out => bus_comm_out_14,
        bus_data_in  => bus_data_in,
        bus_data_out => bus_data_out_14,
        bus_full_in  => bus_full_in,
        bus_full_out => bus_full_out_14,
        bus_lock_in  => bus_lock_in,
        bus_lock_out => bus_lock_out_14,
        bus_av_in    => bus_av_in,
        bus_av_out   => bus_av_out_14,

        agent_comm_in   => agent_comm_in_14,
        agent_comm_out  => agent_comm_out_14,
        agent_data_in   => agent_data_in_14,
        agent_data_out  => agent_data_out_14,
        agent_av_in     => agent_av_in_14,
        agent_av_out    => agent_av_out_14,
        agent_full_out  => agent_full_out_14,
        agent_one_p_out => agent_one_p_out_14,
        agent_we_in     => agent_we_in_14,
        agent_empty_out => agent_empty_out_14,
        agent_one_d_out => agent_one_d_out_14,
        agent_re_in     => agent_re_in_14
        -- synthesis translate_off
        -- pragma translate_off
        ,
        debug_out => open,
        debug_in => (others => '0')
        -- pragma translate_on
        -- synthesis translate_on
        );
  end generate a14;
  

  a15 : if number_of_r4_agents_g > 14 generate
    
    agent_15 : hibi_wrapper_r4
      generic map (
        id_g                => 16,
        base_id_g           => 2**id_width_g-1,
        id_width_g          => id_width_g,
        addr_width_g        => addr_width_g,
        data_width_g        => data_width_g,
        comm_width_g        => comm_width_g,
        counter_width_g     => counter_width_g,
        rx_fifo_depth_g     => fifo_depths_c(15),
        rx_msg_fifo_depth_g => msg_fifo_depths_c(15),
        tx_fifo_depth_g     => fifo_depths_c(15),
        tx_msg_fifo_depth_g => msg_fifo_depths_c(15),
        addr_g              => addr_c(15),
        prior_g             => agent_priority_15_g,
        inv_addr_en_g       => 0,
        max_send_g          => agent_max_send_15_g,
        n_agents_g          => number_of_r4_agents_g + number_of_r3_agents_g,
        n_cfg_pages_g       => 1,
        n_time_slots_g      => 0,
        n_extra_params_g    => 0
        -- cfg_rom_en_g        => 1
        )
      port map (
        bus_clk      => clk,
        agent_clk    => clk,
        bus_sync_clk => clk,
        agent_sync_clk => clk,
        rst_n        => rst_n,
        bus_comm_in  => bus_comm_in,
        bus_comm_out => bus_comm_out_15,
        bus_data_in  => bus_data_in,
        bus_data_out => bus_data_out_15,
        bus_full_in  => bus_full_in,
        bus_full_out => bus_full_out_15,
        bus_lock_in  => bus_lock_in,
        bus_lock_out => bus_lock_out_15,
        bus_av_in    => bus_av_in,
        bus_av_out   => bus_av_out_15,

        agent_comm_in   => agent_comm_in_15,
        agent_comm_out  => agent_comm_out_15,
        agent_data_in   => agent_data_in_15,
        agent_data_out  => agent_data_out_15,
        agent_av_in     => agent_av_in_15,
        agent_av_out    => agent_av_out_15,
        agent_full_out  => agent_full_out_15,
        agent_one_p_out => agent_one_p_out_15,
        agent_we_in     => agent_we_in_15,
        agent_empty_out => agent_empty_out_15,
        agent_one_d_out => agent_one_d_out_15,
        agent_re_in     => agent_re_in_15
        -- synthesis translate_off
        -- pragma translate_off
        ,
        debug_out => open,
        debug_in => (others => '0')
        -- pragma translate_on
        -- synthesis translate_on
        );
  end generate a15;

  a16 : if number_of_r4_agents_g > 15 generate
    
    agent_16 : hibi_wrapper_r4
      generic map (
        id_g                => 17,
        base_id_g           => 2**id_width_g-1,
        id_width_g          => id_width_g,
        addr_width_g        => addr_width_g,
        data_width_g        => data_width_g,
        comm_width_g        => comm_width_g,
        counter_width_g     => counter_width_g,
        rx_fifo_depth_g     => fifo_depths_c(16),
        rx_msg_fifo_depth_g => msg_fifo_depths_c(16),
        tx_fifo_depth_g     => fifo_depths_c(16),
        tx_msg_fifo_depth_g => msg_fifo_depths_c(16),
        addr_g              => addr_c(16),
        prior_g             => agent_priority_16_g,
        inv_addr_en_g       => 0,
        max_send_g          => agent_max_send_16_g,
        n_agents_g          => number_of_r4_agents_g + number_of_r3_agents_g,
        n_cfg_pages_g       => 1,
        n_time_slots_g      => 0,
        n_extra_params_g    => 0
        -- cfg_rom_en_g        => 1
        )
      port map (
        bus_clk      => clk,
        agent_clk    => clk,
        bus_sync_clk => clk,
        agent_sync_clk => clk,
        rst_n        => rst_n,
        bus_comm_in  => bus_comm_in,
        bus_comm_out => bus_comm_out_16,
        bus_data_in  => bus_data_in,
        bus_data_out => bus_data_out_16,
        bus_full_in  => bus_full_in,
        bus_full_out => bus_full_out_16,
        bus_lock_in  => bus_lock_in,
        bus_lock_out => bus_lock_out_16,
        bus_av_in    => bus_av_in,
        bus_av_out   => bus_av_out_16,

        agent_comm_in   => agent_comm_in_16,
        agent_comm_out  => agent_comm_out_16,
        agent_data_in   => agent_data_in_16,
        agent_data_out  => agent_data_out_16,
        agent_av_in     => agent_av_in_16,
        agent_av_out    => agent_av_out_16,
        agent_full_out  => agent_full_out_16,
        agent_one_p_out => agent_one_p_out_16,
        agent_we_in     => agent_we_in_16,
        agent_empty_out => agent_empty_out_16,
        agent_one_d_out => agent_one_d_out_16,
        agent_re_in     => agent_re_in_16
        -- synthesis translate_off
        -- pragma translate_off
        ,
        debug_out => open,
        debug_in => (others => '0')
        -- pragma translate_on
        -- synthesis translate_on
        );
  end generate a16;
  
  a17 : if number_of_r3_agents_g > 0 generate
    
    agent_17 : hibi_wrapper_r3
      generic map (
        id_g                => number_of_r4_agents_g + 2, --because indexing starts from 2...
        base_id_g           => 2**id_width_g-1,
        id_width_g          => id_width_g,
        addr_width_g        => addr_width_g,
        data_width_g        => data_width_g,
        comm_width_g        => comm_width_g,
        counter_width_g     => counter_width_g,
        rx_fifo_depth_g     => fifo_depths_c(17),
        rx_msg_fifo_depth_g => msg_fifo_depths_c(17),
        tx_fifo_depth_g     => fifo_depths_c(17),
        tx_msg_fifo_depth_g => msg_fifo_depths_c(17),
        addr_g              => addr_c(17),
        prior_g             => number_of_r4_agents_g + 1, -- to prevent empty priority numbers.
        inv_addr_en_g       => 0,
        max_send_g          => agent_max_send_17_g,
        n_agents_g          => number_of_r4_agents_g + number_of_r3_agents_g,
        n_cfg_pages_g       => 1,
        n_time_slots_g      => 0,
        n_extra_params_g    => 0
        -- cfg_rom_en_g        => 1
        )
      port map (
        bus_clk      => clk,
        agent_clk    => clk,
        bus_sync_clk => clk,
        agent_sync_clk => clk,
        rst_n        => rst_n,
        bus_comm_in  => bus_comm_in,
        bus_comm_out => bus_comm_out_17,
        bus_data_in  => bus_data_in,
        bus_data_out => bus_data_out_17,
        bus_full_in  => bus_full_in,
        bus_full_out => bus_full_out_17,
        bus_lock_in  => bus_lock_in,
        bus_lock_out => bus_lock_out_17,
        bus_av_in    => bus_av_in,
        bus_av_out   => bus_av_out_17,

        agent_addr_in   => agent_addr_in_17,
        agent_addr_out  => agent_addr_out_17,
        agent_comm_in   => agent_comm_in_17,
        agent_comm_out  => agent_comm_out_17,
        agent_data_in   => agent_data_in_17,
        agent_data_out  => agent_data_out_17,
        agent_full_out  => agent_full_out_17,
        agent_one_p_out => agent_one_p_out_17,
        agent_we_in     => agent_we_in_17,
        agent_empty_out => agent_empty_out_17,
        agent_one_d_out => agent_one_d_out_17,
        agent_re_in     => agent_re_in_17,
        
        agent_msg_data_in => agent_msg_data_in_17,
        agent_msg_addr_in => agent_msg_addr_in_17,
        agent_msg_comm_in => agent_msg_comm_in_17,
        agent_msg_we_in   => agent_msg_we_in_17,
        agent_msg_re_in   => agent_msg_re_in_17,      
        agent_msg_data_out  => agent_msg_data_out_17,
        agent_msg_addr_out  => agent_msg_addr_out_17,
        agent_msg_comm_out  => agent_msg_comm_out_17,
        agent_msg_empty_out => agent_msg_empty_out_17,
        agent_msg_one_d_out => agent_msg_one_d_out_17,
        agent_msg_full_out  => agent_msg_full_out_17,
        agent_msg_one_p_out => agent_msg_one_p_out_17
        );
  end generate a17;
  
  -- only one agent
  s2 : if number_of_r4_agents_g < 2 generate
    bus_data_out_2 <= (others => '0');
    bus_comm_out_2 <= (others => '0');
    bus_lock_out_2 <= '0';
    bus_av_out_2   <= '0';
    bus_full_out_2 <= '0';
    agent_data_out_2 <= (others => '0');
  end generate s2;

  s3 : if number_of_r4_agents_g < 3 generate
    bus_data_out_3 <= (others => '0');
    bus_comm_out_3 <= (others => '0');
    bus_lock_out_3 <= '0';
    bus_av_out_3   <= '0';
    bus_full_out_3 <= '0';
    agent_data_out_3 <= (others => '0');
  end generate s3;

  s4 : if number_of_r4_agents_g < 4 generate
    bus_data_out_4 <= (others => '0');
    bus_comm_out_4 <= (others => '0');
    bus_lock_out_4 <= '0';
    bus_av_out_4   <= '0';
    bus_full_out_4 <= '0';
    agent_data_out_4 <= (others => '0');
  end generate s4;

  s5 : if number_of_r4_agents_g < 5 generate
    bus_data_out_5 <= (others => '0');
    bus_comm_out_5 <= (others => '0');
    bus_lock_out_5 <= '0';
    bus_av_out_5   <= '0';
    bus_full_out_5 <= '0';
    agent_data_out_5 <= (others => '0');
  end generate s5;

  s6 : if number_of_r4_agents_g < 6 generate
    bus_data_out_6 <= (others => '0');
    bus_comm_out_6 <= (others => '0');
    bus_lock_out_6 <= '0';
    bus_av_out_6   <= '0';
    bus_full_out_6 <= '0';
    agent_data_out_6 <= (others => '0');
  end generate s6;

  s7 : if number_of_r4_agents_g < 7 generate
    bus_data_out_7 <= (others => '0');
    bus_comm_out_7 <= (others => '0');
    bus_lock_out_7 <= '0';
    bus_av_out_7   <= '0';
    bus_full_out_7 <= '0';
    agent_data_out_7 <= (others => '0');
  end generate s7;

  s8 : if number_of_r4_agents_g < 8 generate
    bus_data_out_8 <= (others => '0');
    bus_comm_out_8 <= (others => '0');
    bus_lock_out_8 <= '0';
    bus_av_out_8   <= '0';
    bus_full_out_8 <= '0';
    agent_data_out_8 <= (others => '0');
  end generate s8;

  s9 : if number_of_r4_agents_g < 9 generate
    bus_data_out_9 <= (others => '0');
    bus_comm_out_9 <= (others => '0');
    bus_lock_out_9 <= '0';
    bus_av_out_9   <= '0';
    bus_full_out_9 <= '0';
    agent_data_out_9 <= (others => '0');
  end generate s9;
  
  s10 : if number_of_r4_agents_g < 10 generate
    bus_data_out_10 <= (others => '0');
    bus_comm_out_10 <= (others => '0');
    bus_lock_out_10 <= '0';
    bus_av_out_10   <= '0';
    bus_full_out_10 <= '0';
    agent_data_out_10 <= (others => '0');
  end generate s10;
  
  s11 : if number_of_r4_agents_g < 11 generate
    bus_data_out_11 <= (others => '0');
    bus_comm_out_11 <= (others => '0');
    bus_lock_out_11 <= '0';
    bus_av_out_11   <= '0';
    bus_full_out_11 <= '0';
    agent_data_out_11 <= (others => '0');
  end generate s11;
  
  s12 : if number_of_r4_agents_g < 12 generate
    bus_data_out_12 <= (others => '0');
    bus_comm_out_12 <= (others => '0');
    bus_lock_out_12 <= '0';
    bus_av_out_12   <= '0';
    bus_full_out_12 <= '0';
    agent_data_out_12 <= (others => '0');
  end generate s12;
  
  s13 : if number_of_r4_agents_g < 13 generate
    bus_data_out_13 <= (others => '0');
    bus_comm_out_13 <= (others => '0');
    bus_lock_out_13 <= '0';
    bus_av_out_13   <= '0';
    bus_full_out_13 <= '0';
    agent_data_out_13 <= (others => '0');
  end generate s13;
  
  s14 : if number_of_r4_agents_g < 14 generate
    bus_data_out_14 <= (others => '0');
    bus_comm_out_14 <= (others => '0');
    bus_lock_out_14 <= '0';
    bus_av_out_14   <= '0';
    bus_full_out_14 <= '0';
    agent_data_out_14 <= (others => '0');
  end generate s14;
  
  s15 : if number_of_r4_agents_g < 15 generate
    bus_data_out_15 <= (others => '0');
    bus_comm_out_15 <= (others => '0');
    bus_lock_out_15 <= '0';
    bus_av_out_15   <= '0';
    bus_full_out_15 <= '0';
    agent_data_out_15 <= (others => '0');
  end generate s15;
  
  s16 : if number_of_r4_agents_g < 16 generate
    bus_data_out_16 <= (others => '0');
    bus_comm_out_16 <= (others => '0');
    bus_lock_out_16 <= '0';
    bus_av_out_16   <= '0';
    bus_full_out_16 <= '0';
    agent_data_out_16 <= (others => '0');
  end generate s16;
  
  s17 : if number_of_r3_agents_g < 1 generate
    bus_data_out_17 <= (others => '0');
    bus_comm_out_17 <= (others => '0');
    bus_lock_out_17 <= '0';
    bus_av_out_17   <= '0';
    bus_full_out_17 <= '0';
    agent_msg_data_out_17 <= (others => '0');
  end generate s17;
  
  -- continuous assignments
  bus_comm_in <= bus_comm_out_1 or bus_comm_out_2 or bus_comm_out_3
                 or bus_comm_out_4 or bus_comm_out_5 or bus_comm_out_6
                 or bus_comm_out_7 or bus_comm_out_8 or bus_comm_out_9
                 or bus_comm_out_10 or bus_comm_out_11 or bus_comm_out_12
                 or bus_comm_out_13 or bus_comm_out_14 or bus_comm_out_15
                 or bus_comm_out_16 or bus_comm_out_17;  -- after period/3;
  bus_av_in <= bus_av_out_1 or bus_av_out_2
               or bus_av_out_3 or bus_av_out_4
               or bus_av_out_5 or bus_av_out_6
               or bus_av_out_7 or bus_av_out_8
               or bus_av_out_9 or bus_av_out_10
               or bus_av_out_11 or bus_av_out_12
               or bus_av_out_13 or bus_av_out_14
               or bus_av_out_15 or bus_av_out_16
               or bus_av_out_17;        -- after period/3;
  bus_lock_in <= bus_lock_out_1 or bus_lock_out_2 or bus_lock_out_3
                 or bus_lock_out_4 or bus_lock_out_5 or bus_lock_out_6
                 or bus_lock_out_7 or bus_lock_out_8 or bus_lock_out_9
                 or bus_lock_out_10 or bus_lock_out_11 or bus_lock_out_12
                 or bus_lock_out_13 or bus_lock_out_14 or bus_lock_out_15
                 or bus_lock_out_16 or bus_lock_out_17;  -- after period/3;

  bus_full_in <= bus_full_out_1
                 or bus_full_out_2
                 or bus_full_out_3
                 or bus_full_out_4
                 or bus_full_out_5
                 or bus_full_out_6
                 or bus_full_out_7
                 or bus_full_out_8
                 or bus_full_out_9
                 or bus_full_out_10
                 or bus_full_out_11
                 or bus_full_out_12
                 or bus_full_out_13
                 or bus_full_out_14
                 or bus_full_out_15
                 or bus_full_out_16
                 or bus_full_out_17;     --                after period/3;

  -- Debug signals OUT
  debug_bus_full_out <= bus_full_in;
  debug_bus_comm_out <= bus_comm_in;
  debug_bus_av_out  <= bus_av_in;

  --1) wire the wrappers together

--  hibi_or : process (bus_comm_out_1, bus_comm_out_2, bus_data_out_1, bus_data_out_2)
--  begin  -- process hibi_or
  -- logical or for bus data
--    if bus_comm_out_1 /= "000" or bus_comm_out_2 /= "000"
--      or bus_comm_out_3 /= "000" or bus_comm_out_4 /= "000"
--      or bus_comm_out_5 /= "000" or bus_comm_out_6 /= "000"
--      or bus_comm_out_7 /= "000" or bus_comm_out_8 /= "000" then

  bus_data_in <= bus_data_out_1 or bus_data_out_2 or bus_data_out_3
                 or bus_data_out_4 or bus_data_out_5 or bus_data_out_6
                 or bus_data_out_7 or bus_data_out_8 or bus_data_out_9
                 or bus_data_out_10 or bus_data_out_11 or bus_data_out_12
                 or bus_data_out_13 or bus_data_out_14 or bus_data_out_15
                 or bus_data_out_16 or bus_data_out_17;  -- after period/3;
--    else
--      -- tri-state 'z' added only to ease debugging!
--      bus_data_in <= (others => '0');  -- 'z'    --    after period/3;
--    end if;
--  end process hibi_or;
  
end structural;

