----------------------------------------------------------------------
----                                                              ----
---- Package used by the test pattern generator for the           ----
---- Synchronous static RAM ("Zero Bus Turnaround" RAM, ZBT RAM)  ----
---- simulation model.                                            ----
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
LIBRARY ieee, misc;
USE ieee.std_logic_1164.ALL; 
USE ieee.numeric_std.ALL; 
USE misc.math_pkg.ALL;

PACKAGE patgen_pkg IS
  COMPONENT patgen IS
    GENERIC (
      clk_periode : TIME);
    port (
      Clk   : IN  STD_LOGIC;
      Rst   : IN  STD_LOGIC;
      Ena   : IN  STD_LOGIC;
      A     : OUT STD_LOGIC_VECTOR;
      D     : OUT STD_LOGIC_VECTOR;
      CKE_n : OUT STD_LOGIC;
      CS1_n : OUT STD_LOGIC;
      CS2   : OUT STD_LOGIC;
      CS2_n : OUT STD_LOGIC;
      WE_n  : OUT STD_LOGIC;
      BW_n  : OUT STD_LOGIC_VECTOR;
      OE_n  : OUT STD_LOGIC;
      ADV   : OUT STD_LOGIC;
      ZZ    : OUT STD_LOGIC;
      LBO_n : OUT STD_LOGIC);
  END COMPONENT patgen;

  PROCEDURE random_vector (
    SIGNAL   D      : OUT   STD_LOGIC_VECTOR;
    VARIABLE random : INOUT NATURAL);
END PACKAGE patgen_pkg;

PACKAGE BODY patgen_pkg IS
   PROCEDURE random_vector (
     SIGNAL D        : OUT   STD_LOGIC_VECTOR;
     VARIABLE random : INOUT NATURAL) IS
   BEGIN
     IF (D'length >= 31) THEN
       random := lcg (random);
       D (30 DOWNTO 0) <= STD_LOGIC_VECTOR (TO_UNSIGNED (random, 32)(30 DOWNTO 0));

       random := lcg (random);
       D (D'length - 1 DOWNTO 31) <= 
         STD_LOGIC_VECTOR (TO_UNSIGNED (random, 32)(D'length - 32 DOWNTO 0));
     else
       random := lcg (random);
       D      <= STD_LOGIC_VECTOR (TO_UNSIGNED (random, 32)(D'length - 1 DOWNTO 0));
     END IF;
   END PROCEDURE random_vector;
END PACKAGE BODY patgen_pkg;
