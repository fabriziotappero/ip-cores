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
USE ieee.numeric_std.all;
  
ENTITY memory IS

  PORT (
    CLK     : IN  STD_LOGIC;
    ADDRESS : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
    Q       : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));

END ENTITY memory;

ARCHITECTURE Behavioral OF memory IS

  TYPE mem_type IS ARRAY (0 TO 255) OF STD_LOGIC_VECTOR(7 DOWNTO 0);

  SIGNAL memory : mem_type := (
    X"F0", X"17", X"AF", X"AD",
    X"AF", X"36", X"59", X"0F",
    OTHERS => X"00"
    );
  SIGNAL iar    : INTEGER RANGE 0 TO 255 := 0;

BEGIN  -- ARCHITECTURE Behavioral

  register_iar: PROCESS (CLK) IS
  BEGIN  -- PROCESS register_iar
    IF rising_edge(CLK) THEN  -- rising clock edge
      iar <= to_integer(UNSIGNED(ADDRESS));
    END IF;
  END PROCESS register_iar;

  Q <= memory(iar);

END ARCHITECTURE Behavioral;
