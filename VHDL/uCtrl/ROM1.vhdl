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

PACKAGE rom_parts IS

  COMPONENT rom_in_pr IS

    GENERIC (
      w_data : NATURAL RANGE 1 TO 48 := 16;
      w_addr : NATURAL RANGE 6 TO 14 := 10);
    PORT (
      clk : IN  STD_LOGIC;
      a1  : IN  STD_LOGIC_VECTOR(w_addr - 1 DOWNTO 0);   -- ROM address
      q1  : OUT STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0));  -- ROM output

  END COMPONENT rom_in_pr;

  COMPONENT rom_db_pr IS

    GENERIC (
      w_data : NATURAL RANGE 1 TO 48 := 16;
      w_addr : NATURAL RANGE 6 TO 14 := 10);
    PORT (
      clk : IN  STD_LOGIC;
      a1  : IN  STD_LOGIC_VECTOR(w_addr - 1 DOWNTO 0);   -- ROM address
      q1  : OUT STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0));  -- ROM output

  END COMPONENT rom_db_pr;

  COMPONENT rom_out_pr IS

    GENERIC (
      w_data : NATURAL RANGE 1 TO 48 := 16;
      w_addr : NATURAL RANGE 6 TO 14 := 10);
    PORT (
      clk : IN  STD_LOGIC;
      a1  : IN  STD_LOGIC_VECTOR(w_addr - 1 DOWNTO 0);   -- ROM address
      q1  : OUT STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0));  -- ROM output

  END COMPONENT rom_out_pr;

END PACKAGE rom_parts;

-------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY rom_in_pr IS

  GENERIC (
    w_data : NATURAL RANGE 1 TO 48 := 16;
    w_addr : NATURAL RANGE 6 TO 14 := 10);
  PORT (
    clk : IN  STD_LOGIC;
    a1  : IN  STD_LOGIC_VECTOR(w_addr - 1 DOWNTO 0);   -- ROM address
    q1  : OUT STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0));  -- ROM output

END rom_in_pr;

ARCHITECTURE Behavioral OF rom_in_pr IS

  TYPE rom_array IS ARRAY(0 TO (2**w_addr) - 1) OF STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);

  SIGNAL rom : rom_array := (
    STD_LOGIC_VECTOR(to_unsigned(0, w_data)),
    STD_LOGIC_VECTOR(to_unsigned(1, w_data)),
    STD_LOGIC_VECTOR(to_unsigned(2, w_data)),
    STD_LOGIC_VECTOR(to_unsigned(4, w_data)),
    STD_LOGIC_VECTOR(to_unsigned(8, w_data)),
    STD_LOGIC_VECTOR(to_unsigned(16, w_data)),
    STD_LOGIC_VECTOR(to_unsigned(32, w_data)),
    STD_LOGIC_VECTOR(to_unsigned(64, w_data)),
    STD_LOGIC_VECTOR(to_unsigned(128, w_data)),
    STD_LOGIC_VECTOR(to_unsigned(256, w_data)),
    STD_LOGIC_VECTOR(to_unsigned(512, w_data)),
    OTHERS => STD_LOGIC_VECTOR(to_unsigned(255, w_data)));

  SIGNAL a1_reg : STD_LOGIC_VECTOR(w_addr - 1 DOWNTO 0);

BEGIN  -- Behavioral

  -- purpose: Try to describe a proper block ram without needing to instantiate a BRAM
  -- type   : sequential
  -- inputs : clk, a1
  -- outputs: q1
  MP1 : PROCESS (clk)
  BEGIN  -- PROCESS MP1
    IF rising_edge(clk) THEN            -- rising clock edge

      a1_reg <= a1;

    END IF;
  END PROCESS MP1;

  q1 <= rom(to_integer(UNSIGNED(a1_reg)));

END Behavioral;

-------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY rom_db_pr IS

  GENERIC (
    w_data : NATURAL RANGE 1 TO 48 := 16;
    w_addr : NATURAL RANGE 6 TO 14 := 10);
  PORT (
    clk : IN  STD_LOGIC;
    a1  : IN  STD_LOGIC_VECTOR(w_addr - 1 DOWNTO 0);   -- ROM address
    q1  : OUT STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0));  -- ROM output

END rom_db_pr;

ARCHITECTURE Behavioral OF rom_db_pr IS

  TYPE rom_array IS ARRAY(0 TO (2**w_addr) - 1) OF STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);

  SIGNAL rom : rom_array := (
    STD_LOGIC_VECTOR(to_unsigned(0, w_data)),
    STD_LOGIC_VECTOR(to_unsigned(1, w_data)),
    STD_LOGIC_VECTOR(to_unsigned(2, w_data)),
    STD_LOGIC_VECTOR(to_unsigned(4, w_data)),
    STD_LOGIC_VECTOR(to_unsigned(8, w_data)),
    STD_LOGIC_VECTOR(to_unsigned(16, w_data)),
    STD_LOGIC_VECTOR(to_unsigned(32, w_data)),
    STD_LOGIC_VECTOR(to_unsigned(64, w_data)),
    STD_LOGIC_VECTOR(to_unsigned(128, w_data)),
    STD_LOGIC_VECTOR(to_unsigned(256, w_data)),
    STD_LOGIC_VECTOR(to_unsigned(512, w_data)),
    OTHERS => STD_LOGIC_VECTOR(to_unsigned(255, w_data)));

  SIGNAL a1_reg : STD_LOGIC_VECTOR(w_addr - 1 DOWNTO 0);
  SIGNAL q1_reg : STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);

BEGIN  -- Behavioral

  -- purpose: Try to describe a proper block ram without needing to instantiate a BRAM
  -- type   : sequential
  -- inputs : clk, a1
  -- outputs: q1
  MP1 : PROCESS (clk)
  BEGIN  -- PROCESS MP1
    IF rising_edge(clk) THEN            -- rising clock edge

      a1_reg <= a1;
      q1_reg <= rom(to_integer(UNSIGNED(a1_reg)));


    END IF;
  END PROCESS MP1;

  q1 <= q1_reg;

END Behavioral;

-------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY rom_out_pr IS

  GENERIC (
    w_data : NATURAL RANGE 1 TO 48 := 16;
    w_addr : NATURAL RANGE 6 TO 14 := 10);
  PORT (
    clk : IN  STD_LOGIC;
    a1  : IN  STD_LOGIC_VECTOR(w_addr - 1 DOWNTO 0);   -- ROM address
    q1  : OUT STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0));  -- ROM output

END rom_out_pr;

ARCHITECTURE Behavioral OF rom_out_pr IS

  TYPE rom_array IS ARRAY(0 TO (2**w_addr) - 1) OF STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);

  SIGNAL rom : rom_array := (
    STD_LOGIC_VECTOR(to_unsigned(0, w_data)),
    STD_LOGIC_VECTOR(to_unsigned(1, w_data)),
    STD_LOGIC_VECTOR(to_unsigned(2, w_data)),
    STD_LOGIC_VECTOR(to_unsigned(4, w_data)),
    STD_LOGIC_VECTOR(to_unsigned(8, w_data)),
    STD_LOGIC_VECTOR(to_unsigned(16, w_data)),
    STD_LOGIC_VECTOR(to_unsigned(32, w_data)),
    STD_LOGIC_VECTOR(to_unsigned(64, w_data)),
    STD_LOGIC_VECTOR(to_unsigned(128, w_data)),
    STD_LOGIC_VECTOR(to_unsigned(256, w_data)),
    STD_LOGIC_VECTOR(to_unsigned(512, w_data)),
    OTHERS => STD_LOGIC_VECTOR(to_unsigned(255, w_data)));

  SIGNAL q1_reg : STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);

BEGIN  -- Behavioral

  -- purpose: Try to describe a proper block ram without needing to instantiate a BRAM
  -- type   : sequential
  -- inputs : clk, a1
  -- outputs: q1
  MP1 : PROCESS (clk)
  BEGIN  -- PROCESS MP1
    IF rising_edge(clk) THEN            -- rising clock edge

      q1_reg <= rom(to_integer(UNSIGNED(a1)));

    END IF;
  END PROCESS MP1;

  q1 <= q1_reg;

END Behavioral;
