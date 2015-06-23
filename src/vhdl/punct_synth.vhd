----------------------------------------------------------------------
----                                                              ----
----  punct_synth.vhd                                             ----
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



architecture synth of punct is
    subtype cnt_t is integer range 0 to 6;
    signal pattern  : std_logic_vector(0 to 11);
    signal cntMax   : cnt_t;
    signal cnt      : cnt_t;
    signal ySel     : std_logic;
    signal wSel     : std_logic;
begin
    pattern_g13 : if RATE = 13 generate
        pattern <= "110000000000";
        cntMax  <= 1;
    end generate;
    pattern_g25 : if RATE = 25 generate
        pattern <= "111000000000";
        cntMax  <= 2;
    end generate;
    pattern_g12 : if RATE = 12 generate
        pattern <= "100000000000";
        cntMax  <= 1;
    end generate;
    pattern_g23 : if RATE = 23 generate
        pattern <= "100000000000";
        cntMax  <= 2;
    end generate;
    pattern_g34 : if RATE = 34 generate
        pattern <= "100000000000";
        cntMax  <= 3;
    end generate;
    pattern_g45 : if RATE = 45 generate
        pattern <= "100000000000";
        cntMax  <= 4;
    end generate;
    pattern_g67 : if RATE = 67 generate
        pattern <= "100000000000";
        cntMax  <= 6;
    end generate;

    process(clk, rst)
    begin
        if rst = '0' then
            ySel    <= '0';
            wSel    <= '0';
            cnt     <= 0;
        elsif clk = '1' and clk'event then
            if cnt < cntMax - 1 then
                cnt <= cnt + 1;
            else
                cnt <= 0;
            end if;
            ySel <= pattern(cnt);
            wSel <= pattern(cntMax + cnt);
        end if;
    end process;
    
    yPunct      <=  y       when ySel = '1'     else
                    (others => '0');
    wPunct      <=  w       when wSel = '1'     else
                    (others => '0');
    yIntPunct   <=  yInt    when ySel = '1'     else
                    (others => '0');
    wIntPunct   <=  wInt    when wSel = '1'     else
                    (others => '0');
end;
