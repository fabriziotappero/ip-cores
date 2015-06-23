----------------------------------------------------------------------
----                                                              ----
----  trellis2_e.vhd                                              ----
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
use ieee.std_logic_arith.all;
use work.turbopack.all;

entity trellis2 is  -- second trellis
    port    (
            clk         : in  std_logic;                    -- clock
            rst         : in  std_logic;                    -- negative reset
            selState    : in  std_logic_vector(2 downto 0); -- selected state at time (l - 1)
            state       : in  ARRAY4d;                      -- 4 possible states at time (l - 1)
            selTrans    : in  ARRAY8b;                      -- 8 selected transitions (1 per state) at time (l - 1)
            weight      : in  ARRAY4a;                      -- four weights sorted by transition code at time (l - 1)
            llr0        : out std_logic_vector(ACC_DIST_WIDTH - 1 downto 0);    -- LLR for (a, b) = (0, 0) at time (l + m - 1)
            llr1        : out std_logic_vector(ACC_DIST_WIDTH - 1 downto 0);    -- LLR for (a, b) = (0, 1) at time (l + m - 1)
            llr2        : out std_logic_vector(ACC_DIST_WIDTH - 1 downto 0);    -- LLR for (a, b) = (1, 0) at time (l + m - 1)
            llr3        : out std_logic_vector(ACC_DIST_WIDTH - 1 downto 0);    -- LLR for (a, b) = (1, 1) at time (l + m - 1)
            a           : out std_logic;                    -- decoded value of a at time (l + m - 1)
            b           : out std_logic                     -- decoded value of b at time (l + m - 1)
            );
end trellis2;
