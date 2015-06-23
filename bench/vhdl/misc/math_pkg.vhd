----------------------------------------------------------------------
----                                                              ----
---- Auxiliary package with mathematical functions.               ----
----                                                              ----
---- This file is part of the simu_mem project                    ----
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
PACKAGE math_pkg IS
  -- linear congruential generator (a random number generator)
  -- use result for the seed in the next call
  -- preferably use bits 30...16
  FUNCTION lcg (seed : IN NATURAL) RETURN NATURAL;
END PACKAGE math_pkg;

PACKAGE BODY math_pkg IS
  FUNCTION lcg (seed : IN NATURAL) RETURN NATURAL IS
    -- Constants from: http://en.wikipedia.org/wiki/Linear_congruential_generator
    CONSTANT a : NATURAL := 16807;
    CONSTANT c : NATURAL := 0;
    CONSTANT m : NATURAL := 2 ** 31 - 1;
  BEGIN
    RETURN (a * seed + c) MOD m;
  END FUNCTION;
END PACKAGE BODY math_pkg;
