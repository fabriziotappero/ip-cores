-------------------------------------------------------------------------------
-- Title      : A Package for DCTQIDCT testbench
-- Project    : 
-------------------------------------------------------------------------------
-- File       : tb_dct_package.vhd
-- Author     : Antti Rasmus
-- Created    : 2006-05-02
-- Last update: 2013-03-22
-------------------------------------------------------------------------------
-- Copyright (c) 2006 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2006-05-02  1.0      rasmusa Created
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

package tb_dct_package is

  -----------------------------------------------------------------------------
  -- General settings
  -----------------------------------------------------------------------------
  
  constant clk_period_c : time := 50 ns;
  constant fast_clk_divider_c : integer := 1;
  constant slow_clk_multiplier_c : integer := 1;
  constant reset_time_c : time := 250 ns;

  constant use_self_rel_c : integer := 1;
  
  constant data_width_c : integer := 32;
  constant comm_width_c : integer := 5; --switched to use hibiv3

  -----------------------------------------------------------------------------
  -- Hibi addresses for cpu and dct and other hibi parameters
  -----------------------------------------------------------------------------
  constant hibi_addr_cpu_c : integer := 16#0300_0000#;
  constant hibi_addr_dct_c : integer := 16#0100_0000#;
  constant hibi_addr_cpu_rtm_c : integer := 16#0300_0110#;
  constant hibi_addr_pinger1_c : integer := 16#0b00_0300#;
  constant hibi_addr_pinger2_c : integer := 16#0b00_0500#;
  
  constant ip_addr_width_c : integer := 24;  -- Each zero represents 4 bits..
  
  constant id_width_c       : integer := 3;
  constant counter_width_c  : integer := 16;
  constant addr_width_c     : integer := 32;
  constant max_send_c       : integer := 25;
  constant n_time_slots_c   : integer := 0;
  constant n_extra_params_c : integer := 0;
  constant n_agents_c : integer := 4;

end tb_dct_package;
