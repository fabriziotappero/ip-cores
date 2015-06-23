----------------------------------------------------------------------
----                                                              ----
---- PlTbUtils Example Testcase Entity for Example Testbench      ----
----                                                              ----
---- This file is part of the PlTbUtils project                   ----
---- http://opencores.org/project,pltbutils                       ----
----                                                              ----
---- Description:                                                 ----
---- PlTbUtils is a collection of functions, procedures and       ----
---- components for easily creating stimuli and checking response ----
---- in automatic self-checking testbenches.                      ----
----                                                              ----
---- This file is an example which demonstrates how PlTbUtils     ----
---- can be used.                                                 ----
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
library ieee;
use ieee.std_logic_1164.all;
use work.pltbutils_func_pkg.all;

entity tc_example2 is
  generic (
    G_WIDTH         : integer := 8;
    G_DISABLE_BUGS  : integer range 0 to 1 := 0
  );
  port (
    pltbs           : out pltbs_t;
    clk             : in  std_logic;
    rst             : out std_logic;
    carry_in        : out std_logic;
    x               : out std_logic_vector(G_WIDTH-1 downto 0);
    y               : out std_logic_vector(G_WIDTH-1 downto 0);
    sum             : in  std_logic_vector(G_WIDTH-1 downto 0);
    carry_out       : in  std_logic
  );
end entity tc_example2;
