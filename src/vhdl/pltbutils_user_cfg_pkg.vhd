----------------------------------------------------------------------
----                                                              ----
---- PlTbUtils User Configuration Package                         ----
----                                                              ----
---- This file is part of the PlTbUtils project                   ----
---- http://opencores.org/project,pltbutils                       ----
----                                                              ----
---- Description:                                                 ----
---- PlTbUtils is a collection of functions, procedures and       ----
---- components for easily creating stimuli and checking response ----
---- in automatic self-checking testbenches.                      ----
----                                                              ----
---- This file defines the user's customizations.                 ----
----                                                              ----
---- If the user wishes to modify anything in this file, it is    ----
---- recommended that he/she first copies it to another directory ----
---- and modifies the copy. Also make sure that the simulator     ----
---- read the modified file instead of the original.              ----
---- This makes it easier to update pltbutils to new versions     ----
---- without destroying the customizations.                       ----
----                                                              ----
---- To Do:                                                       ----
---- -                                                            ----
----                                                              ----
---- Author(s):                                                   ----
---- - Per Larsson, pela.opencores@gmail.com                      ----
----                                                              ----
----------------------------------------------------------------------
----                                                              ----
---- Copyright (C) 2014 Authors and OPENCORES.ORG                 ----
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
--use std.textio.all;
--use std.env.all; -- Uncomment if using stop or finish in custom_stopsim() below.
use work.txt_util.all;

package pltbutils_user_cfg_pkg is

  --- Constants ---
  -- The user is free to modify the values to fit his/her requirements.
  constant C_PLTBUTILS_USE_STD_STARTSIM_MSG     : boolean := true;
  constant C_PLTBUTILS_USE_STD_ENDSIM_MSG       : boolean := true;
  constant C_PLTBUTILS_USE_STD_STARTTEST_MSG    : boolean := true;
  constant C_PLTBUTILS_USE_STD_ENDTEST_MSG      : boolean := true;
  constant C_PLTBUTILS_USE_STD_CHECK_MSG        : boolean := true;
  constant C_PLTBUTILS_USE_STD_ERROR_MSG        : boolean := true;
  constant C_PLTBUTILS_USE_STD_STOPSIM          : boolean := true;
  constant C_PLTBUTILS_USE_CUSTOM_STARTSIM_MSG  : boolean := false;
  constant C_PLTBUTILS_USE_CUSTOM_ENDSIM_MSG    : boolean := false;
  constant C_PLTBUTILS_USE_CUSTOM_STARTTEST_MSG : boolean := false;
  constant C_PLTBUTILS_USE_CUSTOM_ENDTEST_MSG   : boolean := false;
  constant C_PLTBUTILS_USE_CUSTOM_CHECK_MSG     : boolean := false;
  constant C_PLTBUTILS_USE_CUSTOM_ERROR_MSG     : boolean := false;
  constant C_PLTBUTILS_USE_CUSTOM_STOPSIM       : boolean := false;

  --- Procedure declarations ---
  -- The user should NOT modify these.
  
  procedure custom_stopsim(
    constant timestamp          : in time
  );
  
  procedure custom_startsim_msg(
    constant testcase_name      : in string;
    constant timestamp          : in time    
  );
  
  procedure custom_endsim_msg(
    constant testcase_name      : in string;
    constant timestamp          : in time;
    constant num_tests          : in integer;
    constant num_checks         : in integer;
    constant num_errors         : in integer;
    constant show_success_fail  : in boolean
  );
  
  procedure custom_starttest_msg(
    constant test_num           : in integer;
    constant test_name          : in string;
    constant timestamp          : in time
  );  
  
  procedure custom_endtest_msg(
    constant test_num           : in integer;
    constant test_name          : in string;
    constant timestamp          : in time;
    constant num_checks_in_test : in integer;
    constant num_errors_in_test : in integer
  );  
  
  procedure custom_check_msg(
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
  
  procedure custom_error_msg(
    constant rpt                : in string;
    constant timestamp          : in time;
    constant test_num           : in integer;      
    constant test_name          : in string;
    constant err_cnt_in_test    : in integer
  );
    
  --- User's function and procedure declarations ---
  -- Example for use with TeamCity. Remove, modify or replace
  -- to suit other other continous integration tools or scripts, if you need to.
  function tcfilter( 
    constant s : string
  ) return string;

end package pltbutils_user_cfg_pkg;

package body pltbutils_user_cfg_pkg is

  --- Procedure definitions ---
  -- The user should NOT modify the arguments,
  -- but the behaviour is free to modify to fit the user's requirements.
  
  procedure custom_stopsim(
    constant timestamp          : in time
  ) is
  begin
    -- The best way to stop a simulation differs between different simulators.
    -- Below are some examples. Modify to suit your simulator.
  
    -- Works with some simulators that supports VHDL-2008. 
    -- Requires that 'use std.env.all' at the top of the file is uncommented.
    --stop;
    
    -- Works with some simulators that support VHDL-2008. 
    -- Requires that 'use std.env.all' at the top of the file is uncommented.
    --finish;
    
    -- Works in all simulators known by the author, but ugly.
    assert false
    report "--- FORCE END OF SIMULATION ---" &
           " (ignore this false failure message, it's not a real failure)"
    severity failure;
    
  end procedure custom_stopsim;  

  -- Example custom messages for TeamCity.
  -- Edit to suit other continous integration tools or scripts, if you need to.
  -- General TeamCity information: http://www.jetbrains.com/teamcity/
  --                               http://en.wikipedia.org/wiki/Teamcity
  -- TeamCity test reporting:      http://confluence.jetbrains.com/display/TCD8/Build+Script+Interaction+with+TeamCity#BuildScriptInteractionwithTeamCity-ReportingTests
  
  procedure custom_startsim_msg(
    constant testcase_name      : in string;
    constant timestamp          : in time    
  ) is
  begin
    print("##teamcity[testSuiteStarted name='" & tcfilter(testcase_name) & "']");
  end procedure custom_startsim_msg;

  procedure custom_endsim_msg(
    constant testcase_name      : in string;
    constant timestamp          : in time;
    constant num_tests          : in integer;
    constant num_checks         : in integer;
    constant num_errors         : in integer;
    constant show_success_fail  : in boolean
  ) is
  begin
    -- TeamCity ignores all arguments except testcase_name
    print("##teamcity[testSuiteFinished name='" & tcfilter(testcase_name) & "']");
  end procedure custom_endsim_msg;
  
  procedure custom_starttest_msg(
    constant test_num           : in integer;
    constant test_name          : in string;
    constant timestamp          : in time
  ) is
  begin
    -- TeamCity ignores test_num and timestamp
    print("##teamcity[testStarted name='" & tcfilter(test_name) & "']");
  end procedure custom_starttest_msg;

  procedure custom_endtest_msg(
    constant test_num           : in integer;
    constant test_name          : in string;
    constant timestamp          : in time;
    constant num_checks_in_test : in integer;
    constant num_errors_in_test : in integer
  ) is
  begin
    -- TeamCity ignores all arguments except test_name
    print("##teamcity[testFinished name='" & tcfilter(test_name) & "']");
  end procedure custom_endtest_msg;

  procedure custom_check_msg(
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
    variable comparison_str     : string(1 to 32) := (others => ' ');
    variable comparison_str_len : integer := 1;
    variable actual_str         : string(1 to 32) := (others => ' ');
    variable actual_str_len     : integer := 1;
    variable expected_str       : string(1 to 32) := (others => ' ');
    variable expected_str_len   : integer := 1;
    variable mask_str           : string(1 to 32) := (others => ' ');
    variable mask_str_len       : integer := 1;
  begin
    if not expr then -- Output message only if the check fails
      if err_cnt_in_test <= 1 then -- TeamCity allows max one error message per test
        if actual /= "" then
          actual_str_len := 10 + actual'length;
          actual_str(1 to actual_str_len) := " actual='" & tcfilter(actual) & "'";
        end if;        
        if expected /= "" then
          comparison_str_len := 26;
          comparison_str(1 to comparison_str_len) := " type='comparisonFailure' ";
          expected_str_len := 12 + expected'length;
          expected_str(1 to expected_str_len) := " expected='" & tcfilter(expected) & "'";
        end if;        
        if mask /= "" then
          mask_str_len := 17 + mask'length;
          mask_str(1 to mask_str_len) := " details='mask=" & tcfilter(mask) & "' ";
        end if;        
        print("##teamcity[testFailed" &
              comparison_str(1 to comparison_str_len) &
              "name='" & tcfilter(test_name) & "' " &
              "message='" & tcfilter(rpt) & "' " &
              expected_str(1 to expected_str_len) & 
              actual_str(1 to actual_str_len) &
              mask_str(1 to mask_str_len) &
              "]");
      else
        print("(TeamCity error message filtered out, because max one message is allowed for each test)");
      end if;
    end if;
  end procedure custom_check_msg;
  
  procedure custom_error_msg(
    constant rpt                : in string;
    constant timestamp          : in time;
    constant test_num           : in integer;      
    constant test_name          : in string;
    constant err_cnt_in_test    : in integer
  ) is
  begin
    if err_cnt_in_test <= 1 then -- TeamCity allows max one error message per test
      print("##teamcity[testFailed" &
            "name='" & tcfilter(test_name) & "' " &
            "message='" & tcfilter(rpt) & "']");
    else
      print("(TeamCity error message filtered out, because max one message is allowed for each test)");  
    end if;
  end procedure custom_error_msg;
  
  --- User's function and procedure definitions ---
  -- Example for use with TeamCity. Remove, modify or replace
  -- to suit other other continous integration tools or scripts, if you need to.

  -- TeamCity string filter. Filters out characters which are not allowed in TeamCity messages.
  -- Search for "escaped values" in 
  --   http://confluence.jetbrains.com/display/TCD8/Build+Script+Interaction+with+TeamCity#BuildScriptInteractionwithTeamCity-ReportingTests
  -- The TeamCity escape character is not used, because that changes the length of the string.
  -- The VHDL code can be simplified if it doesn't have to deal with changes of string
  -- lengths. 
  function tcfilter( 
    constant s : string
  ) return string is
    variable r : string(s'range) := (others => (' '));
  begin
    for i in s'range loop
      if s(i) = ''' then
        r(i) := '`';
      elsif s(i) = lf or s(i) = cr then
        r(i) := ' ';
      elsif s(i) = '|' then
        r(i) := '/';
      elsif s(i) = '[' then
        r(i) := '{';
      elsif s(i) = ']' then
        r(i) := '}';
      else
        r(i) := s(i);
      end if;      
    end loop;
    return r;
  end function tcfilter;
   
end package body pltbutils_user_cfg_pkg;