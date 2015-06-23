----------------------------------------------------------------------
----                                                              ----
----  min8_synth.vhd                                              ----
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



architecture synth of min8 is
    signal tmp      : ARRAY6a;
    signal res_s    : std_logic_vector(6 downto 0);
begin
    res <= res_s;
    cmp2_i0 : cmp2  port map    (
                                op1     => op(0),
                                op2     => op(1),
                                res     => res_s(0)
                                );
    cmp2_i1 : cmp2  port map    (
                                op1     => op(2),
                                op2     => op(3),
                                res     => res_s(1)
                                );
    cmp2_i2 : cmp2  port map    (
                                op1     => op(4),
                                op2     => op(5),
                                res     => res_s(2)
                                );
    cmp2_i3 : cmp2  port map    (
                                op1     => op(6),
                                op2     => op(7),
                                res     => res_s(3)
                                );
    mux2_i0 : mux2  port map    (
                                in1     => op(0),
                                in2     => op(1),
                                sel     => res_s(0),
                                outSel  => tmp(0)
                                );
    mux2_i1 : mux2  port map    (
                                in1     => op(2),
                                in2     => op(3),
                                sel     => res_s(1),
                                outSel  => tmp(1)
                                );
    mux2_i2 : mux2  port map    (
                                in1     => op(4),
                                in2     => op(5),
                                sel     => res_s(2),
                                outSel  => tmp(2)
                                );
    mux2_i3 : mux2  port map    (
                                in1     => op(6),
                                in2     => op(7),
                                sel     => res_s(3),
                                outSel  => tmp(3)
                                );
    cmp2_i4 : cmp2  port map    (
                                op1     => tmp(0),
                                op2     => tmp(1),
                                res     => res_s(4)
                                );
    cmp2_i5 : cmp2  port map    (
                                op1     => tmp(2),
                                op2     => tmp(3),
                                res     => res_s(5)
                                );
    mux2_i4 : mux2  port map    (
                                in1     => tmp(0),
                                in2     => tmp(1),
                                sel     => res_s(4),
                                outSel  => tmp(4)
                                );
    mux2_i5 : mux2  port map    (
                                in1     => tmp(2),
                                in2     => tmp(3),
                                sel     => res_s(5),
                                outSel  => tmp(5)
                                );
    cmp2_i6 : cmp2  port map    (
                                op1     => tmp(4),
                                op2     => tmp(5),
                                res     => res_s(6)
                                );
end;
