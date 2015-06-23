----------------------------------------------------------------------
----                                                              ----
----  accDistSel_synth.vhd                                        ----
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



architecture synth of accDistSel is
    signal comp         : std_logic_vector(23 downto 0);
    signal accDistCod_s : ARRAY8b;
begin
    accDistCod <= accDistCod_s;
    min4_g : for i in 0 to 7 generate
        min4_i : min4   port map    (
                                    op1     => accDist(FROM2TO(4 * i)),
                                    op2     => accDist(FROM2TO(4 * i + 1)),
                                    op3     => accDist(FROM2TO(4 * i + 2)),
                                    op4     => accDist(FROM2TO(4 * i + 3)),
                                    res1    => comp(3 * i),
                                    res2    => comp(3 * i + 1),
                                    res3    => comp(3 * i + 2)
                                    );
    end generate;
    cod2_g : for i in 0 to 7 generate
        cod2_i : cod2   port map    (
                                    in1     => comp(3 * i),
                                    in2     => comp(3 * i + 1),
                                    in3     => comp(3 * i + 2),
                                    outCod  => accDistCod_s(i)
                                    );
    end generate;
    mux4_g : for i in 0 to 7 generate
        mux4_i : mux4   port map    (
                                    in1     => accDist(FROM2TO(4 * i)),
                                    in2     => accDist(FROM2TO(4 * i + 1)),
                                    in3     => accDist(FROM2TO(4 * i + 2)),
                                    in4     => accDist(FROM2TO(4 * i + 3)),
                                    sel     => accDistCod_s(i),
                                    outSel  => accDistOut(i)
                                    );
    end generate;
end;
