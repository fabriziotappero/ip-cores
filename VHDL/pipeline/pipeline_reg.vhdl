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

ENTITY pipeline_reg IS

  PORT (
    D   : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
    Q   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    CLK : IN  STD_LOGIC;
    EN  : IN  STD_LOGIC);

END ENTITY pipeline_reg;

ARCHITECTURE Behavioral OF pipeline_reg IS

BEGIN  -- ARCHITECTURE Behavioral

  PROCESS (CLK) IS
  BEGIN  -- PROCESS
    IF rising_edge(CLK) THEN
      IF EN = '1' THEN
        Q <= D;
      END IF;
    END IF;
  END PROCESS;

END ARCHITECTURE Behavioral;
