----------------------------------------------------------------------  
----  sys_stage                                                   ---- 
----                                                              ---- 
----  This file is part of the                                    ----
----    Modular Simultaneous Exponentiation Core project          ---- 
----    http://www.opencores.org/cores/mod_sim_exp/               ---- 
----                                                              ---- 
----  Description                                                 ---- 
----    stage for use in the montgommery multiplier pipelined     ----
----    systolic array                                            ----
----                                                              ----
----  Dependencies:                                               ----
----    - adder_block                                             ----
----    - standard_cell_block                                     ----
----    - d_flip_flop                                             ----
----    - register_n                                              ----
----    - register_1b                                             ----
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

entity sys_stage is
  generic(
    width : integer := 32 -- width of the stage
  );
  port(
    -- clock input
    core_clk : in  std_logic;
    -- modulus and y operand input (width)-bit
    y        : in  std_logic_vector((width-1) downto 0);
    m        : in  std_logic_vector((width) downto 0);
    my_cin   : in  std_logic;
    my_cout  : out std_logic;
    -- q and x operand input (serial input)
    xin      : in  std_logic;
    qin      : in  std_logic;
    -- q and x operand output (serial output)
    xout     : out std_logic;
    qout     : out std_logic;
    -- msb input (lsb from next stage, for shift right operation)
    a_msb    : in  std_logic;
    a_0      : out std_logic;
    -- carry out(clocked) and in
    cin      : in  std_logic;
    cout     : out std_logic;
    -- reduction adder carry's
    red_cin  : in std_logic;
    red_cout : out std_logic;
    -- control singals
    start    : in  std_logic;
    reset    : in  std_logic;
    done     : out std_logic;
    -- result out
    r_sel    : in  std_logic; -- result selection: 0 -> pipeline result, 1 -> reducted result
    r        : out std_logic_vector((width-1) downto 0)
  );
end sys_stage;

architecture Structural of sys_stage is
  signal my : std_logic_vector((width-1) downto 0);
  signal m_inv : std_logic_vector((width-1) downto 0);
  signal a : std_logic_vector((width-1) downto 0);
  signal cell_result : std_logic_vector((width-1) downto 0);
  signal cell_result_reg : std_logic_vector((width-1) downto 0);
  signal red_r : std_logic_vector((width-1) downto 0);
  
  signal cout_i : std_logic;
  
begin
  
  -- my adder
  ------------
  my_adder : adder_block
  generic map (
    width => width
  )
  port map(
    core_clk => core_clk,
    a => m(width downto 1),
    b => y,
    cin => my_cin,
    cout => my_cout,
    r => my
  );
  
  
  -- systolic pipeline cells
  ---------------------------
  a <= a_msb & cell_result_reg((width-1) downto 1);
  a_0 <= cell_result_reg(0);
  sys_cells : standard_cell_block
  generic map (
    width => width
  )
  port map (
    -- modulus and y operand input (width)-bit
    my => my,
    y => y,
    m => m(width downto 1),
    -- q and x operand input (serial input)
    x => xin,
    q => qin,
    -- previous result in (width)-bit
    a => a,
    -- carry in and out
    cin => cin,
    cout => cout_i,
    -- result out (width)-bit
    r => cell_result
  );
  
  -- cell result register (width)-bit
  result_reg : register_n
  generic map(
    width => width
  )
  port map(
    core_clk => core_clk,
    ce    => start,
    reset => reset,
    din   => cell_result,
    dout  => cell_result_reg
  );
  
  
  -- result reduction
  --------------------
  m_inv <= not(m(width-1 downto 0));
  
  reduction_adder : adder_block
  generic map (
    width => width
  )
  port map(
    core_clk => core_clk,
    a => m_inv,
    b => cell_result_reg,
    cin => red_cin,
    cout => red_cout,
    r => red_r
  );
  
  with r_sel select
    r <= cell_result_reg when '0',
                   red_r when others;
  
  
  -- stage clocked outputs
  -------------------------
  -- stage done signal
  -- 1 cycle after start of stage
  done_signal : d_flip_flop
  port map(
    core_clk  => core_clk,
    reset => reset,
    din   => start,
    dout  => done
  );
  
  -- xout register
  xout_reg : register_1b
  port map(
    core_clk => core_clk,
    ce    => start,
    reset => reset,
    din   => xin,
    dout  => xout
  );
  
  -- qout register
  qout_reg : register_1b
  port map(
    core_clk => core_clk,
    ce    => start,
    reset => reset,
    din   => qin,
    dout  => qout
  );

  -- carry out register
  cout_reg : register_1b
  port map(
    core_clk => core_clk,
    ce    => start,
    reset => reset,
    din   => cout_i,
    dout  => cout
  );
  
end Structural;

