----------------------------------------------------------------------
----                                                              ----
----  extInf_synth.vhd                                            ----
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



architecture synth of extInf is
begin
    process (llr0, llr1, llr2, llr3, zin, a, b)
        variable a_plus_b   : std_logic_vector(SIG_WIDTH - 1 downto 0);
        variable a_min_b    : std_logic_vector(SIG_WIDTH - 1 downto 0);
        variable tmp        : ARRAY7a;
        variable tmp2       : ARRAY4e;
    begin
        a_plus_b    := std_logic_vector(conv_signed(((conv_integer(signed(a)) + conv_integer(signed(b))) / 2), SIG_WIDTH));
        a_min_b     := std_logic_vector(conv_signed(((conv_integer(signed(a)) - conv_integer(signed(b))) / 2), SIG_WIDTH));
        tmp(0)      := conv_integer(unsigned(llr0)) - conv_integer(signed(a_plus_b)) - conv_integer(unsigned(zin(0)));
        tmp(1)      := conv_integer(unsigned(llr1)) - conv_integer(signed(a_min_b))  - conv_integer(unsigned(zin(1)));
        tmp(2)      := conv_integer(unsigned(llr2)) + conv_integer(signed(a_min_b))  - conv_integer(unsigned(zin(2)));
        tmp(3)      := conv_integer(unsigned(llr3)) + conv_integer(signed(a_plus_b)) - conv_integer(unsigned(zin(3)));
        if tmp(0) < tmp(1) then
            tmp(4) := tmp(0);
        else
            tmp(4) := tmp(1);
        end if;
        if tmp(2) < tmp(3) then
            tmp(5) := tmp(2);
        else
            tmp(5) := tmp(3);
        end if;
        if tmp(4) < tmp(5) then
            tmp(6) := tmp(4);
        else
            tmp(6) := tmp(5);
        end if;
        tmp2(0) := tmp(0) - tmp(6);
        tmp2(1) := tmp(1) - tmp(6);
        tmp2(2) := tmp(2) - tmp(6);
        tmp2(3) := tmp(3) - tmp(6);
        if tmp2(0) >= (2 ** Z_WIDTH) then
            zout(0) <= std_logic_vector(conv_unsigned((2 ** Z_WIDTH) - 1, Z_WIDTH));
        else
            zout(0) <= std_logic_vector(conv_unsigned(tmp2(0), Z_WIDTH));
        end if;
        if tmp2(1) >= (2 ** Z_WIDTH) then
            zout(1) <= std_logic_vector(conv_unsigned((2 ** Z_WIDTH) - 1, Z_WIDTH));
        else
            zout(1) <= std_logic_vector(conv_unsigned(tmp2(1), Z_WIDTH));
        end if;
        if tmp2(2) >= (2 ** Z_WIDTH) then
            zout(2) <= std_logic_vector(conv_unsigned((2 ** Z_WIDTH) - 1, Z_WIDTH));
        else
            zout(2) <= std_logic_vector(conv_unsigned(tmp2(2), Z_WIDTH));
        end if;
        if tmp2(3) >= (2 ** Z_WIDTH) then
            zout(3) <= std_logic_vector(conv_unsigned((2 ** Z_WIDTH) - 1, Z_WIDTH));
        else
            zout(3) <= std_logic_vector(conv_unsigned(tmp2(3), Z_WIDTH));
        end if;
    end process;
end;
