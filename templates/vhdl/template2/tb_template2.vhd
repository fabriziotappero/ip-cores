----------------------------------------------------------------------
----                                                              ----
---- PlTbUtils Testbench Template 2                               ----
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
---- "template" with a name for your design.                      ----
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
use std.textio.all;
use work.txt_util.all;
use work.pltbutils_func_pkg.all;
use work.pltbutils_comp_pkg.all;
-- < Template info: add more libraries here, if needed >

entity tb_template2 is
  generic (
    -- < Template info: add generics here if needed, or remove the generic block >    
  );
end entity tb_template2;

architecture bhv of tb_template2 is

  -- Simulation status- and control signals
  -- for accessing .stop_sim and for viewing in waveform window
  signal pltbs          : pltbs_t := C_PLTBS_INIT;
  
  -- DUT stimuli and response signals
  signal clk            : std_logic;
  signal rst            : std_logic;
  -- < Template info: add more DUT stimuli and response signals here. >
  
begin

  dut0 : entity work.template
    generic map (
      -- < Template info: add DUT generics here, if any. >      
    )
    port map (
      clk_i             => clk, -- Template example
      rst_i             => rst, -- Template example
      -- < Template info: add more DUT ports here. >
    );
    
  clkgen0 : pltbutils_clkgen
    generic map(
      G_PERIOD          => G_CLK_PERIOD
    )
    port map(
      clk_o             => clk,
      stop_sim_i        => pltbs.stop_sim
    );
   
  tc0 : entity work.tc_template2
    generic map (
      -- < Template info: add generics for testcase component here, if any. >
    )
    port map(
      clk               => clk, -- Template example
      rst               => rst, -- Template example
      -- < Template info: add more ports for testcase component here. >
    );
  
end architecture bhv;
