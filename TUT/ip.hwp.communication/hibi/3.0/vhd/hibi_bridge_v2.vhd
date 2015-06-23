-------------------------------------------------------------------------------
-- File        : hibi_bridge.vhd
-- Description : Connects two HIBI buses together
-- Author      : Erno Salminen
-- e-mail      : erno.salminen@tut.fi
-- Project     : 
-- Design      : 
-- Date        : 02.12.2002
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

entity hibi_bridge is

  generic (
    -- Bus A
    a_id_g            : integer := 0;
    a_addr_g          : integer := 0;
    a_inv_addr_en_g   : integer := 0;    

    a_id_width_g      : integer := 0;
    a_addr_width_g    : integer := 0;   -- in bits
    a_data_width_g    : integer := 0;   -- in bits    
    a_comm_width_g    : integer := 0;
    a_counter_width_g : integer := 0;

    a_rx_fifo_depth_g     : integer := 0;
    a_tx_fifo_depth_g     : integer := 0;
    a_rx_msg_fifo_depth_g : integer := 0;
    a_tx_msg_fifo_depth_g : integer := 0;

    -- These 4 added 2007/04/17
    -- 0 round-robin, 1 priority,2=prior+rr,3=rand 
    a_arb_type_g     : integer := 0;
    -- fifo_sel: 0 synch multiclk,         1 basic GALS,
    --           2 Gray FIFO (depth=2^n!), 3 mixed clock pausible
    a_fifo_sel_g     : integer := 0;

    a_debug_width_g  : integer := 0;

    a_prior_g          : integer := 0;
    a_max_send_g       : integer := 0;
    a_n_agents_g       : integer := 0;
    a_n_cfg_pages_g    : integer := 0;
    a_n_time_slots_g   : integer := 0;
    a_n_extra_params_g : integer := 0;
    a_cfg_re_g         : integer := 0;
    a_cfg_we_g         : integer := 0;

    -- Bus B    
    b_id_g            : integer := 0;
    b_addr_g          : integer := 0;
    b_inv_addr_en_g   : integer := 0;   

    b_id_width_g      : integer := 0;
    b_addr_width_g    : integer := 0;   -- in bits
    b_data_width_g    : integer := 0;   -- in bits    
    b_comm_width_g    : integer := 0;
    b_counter_width_g : integer := 0;

    b_rx_fifo_depth_g     : integer := 0;
    b_tx_fifo_depth_g     : integer := 0;
    b_rx_msg_fifo_depth_g : integer := 0;
    b_tx_msg_fifo_depth_g : integer := 0;

    -- These 4 added 2007/04/17
    -- 0 round-robin, 1 priority,2=prior+rr,3=rand 
    b_arb_type_g     : integer := 0;
    -- fifo_sel: 0 synch multiclk,         1 basic GALS,
    --           2 Gray FIFO (depth=2^n!), 3 mixed clock pausible
    b_fifo_sel_g     : integer := 0;

    b_debug_width_g  : integer := 0;

    b_prior_g          : integer := 0;
    b_max_send_g       : integer := 0;
    b_n_agents_g       : integer := 0;
    b_n_cfg_pages_g    : integer := 0;
    b_n_time_slots_g   : integer := 0;
    b_n_extra_params_g : integer := 0;
    b_cfg_re_g         : integer := 0;
    b_cfg_we_g         : integer := 0;

    a_id_min_g        : integer := 0;
    a_id_max_g        : integer := 0;
    a_addr_limit_g    : integer := 0;
    a_separate_addr_g : integer := 0;

    b_id_min_g        : integer := 0;
    b_id_max_g        : integer := 0;
    b_addr_limit_g    : integer := 0;
    b_separate_addr_g : integer := 0
    );

  port (
    a_clk   : in std_logic;
    a_rst_n : in std_logic;

    b_clk   : in std_logic;
    b_rst_n : in std_logic;

    a_bus_av_in   : in std_logic;
    a_bus_data_in : in std_logic_vector (a_data_width_g-1 downto 0);
    a_bus_comm_in : in std_logic_vector (a_comm_width_g-1 downto 0);
    a_bus_full_in : in std_logic;
    a_bus_lock_in : in std_logic;

    b_bus_av_in   : in std_logic;
    b_bus_data_in : in std_logic_vector (b_data_width_g-1 downto 0);
    b_bus_comm_in : in std_logic_vector (b_comm_width_g-1 downto 0);
    b_bus_full_in : in std_logic;
    b_bus_lock_in : in std_logic;

    a_bus_av_out   : out std_logic;
    a_bus_data_out : out std_logic_vector (a_data_width_g-1 downto 0);
    a_bus_comm_out : out std_logic_vector (a_comm_width_g-1 downto 0);
    a_bus_lock_out : out std_logic;
    a_bus_full_out : out std_logic;

    b_bus_av_out   : out std_logic;
    b_bus_data_out : out std_logic_vector (b_data_width_g-1 downto 0);
    b_bus_comm_out : out std_logic_vector (b_comm_width_g-1 downto 0);
    b_bus_lock_out : out std_logic;
    b_bus_full_out : out std_logic

    -- synthesis translate_off 
;
    a_debug_out : out std_logic_vector(a_debug_width_g-1 downto 0);
    a_debug_in  : in  std_logic_vector(a_debug_width_g-1 downto 0);
    b_debug_out : out std_logic_vector(b_debug_width_g-1 downto 0);
    b_debug_in  : in  std_logic_vector(b_debug_width_g-1 downto 0)
    -- synthesis translate_on

    );

end hibi_bridge;


architecture rtl of hibi_bridge is




  -- A-sillasta ulos
  signal a_c_d_from_a : std_logic_vector (1 + a_comm_width_g + a_data_width_g -1 downto 0);
  signal av_from_a    : std_logic;
  signal data_from_a  : std_logic_vector (a_data_width_g-1 downto 0);
  signal comm_from_a  : std_logic_vector (a_comm_width_g-1 downto 0);  --13.03.03 Command_type;
  signal full_from_a  : std_logic;
  signal one_p_from_a : std_logic;
  signal empty_from_a : std_logic;
  signal one_d_from_a : std_logic;

  -- A-sillan kattelylogiikasta komb.prosessille "A->B"
  signal data_a_HS  : std_logic_vector (a_data_width_g-1 downto 0);
  signal empty_hs_a : std_logic;
  signal one_d_a_HS : std_logic;
  -- Komb. pros "A->B":lta A-sillan kattelylogiikalle
  signal re_a_HS    : std_logic;



  -- A-sillalle sisaan
  signal a_c_d_to_a : std_logic_vector (1 + a_comm_width_g + a_data_width_g-1 downto 0);
  signal av_to_a    : std_logic;
  signal data_to_a  : std_logic_vector (a_data_width_g-1 downto 0);
  signal comm_to_a  : std_logic_vector (a_comm_width_g-1 downto 0);  --13.03.03 command_type;
  signal we_to_a    : std_logic;
  signal re_to_a    : std_logic;

  signal Msg_av_to_a      : std_logic;
  signal Msg_data_to_a    : std_logic_vector (a_data_width_g-1 downto 0);
  signal Msg_comm_to_a    : std_logic_vector (a_comm_width_g-1 downto 0);  --13.03.03 command_type;
  signal Msg_we_to_a      : std_logic;
  signal Msg_re_to_a      : std_logic;
  signal Msg_full_From_b  : std_logic;
  signal Msg_one_p_from_b : std_logic;
  signal Msg_empty_from_b : std_logic;
  signal Msg_one_d_from_b : std_logic;







  -- b- sillalta ulos
  signal a_c_d_from_b : std_logic_vector (1 + a_comm_width_g + a_data_width_g-1 downto 0);
  signal av_From_b    : std_logic;
  signal data_from_b  : std_logic_vector (a_data_width_g-1 downto 0);
  signal comm_From_b  : std_logic_vector (a_comm_width_g-1 downto 0);
  signal full_From_b  : std_logic;
  signal one_p_from_b : std_logic;
  signal empty_from_b : std_logic;
  signal one_d_from_b : std_logic;

  -- b-sillalle sisaan
  signal a_c_d_to_b : std_logic_vector (1 + a_comm_width_g + a_data_width_g-1 downto 0);
  signal av_to_b    : std_logic;
  signal data_to_b  : std_logic_vector (a_data_width_g-1 downto 0);
  signal comm_to_b  : std_logic_vector (a_comm_width_g-1 downto 0);
  signal we_to_b    : std_logic;
  signal re_to_b    : std_logic;

  signal Msg_av_a_to_b    : std_logic;
  signal Msg_data_a_to_b  : std_logic_vector (a_data_width_g-1 downto 0);
  signal Msg_comm_a_to_b  : std_logic_vector (a_comm_width_g-1 downto 0);
  signal Msg_full_from_a  : std_logic;
  signal Msg_one_p_from_a : std_logic;
  signal Msg_empty_from_a : std_logic;
  signal Msg_one_d_from_a : std_logic;
  signal Msg_we_to_b      : std_logic;
  signal Msg_re_to_b      : std_logic;

  -- B-sillan kattelylogiikasta komb.prosessille "B->A"
  signal data_b_HS  : std_logic_vector (b_data_width_g-1 downto 0);
  signal empty_hs_b : std_logic;
  signal one_d_b_HS : std_logic;
  -- Komb. pros "B->A":lta B-sillan kattelylogiikalle
  signal re_b_HS    : std_logic;



begin  -- rtl

  assert a_comm_width_g = b_comm_width_g report "Command widths do not match" severity warning;

  HibiWrapper_a : entity work.hibi_wrapper_r1
    generic map (
      id_g            => a_id_g,
      addr_g          => a_addr_g,
      inv_addr_en_g   => a_inv_addr_en_g,

      id_width_g      => a_id_width_g,
      addr_width_g    => a_addr_width_g,
      data_width_g    => a_data_width_g,
      comm_width_g    => a_comm_width_g,
      counter_width_g => a_counter_width_g,

      -- These 6 added 2007/04/17
      rel_agent_freq_g => 1,                 -- fully synchronous 2007/04/17
      rel_bus_freq_g   => 1,                 -- fully synchronous2007/04/17
      arb_type_g       => a_arb_type_g,      -- 2007/04/17
      fifo_sel_g       => a_fifo_sel_g,      --2007/04/17

      debug_width_g    => a_debug_width_g,   --2007/04/17

      rx_fifo_depth_g     => a_rx_fifo_depth_g,
      rx_msg_fifo_depth_g => a_rx_msg_fifo_depth_g,
      tx_fifo_depth_g     => a_tx_fifo_depth_g,
      tx_msg_fifo_depth_g => a_tx_msg_fifo_depth_g,

      prior_g          => a_prior_g,
      max_send_g       => a_max_send_g,
      n_agents_g       => a_n_agents_g,
      n_cfg_pages_g    => a_n_cfg_pages_g,
      n_time_slots_g   => a_n_time_slots_g,
      n_extra_params_g => a_n_extra_params_g,
      cfg_re_g         => a_cfg_re_g,
      cfg_we_g         => a_cfg_we_g,

      id_min_g        => a_id_min_g,
      id_max_g        => a_id_max_g,
      addr_limit_g    => a_addr_limit_g,
      separate_addr_g => a_separate_addr_g

      )
    port map (
      bus_clk        => a_clk,
      agent_clk      => a_clk,
      bus_sync_clk   => a_clk,
      agent_sync_clk => a_clk,

      rst_n => a_rst_n,

      bus_comm_in => a_bus_comm_in,
      bus_data_in => a_bus_data_in,
      bus_full_in => a_bus_full_in,
      bus_lock_in => a_bus_lock_in,
      bus_av_in   => a_bus_av_in,

      agent_av_in       => av_to_a,
      agent_data_in     => data_to_a,
      agent_comm_in     => comm_to_a,
      agent_we_in       => we_to_a,
      agent_re_in       => re_to_a,
      agent_msg_av_in   => Msg_av_to_a,
      agent_msg_data_in => Msg_data_to_a,
      agent_msg_comm_in => Msg_comm_to_a,
      agent_msg_we_in   => Msg_we_to_a,
      agent_msg_re_in   => Msg_re_to_a,

      bus_comm_out => a_bus_comm_out,
      bus_data_out => a_bus_data_out,
      bus_full_out => a_bus_full_out,
      bus_lock_out => a_bus_lock_out,
      bus_av_out   => a_bus_av_out,

      agent_comm_out  => comm_from_a,
      agent_data_out  => data_from_a,
      agent_av_out    => av_from_a,
      agent_full_out  => full_from_a,
      agent_one_p_out => one_p_from_a,
      agent_empty_out => empty_from_a,
      agent_one_d_out => one_d_from_a,

      agent_msg_comm_out  => Msg_comm_a_to_b,
      agent_msg_data_out  => Msg_data_a_to_b,
      agent_msg_av_out    => Msg_av_a_to_b,
      agent_msg_full_out  => Msg_full_from_a,
      agent_msg_one_p_out => Msg_one_p_from_a,
      agent_msg_empty_out => Msg_empty_from_a,
      agent_msg_one_d_out => Msg_one_d_from_a

      -- synthesis translate_off 
      ,
      debug_out => a_debug_out,
      debug_in  => a_debug_in
      -- synthesis translate_on
      );




  HibiWrapper_b : entity work.hibi_wrapper_r1
    generic map (
      id_g            => b_id_g,
      addr_g          => b_addr_g,
      inv_addr_en_g   => b_inv_addr_en_g,

      id_width_g      => b_id_width_g,
      addr_width_g    => b_addr_width_g,
      data_width_g    => b_data_width_g,
      comm_width_g    => b_comm_width_g,
      counter_width_g => b_counter_width_g,

      rx_fifo_depth_g     => b_rx_fifo_depth_g,
      rx_msg_fifo_depth_g => b_rx_msg_fifo_depth_g,
      tx_fifo_depth_g     => b_tx_fifo_depth_g,
      tx_msg_fifo_depth_g => b_tx_msg_fifo_depth_g,

      -- These 6 added 2007/04/17
      rel_agent_freq_g => 1,                 -- fully synchronous 2007/04/17
      rel_bus_freq_g   => 1,                 -- fully synchronous2007/04/17
      arb_type_g       => b_arb_type_g,      -- 2007/04/17
      fifo_sel_g       => b_fifo_sel_g,      --2007/04/17

      debug_width_g    => b_debug_width_g,   --2007/04/17

      prior_g          => b_prior_g,
      max_send_g       => b_max_send_g,
      n_agents_g       => b_n_agents_g,
      n_cfg_pages_g    => b_n_cfg_pages_g,
      n_time_slots_g   => b_n_time_slots_g,
      n_extra_params_g => b_n_extra_params_g,
      cfg_re_g         => b_cfg_re_g,
      cfg_we_g         => b_cfg_we_g,

      id_min_g        => b_id_min_g,
      id_max_g        => b_id_max_g,
      addr_limit_g    => b_addr_limit_g,
      separate_addr_g => b_separate_addr_g
      )
    port map (
      bus_clk        => b_clk,
      agent_clk      => b_clk,
      bus_sync_clk   => b_clk,
      agent_sync_clk => b_clk,
      rst_n          => b_rst_n,

      bus_comm_in => b_bus_comm_in,
      bus_data_in => b_bus_data_in,
      bus_full_in => b_bus_full_in,
      bus_lock_in => b_bus_lock_in,
      bus_av_in   => b_bus_av_in,

      agent_comm_in => comm_to_b,
      agent_data_in => data_to_b,
      agent_av_in   => av_to_b,
      agent_we_in   => we_to_b,
      agent_re_in   => re_to_b,

      agent_msg_comm_in => Msg_comm_a_to_b,
      agent_msg_data_in => Msg_data_a_to_b,
      agent_msg_av_in   => Msg_av_a_to_b,
      agent_msg_we_in   => Msg_we_to_b,
      agent_msg_re_in   => Msg_re_to_b,

      bus_comm_out => b_bus_comm_out,
      bus_data_out => b_bus_data_out,
      bus_full_out => b_bus_full_out,
      bus_lock_out => b_bus_lock_out,
      bus_av_out   => b_bus_av_out,

      agent_comm_out  => comm_From_b,
      agent_data_out  => data_from_b,
      agent_av_out    => av_From_b,
      agent_full_out  => full_From_b,
      agent_one_p_out => one_p_from_b,
      agent_empty_out => empty_from_b,
      agent_one_d_out => one_d_from_b,

      agent_msg_comm_out  => Msg_comm_to_a,
      agent_msg_data_out  => Msg_data_to_a,
      agent_msg_av_out    => Msg_av_to_a,
      agent_msg_full_out  => Msg_full_From_b,
      agent_msg_one_p_out => Msg_one_p_from_b,
      agent_msg_empty_out => Msg_empty_from_b,
      agent_msg_one_d_out => Msg_one_d_from_b

      -- synthesis translate_off 
      ,
      debug_out => b_debug_out,
      debug_in  => b_debug_in
      -- synthesis translate_on
      );

  -- Continuous assignments
  a_c_d_from_a (1 + a_comm_width_g + a_data_width_g -1)                   <= av_from_a;
  a_c_d_from_a (a_comm_width_g + a_data_width_g -1 downto a_data_width_g) <= comm_from_a;
  a_c_d_from_a (a_data_width_g -1 downto 0)                               <= data_from_a;

  av_to_b   <= a_c_d_to_b (1+ a_comm_width_g + a_data_width_g -1);
  comm_to_b <= a_c_d_to_b (a_comm_width_g + a_data_width_g -1 downto a_data_width_g);
  data_to_b <= a_c_d_to_b (a_data_width_g -1 downto 0);

  a_c_d_from_b (1 + a_comm_width_g + a_data_width_g -1)                   <= av_from_b;
  a_c_d_from_b (a_comm_width_g + a_data_width_g -1 downto a_data_width_g) <= comm_from_b;
  a_c_d_from_b (a_data_width_g -1 downto 0)                               <= data_from_b;

  av_to_a   <= a_c_d_to_a (1+ a_comm_width_g + a_data_width_g -1);
  comm_to_a <= a_c_d_to_a (a_comm_width_g + a_data_width_g -1 downto a_data_width_g);
  data_to_a <= a_c_d_to_a (a_data_width_g -1 downto 0);


  re_to_a    <= re_b_hs;
  empty_hs_b <= empty_from_a;
  a_c_d_to_b <= a_c_d_from_a;


  re_to_b    <= re_a_hs;
  empty_hs_a <= empty_from_b;
  a_c_d_to_a <= a_c_d_from_b;


  A_to_b : process (empty_hs_a, full_from_a)
  begin  -- process A_to_b
    if empty_hs_a = '0' and full_from_a = '0' then
      re_a_hs <= '1';
      we_to_a <= '1';
    else
      re_a_hs <= '0';
      we_to_a <= '0';
    end if;

  end process A_to_b;


  b_to_a : process (empty_hs_b, full_from_b)
  begin  -- process b_to_a
    if empty_hs_b = '0' and full_from_b = '0' then
      re_b_hs <= '1';
      we_to_b <= '1';
    else
      re_b_hs <= '0';
      we_to_b <= '0';
    end if;

  end process b_to_a;

  msg_a_to_b : process (Msg_empty_from_a, Msg_full_From_b)
  begin  -- process b_to_a
    if Msg_empty_from_a = '0' and Msg_full_From_b = '0' then
      Msg_we_to_b <= '1';
      Msg_re_to_a <= '1';
    else
      Msg_we_to_b <= '0';
      Msg_re_to_a <= '0';
    end if;

  end process msg_a_to_b;

  msg_b_to_a : process (Msg_empty_from_b, Msg_full_From_a)
  begin  -- process b_to_a
    if Msg_empty_from_b = '0' and Msg_full_From_a = '0' then
      Msg_we_to_a <= '1';
      Msg_re_to_b <= '1';
    else
      Msg_we_to_a <= '0';
      Msg_re_to_b <= '0';
    end if;

  end process msg_b_to_a;

  

  
end rtl;






































































