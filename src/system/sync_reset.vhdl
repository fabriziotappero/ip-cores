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

ENTITY sync_reset IS
  PORT (
    async_rst : IN  STD_LOGIC;
    clk       : IN  STD_LOGIC;
    clk_valid : IN  STD_LOGIC;
    rst       : OUT STD_LOGIC);
END ENTITY sync_reset;

ARCHITECTURE Behavioral OF sync_reset IS

  SIGNAL count : INTEGER RANGE 0 TO 3 := 0;
  
BEGIN  -- Behavioral

  -- purpose: Turn asynchronous reset into synchronous reset
  -- type   : sequential
  -- inputs : clk, async_rst, clk_valid
  -- outputs: rst
  reset : PROCESS (clk)
  BEGIN  -- PROCESS reset
    IF rising_edge(clk) THEN
      IF clk_valid = '1' THEN
        IF count < 3 THEN
          count <= count + 1;
        ELSE
          count <= 3;
        END IF;
      ELSE
        count <= 0;
      END IF;
    END IF;
  END PROCESS reset;

  rst <= '1' WHEN count < 3 ELSE '0';
  
END Behavioral;
