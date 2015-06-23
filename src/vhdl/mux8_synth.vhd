----------------------------------------------------------------------
----                                                              ----
----  mux8_synth.vhd                                              ----
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



architecture synth of mux8 is
begin
    process (in8x4, sel)
    begin
        if sel = "000" then
            for i in 0 to 3 loop
                outSel4(i) <= in8x4(i);
            end loop;
        elsif sel = "001" then
            for i in 0 to 3 loop
                outSel4(i) <= in8x4(i + 4);
            end loop;
        elsif sel = "010" then
            for i in 0 to 3 loop
                outSel4(i) <= in8x4(i + 8);
            end loop;
        elsif sel = "011" then
            for i in 0 to 3 loop
                outSel4(i) <= in8x4(i + 12);
            end loop;
        elsif sel = "100" then
            for i in 0 to 3 loop
                outSel4(i) <= in8x4(i + 16);
            end loop;
        elsif sel = "101" then
            for i in 0 to 3 loop
                outSel4(i) <= in8x4(i + 20);
            end loop;
        elsif sel = "110" then
            for i in 0 to 3 loop
                outSel4(i) <= in8x4(i + 24);
            end loop;
        else
            for i in 0 to 3 loop
                outSel4(i) <= in8x4(i + 28);
            end loop;
        end if;
    end process;
end;
