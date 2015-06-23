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
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY flipflop IS
  PORT (clock : IN  STD_LOGIC;
        sig   : OUT STD_LOGIC);
END flipflop;

ARCHITECTURE Behavioral OF flipflop IS

  SIGNAL count  : NATURAL RANGE 0 TO 63 := 0;
  SIGNAL result : STD_LOGIC_VECTOR(5 DOWNTO 0);
  
BEGIN

  PROCESS (clock)
  BEGIN  -- PROCESS
    IF rising_edge(clock) THEN

      IF count = 63 THEN
        count <= 0;
      ELSE
        count <= count + 1;
      END IF;
      
    END IF;
  END PROCESS;

  result <= STD_LOGIC_VECTOR(to_unsigned(count, 6));

  sig <= result(5);
  
END Behavioral;

