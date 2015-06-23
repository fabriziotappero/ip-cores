----------------------------------------------------------------------
----                                                              ----
----  distances_synth.vhd                                         ----
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



architecture synth of distances is
    signal partDist : ARRAY16b;
begin
    partDistance_g : for i in 0 to 7 generate
        partDistance_i : partDistance generic map   (
                                                    ref => i
                                                    )
                                        port map    (
                                                    a   => a,
                                                    b   => b,
                                                    y   => y,
                                                    w   => w,
                                                    res => partDist(i)
                                                    );
    end generate;
    opposite_g : for i in 0 to 7 generate
        opposite_i : opposite port map  (
                                        pos => partDist(i),
                                        neg => partDist(15 - i)
                                        );
    end generate;
    distance_g : for i in 0 to 15 generate
        distance_i : distance port map  (
                                        partDist    => partDist(i),
                                        z           => z(i / 4),
                                        dist        => distance16(i)
                                        );
    end generate;
end;
