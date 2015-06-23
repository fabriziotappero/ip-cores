-- Copyright 2015, Jürgen Defurne
--
-- This file is part of the Experimental Unstable CPU System.
--
-- The Experimental Unstable CPU System Is free software: you can redistribute
-- it and/or modify it under the terms of the GNU Lesser General Public License
-- as published by the Free Software Foundation, either version 3 of the
-- License, or (at your option) any later version.
--
-- The Experimental Unstable CPU System is distributed in the hope that it will
-- be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
-- General Public License for more details.
--
-- You should have received a copy of the GNU Lesser General Public License
-- along with Experimental Unstable CPU System. If not, see
-- http://www.gnu.org/licenses/lgpl.txt.


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY incr IS
  GENERIC(
    w_data : NATURAL RANGE 1 TO 32 := 16);
  PORT(
    A : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    Y : OUT STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0));
END ENTITY incr;

ARCHITECTURE Behavioral OF incr IS

BEGIN  -- Behavioral

  Y <= STD_LOGIC_VECTOR(UNSIGNED(A) + to_unsigned(1, w_data));

END Behavioral;
