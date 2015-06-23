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

ENTITY rf IS

  PORT (
    CLK : IN  STD_LOGIC;
    D   : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
    Q1  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    Q2  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    A1  : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
    A2  : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
    WR  : IN  STD_LOGIC);

END ENTITY rf;

ARCHITECTURE Behavioral OF rf IS

  TYPE rf_type IS ARRAY(0 TO 3) OF STD_LOGIC_VECTOR(7 DOWNTO 0);

  SIGNAL reg : rf_type;

BEGIN  -- ARCHITECTURE Behavioral

  PROCESS (CLK)
  BEGIN
    IF rising_edge(CLK) THEN
      IF WR = '0' THEN
        reg(to_integer(UNSIGNED(A1))) <= reg(to_integer(UNSIGNED(A1)));
      ELSE
        reg(to_integer(UNSIGNED(A1))) <= D;
      END IF;
    END IF;
  END PROCESS;

  Q1 <= reg(to_integer(UNSIGNED(A1)));
  Q2 <= reg(to_integer(UNSIGNED(A2)));

END ARCHITECTURE Behavioral;
