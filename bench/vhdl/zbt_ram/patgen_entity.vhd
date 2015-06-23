----------------------------------------------------------------------
----                                                              ----
---- Test pattern generator for the                               ----
---- Synchronous static RAM ("Zero Bus Turnaround" RAM, ZBT RAM)  ----
---- simulation model.                                            ----
---- Entity declaration only.                                     ----
----                                                              ----
---- This file is part of the simu_mem project.                   ----
----                                                              ----
---- Authors:                                                     ----
---- - Michael Geng, vhdl@MichaelGeng.de                          ----
----                                                              ----
----------------------------------------------------------------------
----                                                              ----
---- Copyright (C) 2008 Authors                                   ----
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
---- from http://www.gnu.org/licenses/lgpl.html                   ----
----                                                              ----
----------------------------------------------------------------------
-- CVS Revision History
--
-- $Log: not supported by cvs2svn $
--
LIBRARY ieee, misc, RAM;
USE ieee.std_logic_1164.ALL; 
USE ieee.numeric_std.ALL; 
USE misc.math_pkg.ALL;
USE RAM.ZBT_RAM_pkg.ALL;
USE work.patgen_pkg.ALL;

ENTITY patgen IS
  GENERIC (
    clk_periode : TIME;
    tOE         : TIME := 2.7 ns;
    tWS         : TIME := 1.2 ns;
    tWH         : TIME := 0.3 ns);
  PORT (
    -- system clock
    Clk : IN STD_LOGIC;

    -- global reset
    Rst : IN STD_LOGIC;

    -- clock enable
    Ena : IN STD_LOGIC;

    A     : OUT    STD_LOGIC_VECTOR;
    D     : OUT    STD_LOGIC_VECTOR;
    CKE_n : BUFFER STD_LOGIC;
    CS1_n : BUFFER STD_LOGIC;
    CS2   : BUFFER STD_LOGIC;
    CS2_n : BUFFER STD_LOGIC;
    WE_n  : BUFFER STD_LOGIC;
    BW_n  : BUFFER STD_LOGIC_VECTOR;
    OE_n  : BUFFER STD_LOGIC;
    ADV   : BUFFER STD_LOGIC;
    ZZ    : BUFFER STD_LOGIC;
    LBO_n : BUFFER STD_LOGIC);
END ENTITY patgen;
