----------------------------------------------------------------------  
----  sys_pipeline                                                ---- 
----                                                              ---- 
----  This file is part of the                                    ----
----    Modular Simultaneous Exponentiation Core project          ---- 
----    http://www.opencores.org/cores/mod_sim_exp/               ---- 
----                                                              ---- 
----  Description                                                 ---- 
----    the pipelined systolic array for a montgommery multiplier ----
----                                                              ----
----  Dependencies:                                               ----
----    - sys_stage                                               ----
----    - register_n                                              ----
----    - d_flip_flop                                             ----
----    - cell_1b_adder                                           ----
----    - cell_1b_mux                                             ----
----                                                              ----
----  Authors:                                                    ----
----      - Geoffrey Ottoy, DraMCo research group                 ----
----      - Jonas De Craene, JonasDC@opencores.org                ---- 
----                                                              ---- 
---------------------------------------------------------------------- 
----                                                              ---- 
---- Copyright (C) 2011 DraMCo research group and OPENCORES.ORG   ---- 
----                                                              ---- 
---- This source file may be used and distributed without         ---- 
---- restriction provided that this copyright statement is not    ---- 
---- removed from the file and that any derivative work contains  ---- 
---- the original copyright notice and the associated disclaimer. ---- 
----                                                              ---- 
---- This source file is free software; you can redistribute it   ---- 
---- and/or modify it under the terms of the GNU Lesser General   ---- 
---- Public License as published by the Free Software Foundation; ---- 
---- either version 2.1 of the License, or (at your option) any   ---- 
---- later version.                                               ---- 
----                                                              ---- 
---- This source is distributed in the hope that it will be       ---- 
---- useful, but WITHOUT ANY WARRANTY; without even the implied   ---- 
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ---- 
---- PURPOSE.  See the GNU Lesser General Public License for more ---- 
---- details.                                                     ---- 
----                                                              ---- 
---- You should have received a copy of the GNU Lesser General    ---- 
---- Public License along with this source; if not, download it   ---- 
---- from http://www.opencores.org/lgpl.shtml                     ---- 
----                                                              ---- 
----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library mod_sim_exp;
use mod_sim_exp.mod_sim_exp_pkg.all;

-- the pipelined systolic array for a montgommery multiplier
-- contains a structural description of the pipeline using the systolic stages
entity sys_pipeline is
	generic(
    n  : integer := 1536; -- width of the operands (# bits)
    t  : integer := 192;  -- total number of stages (minimum 2)
    tl : integer := 64;   -- lower number of stages (minimum 1)
    split : boolean := true -- if true the pipeline wil be split in 2 parts,
                            -- if false there are no lower stages, only t counts
  );
  port(
    -- clock input
    core_clk : in  std_logic;
    -- modulus and y opperand input (n)-bit
    y        : in  std_logic_vector((n-1) downto 0);
    m        : in  std_logic_vector((n-1) downto 0);
    -- x operand input (serial)
    xi       : in  std_logic;
    next_x   : out std_logic; -- next x operand bit
    -- control signals
    start    : in  std_logic; -- start multiplier
    reset    : in  std_logic;
    p_sel    : in  std_logic_vector(1 downto 0); -- select which piece of the pipeline will be used
    -- result out
    r        : out std_logic_vector((n-1) downto 0)
  );
end sys_pipeline;

architecture Structural of sys_pipeline is
  constant s : integer := n/t;
  
  signal m_i     : std_logic_vector(n downto 0);
  signal y_i     : std_logic_vector(n downto 0);
  
  -- systolic stages signals
  signal my_cin_stage   : std_logic_vector((t-1) downto 0);
  signal my_cout_stage  : std_logic_vector((t-1) downto 0);
  signal xin_stage      : std_logic_vector((t-1) downto 0);
  signal qin_stage      : std_logic_vector((t-1) downto 0);
  signal xout_stage     : std_logic_vector((t-1) downto 0);
  signal qout_stage     : std_logic_vector((t-1) downto 0);
  signal a_msb_stage    : std_logic_vector((t-1) downto 0);
  signal a_0_stage      : std_logic_vector((t-1) downto 0);
  signal cin_stage      : std_logic_vector((t-1) downto 0);
  signal cout_stage     : std_logic_vector((t-1) downto 0);
  signal red_cin_stage  : std_logic_vector((t-1) downto 0);
  signal red_cout_stage : std_logic_vector((t-1) downto 0);
  signal start_stage    : std_logic_vector((t-1) downto 0);
  signal done_stage     : std_logic_vector((t-1) downto 0);
  signal r_sel_stage    : std_logic_vector((t-1) downto 0);
  
  -- end logic signals
  signal r_sel_end : std_logic;
  
  -- signals needed if pipeline is split
  ---------------------------------------
  signal r_sel_l : std_logic;
  signal r_sel_h : std_logic;
  -- mid end logic signals
  signal a_0_midend   : std_logic;
  signal r_sel_midend : std_logic;
  
  -- mid start logic signals
  signal my_cout_midstart   : std_logic;
  signal xout_midstart      : std_logic;
  signal qout_midstart      : std_logic;
  signal cout_midstart      : std_logic;
  signal red_cout_midstart  : std_logic;
  

begin

  m_i <= '0' & m;
  y_i <= '0' & y;

  -- generate the stages for the full pipeline
  pipeline_stages : for i in 0 to (t-1) generate
    stage : sys_stage
    generic map(
      width => s
    )
    port map(
      core_clk => core_clk,
      y        => y_i((i+1)*s downto (i*s)+1),
      m        => m_i((i+1)*s downto (i*s)),
      my_cin   => my_cin_stage(i),
      my_cout  => my_cout_stage(i),
      xin      => xin_stage(i),
      qin      => qin_stage(i),
      xout     => xout_stage(i),
      qout     => qout_stage(i),
      a_0      => a_0_stage(i),
      a_msb    => a_msb_stage(i),
      cin      => cin_stage(i),
      cout     => cout_stage(i),
      red_cin  => red_cin_stage(i),
      red_cout => red_cout_stage(i),
      start    => start_stage(i),
      reset    => reset,
      done     => done_stage(i),
      r_sel    => r_sel_stage(i),
      r        => r(((i+1)*s)-1 downto (i*s))
    );
  end generate;
  
  -- first cell logic
  --------------------
  first_cell : sys_first_cell_logic
  port map (
    m0       => m_i(0),
    y0       => y_i(0),
    my_cout  => my_cin_stage(0),
    xi       => xi,
    xout     => xin_stage(0),
    qout     => qin_stage(0),
    cout     => cin_stage(0),
    a_0      => a_0_stage(0),
    red_cout => red_cin_stage(0)
  );
  
    -- last cell logic
  -------------------
  last_cell : sys_last_cell_logic
  port map (
    core_clk => core_clk,
    reset    => reset,
    a_0      => a_msb_stage(t-1),
    cin      => cout_stage(t-1),
    red_cin  => red_cout_stage(t-1),
    r_sel    => r_sel_end,
    start    => done_stage(t-1)
  );
  
------------------------------------
-- SINGLE PART PIPELINE CONNECTIONS
------------------------------------
single_pipeline : if split=false generate
  -- link stages to eachother
  stage_connect : for i in 1 to (t-1) generate
    my_cin_stage(i) <= my_cout_stage(i-1);
    cin_stage(i) <= cout_stage(i-1);
    xin_stage(i) <= xout_stage(i-1);
    qin_stage(i) <= qout_stage(i-1);
    red_cin_stage(i) <= red_cout_stage(i-1);
    start_stage(i) <= done_stage(i-1);
    a_msb_stage(i-1) <= a_0_stage(i);
    r_sel_stage(i) <= r_sel_end;
  end generate;
    r_sel_stage(0) <= r_sel_end;
  
  start_stage(0) <= start;
  next_x <= done_stage(0);
end generate;

----------------------------------------
-- SPLIT PIPELINE CONNECTIONS AND LOGIC
----------------------------------------
split_pipeline : if split=true generate
  -- only start first stage if lower part is used
  with p_sel select
    start_stage(0) <= '0' when "10",
                      start when others;
  
  -- select start or midstart stage for requesting new xi bit
  with p_sel select
    next_x <= done_stage(tl) when "10",
              done_stage(0) when others;
  
  -- link lower stages to eachother
  stage_connect_l : for i in 1 to (tl-1) generate
    my_cin_stage(i) <= my_cout_stage(i-1);
    cin_stage(i) <= cout_stage(i-1);
    xin_stage(i) <= xout_stage(i-1);
    qin_stage(i) <= qout_stage(i-1);
    red_cin_stage(i) <= red_cout_stage(i-1);
    start_stage(i) <= done_stage(i-1);
    a_msb_stage(i-1) <= a_0_stage(i);
    r_sel_stage(i) <= r_sel_l;
  end generate;
    r_sel_stage(0) <= r_sel_l;
  
  -- mid end logic
  -----------------
  mid_end_cell : sys_last_cell_logic
  port map (
    core_clk => core_clk,
    reset    => reset,
    a_0      => a_0_midend,
    cin      => cout_stage(tl-1),
    red_cin  => red_cout_stage(tl-1),
    r_sel    => r_sel_midend,
    start    => done_stage(tl-1)
  );
  --muxes for midend signals
  with p_sel select
    a_msb_stage(tl-1) <= a_0_midend when "01",
                         a_0_stage(tl) when others;
  
  -- mid start logic
  -------------------
  mid_start_logic : sys_first_cell_logic
  port map (
    m0       => m_i(tl*s),
    y0       => y_i(tl*s),
    my_cout  => my_cout_midstart,
    xi       => xi,
    xout     => xout_midstart,
    qout     => qout_midstart,
    cout     => cout_midstart,
    a_0      => a_0_stage(tl),
    red_cout => red_cout_midstart
  );
  
  -- only start stage tl if only higher part is used
  with p_sel select
    start_stage(tl) <= start when "10",
                       done_stage(tl-1) when "11",
                       '0' when others;
                      
  with p_sel select
    my_cin_stage(tl) <= my_cout_midstart when "10",
                        my_cout_stage(tl-1) when others;
  with p_sel select
    xin_stage(tl) <= xout_midstart when "10",
                     xout_stage(tl-1) when others;
  with p_sel select
    qin_stage(tl) <= qout_midstart when "10",
                     qout_stage(tl-1) when others;
  with p_sel select
    cin_stage(tl) <= cout_midstart when "10",
                     cout_stage(tl-1) when others;
  with p_sel select
    red_cin_stage(tl) <= red_cout_midstart when "10",
                         red_cout_stage(tl-1) when others;
  
    -- link higher stages to eachother
  stage_connect_h : for i in (tl+1) to (t-1) generate
    my_cin_stage(i) <= my_cout_stage(i-1);
    cin_stage(i) <= cout_stage(i-1);
    xin_stage(i) <= xout_stage(i-1);
    qin_stage(i) <= qout_stage(i-1);
    red_cin_stage(i) <= red_cout_stage(i-1);
    start_stage(i) <= done_stage(i-1);
    a_msb_stage(i-1) <= a_0_stage(i);
    r_sel_stage(i) <= r_sel_h;
  end generate;
    r_sel_stage(tl) <= r_sel_h;
  
  with p_sel select
    r_sel_l <= r_sel_midend when "01",
               r_sel_end when "11",
               '0' when others;
               
  with p_sel select
    r_sel_h <= '0' when "01",
               r_sel_end when others;           
end generate;

end Structural;
