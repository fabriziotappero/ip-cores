----------------------------------------------------------------------
----                                                              ----
----  interleaver_synth.vhd                                       ----
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



architecture synth of interleaver is
    type ARRAYfrSize is array (0 to FRSIZE - 1) of std_logic_vector(d'length - 1 downto 0);
    subtype cnt_t is integer range 0 to delay;
    subtype p_t is integer range 0 to 652;
    subtype frSize_t is integer range 0 to FRSIZE - 1;
    subtype frSize2_t is integer range 0 to 2 * FRSIZE - 1;
    signal array1   : ARRAYfrSize;
    signal array2   : ARRAYfrSize;
    signal cnt      : cnt_t;
    signal i        : frSize_t;
    signal iTmp     : frSize_t;
    signal j        : frSize_t;
    signal full     : std_logic;
    signal p0       : p_t;
    signal p1       : p_t;
    signal p2       : p_t;
    signal p3       : p_t;
begin
    frSize48_g : if FRSIZE = 48 generate
        p0 <= 11;
        p1 <= 24;
        p2 <= 0;
        p3 <= 24;
    end generate;
    frSize64_g : if FRSIZE = 64 generate
        p0 <= 7;
        p1 <= 34;
        p2 <= 32;
        p3 <= 2;
    end generate;
    frSize212_g : if FRSIZE = 212 generate
        p0 <= 13;
        p1 <= 106;
        p2 <= 108;
        p3 <= 2;
    end generate;
    frSize220_g : if FRSIZE = 220 generate
        p0 <= 23;
        p1 <= 112;
        p2 <= 4;
        p3 <= 116;
    end generate;
    frSize228_g : if FRSIZE = 228 generate
        p0 <= 17;
        p1 <= 116;
        p2 <= 72;
        p3 <= 188;
    end generate;
    frSize424_g : if FRSIZE = 424 generate
        p0 <= 11;
        p1 <= 6;
        p2 <= 8;
        p3 <= 2;
    end generate;
    frSize432_g : if FRSIZE = 432 generate
        p0 <= 13;
        p1 <= 0;
        p2 <= 4;
        p3 <= 8;
    end generate;
    frSize440_g : if FRSIZE = 440 generate
        p0 <= 13;
        p1 <= 10;
        p2 <= 4;
        p3 <= 2;
    end generate;
    frSize848_g : if FRSIZE = 848 generate
        p0 <= 19;
        p1 <= 2;
        p2 <= 16;
        p3 <= 6;
    end generate;
    frSize856_g : if FRSIZE = 856 generate
        p0 <= 19;
        p1 <= 428;
        p2 <= 224;
        p3 <= 652;
    end generate;
    frSize864_g : if FRSIZE = 864 generate
        p0 <= 19;
        p1 <= 2;
        p2 <= 16;
        p3 <= 6;
    end generate;
    frSize752_g : if FRSIZE = 752 generate
        p0 <= 19;
        p1 <= 376;
        p2 <= 224;
        p3 <= 600;
    end generate;

    process (clk, rst)
        variable p      : frSize2_t;
        variable iTmp1  : frSize2_t;
        variable iTmp2  : frSize2_t;
        variable iTmp3  : frSize2_t;
        variable ii     : frSize_t;
        variable jj     : frSize_t;
    begin
        if rst = '0' then
            cnt     <= 0;
            i       <= 0;
            j       <= 0;
            iTmp    <= 0;
            full    <= '0';
            q       <= std_logic_vector(conv_unsigned(0, q'length));
            for k in 0 to FRSIZE - 1 loop
                array1(k) <= (others => '0');
                array2(k) <= (others => '0');
            end loop;
        elsif clk = '1' and clk'event then
            if cnt < delay then
                cnt <= cnt + 1;
            else
                if j mod 4 = 0 then
                    p := 0;
                elsif j mod 4 = 1 then
                    p := FRSIZE / 2 + p1;
                elsif j mod 4 = 2 then
                    p := p2;
                else    -- if j mod 4 = 3 then
                    p := FRSIZE / 2 + p3;
                end if;
                iTmp1 := iTmp + p0;
                if iTmp1 >= FRSIZE then
                    iTmp2 := iTmp1 - FRSIZE;
                else
                    iTmp2 := iTmp1;
                end if;
                iTmp <= iTmp2;
                iTmp3 := iTmp2 + p + 1;
                if iTmp3 >= 2 * FRSIZE then
                    i <= iTmp3 - 2 * FRSIZE;
                elsif iTmp3 >= FRSIZE then
                    i <= iTmp3 - FRSIZE;
                else
                    i <= iTmp3;
                end if;
                if j = (FRSIZE - 1) then
                    j       <= 0;
                    full    <= not full;
                else
                    j <= j + 1;
                end if;
                if way = 0 then
                    ii := i;
                    jj := j;
                else
                    ii := j;
                    jj := i;
                end if;
                if full = '0' then
                    array1(jj) <= d;
                    q <= array2(ii);
                else
                    array2(jj) <= d;
                    q <= array1(ii);
                end if;
            end if;
        end if;
    end process;
end;
