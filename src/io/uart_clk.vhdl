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
USE work.system_package.ALL;

ENTITY uart_clock IS
    PORT (
      reset   : IN  STD_LOGIC;
      clock   : IN  STD_LOGIC;
      baudout : OUT STD_LOGIC);
END uart_clock;

ARCHITECTURE Behavioral OF uart_clock IS

  SIGNAL div_ctr : INTEGER RANGE 0 TO 650 := 0;

BEGIN

  -- purpose: Divide 100 MHz Atlys clock by 651
  -- type   : sequential
  -- inputs : clock, reset
  -- outputs: baudout
  baudgen: PROCESS (clock, reset)
  BEGIN  -- PROCESS baudgen
    IF reset = '0' THEN                 -- asynchronous reset (active low)
      div_ctr <= 0;
      baudout <= '1';
    ELSIF rising_edge(clock) THEN  -- rising clock edge
      IF div_ctr >= 650 THEN
        div_ctr <= 0;
        baudout <= '1';
      ELSE
        div_ctr <= div_ctr + 1;
        baudout <= '0';
      END IF;
    END IF;
  END PROCESS baudgen;

END Behavioral;
