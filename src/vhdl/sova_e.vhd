----------------------------------------------------------------------
----                                                              ----
----  sova_e.vhd                                                  ----
----                                                              ----
----  This file is part of the turbo decoder IP core project      ----
----  http://www.opencores.org/projects/turbocodes/               ----
----                                                              ----
----  Author(s):                                                  ----
----      - David Brochart(dbrochart@opencores.org)               ----
----                                                              ----
----  All additional information is available in the README.txt   ----
----  file.                                                       ----
----                                                              ----
----------------------------------------------------------------------
----                                                              ----
---- Copyright (C) 2005 Authors                                   ----
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
use work.turbopack.all;

entity sova is  -- Soft Output Viterbi Algorithm top level
    port    (
            clk     : in  std_logic;                                -- clock
            rst     : in  std_logic;                                -- negative reset
            aNoisy  : in  std_logic_vector(SIG_WIDTH - 1 downto 0); -- received decoder signal
            bNoisy  : in  std_logic_vector(SIG_WIDTH - 1 downto 0); -- received decoder signal
            yNoisy  : in  std_logic_vector(SIG_WIDTH - 1 downto 0); -- received decoder signal
            wNoisy  : in  std_logic_vector(SIG_WIDTH - 1 downto 0); -- received decoder signal
            zin     : in  ARRAY4c;                                  -- extrinsic information input
            zout    : out ARRAY4c;                                  -- extrinsic information output
            aClean  : out std_logic;                                -- decoded systematic data
            bClean  : out std_logic                                 -- decoded systematic data
            );
end sova;
