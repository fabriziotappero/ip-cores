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

ENTITY array_issue IS
  
  GENERIC (
    address_width : NATURAL := 16;
    data_width    : NATURAL := 8);

END ENTITY array_issue;

ARCHITECTURE Behavioral OF array_issue IS

  TYPE mem_type IS ARRAY (INTEGER RANGE <>) OF STD_LOGIC_VECTOR(data_width - 1 DOWNTO 0);

  SIGNAL memory : mem_type(0 TO (2**address_width - 1));

BEGIN  -- ARCHITECTURE Behavioral

  test : PROCESS IS
    VARIABLE l : INTEGER := memory'LENGTH;
  BEGIN  -- PROCESS test

    FOR i IN 0 TO l - 1 LOOP

    END LOOP;  -- i
    
  END PROCESS test;

END ARCHITECTURE Behavioral;
