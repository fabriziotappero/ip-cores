----------------------------------------------------------------------
----                                                              ----
---- PlTbUtils Fuctions and Procedures Package                    ----
----                                                              ----
---- This file is part of the PlTbUtils project                   ----
---- http://opencores.org/project,pltbutils                       ----
----                                                              ----
---- Description:                                                 ----
---- PlTbUtils is a collection of functions, procedures and       ----
---- components for easily creating stimuli and checking response ----
---- in automatic self-checking testbenches.                      ----
----                                                              ----
---- This file defines fuctions and procedures for controlling    ----
---- stimuli to a DUT and checking response.                      ----
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
use work.pltbutils_user_cfg_pkg.all;

package pltbutils_func_pkg is

  -- See the package body for a description of the functions and procedures.
  constant C_PLTBUTILS_STRLEN  : natural := 80;
  constant C_PLTBUTILS_TIMEOUT : time    := 10 sec;
  constant C_WAIT_BEFORE_STOP_TIME : time := 1 us;

  -- Type for status- and control variable
  type pltbv_t is
    record
      testcase_name    : string(1 to C_PLTBUTILS_STRLEN);
      testcase_name_len: integer;
      test_num         : integer;
      test_name        : string(1 to C_PLTBUTILS_STRLEN);
      test_name_len    : integer;
      info             : string(1 to C_PLTBUTILS_STRLEN);
      info_len         : integer;
      test_cnt         : integer;
      chk_cnt          : integer;
      err_cnt          : integer;
      chk_cnt_in_test  : integer;
      err_cnt_in_test  : integer;
      stop_sim         : std_logic;
    end record;
    
  constant C_PLTBV_INIT : pltbv_t := (
    (others => ' '),   -- testcase_name
    1,                 -- testcase_name_len
    0,                 -- test_num
    (others => ' '),   -- test_name
    1,                 -- test_name_len
    (others => ' '),   -- info
    1,                 -- info_len
    0,                 -- test_cnt
    0,                 -- chk_cnt
    0,                 -- err_cnt
    0,                 -- chk_cnt_in_test
    0,                 -- err_cnt_in_test
    '0'                -- stop_sim
  );

  -- Status- and control signal (subset of pltbv_t)
  type pltbs_t is
    record
      test_num  : natural;
      test_name : string(1 to C_PLTBUTILS_STRLEN);
      info      : string(1 to C_PLTBUTILS_STRLEN);
      chk_cnt   : natural;
      err_cnt   : natural;
      stop_sim  : std_logic;
    end record;
    
  constant C_PLTBS_INIT : pltbs_t := (
    0,                  -- test_num
    (others => ' '),    -- test_name    
    (others => ' '),    -- info
    0,                  -- chk_cnt
    0,                  -- err_cnt
    '0'                 -- stop_sim
  );
  
  -- startsim
  procedure startsim(
    constant testcase_name      : in    string;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t
  );

  -- endsim
  procedure endsim(
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t;
    constant show_success_fail  : in    boolean := false;
    constant force_stop         : in    boolean := false
  );

  -- starttest
  procedure starttest(
    constant num                : in    integer := -1;
    constant name               : in    string;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t
  );
  procedure starttest(
    constant name               : in    string;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t
  );

  -- endtest
  procedure endtest(
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t
  );

  -- print, printv, print2
  procedure print(
    constant active             : in    boolean;
    signal   s                  : out   string;
    constant txt                : in    string
  );
  procedure print(
    signal   s                  : out   string;
    constant txt                : in    string
  );
  procedure printv(
    constant active             : in    boolean;
    variable s                  : out   string;
    constant txt                : in    string
  );
  procedure printv(
    variable s                  : out   string;
    constant txt                : in    string
  );
  procedure print(
    constant active             : in    boolean;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t;
    constant txt                : in    string
  );
  procedure print(
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t;
    constant txt                : in    string
  );
  procedure print2(
    constant active             : in    boolean;
    signal   s                  : out   string;
    constant txt                : in    string
  );
  procedure print2(
    signal   s                  : out   string;
    constant txt                : in    string
  );
  procedure print2(
    constant active             : in    boolean;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t;
    constant txt                : in    string
  );
  procedure print2(
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t;
    constant txt                : in    string
  );

  -- waitclks
  procedure waitclks(
    constant N                  : in    natural;
    signal   clk                : in    std_logic;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t;
    constant falling            : in    boolean := false;
    constant timeout            : in    time    := C_PLTBUTILS_TIMEOUT
  );

  -- waitsig
  procedure waitsig(
    signal   s                  : in    integer;
    constant value              : in    integer;
    signal   clk                : in    std_logic;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t;
    constant falling            : in    boolean := false;
    constant timeout            : in    time    := C_PLTBUTILS_TIMEOUT
  );
  procedure waitsig(
    signal   s                  : in    std_logic;
    constant value              : in    std_logic;
    signal   clk                : in    std_logic;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t;
    constant falling            : in    boolean := false;
    constant timeout            : in    time    := C_PLTBUTILS_TIMEOUT
  );
  procedure waitsig(
    signal   s                  : in    std_logic;
    constant value              : in    integer;
    signal   clk                : in    std_logic;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t;
    constant falling            : in    boolean := false;
    constant timeout            : in    time    := C_PLTBUTILS_TIMEOUT
  );
  procedure waitsig(
    signal   s                  : in    std_logic_vector;
    constant value              : in    std_logic_vector;
    signal   clk                : in    std_logic;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t;
    constant falling            : in    boolean := false;
    constant timeout            : in    time    := C_PLTBUTILS_TIMEOUT
  );
  procedure waitsig(
    signal   s                  : in    std_logic_vector;
    constant value              : in    integer;
    signal   clk                : in    std_logic;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t;
    constant falling            : in    boolean := false;
    constant timeout            : in    time    := C_PLTBUTILS_TIMEOUT
  );
  procedure waitsig(
    signal   s                  : in    unsigned;
    constant value              : in    unsigned;
    signal   clk                : in    std_logic;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t;
    constant falling            : in    boolean := false;
    constant timeout            : in    time    := C_PLTBUTILS_TIMEOUT
  );
  procedure waitsig(
    signal   s                  : in    unsigned;
    constant value              : in    integer;
    signal   clk                : in    std_logic;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t;
    constant falling            : in    boolean := false;
    constant timeout            : in    time    := C_PLTBUTILS_TIMEOUT
  );
  procedure waitsig(
    signal   s                  : in    signed;
    constant value              : in    signed;
    signal   clk                : in    std_logic;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t;
    constant falling            : in    boolean := false;
    constant timeout            : in    time    := C_PLTBUTILS_TIMEOUT
  );
  procedure waitsig(
    signal   s                  : in    signed;
    constant value              : in    integer;
    signal   clk                : in    std_logic;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t;
    constant falling            : in    boolean := false;
    constant timeout            : in    time    := C_PLTBUTILS_TIMEOUT
  );
  procedure waitsig(
    signal   s                  : in    std_logic;
    constant value              : in    std_logic;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t;
    constant timeout            : in    time    := C_PLTBUTILS_TIMEOUT
  );

  -- check
  procedure check(
    constant rpt                : in    string;
    constant actual             : in    integer;
    constant expected           : in    integer;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t
  );
  procedure check(
    constant rpt                : in    string;
    constant actual             : in    std_logic;
    constant expected           : in    std_logic;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t
  );
  procedure check(
    constant rpt                : in    string;
    constant actual             : in    std_logic;
    constant expected           : in    integer;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t
  );
  procedure check(
    constant rpt                : in    string;
    constant actual             : in    std_logic_vector;
    constant expected           : in    std_logic_vector;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t
  );
  procedure check(
    constant rpt                : in    string;
    constant actual             : in    std_logic_vector;
    constant expected           : in    std_logic_vector;
    constant mask               : in    std_logic_vector;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t
  );
  procedure check(
    constant rpt                : in    string;
    constant actual             : in    std_logic_vector;
    constant expected           : in    integer;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t
  );
  procedure check(
    constant rpt                : in    string;
    constant actual             : in    std_logic_vector;
    constant expected           : in    integer;
    constant mask               : in    std_logic_vector;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t
  );
  procedure check(
    constant rpt                : in    string;
    constant actual             : in    unsigned;
    constant expected           : in    unsigned;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t
  );
  procedure check(
    constant rpt                : in    string;
    constant actual             : in    unsigned;
    constant expected           : in    integer;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t
  );
  procedure check(
    constant rpt                : in    string;
    constant actual             : in    signed;
    constant expected           : in    signed;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t
  );
  procedure check(
    constant rpt                : in    string;
    constant actual             : in    signed;
    constant expected           : in    integer;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t
  );
  procedure check(
    constant rpt                : in    string;
    constant actual             : in    string;
    constant expected           : in    string;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t
  );  
  procedure check(
    constant rpt                : in    string;
    constant expr               : in    boolean;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t
  );
   procedure check(
    constant rpt                : in    string;
    constant expr               : in    boolean;
    constant actual             : in    string;
    constant expected           : in    string;
    constant mask               : in    string;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t
  );

  -- to_ascending
  function to_ascending(
    constant s                  : std_logic_vector
  ) return std_logic_vector;
  function to_ascending(
    constant s                  : unsigned
  ) return unsigned;
  function to_ascending(
    constant s                  : signed
  ) return signed;

  -- to_descending
  function to_descending(
    constant s                  : std_logic_vector
  ) return std_logic_vector;
  function to_descending(
    constant s                  : unsigned
  ) return unsigned;
  function to_descending(
    constant s                  : signed
  ) return signed;

  -- hxstr
  function hxstr(
    constant s                  : std_logic_vector;
    constant prefix             : string := "";
    constant postfix            : string := ""
  ) return string;
  function hxstr(
    constant s                  : unsigned;
    constant prefix             : string := "";
    constant postfix            : string := ""
  ) return string;
  function hxstr(
    constant s                  : signed;
    constant prefix             : string := "";
    constant postfix            : string := ""
  ) return string;

  -- pltbutils internal procedure(s), do not call from user's code
  procedure pltbs_update(
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t
  );

  procedure stopsim(
    constant timestamp          : in time
  );

  procedure pltbutils_error(
    constant rpt                : in string;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t
  );

  procedure startsim_msg(
    constant testcase_name      : in string;
    constant timestamp          : in time
  );

  procedure endsim_msg(
    constant testcase_name      : in string;
    constant timestamp          : in time;
    constant num_tests          : in integer;
    constant num_checks         : in integer;
    constant num_errors         : in integer;
    constant show_success_fail  : in boolean
  );

  procedure starttest_msg(
    constant test_num           : in integer;
    constant test_name          : in string;
    constant timestamp          : in time
  );

  procedure endtest_msg(
    constant test_num           : in integer;
    constant test_name          : in string;
    constant timestamp          : in time;
    constant num_checks_in_test : in integer;
    constant num_errors_in_test : in integer
  );

  procedure check_msg(
    constant rpt                : in string;
    constant timestamp          : in time;
    constant expr               : in boolean;
    constant actual             : in string;
    constant expected           : in string;
    constant mask               : in string;
    constant test_num           : in integer;
    constant test_name          : in string;
    constant check_num          : in integer;
    constant err_cnt_in_test    : in integer
  );

  procedure error_msg(
    constant rpt                : in string;
    constant timestamp          : in time;
    constant test_num           : in integer;
    constant test_name          : in string;
    constant err_cnt_in_test    : in integer
  );

end package pltbutils_func_pkg;

package body pltbutils_func_pkg is

  ----------------------------------------------------------------------------
  -- startsim
  --
  -- procedure startsim(
  --   constant testcase_name      : in    string;
  --   variable pltbv              : inout pltbv_t;
  --   signal   pltbs              : out   pltbs_t
  -- )
  --
  -- Displays a message at start of simulation message, and initializes
  -- PlTbUtils' status and control variable and -signal.
  -- Call startsim() only once.
  --
  -- Arguments:
  --   testcase_name            Name of the test case, e.g. "tc1".
  --
  --   pltbv, pltbs             PlTbUtils' status- and control variable and
  --                            -signal.
  --
  -- NOTE:
  -- The start-of-simulation message is not only intended to be informative
  -- for humans. It is also intended to be searched for by scripts,
  -- e.g. for collecting results from a large number of regression tests.
  -- For this reason, the message must be consistent and unique.
  --
  -- DO NOT MODIFY the message "--- START OF SIMULATION ---".
  -- DO NOT OUTPUT AN IDENTICAL MESSAGE anywhere else.
  --
  -- Example:
  -- startsim("tc1", pltbv, pltbs);
  ----------------------------------------------------------------------------
  procedure startsim(
    constant testcase_name      : in    string;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t
  ) is
    variable timestamp          : time;
  begin
    timestamp := now;
    pltbv := C_PLTBV_INIT;
    printv(pltbv.testcase_name, testcase_name);
    pltbv.testcase_name_len := testcase_name'length;
    printv(pltbv.test_name, "START OF SIMULATION");
    pltbv.test_name_len     := 19;
    printv(pltbv.info, testcase_name);
    pltbv.info_len          := testcase_name'length;
    pltbs_update(pltbv, pltbs);
    if C_PLTBUTILS_USE_STD_STARTSIM_MSG then
      startsim_msg(testcase_name, timestamp);
    end if;
    if C_PLTBUTILS_USE_CUSTOM_STARTSIM_MSG then
      custom_startsim_msg(testcase_name, timestamp);
    end if;
  end procedure startsim;

  ----------------------------------------------------------------------------
  -- endsim
  --
  -- procedure endsim(
  --   variable pltbv              : inout pltbv_t;
  --   signal   pltbs              : out   pltbs_t;
  --   constant show_success_fail  : in  boolean := false;
  --   constant force_stop         : in  boolean := false
  -- )
  --
  -- Displays a message at end of simulation message, presents the simulation
  -- results, and stops the simulation.
  -- Call endsim() it only once.
  --
  -- Arguments:
  --   pltbv, pltbs             PlTbUtils' status- and control variable and
  --                            -signal.
  --
  --   show_success_fail        If true, endsim() shows "*** SUCCESS ***",
  --                            "*** FAIL ***", or "*** NO CHECKS ***".
  --                            Optional, default is false.
  --
  --   force_stop               If true, forces the simulation to stop using an
  --                            assert failure statement. Use this option only
  --                            if the normal way of stopping the simulation
  --                            doesn't work (see below).
  --                            Optional, default is false.
  --
  -- The testbench should be designed so that all clocks stop when endsim()
  -- sets the signal pltbs.stop_sim to '1'. This should stop the simulator.
  -- In some cases that doesn't work, then set the force_stop argument to true,
  -- which causes a false assert failure, which should stop the simulator.
  -- Scripts searching transcript logs for errors and failures, should ignore
  -- the failure with "--- FORCE END OF SIMULATION ---" as part of the report.
  --
  -- NOTE:
  -- The end-of-simulation messages and success/fail messages are not only
  -- intended to be informative for humans. They are also intended to be
  -- searched for by scripts, e.g. for collecting results from a large number
  -- of regression tests.
  -- For this reason, the message must be consistent and unique.
  --
  -- DO NOT MODIFY the messages "--- END OF SIMULATION ---",
  -- "*** SUCCESS ***", "*** FAIL ***", "*** NO CHECKS ***".
  -- DO NOT OUTPUT IDENTICAL MESSAGES anywhere else.
  --
  -- Examples:
  -- endsim(pltbv, pltbs);
  -- endsim(pltbv, pltbs, true);
  -- endsim(pltbv, pltbs, true, true);
  ----------------------------------------------------------------------------
  procedure endsim(
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t;
    constant show_success_fail  : in    boolean := false;
    constant force_stop         : in    boolean := false
  ) is
    variable timestamp : time;
  begin
    timestamp := now;
    if C_PLTBUTILS_USE_STD_ENDSIM_MSG then
      endsim_msg(pltbv.testcase_name(1 to pltbv.testcase_name_len), timestamp,
        pltbv.test_cnt, pltbv.chk_cnt, pltbv.err_cnt, show_success_fail);
    end if;
    if C_PLTBUTILS_USE_CUSTOM_ENDSIM_MSG then
      custom_endsim_msg(pltbv.testcase_name(1 to pltbv.testcase_name_len), timestamp,
        pltbv.test_cnt, pltbv.chk_cnt, pltbv.err_cnt, show_success_fail);
    end if;
    pltbv.test_num      := 0;
    printv(pltbv.test_name, "END OF SIMULATION");
    pltbv.test_name_len := 17;
    pltbv.stop_sim      := '1';
    pltbs_update(pltbv, pltbs);
    wait for C_WAIT_BEFORE_STOP_TIME;
    if force_stop then
      if C_PLTBUTILS_USE_STD_STOPSIM then
        stopsim(now);
      end if;
      if C_PLTBUTILS_USE_CUSTOM_STOPSIM then
        custom_stopsim(now);
      end if;
    end if;
    wait;
  end procedure endsim;

  ----------------------------------------------------------------------------
  -- starttest
  --
  -- procedure starttest(
  --   constant num                : in    integer := -1;
  --   constant name               : in    string;
  --   variable pltbv              : inout pltbv_t;
  --   signal   pltbs              : out   pltbs_t
  -- )
  --
  -- Sets a number (optional) and a name for a test. The number and name will
  -- be printed to the screen, and displayed in the simulator's waveform
  -- window.
  -- The test number and name is also included if there errors reported by the
  -- check() procedure calls.
  --
  -- Arguments:
  --   num                      Test number. Optional, default is to increment
  --                            the current test number.
  --
  --   name                     Test name.
  --
  --   pltbv, pltbs             PlTbUtils' status- and control variable and
  --                            -signal.
  --
  -- If the test number is omitted, a new test number is automatically
  -- computed by incrementing the current test number.
  -- Manually setting the test number may make it easier to find the test code
  -- in the testbench code, though.
  --
  -- Examples:
  -- starttest("Reset test", pltbv, pltbs);
  -- starttest(1, "Reset test", pltbv, pltbs);
  ----------------------------------------------------------------------------
  procedure starttest(
    constant num                : in    integer := -1;
    constant name               : in    string;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t
  ) is
    variable timestamp : time;
  begin
    timestamp := now;
    if num = -1 then
      pltbv.test_num := pltbv.test_num + 1;
    else
      pltbv.test_num := num;
    end if;
    printv(pltbv.test_name, name);
    pltbv.test_name_len := name'length;
    pltbv.test_cnt := pltbv.test_cnt + 1;
    pltbv.chk_cnt_in_test := 0;
    pltbv.err_cnt_in_test := 0;
    pltbs_update(pltbv, pltbs);
    if C_PLTBUTILS_USE_STD_STARTTEST_MSG then
     starttest_msg(pltbv.test_num, name, timestamp);
    end if;
    if C_PLTBUTILS_USE_CUSTOM_STARTTEST_MSG then
     custom_starttest_msg(pltbv.test_num, name, timestamp);
    end if;
  end procedure starttest;

  procedure starttest(
    constant name               : in    string;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t
  ) is
  begin
    starttest(-1, name, pltbv, pltbs);
  end procedure starttest;

  ----------------------------------------------------------------------------
  -- endtest
  --
  -- procedure endtest(
  --   variable pltbv              : inout pltbv_t;
  --   signal   pltbs              : out   pltbs_t
  -- )
  --
  -- Prints an end-of-test message to the screen.
  --
  -- Arguments:
  --   pltbv, pltbs             PlTbUtils' status- and control variable and
  --                            -signal.
  --
  -- Example:
  -- endtest(pltbv, pltbs);
  ----------------------------------------------------------------------------
  procedure endtest(
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t
  ) is
    variable timestamp : time;
  begin
    timestamp := now;
    if C_PLTBUTILS_USE_STD_ENDTEST_MSG then
      endtest_msg(pltbv.test_num, pltbv.test_name(1 to pltbv.test_name_len),
        timestamp, pltbv.chk_cnt_in_test, pltbv.err_cnt_in_test);
    end if;
    if C_PLTBUTILS_USE_CUSTOM_ENDTEST_MSG then
      custom_endtest_msg(pltbv.test_num, pltbv.test_name(1 to pltbv.test_name_len),
        timestamp, pltbv.chk_cnt_in_test, pltbv.err_cnt_in_test);
    end if;
    printv(pltbv.test_name, " ");
    pltbv.test_name_len := 1;
    pltbs_update(pltbv, pltbs);
  end procedure endtest;

  ----------------------------------------------------------------------------
  -- print printv print2
  --
  -- procedure print(
  --   signal   s                  : out   string;
  --   constant txt                : in    string
  -- )
  --
  -- procedure print(
  --   constant active             : in    boolean;
  --   signal   s                  : out   string;
  --   constant txt                : in    string
  -- )
  --
  -- procedure print(
  --   variable pltbv              : inout pltbv_t;
  --   signal   pltbs              : out   pltbs_t;
  --   constant txt                : in    string
  -- )
  --
  -- procedure print(
  --   constant active             : in    boolean;
  --   variable pltbv              : inout pltbv_t;
  --   signal   pltbs              : out   pltbs_t;
  --   constant txt                : in    string
  -- )
  --
  -- procedure printv(
  --   variable s                  : out   string;
  --   constant txt                : in    string
  -- )
  --
  -- procedure printv(
  --   constant active             : in    boolean;
  --   variable s                  : out   string;
  --   constant txt                : in    string
  -- )
  --
  -- procedure print2(
  --   signal   s                  : out   string;
  --   constant txt                : in    string
  -- )
  --
  -- procedure print2(
  --   constant active             : in    boolean;
  --   signal   s                  : out   string;
  --   constant txt                : in    string
  -- )
  --
  -- procedure print2(
  --   variable pltbv              : inout pltbv_t;
  --   signal   pltbs              : out   pltbs_t;
  --   constant txt                : in    string
  -- )
  --
  -- procedure print2(
  --   constant active             : in    boolean;
  --   variable pltbv              : inout pltbv_t;
  --   signal   pltbs              : out   pltbs_t;
  --   constant txt                : in    string
  -- )
  --
  -- print() prints text messages to a signal for viewing in the simulator's
  -- waveform window. printv() does the same thing, but to a variable instead.
  -- print2() prints both to a signal and to the transcript window.
  -- The type of the output can be string or pltbv_t+pltbs_t.
  --
  -- Arguments:
  --   s                        Signal or variable of type string to be
  --                            printed to.
  --
  --   txt                      The text.
  --
  --   active                   The text is only printed if active is true.
  --                            Useful for debug switches, etc.
  --
  --   pltbv, pltbs             PlTbUtils' status- and control variable and
  --                            -signal.
  --
  -- If the string txt is longer than the signal s, the text will be truncated.
  -- If txt is shorter, s will be padded with spaces.
  --
  -- Examples:
  -- print(msg, "Hello, world"); -- Prints to signal msg
  -- print(G_DEBUG, msg, "Hello, world"); -- Prints to signal msg if
  --                                      -- generic G_DEBUG is true
  -- printv(v_msg, "Hello, world"); -- Prints to variable msg
  -- print(pltbv, pltbs, "Hello, world"); -- Prints to "info" in waveform window
  -- print2(msg, "Hello, world"); -- Prints to signal and transcript window
  -- print2(pltbv, pltbs, "Hello, world"); -- Prints to "info" in waveform and
  --                                      -- transcript windows
  ----------------------------------------------------------------------------
  procedure print(
    constant active             : in    boolean;
    signal   s                  : out   string;
    constant txt                : in    string
  ) is
    variable j : positive := txt 'low;
  begin
    if active then
      for i in s'range loop
        if j <= txt 'high then
          s(i) <= txt (j);
        else
          s(i) <= ' ';
        end if;
        j := j + 1;
      end loop;
    end if;
  end procedure print;

  procedure print(
    signal   s                  : out   string;
    constant txt                : in    string
  ) is
  begin
    print(true, s, txt);
  end procedure print;

  procedure printv(
    constant active             : in    boolean;
    variable s                  : out   string;
    constant txt                : in    string
  ) is
    variable j : positive := txt 'low;
  begin
    if active then
      for i in s'range loop
        if j <= txt 'high then
          s(i) := txt (j);
        else
          s(i) := ' ';
        end if;
        j := j + 1;
      end loop;
    end if;
  end procedure printv;

  procedure printv(
    variable s                  : out   string;
    constant txt                : in    string
  ) is
  begin
    printv(true, s, txt);
  end procedure printv;

  -- Print to info element in pltbv/pltbs, which shows up in waveform window
  procedure print(
    constant active             : in    boolean;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t;
    constant txt                : in    string
  ) is
    variable j : positive := txt 'low;
  begin
    if active then
      printv(pltbv.info, txt);
      pltbv.info_len := txt'length;
      pltbs_update(pltbv, pltbs);
    end if;
  end procedure print;

  procedure print(
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t;
    constant txt                : in    string
  ) is
  begin
    print(true, pltbv, pltbs, txt);
  end procedure print;

  procedure print2(
    constant active             : in    boolean;
    signal   s                  : out   string;
    constant txt                : in    string
  ) is
  begin
    if active then
      print(s, txt);
      print(txt);
    end if;
  end procedure print2;

  procedure print2(
    signal   s                  : out   string;
    constant txt                : in    string
  ) is
  begin
    print2(true, s, txt);
  end procedure print2;

  procedure print2(
    constant active             : in    boolean;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t;
    constant txt                : in    string
  ) is
  begin
    print(active, pltbv, pltbs, txt);
    print(active, txt);
  end procedure print2;

  procedure print2(
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t;
    constant txt                : in    string
  ) is
  begin
    print2(true, pltbv, pltbs, txt);
  end procedure print2;

  ----------------------------------------------------------------------------
  -- waitclks
  --
  -- procedure waitclks(
  --   constant n                  : in    natural;
  --   signal   clk                : in    std_logic;
  --   variable pltbv              : inout pltbv_t;
  --   signal   pltbs              : out   pltbs_t;
  --   constant falling            : in    boolean := false;
  --   constant timeout            : in    time    := C_PLTBUTILS_TIMEOUT
  -- )
  --
  -- Waits specified amount of clock cycles of the specified clock.
  -- Or, to be more precise, a specified number of specified clock edges of
  -- the specified clock.
  --
  -- Arguments:
  --   n                        Number of rising or falling clock edges to wait.
  --
  --   clk                      The clock to wait for.
  --
  --   pltbv, pltbs             PlTbUtils' status- and control variable and
  --                            -signal.
  --
  --   falling                  If true, waits for falling edges, otherwise
  --                            rising edges. Optional, default is false.
  --
  --   timeout                  Timeout time, in case the clock is not working.
  --                            Optional, default is C_PLTBUTILS_TIMEOUT.
  --
  -- Examples:
  -- waitclks(5, sys_clk, pltbv, pltbs);
  -- waitclks(5, sys_clk, pltbv, pltbs true);
  -- waitclks(5, sys_clk, pltbv, pltbs, true, 1 ms);
  ----------------------------------------------------------------------------
  procedure waitclks(
    constant n                  : in    natural;
    signal   clk                : in    std_logic;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t;
    constant falling            : in    boolean := false;
    constant timeout            : in    time    := C_PLTBUTILS_TIMEOUT
  ) is
    variable i                  : natural := n;
    variable v_timeout_time     : time;
  begin
    v_timeout_time := now + timeout;
    while i > 0 loop
      if falling then
        wait until falling_edge(clk) for timeout / n;
      else
        wait until rising_edge(clk)  for timeout / n;
      end if;
      i := i - 1;
    end loop;
    if now >= v_timeout_time then
      pltbutils_error("waitclks() timeout", pltbv, pltbs);
    end if;
  end procedure waitclks;

  ----------------------------------------------------------------------------
  -- waitsig
  --
  -- procedure waitsig(
  --   signal   s                  : in    integer|std_logic|std_logic_vector|unsigned|signed;
  --   constant value              : in    integer|std_logic|std_logic_vector|unsigned|signed;
  --   signal   clk                : in    std_logic;
  --   variable pltbv              : inout pltbv_t;
  --   signal   pltbs              : out   pltbs_t;
  --   constant falling            : in    boolean := false;
  --   constant timeout            : in    time    := C_PLTBUTILS_TIMEOUT
  -- )
  --
  -- Waits until a signal has reached a specified value after specified clock
  -- edge.
  --
  -- Arguments:
  --   s                        The signal to test.
  --                            Supported types: integer, std_logic,
  --                            std_logic_vector, unsigned, signed.
  --
  --   value                    Value to wait for.
  --                            Same type as data or integer.
  --
  --   clk                      The clock.
  --
  --   pltbv, pltbs             PlTbUtils' status- and control variable and
  --                            -signal.
  --
  --   falling                  If true, waits for falling edges, otherwise
  --                            rising edges. Optional, default is false.
  --
  --   timeout                  Timeout time, in case the clock is not working.
  --                            Optional, default is C_PLTBUTILS_TIMEOUT.
  --
  -- Examples:
  -- waitsig(wr_en, '1', sys_clk, pltbv, pltbs);
  -- waitsig(rd_en,   1, sys_clk, pltbv, pltbs, true);
  -- waitclks(full, '1', sys_clk, pltbv, pltbs, true, 1 ms);
  ----------------------------------------------------------------------------
  -- waitsig integer, clocked
  procedure waitsig(
    signal   s                  : in    integer;
    constant value              : in    integer;
    signal   clk                : in    std_logic;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t;
    constant falling            : in    boolean := false;
    constant timeout            : in    time    := C_PLTBUTILS_TIMEOUT
  ) is
    variable v_timeout_time     : time;
  begin
    v_timeout_time := now + timeout;
    l1 : loop
      waitclks(1, clk, pltbv, pltbs, falling, timeout);
      exit l1 when s = value or now >= v_timeout_time;
    end loop;
    if now >= v_timeout_time then
      pltbutils_error("waitsig() timeout", pltbv, pltbs);
    end if;
  end procedure waitsig;

  -- waitsig std_logic, clocked
  procedure waitsig(
    signal   s                  : in    std_logic;
    constant value              : in    std_logic;
    signal   clk                : in    std_logic;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t;
    constant falling            : in    boolean := false;
    constant timeout            : in    time    := C_PLTBUTILS_TIMEOUT
  ) is
    variable v_timeout_time     : time;
  begin
    v_timeout_time := now + timeout;
    l1 : loop
      waitclks(1, clk, pltbv, pltbs, falling, timeout);
      exit l1 when s = value or now >= v_timeout_time;
    end loop;
    if now >= v_timeout_time then
      pltbutils_error("waitsig() timeout", pltbv, pltbs);
    end if;
  end procedure waitsig;

  -- waitsig std_logic against integer, clocked
  procedure waitsig(
    signal   s                  : in    std_logic;
    constant value              : in    integer;
    signal   clk                : in    std_logic;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t;
    constant falling            : in    boolean := false;
    constant timeout            : in    time    := C_PLTBUTILS_TIMEOUT
  ) is
    variable v_value            : std_logic;
    variable v_timeout_time     : time;
  begin
    case value is
      when 0      => v_value := '0';
      when 1      => v_value := '1';
      when others => v_value := 'X';
    end case;
    if v_value /= 'X' then
      waitsig(s, v_value, clk, pltbv, pltbs, falling, timeout);
    else
      pltbutils_error("waitsig() timeout", pltbv, pltbs);
    end if;
  end procedure waitsig;

  -- waitsig std_logic_vector, clocked
  procedure waitsig(
    signal   s                  : in    std_logic_vector;
    constant value              : in    std_logic_vector;
    signal   clk                : in    std_logic;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t;
    constant falling            : in    boolean := false;
    constant timeout            : in    time    := C_PLTBUTILS_TIMEOUT
  ) is
    variable v_timeout_time     : time;
  begin
    v_timeout_time := now + timeout;
    l1 : loop
      waitclks(1, clk, pltbv, pltbs, falling, timeout);
      exit l1 when s = value or now >= v_timeout_time;
    end loop;
    if now >= v_timeout_time then
      pltbutils_error("waitsig() timeout", pltbv, pltbs);
    end if;
  end procedure waitsig;

  -- waitsig std_logic_vector against integer, clocked
  procedure waitsig(
    signal   s                  : in    std_logic_vector;
    constant value              : in    integer;
    signal   clk                : in    std_logic;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t;
    constant falling            : in    boolean := false;
    constant timeout            : in    time    := C_PLTBUTILS_TIMEOUT
  ) is
    variable v_timeout_time     : time;
  begin
    waitsig(s, std_logic_vector(to_unsigned(value, s'length)), clk,
            pltbv, pltbs, falling, timeout);
  end procedure waitsig;

  -- waitsig unsigned, clocked
  procedure waitsig(
    signal   s                  : in    unsigned;
    constant value              : in    unsigned;
    signal   clk                : in    std_logic;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t;
    constant falling            : in    boolean := false;
    constant timeout            : in    time    := C_PLTBUTILS_TIMEOUT
  ) is
    variable v_timeout_time     : time;
  begin
    v_timeout_time := now + timeout;
    l1 : loop
      waitclks(1, clk, pltbv, pltbs, falling, timeout);
      exit l1 when s = value or now >= v_timeout_time;
    end loop;
    if now >= v_timeout_time then
      pltbutils_error("waitsig() timeout", pltbv, pltbs);
    end if;
  end procedure waitsig;

  -- waitsig unsigned against integer, clocked
  procedure waitsig(
    signal   s                  : in    unsigned;
    constant value              : in    integer;
    signal   clk                : in    std_logic;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t;
    constant falling            : in    boolean := false;
    constant timeout            : in    time    := C_PLTBUTILS_TIMEOUT
  ) is
    variable v_timeout_time     : time;
  begin
    waitsig(s, to_unsigned(value, s'length), clk,
            pltbv, pltbs, falling, timeout);
  end procedure waitsig;

  -- waitsig signed, clocked
  procedure waitsig(
    signal   s                  : in    signed;
    constant value              : in    signed;
    signal   clk                : in    std_logic;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t;
    constant falling            : in    boolean := false;
    constant timeout            : in    time    := C_PLTBUTILS_TIMEOUT
  ) is
    variable v_timeout_time     : time;
  begin
    v_timeout_time := now + timeout;
    l1 : loop
      waitclks(1, clk, pltbv, pltbs, falling, timeout);
      exit l1 when s = value or now >= v_timeout_time;
    end loop;
    if now >= v_timeout_time then
      pltbutils_error("waitsig() timeout", pltbv, pltbs);
    end if;
  end procedure waitsig;

  -- waitsig signed against integer, clocked
  procedure waitsig(
    signal   s                  : in    signed;
    constant value              : in    integer;
    signal   clk                : in    std_logic;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t;
    constant falling            : in    boolean := false;
    constant timeout            : in    time    := C_PLTBUTILS_TIMEOUT
  ) is
    variable v_timeout_time     : time;
  begin
    waitsig(s, to_signed(value, s'length), clk,
            pltbv, pltbs, falling, timeout);
  end procedure waitsig;

  -- waitsig std_logic, unclocked
  procedure waitsig(
    signal   s                  : in    std_logic;
    constant value              : in    std_logic;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t;
    constant timeout            : in    time    := C_PLTBUTILS_TIMEOUT
  ) is
  begin
    if s /= value then
      wait until s = value for timeout;
      if s /= value then
        pltbutils_error("waitsig() timeout", pltbv, pltbs);
      end if;
    end if;
  end procedure waitsig;

  ----------------------------------------------------------------------------
  -- check
  --
  -- procedure check(
  --   constant rpt             : in    string;
  --   constant actual          : in    integer|std_logic|std_logic_vector|unsigned|signed|string;
  --   constant expected        : in    integer|std_logic|std_logic_vector|unsigned|signed|string;
  --   variable pltbv           : inout pltbv_t;
  --   signal   pltbs           : out   pltbs_t
  -- )
  --
  -- procedure check(
  --   constant rpt             : in    string;
  --   constant actual          : in    std_logic_vector;
  --   constant expected        : in    std_logic_vector;
  --   constant mask            : in    std_logic_vector;
  --   variable pltbv           : inout pltbv_t;
  --   signal   pltbs           : out   pltbs_t
  -- )
  --
  -- procedure check(
  --   constant rpt             : in    string;
  --   constant expr            : in    boolean;
  --   variable pltbv           : inout pltbv_t;
  --   signal   pltbs           : out   pltbs_t
  -- )
  --
  -- Checks that the value of a signal or variable is equal to expected.
  -- If not equal, displays an error message and increments the error counter.
  --
  -- Arguments:
  --   rpt                      Report message to be displayed in case of
  --                            mismatch.
  --                            It is recommended that the message is unique
  --                            and that it contains the name of the signal
  --                            or variable being checked.
  --                            The message should NOT contain the expected
  --                            value, becase check() prints that
  --                            automatically.
  --
  --   actual                   The signal or variable to be checked.
  --                            Supported types: integer, std_logic,
  --                            std_logic_vector, unsigned, signed.
  --
  --   expected                 Expected value.
  --                            Same type as data or integer.
  --
  --   mask                     Bit mask and:ed to data and expected
  --                            before comparison.
  --                            Optional if data is std_logic_vector.
  --                            Not allowed for other types.
  --
  --   expr                     boolean expression for checking.
  --                            This makes it possible to check any kind of
  --                            expresion, not just equality.
  --
  --   pltbv, pltbs             PlTbUtils' status- and control variable and
  --                            -signal.
  --
  -- Examples:
  -- check("dat_o after reset", dat_o, 0, pltbv, pltbs);
  -- -- With mask:
  -- check("Status field in reg_o after start", reg_o, x"01", x"03", pltbv, pltbs);
  -- -- Boolean expression:
  -- check("Counter after data burst", cnt_o > 10, pltbv, pltbs);
  ----------------------------------------------------------------------------
  -- check integer
  procedure check(
    constant rpt                : in    string;
    constant actual             : in    integer;
    constant expected           : in    integer;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t
  ) is
  begin
    check(rpt, actual = expected, str(actual), str(expected), "", pltbv, pltbs);
  end procedure check;

  -- check std_logic
  procedure check(
    constant rpt                : in    string;
    constant actual             : in    std_logic;
    constant expected           : in    std_logic;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t
  ) is
  begin
    check(rpt, actual = expected, str(actual), str(expected), "", pltbv, pltbs);
  end procedure check;

  -- check std_logic against integer
  procedure check(
    constant rpt                : in    string;
    constant actual             : in    std_logic;
    constant expected           : in    integer;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t
  ) is
  begin
    check(rpt, ((actual = '0' and expected = 0) or (actual = '1' and expected = 1)),
          str(actual), str(expected), "", pltbv, pltbs);
  end procedure check;

  -- check std_logic_vector
  procedure check(
    constant rpt                : in    string;
    constant actual             : in    std_logic_vector;
    constant expected           : in    std_logic_vector;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t
  ) is
  begin
    check(rpt, actual = expected, hxstr(actual, "0x"), hxstr(expected, "0x"), "", pltbv, pltbs);
  end procedure check;

  -- check std_logic_vector with mask
  procedure check(
    constant rpt                : in    string;
    constant actual             : in    std_logic_vector;
    constant expected           : in    std_logic_vector;
    constant mask               : in    std_logic_vector;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t
  ) is
  begin
    check(rpt, (actual and mask) = (expected and mask),
          hxstr(actual, "0x"), hxstr(expected, "0x"), hxstr(mask, "0x"), pltbv, pltbs);
  end procedure check;

  -- check std_logic_vector against integer
  procedure check(
    constant rpt                : in    string;
    constant actual             : in    std_logic_vector;
    constant expected           : in    integer;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t
  ) is
  begin
    check(rpt, actual, std_logic_vector(to_signed(expected, actual'length)), pltbv, pltbs);
  end procedure check;

  -- check std_logic_vector with mask against integer
  procedure check(
    constant rpt                : in    string;
    constant actual             : in    std_logic_vector;
    constant expected           : in    integer;
    constant mask               : in    std_logic_vector;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t
  ) is
  begin
    check(rpt, actual, std_logic_vector(to_signed(expected, actual'length)), mask, pltbv, pltbs);
  end procedure check;

  -- check unsigned
  procedure check(
    constant rpt                : in    string;
    constant actual             : in    unsigned;
    constant expected           : in    unsigned;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t
  ) is
  begin
    check(rpt, actual = expected, hxstr(actual, "0x"), hxstr(expected, "0x"), "", pltbv, pltbs);
  end procedure check;

  -- check unsigned against integer
  procedure check(
    constant rpt                : in    string;
    constant actual             : in    unsigned;
    constant expected           : in    integer;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t
  ) is
  begin
    check(rpt, actual, to_unsigned(expected, actual'length), pltbv, pltbs);
  end procedure check;

  -- check signed
  procedure check(
    constant rpt                : in    string;
    constant actual             : in    signed;
    constant expected           : in    signed;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t
  ) is
  begin
    check(rpt, actual = expected, hxstr(actual, "0x"), hxstr(expected, "0x"), "", pltbv, pltbs);
  end procedure check;

  -- check signed against integer
  -- TODO: find the bug reported by tb_pltbutils when expected  is negative (-1):
  --       ** Error: (vsim-86) numstd_conv_unsigned_nu: NATURAL arg value is negative (-1)
  procedure check(
    constant rpt                : in    string;
    constant actual             : in    signed;
    constant expected           : in    integer;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t
  ) is
  begin
    check(rpt, actual, to_signed(expected, actual'length), pltbv, pltbs);
  end procedure check;
  
  -- check string
  procedure check(
    constant rpt                : in    string;
    constant actual             : in    string;
    constant expected           : in    string;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t
  ) is
    variable mismatch : boolean := false;
  begin
    if actual'length /= expected'length then
      mismatch := true;
    else
      for i in 0 to actual'length-1 loop
        if actual(i+actual'low) /= expected(i+expected'low) then
          mismatch := true;
          exit;
        end if;
      end loop;
    end if;
    check(rpt, not mismatch, actual, expected, "", pltbv, pltbs);
  end procedure check;  
  
  -- check with boolean expression
  -- Check signal or variable with a boolean expression as argument C_EXPR.
  -- This allowes any kind of check.
  procedure check(
    constant rpt                : in    string;
    constant expr               : in    boolean;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t
  ) is
  begin
    check(rpt, expr, "", "", "", pltbv, pltbs);
  end procedure check;

  procedure check(
    constant rpt                : in    string;
    constant expr               : in    boolean;
    constant actual             : in    string;
    constant expected           : in    string;
    constant mask               : in    string;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t
  ) is
    variable timestamp          : time;
  begin
    timestamp := now;
    pltbv.chk_cnt := pltbv.chk_cnt + 1;
    pltbv.chk_cnt_in_test := pltbv.chk_cnt_in_test + 1;
    if not expr then
      pltbv.err_cnt := pltbv.err_cnt + 1;
      pltbv.err_cnt_in_test := pltbv.err_cnt_in_test + 1;
    end if;
    pltbs_update(pltbv, pltbs);
    if C_PLTBUTILS_USE_STD_CHECK_MSG then
      check_msg(rpt, timestamp, expr, actual, expected, mask, pltbv.test_num,
        pltbv.test_name(1 to pltbv.test_name_len), pltbv.chk_cnt, pltbv.err_cnt_in_test);
    end if;
    if C_PLTBUTILS_USE_CUSTOM_CHECK_MSG then
      custom_check_msg(rpt, timestamp, expr, actual, expected, mask, pltbv.test_num,
        pltbv.test_name(1 to pltbv.test_name_len), pltbv.chk_cnt, pltbv.err_cnt_in_test);
    end if;
    pltbs_update(pltbv, pltbs);
  end procedure check;

  ----------------------------------------------------------------------------
  -- to_ascending
  --
  -- function to_ascending(
  --  constant s                  : std_logic_vector
  -- ) return std_logic_vector;
  --
  -- function to_ascending(
  --  constant s                  : unsigned
  -- ) return unsigned
  --
  -- function to_ascending(
  --  constant s                  : signed
  -- ) return signed;
  --
  -- Converts a vector to ascending range ("to-range").
  -- The argument s can have ascending or descending range.
  -- E.g. an argument defined as a std_logic_vector(3 downto 1) 
  -- will be returned as a std_logic_vector(1 to 3).
  --
  -- Arguments: 
  --   s             Constant, signal or variable to convert
  --
  -- Return value:   Converted value
  --
  -- Examples:
  -- ascending_sig <= to_ascending(descending_sig);
  -- ascending_var := to_ascending(descending_var);
  ----------------------------------------------------------------------------
  function to_ascending(
    constant s                  : std_logic_vector
  ) return std_logic_vector is
    variable r : std_logic_vector(s'low to s'high);
  begin
    for i in r'range loop
      r(i) := s(i);
    end loop;
    return r;
  end function to_ascending;

  function to_ascending(
    constant s                  : unsigned
  ) return unsigned is
    variable r : unsigned(s'low to s'high);
  begin
    for i in r'range loop
      r(i) := s(i);
    end loop;
    return r;
  end function to_ascending;

  function to_ascending(
    constant s                  : signed
  ) return signed is
    variable r : signed(s'low to s'high);
  begin
    for i in r'range loop
      r(i) := s(i);
    end loop;
    return r;
  end function to_ascending;

  ----------------------------------------------------------------------------
  -- to_descending
  --
  -- function to_descending(
  --  constant s                  : std_logic_vector
  -- ) return std_logic_vector;
  --
  -- function to_descending(
  --  constant s                  : unsigned
  -- ) return unsigned
  --
  -- function to_descending(
  --  constant s                  : signed
  -- ) return signed;
  --
  -- Converts a vector to descending range ("downto-range").
  -- The argument s can have ascending or descending range.
  -- E.g. an argument defined as a std_logic_vector(1 to 3) 
  -- will be returned as a std_logic_vector(3 downto 1).
  --
  -- Arguments: 
  --   s             Constant, signal or variable to convert
  --
  -- Return value:   Converted value
  --
  -- Examples:
  -- descending_sig <= to_descending(ascending_sig);
  -- descending_var := to_descending(ascending_var);
  ----------------------------------------------------------------------------
  function to_descending(
    constant s                  : std_logic_vector
  ) return std_logic_vector is
    variable r : std_logic_vector(s'high downto s'low);
  begin
    for i in r'range loop
      r(i) := s(i);
    end loop;
    return r;
  end function to_descending;

  function to_descending(
    constant s                  : unsigned
  ) return unsigned is
    variable r : unsigned(s'high downto s'low);
  begin
    for i in r'range loop
      r(i) := s(i);
    end loop;
    return r;
  end function to_descending;

  function to_descending(
    constant s                  : signed
  ) return signed is
    variable r : signed(s'high downto s'low);
  begin
    for i in r'range loop
      r(i) := s(i);
    end loop;
    return r;
  end function to_descending;

  ----------------------------------------------------------------------------
  -- hxstr
  -- function hxstr(
  --  constant s                  : std_logic_vector;
  --  constant prefix             : string := "";
  --  constant postfix            : string := ""
  -- ) return string;
  --
  -- function hxstr(
  --  constant s                  : unsigned;
  --  constant prefix             : string := "";
  --  constant postfix            : string := ""
  -- ) return string;
  --
  -- function hxstr(
  --  constant s                  : signed;
  --  constant prefix             : string := "";
  --  constant postfix            : string := ""
  -- ) return string;
  --
  -- Converts a vector to a string in hexadecimal format.
  -- An optional prefix can be specified, e.g. "0x", as well as a suffix.
  --
  -- The input argument can have ascending range ( "to-range" ) or descending range
  -- ("downto-range"). There is no vector length limitation.
  --
  -- Arguments: 
  --   s             Constant, signal or variable to convert
  --
  -- Return value:   Converted value
  --
  -- Examples:
  -- print("value=" & hxstr(s));
  -- print("value=" & hxstr(s, "0x"));
  -- print("value=" & hxstr(s, "16#", "#"));
  ----------------------------------------------------------------------------
  function hxstr(
    constant s                  : std_logic_vector;
    constant prefix             : string := "";
    constant postfix            : string := ""
  ) return string is
    variable hexstr             : string(1 to (s'length+3)/4);
    variable nibble_aligned_s   : std_logic_vector(((s'length+3)/4)*4-1 downto 0) := (others => '0');
    variable nibble             : std_logic_vector(3 downto 0);
  begin
    nibble_aligned_s(s'length-1 downto 0) := to_descending(s);
    for i in 0 to nibble_aligned_s'high/4 loop
      nibble := nibble_aligned_s(4*i + 3 downto 4*i); 
      case nibble is
        when "0000" => hexstr(hexstr'high-i) := '0';
        when "0001" => hexstr(hexstr'high-i) := '1';
        when "0010" => hexstr(hexstr'high-i) := '2';
        when "0011" => hexstr(hexstr'high-i) := '3';
        when "0100" => hexstr(hexstr'high-i) := '4';
        when "0101" => hexstr(hexstr'high-i) := '5';
        when "0110" => hexstr(hexstr'high-i) := '6';
        when "0111" => hexstr(hexstr'high-i) := '7';
        when "1000" => hexstr(hexstr'high-i) := '8';
        when "1001" => hexstr(hexstr'high-i) := '9';
        when "1010" => hexstr(hexstr'high-i) := 'A';
        when "1011" => hexstr(hexstr'high-i) := 'B';
        when "1100" => hexstr(hexstr'high-i) := 'C';
        when "1101" => hexstr(hexstr'high-i) := 'D';
        when "1110" => hexstr(hexstr'high-i) := 'E';
        when "1111" => hexstr(hexstr'high-i) := 'F';
        when "UUUU" => hexstr(hexstr'high-i) := 'U';
        when "XXXX" => hexstr(hexstr'high-i) := 'X';
        when "ZZZZ" => hexstr(hexstr'high-i) := 'Z';
        when "WWWW" => hexstr(hexstr'high-i) := 'W';
        when "LLLL" => hexstr(hexstr'high-i) := 'L';
        when "HHHH" => hexstr(hexstr'high-i) := 'H';
        when "----" => hexstr(hexstr'high-i) := '-';
        when others => hexstr(hexstr'high-i) := '?';
        -- TODO: handle vectors where nibble_aligned_s'length > a'length and the highest nibble are all equal characters such as "XXX"
      end case; 
    end loop;
    return prefix & hexstr & postfix;
  end function hxstr;

  function hxstr(
    constant s                  : unsigned;
    constant prefix             : string := "";
    constant postfix            : string := ""
  ) return string is
  begin
    return hxstr(std_logic_vector(s), prefix, postfix);
  end function hxstr;

  function hxstr(
    constant s                  : signed;
    constant prefix             : string := "";
    constant postfix            : string := ""
  ) return string is
  begin
    return hxstr(std_logic_vector(s), prefix, postfix);
  end function hxstr;

  ----------------------------------------------------------------------------
  -- pltbutils internal procedures, called from other pltbutils procedures.
  -- Do not to call these from user's code.
  -- These procedures are undocumented in the specification on purpose.
  ----------------------------------------------------------------------------
  procedure pltbs_update(
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t
  ) is
  begin
    pltbs.test_num  <= pltbv.test_num;
    print(pltbs.test_name, pltbv.test_name);
    print(pltbs.info, pltbv.info);
    pltbs.chk_cnt   <= pltbv.chk_cnt;
    pltbs.err_cnt   <= pltbv.err_cnt;
    pltbs.stop_sim  <= pltbv.stop_sim;
  end procedure pltbs_update;

  procedure pltbutils_error(
    constant rpt                : in string;
    variable pltbv              : inout pltbv_t;
    signal   pltbs              : out   pltbs_t
  ) is
  begin
    pltbv.err_cnt := pltbv.err_cnt + 1;
    pltbv.err_cnt_in_test := pltbv.err_cnt_in_test + 1;
    pltbs_update(pltbv, pltbs);
    if C_PLTBUTILS_USE_STD_ERROR_MSG then
      error_msg(rpt, now, pltbv.test_num,
        pltbv.test_name(1 to pltbv.test_name_len), pltbv.err_cnt_in_test);
    end if;
    if C_PLTBUTILS_USE_CUSTOM_ERROR_MSG then
      custom_error_msg(rpt, now, pltbv.test_num,
        pltbv.test_name(1 to pltbv.test_name_len), pltbv.err_cnt_in_test);
    end if;
  end procedure pltbutils_error;

  procedure stopsim(
    constant timestamp          : in time
  ) is
  begin
    assert false
    report "--- FORCE END OF SIMULATION ---" &
           " (ignore this false failure message, it's not a real failure)"
    severity failure;
  end procedure stopsim;

  procedure startsim_msg(
    constant testcase_name      : in string;
    constant timestamp          : in time
  ) is
  begin
    print(lf & "--- START OF SIMULATION ---");
    print("Testcase: " & testcase_name);
    print(time'image(timestamp));
  end procedure startsim_msg;

  procedure endsim_msg(
    constant testcase_name      : in string;
    constant timestamp          : in time;
    constant num_tests          : in integer;
    constant num_checks         : in integer;
    constant num_errors         : in integer;
    constant show_success_fail  : in boolean
  ) is
    variable l : line;
  begin
    print(lf & "--- END OF SIMULATION ---");
    print("Note: the results presented below are based on the PlTbUtil's check() procedure calls.");
    print("      The design may contain more errors, for which there are no check() calls.");
    write(l, timestamp, right, 14);
    writeline(output, l);
    write(l, num_tests, right, 11);
    write(l, string'(" Tests"));
    writeline(output, l);
    write(l, num_checks, right, 11);
    write(l, string'(" Checks"));
    writeline(output, l);
    write(l, num_errors, right, 11);
    write(l, string'(" Errors"));
    writeline(output, l);
    if show_success_fail then
      if num_errors = 0 and num_checks > 0 then
        print("*** SUCCESS ***");
      elsif num_checks > 0 then
        print("*** FAIL ***");
      else
        print("*** NO CHECKS ***");
      end if;
    end if;
  end procedure endsim_msg;

  procedure starttest_msg(
    constant test_num           : in integer;
    constant test_name          : in string;
    constant timestamp          : in time
  ) is
  begin
    print(lf & "Test " & str(test_num) & ": " & test_name & " (" & time'image(timestamp) & ")");
  end procedure starttest_msg;

  procedure endtest_msg(
    constant test_num           : in integer;
    constant test_name          : in string;
    constant timestamp          : in time;
    constant num_checks_in_test : in integer;
    constant num_errors_in_test : in integer
  ) is
  begin
    print("Done with test " & str(test_num) & ": " & test_name & " (" & time'image(timestamp) & ")");
  end procedure endtest_msg;

  procedure check_msg(
    constant rpt                : in string;
    constant timestamp          : in time;
    constant expr               : in boolean;
    constant actual             : in string;
    constant expected           : in string;
    constant mask               : in string;
    constant test_num           : in integer;
    constant test_name          : in string;
    constant check_num          : in integer;
    constant err_cnt_in_test    : in integer
  ) is
    variable actual_str_len     : integer := 1;
    variable actual_str         : string(1 to actual'length+8) := (others => ' ');
    variable expected_str       : string(1 to expected'length+10) := (others => ' ');
    variable expected_str_len   : integer := 1;
    variable mask_str           : string(1 to mask'length+6) := (others => ' ');
    variable mask_str_len       : integer := 1;
  begin
    if not expr then -- Output message only if the check fails
      if actual /= "" then
        actual_str_len := 8 + actual'length;
        actual_str := " Actual=" & actual;
      end if;
      if expected /= "" then
        expected_str_len := 10 + expected'length;
        expected_str := " Expected=" & expected;
      end if;
      if mask /= "" then
        mask_str_len := 6 + mask'length;
        mask_str := " Mask=" & mask;
      end if;
      assert false
        report "Check " & str(check_num) & "; " & rpt & "; " &
               actual_str(1 to actual_str_len) &
               expected_str(1 to expected_str_len) &
               mask_str(1 to mask_str_len) &
               "  in test " & str(test_num) & " " & test_name
        severity error;
    end if;
  end procedure check_msg;

  procedure error_msg(
    constant rpt                : in string;
    constant timestamp          : in time;
    constant test_num           : in integer;
    constant test_name          : in string;
    constant err_cnt_in_test    : in integer
  ) is
  begin
    assert false
    report rpt & " in test " & str(test_num) & ": " & test_name
    severity error;
  end procedure error_msg;

end package body pltbutils_func_pkg;