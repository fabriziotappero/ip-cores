----------------------------------------------------------------------  
----  multiplier_tb                                               ---- 
----                                                              ---- 
----  This file is part of the                                    ----
----    Modular Simultaneous Exponentiation Core project          ---- 
----    http://www.opencores.org/cores/mod_sim_exp/               ---- 
----                                                              ---- 
----  Description                                                 ---- 
----    testbench for the Montgomery multiplier                   ----
----    Performs some multiplications to verify the design        ----
----    Takes input parameters from sim_mult_input.txt and writes ----
----    result and output to sim_mult_output.txt                  ----
----                                                              ----
----  Dependencies:                                               ----
----    - mont_multiplier                                         ----
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
use ieee.std_logic_arith.all;

library std;
use std.textio.all;

library ieee;
use ieee.std_logic_textio.all;

library mod_sim_exp;
use mod_sim_exp.mod_sim_exp_pkg.all;

entity multiplier_tb is
end multiplier_tb;

architecture test of multiplier_tb is
  constant CLK_PERIOD : time := 10 ns;
  signal clk          : std_logic := '0';
  signal reset        : std_logic := '1';
  file input          : text open read_mode is "src/sim_mult_input.txt";
  file output         : text open write_mode is "out/sim_mult_output.txt";
  
  ------------------------------------------------------------------
  -- Core parameters
  ------------------------------------------------------------------
  constant NR_BITS_TOTAL   : integer := 1536;
  constant NR_STAGES_TOTAL : integer := 96;
  constant NR_STAGES_LOW   : integer := 32;
  constant SPLIT_PIPELINE  : boolean := true;
  
  -- extra calculated constants
  constant NR_BITS_LOW : integer := (NR_BITS_TOTAL/NR_STAGES_TOTAL)*NR_STAGES_LOW;
  constant NR_BITS_HIGH : integer := NR_BITS_TOTAL-NR_BITS_LOW;
  
  -- the width of the input operand for the mulitplier test
  constant TEST_NR_BITS : integer := NR_BITS_LOW;
  
  ------------------------------------------------------------------
  -- Signals for multiplier core memory space
  ------------------------------------------------------------------
  -- data busses
  signal xy   : std_logic_vector(NR_BITS_TOTAL-1 downto 0);  -- x and y operand data bus RAM -> multiplier
  signal m    : std_logic_vector(NR_BITS_TOTAL-1 downto 0);  -- modulus data bus RAM -> multiplier
  signal r    : std_logic_vector(NR_BITS_TOTAL-1 downto 0);  -- result data bus RAM <- multiplier
  
  -- control signals
  signal p_sel          : std_logic_vector(1 downto 0); -- operand selection
  signal result_dest_op : std_logic_vector(1 downto 0); -- result destination operand
  signal ready          : std_logic;
  signal start          : std_logic;
  signal load_op        : std_logic;
  signal load_x         : std_logic;
  signal load_m         : std_logic;
  signal load_result    : std_logic;
begin

------------------------------------------
-- Generate clk
------------------------------------------
clk_process : process
begin
  while (true) loop
    clk <= '0';
    wait for CLK_PERIOD/2;
    clk <= '1';
    wait for CLK_PERIOD/2;
  end loop;
end process;

------------------------------------------
-- Stimulus Process
------------------------------------------
stim_proc : process
  procedure waitclk(n : natural := 1) is
  begin
    for i in 1 to n loop
      wait until rising_edge(clk);
    end loop;
  end waitclk;

  function ToString(constant Timeval : time) return string is
    variable StrPtr : line;
  begin
    write(StrPtr,Timeval);
    return StrPtr.all;
  end ToString;

  -- variables to read file
  variable L : line;
  variable Lw : line;
  variable x_op : std_logic_vector((NR_BITS_TOTAL-1) downto 0) := (others=>'0');
  variable y_op : std_logic_vector((NR_BITS_TOTAL-1) downto 0) := (others=>'0');
  variable m_op : std_logic_vector((NR_BITS_TOTAL-1) downto 0) := (others=>'0');
  variable result : std_logic_vector((NR_BITS_TOTAL-1) downto 0) := (others=>'0');
  variable good_value : boolean;
  variable param_count : integer := 0;
  
  variable timer : time;
begin
  -- initialisation
  xy <= (others=>'0');
  m <= (others=>'0');
  start <='0';
  reset <= '0';
  load_x <= '0';
  write(Lw, string'("----- Selecting pipeline: "));
  writeline(output, Lw);
  case (TEST_NR_BITS) is
    when NR_BITS_TOTAL =>  p_sel <= "11"; write(Lw, string'("  Full pipeline selected"));
    when NR_BITS_HIGH =>  p_sel <= "10"; write(Lw, string'("  Upper pipeline selected"));
    when NR_BITS_LOW  =>  p_sel <= "01"; write(Lw, string'("  Lower pipeline selected"));
    when others =>
      write(Lw, string'("  Invallid bitwidth for design"));
      assert false report "impossible basewidth!" severity failure;
  end case;
  writeline(output, Lw);
  
  -- Generate active high reset signal
  reset <= '1';
  waitclk(10);
  reset <= '0';
  waitclk(10);
  
  while not endfile(input) loop
    readline(input, L); -- read next line
    next when L(1)='-'; -- skip comment lines
    -- read input values
    case param_count is
      when 0 =>
        hread(L, x_op(TEST_NR_BITS-1 downto 0), good_value);
        assert good_value report "Can not read x operand" severity failure;
        assert false report "Simulating multiplication" severity note;
        write(Lw, string'("----------------------------------------------"));
        writeline(output, Lw);
        write(Lw, string'("--              MULTIPLICATION              --"));
        writeline(output, Lw);
        write(Lw, string'("----------------------------------------------"));
        writeline(output, Lw);
        write(Lw, string'("----- Variables used:"));
        writeline(output, Lw);
        write(Lw, string'("x: "));
        hwrite(Lw, x_op(TEST_NR_BITS-1 downto 0));
        writeline(output, Lw);
        
      when 1 =>
        hread(L, y_op(TEST_NR_BITS-1 downto 0), good_value);
        assert good_value report "Can not read y operand" severity failure;
        write(Lw, string'("y: "));
        hwrite(Lw, y_op(TEST_NR_BITS-1 downto 0));
        writeline(output, Lw);
     
      when 2 =>
        hread(L, m_op(TEST_NR_BITS-1 downto 0), good_value);
        assert good_value report "Can not read m operand" severity failure;
        write(Lw, string'("m: "));
        hwrite(Lw, m_op(TEST_NR_BITS-1 downto 0));
        writeline(output, Lw);
        
        -- load in x
        xy <= x_op;
        wait until rising_edge(clk);
        load_x <='1';
        wait until rising_edge(clk);
        load_x <='0';
        
        -- put y and m on the bus
        xy <= y_op;
        m <= m_op;
        wait until rising_edge(clk);
        
        -- start multiplication and wait for result
        start <= '1';
        wait until rising_edge(clk);
        start <= '0';
        
        wait until ready='1';
        wait until rising_edge(clk);
        writeline(output, Lw);
        write(Lw, string'("  Computed result: "));
        hwrite(Lw, r(TEST_NR_BITS-1 downto 0));
        writeline(output, Lw);
        
      when 3 =>
        hread(L, result(TEST_NR_BITS-1 downto 0), good_value);
        assert good_value report "Can not read result" severity failure;
        write(Lw, string'("  Read result:     "));
        hwrite(Lw, result(TEST_NR_BITS-1 downto 0));
        writeline(output, Lw);
        
        if (r(TEST_NR_BITS-1 downto 0) = result(TEST_NR_BITS-1 downto 0)) then
          write(Lw, string'("  => result is correct!")); writeline(output, Lw);
        else
          write(Lw, string'("  => Error: result is incorrect!!!")); writeline(output, Lw);
          assert false report "result is incorrect!!!" severity error;
        end if;
        
      when others => 
        assert false report "undefined state!" severity failure;
    end case;
    
    if (param_count = 3) then
      param_count := 0;
    else
      param_count := param_count+1;
    end if;
  end loop;
  
  wait for 1 us;
  assert false report "End of simulation" severity failure;

end process;

------------------------------------------
-- Multiplier instance
------------------------------------------
the_multiplier : mont_multiplier
  generic map(
    n     => NR_BITS_TOTAL,
    t     => NR_STAGES_TOTAL,
    tl    => NR_STAGES_LOW,
    split => SPLIT_PIPELINE
  )
  port map(
    core_clk => clk,
    xy       => xy,
    m        => m,
    r        => r,
    start    => start,
    reset    => reset,
    p_sel    => p_sel,
    load_x   => load_x,
    ready    => ready
  );

end test;
