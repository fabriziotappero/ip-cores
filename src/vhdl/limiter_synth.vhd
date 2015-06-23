----------------------------------------------------------------------
----                                                              ----
----  limiter_synth.vhd                                           ----
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



architecture synth of limiter is
begin
    aLim    <=  std_logic_vector(conv_signed(-2**(SIG_WIDTH - 1) + 1, SIG_WIDTH))   when conv_integer(unsigned(a)) <= -2**(SIG_WIDTH - 1)   else
                std_logic_vector(conv_signed(2**(SIG_WIDTH - 1) - 1, SIG_WIDTH))    when conv_integer(unsigned(a)) >= 2**(SIG_WIDTH - 1)    else
                a;
    bLim    <=  std_logic_vector(conv_signed(-2**(SIG_WIDTH - 1) + 1, SIG_WIDTH))   when conv_integer(unsigned(b)) <= -2**(SIG_WIDTH - 1)   else
                std_logic_vector(conv_signed(2**(SIG_WIDTH - 1) - 1, SIG_WIDTH))    when conv_integer(unsigned(b)) >= 2**(SIG_WIDTH - 1)    else
                b;
    yLim    <=  std_logic_vector(conv_signed(-2**(SIG_WIDTH - 1) + 1, SIG_WIDTH))   when conv_integer(unsigned(y)) <= -2**(SIG_WIDTH - 1)   else
                std_logic_vector(conv_signed(2**(SIG_WIDTH - 1) - 1, SIG_WIDTH))    when conv_integer(unsigned(y)) >= 2**(SIG_WIDTH - 1)    else
                y;
    wLim    <=  std_logic_vector(conv_signed(-2**(SIG_WIDTH - 1) + 1, SIG_WIDTH))   when conv_integer(unsigned(w)) <= -2**(SIG_WIDTH - 1)   else
                std_logic_vector(conv_signed(2**(SIG_WIDTH - 1) - 1, SIG_WIDTH))    when conv_integer(unsigned(w)) >= 2**(SIG_WIDTH - 1)    else
                w;
    yIntLim <=  std_logic_vector(conv_signed(-2**(SIG_WIDTH - 1) + 1, SIG_WIDTH))   when conv_integer(unsigned(yInt)) <= -2**(SIG_WIDTH - 1) else
                std_logic_vector(conv_signed(2**(SIG_WIDTH - 1) - 1, SIG_WIDTH))    when conv_integer(unsigned(yInt)) >= 2**(SIG_WIDTH - 1) else
                yInt;
    wIntLim <=  std_logic_vector(conv_signed(-2**(SIG_WIDTH - 1) + 1, SIG_WIDTH))   when conv_integer(unsigned(wInt)) <= -2**(SIG_WIDTH - 1) else
                std_logic_vector(conv_signed(2**(SIG_WIDTH - 1) - 1, SIG_WIDTH))    when conv_integer(unsigned(wInt)) >= 2**(SIG_WIDTH - 1) else
                wInt;
end;
