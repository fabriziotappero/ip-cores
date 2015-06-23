----------------------------------------------------------------------
----                                                              ----
----  accDist_synth.vhd                                           ----
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



architecture synth of accDist is
    signal accDistOld   : ARRAY8a;
    signal accDistRed   : ARRAY8a;
begin
    adder_g : for i in 0 to 31 generate
        adder_i : adder port map    (
                                    op1     => accDistOld(i / 4),
                                    op2     => dist(DISTINDEX(i)),
                                    res     => accDistNew(i)
                                    );
    end generate;
    reduction_i0 : reduction    port map    (
                                            org => accDistReg,
                                            chd => accDistRed
                                            );
    reg_g : for i in 0 to 7 generate
        reg_i : reg port map    (
                                clk     => clk,
                                rst     => rst,
                                d       => accDistRed(i),
                                q       => accDistOld(i)
                                );
    end generate;
end;
