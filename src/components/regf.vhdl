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

ENTITY regf IS
  GENERIC (
    w_data : NATURAL := 16;
    w_addr : NATURAL := 5);
  PORT (clk : IN  STD_LOGIC;
        we  : IN  STD_LOGIC;
        a1  : IN  STD_LOGIC_VECTOR(w_addr - 1 DOWNTO 0);
        a2  : IN  STD_LOGIC_VECTOR(w_addr - 1 DOWNTO 0);
        d   : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
        q1  : OUT STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
        q2  : OUT STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0));
END ENTITY regf;

ARCHITECTURE Behavioral OF regf IS

  CONSTANT RFSIZE : NATURAL := 2**w_addr;
  
  TYPE reg_array IS ARRAY(0 TO RFSIZE - 1) OF STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);

  SIGNAL reg : reg_array;

BEGIN  -- ARCHITECTURE Behavioral

  -- purpose: Single input, dual output register file
  -- type   : sequential
  -- inputs : clk, we, a1, a2, d
  -- outputs: q1, q2
  REGF: PROCESS (clk) IS
  BEGIN  -- PROCESS REGF
    IF rising_edge(clk) THEN  -- rising clock edge
      IF we = '1' THEN
        reg(to_integer(UNSIGNED('0' & a1))) <= d;
      END IF;
    END IF;
  END PROCESS REGF;

  q1 <= reg(to_integer(UNSIGNED('0' & a1)));
  q2 <= reg(to_integer(UNSIGNED('0' & a2)));

END ARCHITECTURE Behavioral;

