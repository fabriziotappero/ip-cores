----------------------------------------------------------------------
----                                                              ----
----  min4_synth.vhd                                              ----
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



architecture synth of min4 is
    signal res1_s   : std_logic;
    signal res2_s   : std_logic;
    signal op5      : std_logic_vector(ACC_DIST_WIDTH - 1 downto 0);
    signal op6      : std_logic_vector(ACC_DIST_WIDTH - 1 downto 0);
begin
    res1 <= res1_s;
    res2 <= res2_s;
    cmp2_i0 : cmp2  port map    (
                                op1     => op1,
                                op2     => op2,
                                res     => res1_s
                                );
    cmp2_i1 : cmp2  port map    (
                                op1     => op3,
                                op2     => op4,
                                res     => res2_s
                                );
    mux2_i0 : mux2  port map    (
                                in1     => op1,
                                in2     => op2,
                                sel     => res1_s,
                                outSel  => op5
                                );
    mux2_i1 : mux2  port map    (
                                in1     => op3,
                                in2     => op4,
                                sel     => res2_s,
                                outSel  => op6
                                );
    cmp2_i2 : cmp2  port map    (
                                op1     => op5,
                                op2     => op6,
                                res     => res3
                                );
end;
