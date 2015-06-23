----------------------------------------------------------------------
----                                                              ----
---- PlTbUtils Components                                         ----
----                                                              ----
---- This file is part of the PlTbUtils project                   ----
---- http://opencores.org/project,pltbutils                       ----
----                                                              ----
---- Description:                                                 ----
---- PlTbUtils is a collection of functions, procedures and       ----
---- components for easily creating stimuli and checking response ----
---- in automatic self-checking testbenches.                      ----
----                                                              ----
---- pltbutils_comp.vhd (this file) defines testbench components. ----
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
---- Copyright (C) 2013 Authors and OPENCORES.ORG                 ----
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

----------------------------------------------------------------------
-- pltbutils_clkgen
-- Creates a clock for use in a testbech.
-- A non-inverted as well as an inverted output is available, 
-- use one or both depending on if you need a single-ended or
-- differential clock.
-- The clock stops when input port stop_sim goes '1'.
-- This makes the simulator stop (unless there are other infinite 
-- processes running in the simulation).
----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity pltbutils_clkgen is
  generic (
    G_PERIOD        : time := 10 ns;
    G_INITVALUE     : std_logic := '0'
  );
  port (
    clk_o           : out std_logic;
    clk_n_o         : out std_logic;
    stop_sim_i      : in  std_logic
  );
end entity pltbutils_clkgen;

architecture bhv of pltbutils_clkgen is
  constant C_HALF_PERIOD    : time := G_PERIOD / 2;
  signal   clk              : std_logic := G_INITVALUE;
begin

  clk       <= not clk and not stop_sim_i after C_HALF_PERIOD;
  clk_o     <= clk;
  clk_n_o   <= not clk;

end architecture bhv;


