----------------------------------------------------------------------
----                                                              ----
---- Misc utility                                                 ----
----                                                              ----
---- Author(s):                                                   ----
---- - Slavek Valach, s.valach@dspfpga.com                        ----
----                                                              ----
----------------------------------------------------------------------
----                                                              ----
---- Copyright (C) 2008 Authors and OPENCORES.ORG                 ----
----                                                              ----
---- This source file may be used and distributed without         ----
---- restriction provided that this copyright statement is not    ----
---- removed from the file and that any derivative work contains  ----
---- the original copyright notice and the associated disclaimer. ----
----                                                              ----
---- This source file is free software; you can redistribute it   ----
---- and/or modify it under the terms of the GNU General          ----
---- Public License as published by the Free Software Foundation; ----
---- either version 2.0 of the License, or (at your option) any   ----
---- later version.                                               ----
----                                                              ----
---- This source is distributed in the hope that it will be       ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied   ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ----
---- PURPOSE. See the GNU General Public License for more details.----
----                                                              ----
---- You should have received a copy of the GNU General           ----
---- Public License along with this source; if not, download it   ----
---- from http://www.gnu.org/licenses/gpl.txt                     ----
----                                                              ----
----------------------------------------------------------------------

library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-------------------------------------------------------------------------------
-- Entity section
-----------------------------------------------------------------------------

entity resample_r is             -- Resample signal at rising edges
port (
   Clk                           : in     std_logic;     -- A new clock domain          
   Rst                           : in     std_logic;     -- System reset
   D_i                           : in     std_logic;     -- Input data
   D_o                           : out    std_logic);     -- Output data with new time domain
end resample_r;

-----------------------------------------------------------------------------
-- Architecture section
-----------------------------------------------------------------------------
architecture implementation of resample_r is

signal r_1                       : std_logic;      -- Avoid metastability

BEGIN

PROCESS(Clk, Rst, D_i)
BEGIN
   If Rst = '1' Then
      r_1 <= '0';
      D_o <= '0';
   ElsIf Clk'event And Clk = '1' Then
      r_1 <= D_i;
      D_o <= r_1;
   End If;
END PROCESS;

END Implementation;

-- ********************
-- *** Start det_re ***
-- ********************

-- Detects rising edge on signal D_i
library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-------------------------------------------------------------------------------
-- Entity section
-----------------------------------------------------------------------------

entity det_re is             -- Run process on the rising edge at signal D_i which belong to Clk1 time domain
port (
   Clk                           : in     std_logic;     -- Clock 
   Rst                           : in     std_logic;     -- System reset
   D_i                           : in     std_logic;     -- Input data
   D_o                           : out    std_logic);    -- Output data with new time domain
end det_re;

-----------------------------------------------------------------------------
-- Architecture section
-----------------------------------------------------------------------------
architecture implementation of det_re is

signal r_1                       : std_logic;      -- Avoid metastability

BEGIN

PROCESS(Clk)
BEGIN
   If Clk'event And Clk = '1' Then
      r_1 <= D_i;       -- generates one clock delay
   End If;
End PROCESS;

D_o <= '1' When (r_1 = '0') And (D_i = '1') Else '0';

End Implementation;

-- ******************
-- *** End det_re ***
-- ******************

