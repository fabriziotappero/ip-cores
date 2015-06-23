----------------------------------------------------------------------
----                                                              ----
----  limiter_e.vhd                                               ----
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



library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.turbopack.all;

entity limiter is
    port    (
            a       : in  std_logic_vector(SIG_WIDTH - 1 downto 0); -- decoder input signal
            b       : in  std_logic_vector(SIG_WIDTH - 1 downto 0); -- decoder input signal
            y       : in  std_logic_vector(SIG_WIDTH - 1 downto 0); -- decoder input signal
            w       : in  std_logic_vector(SIG_WIDTH - 1 downto 0); -- decoder input signal
            yInt    : in  std_logic_vector(SIG_WIDTH - 1 downto 0); -- decoder input signal
            wInt    : in  std_logic_vector(SIG_WIDTH - 1 downto 0); -- decoder input signal
            aLim    : out std_logic_vector(SIG_WIDTH - 1 downto 0); -- limited signal
            bLim    : out std_logic_vector(SIG_WIDTH - 1 downto 0); -- limited signal
            yLim    : out std_logic_vector(SIG_WIDTH - 1 downto 0); -- limited signal
            wLim    : out std_logic_vector(SIG_WIDTH - 1 downto 0); -- limited signal
            yIntLim : out std_logic_vector(SIG_WIDTH - 1 downto 0); -- limited signal
            wIntLim : out std_logic_vector(SIG_WIDTH - 1 downto 0)  -- limited signal
            );
end limiter;
