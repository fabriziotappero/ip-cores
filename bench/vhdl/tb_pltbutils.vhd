----------------------------------------------------------------------
----                                                              ----
---- PlTbUtils Testbench                                          ----
----                                                              ----
---- This file is part of the PlTbUtils project                   ----
---- http://opencores.org/project,pltbutils                       ----
----                                                              ----
---- Description                                                  ----
---- PlTbUtils is a collection of functions, procedures and       ----
---- components for easily creating stimuli and checking response ----
---- in automatic self-checking testbenches.                      ----
----                                                              ----
---- This is a testbench file, which is used to verify            ----
---- - pltbutils_func_pkg                                         ----
---- - pltbutils_comp                                           ----
---- This testbench is NOT selfchecking or automatic.             ----
---- Manually check the transcript and waveform, when simulating. ----
---- It prints some informative text in the transcript, to help   ----
---- with the manual inspection.                                  ----
----                                                              ----
----                                                              ----
---- To Do:                                                       ----
---- -                                                            ----
----                                                              ----
---- Author(s):                                                   ----
---- - Per Larsson, pela.opencores@gmail.com                      ----
----                                                              ----
----------------------------------------------------------------------
----                                                              ----
---- Copyright (C) 2013-2014 Authors and OPENCORES.ORG            ----
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
---- PURPOSE. See the GNU Lesser General Public License for more  ----
---- details.                                                     ----
----                                                              ----
---- You should have received a copy of the GNU Lesser General    ----
---- Public License along with this source; if not, download it   ----
---- from http://www.opencores.org/lgpl.shtml                     ----
----                                                              ----
----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.txt_util.all;
use work.pltbutils_func_pkg.all;
use work.pltbutils_comp_pkg.all;

entity tb_pltbutils is
  generic (
    G_CLK_PERIOD  : time := 10 ns
  );
end entity tb_pltbutils;

architecture bhv of tb_pltbutils is

  -- Simulation status- and control signals
  -- for accessing .stop_sim and for viewing in waveform window
  signal pltbs          : pltbs_t := C_PLTBS_INIT;

  -- Expected number of checks and number of errors to be reported
  -- by pltbutils. The counting is made by variables, but the
  -- variables are copied to these signals for easier viewing in
  -- the simulator's waveform window.
  signal expected_checks_cnt : integer := 0;
  signal expected_errors_cnt : integer := 0;
  
  -- DUT stimuli and response signals
  signal clk            : std_logic;
  signal clk_cnt        : integer := 0;
  signal clk_cnt_clr    : boolean := false;
  signal s_i            : integer;
  signal s_sl           : std_logic;
  signal s_slv          : std_logic_vector(7 downto 0);
  signal s_u            : unsigned(7 downto 0);
  signal s_s            : unsigned(7 downto 0);
  signal s_str_exp      : string(1 to 44);
  signal s_str1         : string(1 to 44);    
  signal s_str2         : string(1 to 44);    
  signal s_str3         : string(1 to 43);    
  signal s_str4         : string(1 to 45);    
  
begin
      
  -- Clock generator
  clkgen0 : pltbutils_clkgen
    generic map(
      G_PERIOD      => G_CLK_PERIOD
    )
    port map(
      clk_o         => clk,
      stop_sim_i    => pltbs.stop_sim
    );
    
  -- Clock cycle counter
  p_clk_cnt : process (clk_cnt_clr, clk)
  begin
    if clk_cnt_clr then
      clk_cnt <= 0;
    elsif rising_edge(clk) then
      clk_cnt <= clk_cnt + 1;
    end if;
  end process p_clk_cnt;
   
  -- Testcase
  p_tc1 : process
    variable pltbv                 : pltbv_t := C_PLTBV_INIT;
    variable v_expected_tests_cnt  : integer := 0;
    variable v_expected_checks_cnt : integer := 0;
    variable v_expected_errors_cnt : integer := 0;
  begin
  
    print("<Testing startsim()>");
    startsim("tc1", pltbv, pltbs);
    wait until rising_edge(clk);
    assert (pltbv.test_num = 0) and (pltbs.test_num  = 0)
      report "test_num after startsim() incorrect"
      severity error;
    print("<Done testing startsim()>");
   
    print("<Testing starttest() with auto-incrementing test_num>");   
    starttest("TestName1", pltbv, pltbs);
    v_expected_tests_cnt := v_expected_tests_cnt + 1;    
    wait until rising_edge(clk);
    assert (pltbv.test_num = 1) and (pltbs.test_num  = 1)
      report "test_num after starttest() incorrect"
      severity error;
    print("<Done testing starttest() with auto-incrementing test_num()>");

    print("<Testing endtest()>");   
    endtest(pltbv, pltbs);    
    print("<Done testing endtest()>");

    print("<Testing starttest() with explicit test_num>");   
    starttest(3, "TestName2", pltbv, pltbs);
    v_expected_tests_cnt := v_expected_tests_cnt + 1;        
    wait until rising_edge(clk);
    assert (pltbv.test_num = 3) and (pltbs.test_num  = 3)
      report "test_num after startsim() incorrect"
      severity error;
    print("<Done testing starttest() with explicit test_num>");
    
    print("<Testing waitclks()>"); 
    clk_cnt_clr <= true;
    wait until rising_edge(clk);
    clk_cnt_clr <= false;
    wait until rising_edge(clk);
    waitclks(10, clk, pltbv, pltbs);   
    assert clk_cnt = 10
      report "clk_cnt after waitclks() incorrect:" & integer'image(clk_cnt) &
             " expected:" & integer'image(10)
      severity error;
    print("<Done testing waitclks()>");

    print("<Testing check() integer>");
    s_i <= 0;    
    wait until rising_edge(clk);
    check("Testing correct integer = 0", s_i, 0, pltbv, pltbs);
    v_expected_checks_cnt := v_expected_checks_cnt + 1;
    expected_checks_cnt   <= v_expected_checks_cnt;
    s_i <= 1;    
    wait until rising_edge(clk);
    check("Testing correct integer = 1", s_i, 1, pltbv, pltbs);
    v_expected_checks_cnt := v_expected_checks_cnt + 1;
    expected_checks_cnt   <= v_expected_checks_cnt;
    s_i <= 17;    
    wait until rising_edge(clk);
    check("Testing incorrect integer = 17", s_i, 18, pltbv, pltbs);
    v_expected_checks_cnt := v_expected_checks_cnt + 1;
    expected_checks_cnt   <= v_expected_checks_cnt;
    v_expected_errors_cnt := v_expected_errors_cnt + 1;
    expected_errors_cnt   <= v_expected_errors_cnt;
    s_i <= -1;    
    wait until rising_edge(clk);
    check("Testing negative integer = -1", s_i, -1, pltbv, pltbs);
    v_expected_checks_cnt := v_expected_checks_cnt + 1;    
    expected_checks_cnt   <= v_expected_checks_cnt;
    
    print("<Done testing check() integer>");
    
    print("<Testing check() std_logic>");
    s_sl <= '0';    
    wait until rising_edge(clk);
    check("Testing correct std_logic = '0'", s_sl, '0', pltbv, pltbs);
    v_expected_checks_cnt := v_expected_checks_cnt + 1;
    expected_checks_cnt   <= v_expected_checks_cnt;
    s_sl <= '1';    
    wait until rising_edge(clk);
    check("Testing correct std_logic = '1'", s_sl, '1', pltbv, pltbs);
    v_expected_checks_cnt := v_expected_checks_cnt + 1;
    expected_checks_cnt   <= v_expected_checks_cnt;
    s_sl <= 'X';    
    wait until rising_edge(clk);
    check("Testing incorrect std_logic = '1'", s_sl, '1', pltbv, pltbs);
    v_expected_checks_cnt := v_expected_checks_cnt + 1;
    expected_checks_cnt   <= v_expected_checks_cnt;
    v_expected_errors_cnt := v_expected_errors_cnt + 1;
    expected_errors_cnt   <= v_expected_errors_cnt;
    print("<Done testing check() std_logic>");
    
    print("<Testing check() std_logic against integer>");
    s_sl <= '0';    
    wait until rising_edge(clk);
    check("Testing correct std_logic = '0'", s_sl, 0, pltbv, pltbs);
    v_expected_checks_cnt := v_expected_checks_cnt + 1;
    expected_checks_cnt   <= v_expected_checks_cnt;
    s_sl <= '1';    
    wait until rising_edge(clk);
    check("Testing correct std_logic = '1'", s_sl, 1, pltbv, pltbs);
    v_expected_checks_cnt := v_expected_checks_cnt + 1;
    expected_checks_cnt   <= v_expected_checks_cnt;
    s_sl <= 'X';    
    wait until rising_edge(clk);
    check("Testing incorrect std_logic = '1'", s_sl, 1, pltbv, pltbs);
    v_expected_checks_cnt := v_expected_checks_cnt + 1;
    expected_checks_cnt   <= v_expected_checks_cnt;
    v_expected_errors_cnt := v_expected_errors_cnt + 1;
    expected_errors_cnt   <= v_expected_errors_cnt;
    s_sl <= '1';    
    wait until rising_edge(clk);
    check("Testing std_logic = '1' with incorrect expected", s_sl, 2, pltbv, pltbs);
    v_expected_checks_cnt := v_expected_checks_cnt + 1;
    expected_checks_cnt   <= v_expected_checks_cnt;
    v_expected_errors_cnt := v_expected_errors_cnt + 1;
    expected_errors_cnt   <= v_expected_errors_cnt;
    print("<Done testing check() std_logic against integer>");
    
    print("<Testing check() std_logic_vector>");
    s_slv <= x"00";    
    wait until rising_edge(clk);
    check("Testing correct std_logic_vector = x'00'", s_slv, x"00", pltbv, pltbs);
    v_expected_checks_cnt := v_expected_checks_cnt + 1;
    expected_checks_cnt   <= v_expected_checks_cnt;
    s_slv <= x"47";    
    wait until rising_edge(clk);
    check("Testing correct std_logic_vector = x'47'", s_slv, x"47", pltbv, pltbs);
    v_expected_checks_cnt := v_expected_checks_cnt + 1;
    expected_checks_cnt   <= v_expected_checks_cnt;
    s_slv <= x"11";    
    wait until rising_edge(clk);
    check("Testing incorrect std_logic_vector = x'11'", s_slv, x"10", pltbv, pltbs);
    v_expected_checks_cnt := v_expected_checks_cnt + 1;
    expected_checks_cnt   <= v_expected_checks_cnt;
    v_expected_errors_cnt := v_expected_errors_cnt + 1;
    expected_errors_cnt   <= v_expected_errors_cnt;
    print("<Done testing check() std_logic_vector>");

    print("<Testing check() std_logic_vector with mask>");
    s_slv <= x"47";    
    wait until rising_edge(clk);
    check("Testing std_logic_vector = x'47' with correct nibble mask", s_slv, x"57", x"0F", pltbv, pltbs);
    v_expected_checks_cnt := v_expected_checks_cnt + 1;
    expected_checks_cnt   <= v_expected_checks_cnt;
    s_slv <= x"47";    
    wait until rising_edge(clk);
    check("Testing std_logic_vector = x'47' with incorrect nibble mask", s_slv, x"57", x"F0", pltbv, pltbs);
    v_expected_checks_cnt := v_expected_checks_cnt + 1;
    expected_checks_cnt   <= v_expected_checks_cnt;
    v_expected_errors_cnt := v_expected_errors_cnt + 1;
    expected_errors_cnt   <= v_expected_errors_cnt;
    print("<Done testing check() std_logic_vector with mask>");
        
    print("<Testing check() std_logic_vector against integer>");
    s_slv <= x"00";    
    wait until rising_edge(clk);
    check("Testing correct std_logic_vector = x'00'", s_slv, 0, pltbv, pltbs);
    v_expected_checks_cnt := v_expected_checks_cnt + 1;
    expected_checks_cnt   <= v_expected_checks_cnt;
    s_slv <= x"47";    
    wait until rising_edge(clk);
    check("Testing correct std_logic_vector = x'47'", s_slv, 16#47#, pltbv, pltbs);
    v_expected_checks_cnt := v_expected_checks_cnt + 1;
    expected_checks_cnt   <= v_expected_checks_cnt;
    s_slv <= x"11";    
    wait until rising_edge(clk);
    check("Testing incorrect std_logic_vector = x'11'", s_slv, 16#10#, pltbv, pltbs);
    v_expected_checks_cnt := v_expected_checks_cnt + 1;
    expected_checks_cnt   <= v_expected_checks_cnt;
    v_expected_errors_cnt := v_expected_errors_cnt + 1;
    expected_errors_cnt   <= v_expected_errors_cnt;
    s_slv <= x"FF";    
    wait until rising_edge(clk);
    check("Testing negative std_logic_vector = x'FF'", s_slv, -1, pltbv, pltbs);
    v_expected_checks_cnt := v_expected_checks_cnt + 1;
    expected_checks_cnt   <= v_expected_checks_cnt;
    print("<Done testing check() std_logic_vector against integer>");

    print("<Testing check() std_logic_vector with mask against integer>");
    s_slv <= x"47";    
    wait until rising_edge(clk);
    check("Testing std_logic_vector = x'47' with correct nibble mask", s_slv, 16#57#, x"0F", pltbv, pltbs);
    v_expected_checks_cnt := v_expected_checks_cnt + 1;
    expected_checks_cnt   <= v_expected_checks_cnt;
    s_slv <= x"47";    
    wait until rising_edge(clk);
    check("Testing std_logic_vector = x'47' with incorrect nibble mask", s_slv, 16#57#, x"F0", pltbv, pltbs);
    v_expected_checks_cnt := v_expected_checks_cnt + 1;
    expected_checks_cnt   <= v_expected_checks_cnt;
    v_expected_errors_cnt := v_expected_errors_cnt + 1;
    expected_errors_cnt   <= v_expected_errors_cnt;
    print("<Done testing check() std_logic_vector with mask against integer>");    
    
    print("<Testing check() unsigned>");
    s_u <= x"00";    
    wait until rising_edge(clk);
    check("Testing correct unsigned = x'00'", s_u, x"00", pltbv, pltbs);
    v_expected_checks_cnt := v_expected_checks_cnt + 1;
    expected_checks_cnt   <= v_expected_checks_cnt;
    s_u <= x"47";    
    wait until rising_edge(clk);
    check("Testing correct unsigned = x'47'", s_u, x"47", pltbv, pltbs);
    v_expected_checks_cnt := v_expected_checks_cnt + 1;
    expected_checks_cnt   <= v_expected_checks_cnt;
    s_u <= x"11";    
    wait until rising_edge(clk);
    check("Testing incorrect unsigned = x'11'", s_u, x"10", pltbv, pltbs);
    v_expected_checks_cnt := v_expected_checks_cnt + 1;
    expected_checks_cnt   <= v_expected_checks_cnt;
    v_expected_errors_cnt := v_expected_errors_cnt + 1;
    expected_errors_cnt   <= v_expected_errors_cnt;
    print("<Done testing check() unsigned>");
        
    print("<Testing check() unsigned against integer>");
    s_u <= x"00";    
    wait until rising_edge(clk);
    check("Testing correct unsigned = x'00'", s_u, 0, pltbv, pltbs);
    v_expected_checks_cnt := v_expected_checks_cnt + 1;
    expected_checks_cnt   <= v_expected_checks_cnt;
    s_u <= x"47";    
    wait until rising_edge(clk);
    check("Testing correct unsigned = x'47'", s_u, 16#47#, pltbv, pltbs);
    v_expected_checks_cnt := v_expected_checks_cnt + 1;
    expected_checks_cnt   <= v_expected_checks_cnt;
    s_u <= x"11";    
    wait until rising_edge(clk);
    check("Testing incorrect unsigned = x'11'", s_u, 16#10#, pltbv, pltbs);
    v_expected_checks_cnt := v_expected_checks_cnt + 1;
    expected_checks_cnt   <= v_expected_checks_cnt;
    v_expected_errors_cnt := v_expected_errors_cnt + 1;
    expected_errors_cnt   <= v_expected_errors_cnt;
    print("<Done testing check() unsigned against integer>");
    
    print("<Testing check() signed>");
    s_s <= x"00";    
    wait until rising_edge(clk);
    check("Testing correct signed = x'00'", s_s, x"00", pltbv, pltbs);
    v_expected_checks_cnt := v_expected_checks_cnt + 1;
    expected_checks_cnt   <= v_expected_checks_cnt;
    s_s <= x"47";    
    wait until rising_edge(clk);
    check("Testing correct signed = x'47'", s_s, x"47", pltbv, pltbs);
    v_expected_checks_cnt := v_expected_checks_cnt + 1;
    expected_checks_cnt   <= v_expected_checks_cnt;
    s_s <= x"11";    
    wait until rising_edge(clk);
    check("Testing incorrect signed = x'11'", s_s, x"10", pltbv, pltbs);
    v_expected_checks_cnt := v_expected_checks_cnt + 1;
    expected_checks_cnt   <= v_expected_checks_cnt;
    v_expected_errors_cnt := v_expected_errors_cnt + 1;
    expected_errors_cnt   <= v_expected_errors_cnt;
    s_s <= x"FF";    
    wait until rising_edge(clk);
    check("Testing negative signed = x'FF'", s_s, x"FF", pltbv, pltbs);
    v_expected_checks_cnt := v_expected_checks_cnt + 1;    
    expected_checks_cnt   <= v_expected_checks_cnt;
    print("<Done testing check() signed>");
        
    print("<Testing check() signed against integer>");
    s_s <= x"00";    
    wait until rising_edge(clk);
    check("Testing correct signed = x'00'", s_s, 0, pltbv, pltbs);
    v_expected_checks_cnt := v_expected_checks_cnt + 1;
    expected_checks_cnt   <= v_expected_checks_cnt;
    s_s <= x"47";    
    wait until rising_edge(clk);
    check("Testing correct signed = x'47'", s_s, 16#47#, pltbv, pltbs);
    v_expected_checks_cnt := v_expected_checks_cnt + 1;
    expected_checks_cnt   <= v_expected_checks_cnt;
    s_s <= x"11";    
    wait until rising_edge(clk);
    check("Testing incorrect signed = x'11'", s_s, 16#10#, pltbv, pltbs);
    v_expected_checks_cnt := v_expected_checks_cnt + 1;
    expected_checks_cnt   <= v_expected_checks_cnt;
    v_expected_errors_cnt := v_expected_errors_cnt + 1;
    expected_errors_cnt   <= v_expected_errors_cnt;
    s_s <= x"FF";    
    wait until rising_edge(clk);
    --print("The following check fails in ModelSim for unknown reason." &
    --      " It causes mismatch between expected number of errors" &
    --      " and the number presented by endsim()");
    --check("Testing negative signed = x'FF'", s_s, -1, pltbv, pltbs);
    --v_expected_checks_cnt := v_expected_checks_cnt + 1;    
    --expected_checks_cnt   <= v_expected_checks_cnt;
    --print("<Done testing check() signed against integer>");    

    print("<Testing check() string>");
    s_str_exp   <= string'("The quick brown fox jumps over the lazy dog.");
    s_str1      <= string'("The quick brown fox jumps over the lazy dog.");    
    s_str2      <= string'("The quick brown dog jumps over the lazy fox.");    
    s_str3      <= string'("The quick brown fox jumps over the lazy dog");    
    s_str4      <= string'("The quick brown fox jumps over the lazy dog..");    
    wait until rising_edge(clk);
    check("Testing correct string", s_str1, s_str_exp, pltbv, pltbs);
    v_expected_checks_cnt := v_expected_checks_cnt + 1;
    expected_checks_cnt   <= v_expected_checks_cnt;
    s_s <= x"47";    
    wait until rising_edge(clk);
    check("Testing incorrect string with correct length", s_str2, s_str_exp, pltbv, pltbs);
    v_expected_checks_cnt := v_expected_checks_cnt + 1;
    expected_checks_cnt   <= v_expected_checks_cnt;
    v_expected_errors_cnt := v_expected_errors_cnt + 1;
    expected_errors_cnt   <= v_expected_errors_cnt;    
    s_s <= x"11";    
    wait until rising_edge(clk);
    check("Testing too short string", s_str3, s_str_exp, pltbv, pltbs);
    v_expected_checks_cnt := v_expected_checks_cnt + 1;
    expected_checks_cnt   <= v_expected_checks_cnt;
    v_expected_errors_cnt := v_expected_errors_cnt + 1;
    expected_errors_cnt   <= v_expected_errors_cnt;
    wait until rising_edge(clk);
    check("Testing too long string", s_str4, s_str_exp, pltbv, pltbs);
    v_expected_checks_cnt := v_expected_checks_cnt + 1;
    expected_checks_cnt   <= v_expected_checks_cnt;
    v_expected_errors_cnt := v_expected_errors_cnt + 1;
    expected_errors_cnt   <= v_expected_errors_cnt;
    print("<Done testing check() string>");
    
    print("<Testing check() boolean expression>");
    s_i <= 0;    
    wait until rising_edge(clk);
    check("Testing correct boolean expression 0 = 16#00#", s_i = 16#00#, pltbv, pltbs);
    v_expected_checks_cnt := v_expected_checks_cnt + 1;
    expected_checks_cnt   <= v_expected_checks_cnt;
    s_i <= 47;    
    wait until rising_edge(clk);
    check("Testing incorrect boolean expression 47 < 16#10#", s_i < 16#10#, pltbv, pltbs);
    v_expected_checks_cnt := v_expected_checks_cnt + 1;
    expected_checks_cnt   <= v_expected_checks_cnt;
    v_expected_errors_cnt := v_expected_errors_cnt + 1;
    expected_errors_cnt   <= v_expected_errors_cnt;
    print("<Done testing check() boolean expresson>");

    print("<Testing endtest()>");   
    endtest(pltbv, pltbs);    
    print("<Done testing endtest()>");
    
    wait until rising_edge(clk);
    print("<Testing endsim()>");
    print("Expected number of tests:  " & str(v_expected_tests_cnt));
    print("Expected number of checks: " & str(v_expected_checks_cnt));
    print("Expected number of errors: " & str(v_expected_errors_cnt));
    wait until rising_edge(clk);
    endsim(pltbv, pltbs, true);
    wait until rising_edge(clk);
    print("<Done testing endsim()>");
    wait;
  end process p_tc1;  
end architecture bhv;
