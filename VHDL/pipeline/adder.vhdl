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


LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY adder IS

  PORT (
    ADDEND : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
    SUM    : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));

END ENTITY adder;

ARCHITECTURE Behavioral OF adder IS

BEGIN  -- ARCHITECTURE Behavioral

  -- purpose: Incrementing circuit
  -- type   : combinational
  -- inputs : Q0 (output from first pipeline register)
  -- outputs: D0 (input to first pipeline register)
  PROCESS (ADDEND) IS
  BEGIN  -- PROCESS
      IF ADDEND = "11111111" THEN
        SUM <= "00000000";
      ELSE
        SUM <= STD_LOGIC_VECTOR(UNSIGNED(ADDEND) + 1);
      END IF;
  END PROCESS;

END ARCHITECTURE Behavioral;
