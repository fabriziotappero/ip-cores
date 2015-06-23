----------------------------------------------------------------------
----                                                              ----
---- PlTbUtils Component Declarations                             ----
----                                                              ----
---- This file is part of the PlTbUtils project                   ----
---- http://opencores.org/project,pltbutils                       ----
----                                                              ----
---- Description:                                                 ----
---- PlTbUtils is a collection of functions, procedures and       ----
---- components for easily creating stimuli and checking response ----
---- in automatic self-checking testbenches.                      ----
----                                                              ----
---- This file declares testbench components, which are defined   ----
---- in pltbutils_comp.vhd .                                      ----
---- "use" this file in your testbech, e.g.                       ----
----   use work.pltbutils_comp_pkg.all;                           ----
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

package pltbutils_comp_pkg is

  -- See pltbutils_comp.vhd for a description of the components.

  component pltbutils_clkgen is
    generic (
      G_PERIOD        : time := 10 ns;
      G_INITVALUE     : std_logic := '0'
    );
    port (
      clk_o           : out std_logic;
      clk_n_o         : out std_logic;      
      stop_sim_i      : in  std_logic
    );
  end component pltbutils_clkgen;
  
  -- Instansiation template 
  -- (copy to your own file and remove the comment characters):
  --pltbutils_clkgen0 : pltbutils_clkgen
  --  generic map (
  --    G_PERIOD        => G_PERIOD,
  --    G_INITVALUE     => '0'
  --  )
  --  port map (
  --    clk_o           => clk,
  --    clk_n_o         => clk_n,
  --    stop_sim_i      => stop_sim
  --  );

end package pltbutils_comp_pkg;


