----------------------------------------------------------------------
----                                                              ----
---- PlTbUtils Testcase Architecture for                          ----
---- Template Testbench                                           ----
----                                                              ----
---- This file is part of the PlTbUtils project                   ----
---- http://opencores.org/project,pltbutils                       ----
----                                                              ----
---- Description:                                                 ----
---- PlTbUtils is a collection of functions, procedures and       ----
---- components for easily creating stimuli and checking response ----
---- in automatic self-checking testbenches.                      ----
----                                                              ----
---- This file is a template, which can be used as a base when    ----
---- testbenches which use PlTbUtils.                             ----
---- Copy this file to your preferred location and rename the     ----
---- copied file and its contents, by replacing the word          ---- 
---- "templateXX" with a name for your design.                    ----
---- Also remove informative comments enclosed in < ... > .       ----
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
--use work.txt_util.all;
use work.pltbutils_func_pkg.all;

architecture tc1 of tc_template2 is
begin
  p_tc1 : process
    variable pltbv  : pltbv_t := C_PLTBV_INIT;
  begin
    startsim("tc1", pltbv, pltbs);
    rst         <= '1'; -- Template example
    -- < Template info: initialize other DUT stimuli here. >
        
    starttest(1, "Reset test", pltbv, pltbs); -- Template example
    waitclks(2, clk, pltbv, pltbs); -- Template example
    check("template_signal during reset", template_signal, 0, pltbv, pltbs); -- Template example
    -- < Template info: check other DUT outputs here. 
    rst  <= '0'; -- Template example
    endtest(pltbv, pltbs);
    
    starttest(2, "Template test", pltbv, pltbs);
    -- < Template info: set all relevant DUT inputs here. >
    waitclks(2, clk, pltbv, pltbs); -- Template example
    -- < Template info: check all relevant DUT outputs here. >
    endtest(pltbv, pltbs);
    -- < Template info: add more tests here. >

    endsim(pltbv, pltbs, true);
    wait;
  end process p_tc1;
end architecture tc1;