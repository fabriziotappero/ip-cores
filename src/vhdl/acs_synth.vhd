----------------------------------------------------------------------
----                                                              ----
----  acs_synth.vhd                                               ----
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



architecture synth of acs is
    signal distance16   : ARRAY16a;
    signal accDist8     : ARRAY8a;
    signal accDist32    : ARRAY32c;
    signal accDistDel32 : ARRAY32c;
    signal accDistDel4  : ARRAY4a;
    signal selAccDistL  : std_logic_vector(ACC_DIST_WIDTH - 1 downto 0);
begin
    distances_i0 : distances port map   (
                                        a           => a,
                                        b           => b,
                                        y           => y,
                                        w           => w,
                                        z           => z,
                                        distance16  => distance16
                                        );
    accDist_i0 : accDist port map   (
                                    clk         => clk,
                                    rst         => rst,
                                    accDistReg  => accDist8,
                                    dist        => distance16,
                                    accDistNew  => accDist32
                                    );
    delayer_g0 : for i in 0 to 31 generate
        delayer_i : delayer generic map (
                                        delay   => TREL1_LEN - 1
                                        )
                            port map    (
                                        clk     => clk,
                                        rst     => rst,
                                        d       => accDist32(FROM2TO(i)),
                                        q       => accDistDel32(i)
                                        );
    end generate;
    mux8_i0 : mux8 port map (
                            in8x4   => accDistDel32,
                            sel     => selStateL,
                            outSel4 => accDistDel4
                            );
    mux4_i0 : mux4  port map    (
                                in1     => accDistDel4(0),
                                in2     => accDistDel4(1),
                                in3     => accDistDel4(2),
                                in4     => accDistDel4(3),
                                sel     => selTransL,
                                outSel  => selAccDistL
                                );
    subs_g : for i in 0 to 3 generate
        subs_i : subs   port map    (
                                    op1     => accDistDel4(i),
                                    op2     => selAccDistL,
                                    res     => weight(i)
                                    );
    end generate;
    accDistSel_i0 : accDistSel port map (
                                        accDist     => accDist32,
                                        accDistCod  => stateDist,
                                        accDistOut  => accDist8
                                        );
    stateSel_i0 : stateSel port map (
                                    stateDist   => accDist8,
                                    selState    => selState
                                    );
end;
