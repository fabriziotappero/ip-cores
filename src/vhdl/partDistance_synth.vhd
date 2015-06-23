----------------------------------------------------------------------
----                                                              ----
----  partDistance_synth.vhd                                      ----
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



architecture synth of partDistance is
    signal bSigned  : std_logic_vector(SIG_WIDTH - 1 downto 0);
    signal ySigned  : std_logic_vector(SIG_WIDTH - 1 downto 0);
    signal wSigned  : std_logic_vector(SIG_WIDTH - 1 downto 0);
begin
    bPos_g : if std_logic_vector(conv_unsigned(ref, 3))(2) = '0' generate
        bSigned <= b;
    end generate;
    bNeg_g : if std_logic_vector(conv_unsigned(ref, 3))(2) = '1' generate
        bSigned <= std_logic_vector(conv_signed(-conv_integer(signed(b)), SIG_WIDTH));
    end generate;
    yPos_g : if std_logic_vector(conv_unsigned(ref, 3))(1) = '0' generate
        ySigned <= y;
    end generate;
    yNeg_g : if std_logic_vector(conv_unsigned(ref, 3))(1) = '1' generate
        ySigned <= std_logic_vector(conv_signed(-conv_integer(signed(y)), SIG_WIDTH));
    end generate;
    wPos_g : if std_logic_vector(conv_unsigned(ref, 3))(0) = '0' generate
        wSigned <= w;
    end generate;
    wNeg_g : if std_logic_vector(conv_unsigned(ref, 3))(0) = '1' generate
        wSigned <= std_logic_vector(conv_signed(-conv_integer(signed(w)), SIG_WIDTH));
    end generate;
    res <= std_logic_vector(conv_signed(conv_integer(signed(a)) + conv_integer(signed(bSigned)) + conv_integer(signed(ySigned)) + conv_integer(signed(wSigned)), SIG_WIDTH + 2));
end;
