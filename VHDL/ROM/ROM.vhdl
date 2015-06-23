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

ENTITY rams_01 IS
  PORT (clk  : IN  STD_LOGIC;
        we   : IN  STD_LOGIC;
        en   : IN  STD_LOGIC;
        addr : IN  STD_LOGIC_VECTOR(5 DOWNTO 0);
        di   : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        do   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
END rams_01;

ARCHITECTURE syn OF rams_01 IS
  
  TYPE ram_type IS ARRAY (0 TO 63) OF STD_LOGIC_VECTOR (15 DOWNTO 0);

  SIGNAL RAM : ram_type :=
    (X"0000", X"0001", X"0002", X"0004", X"0008",
     X"0010", X"0020", X"0040", X"0080", X"0100",
     OTHERS => X"1111");

  ATTRIBUTE ram_style        : STRING;
  ATTRIBUTE ram_style OF RAM : SIGNAL IS "block";

BEGIN
  
  PROCESS (clk)
  BEGIN
    IF rising_edge(clk) THEN
      IF en = '1' THEN
        IF we = '1' THEN
          RAM(to_integer(UNSIGNED(addr))) <= di;
        END IF;
        do <= RAM(to_integer(UNSIGNED(addr)));
      END IF;
    END IF;
  END PROCESS;
  
END syn;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY driver IS
  
  PORT (
    clk : IN  STD_LOGIC;
    led : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));

END driver;

ARCHITECTURE Structural OF driver IS

  COMPONENT rams_01 IS
    PORT (clk  : IN  STD_LOGIC;
          we   : IN  STD_LOGIC;
          en   : IN  STD_LOGIC;
          addr : IN  STD_LOGIC_VECTOR(5 DOWNTO 0);
          di   : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          do   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
  END COMPONENT rams_01;

  SIGNAL counter : STD_LOGIC_VECTOR(5 DOWNTO 0) := "000000";
  SIGNAL result  : STD_LOGIC_VECTOR(15 DOWNTO 0);

BEGIN  -- Structural

  RAM1 : rams_01
    PORT MAP (
      clk  => clk,
      we   => '0',
      en   => '1',
      addr => counter,
      di   => X"0000",
      do   => result);

  PROCESS (clk)
  BEGIN  -- PROCESS
    IF rising_edge(clk) THEN
      IF counter = "111111" THEN
        counter <= "000000";
      ELSE
        counter <= STD_LOGIC_VECTOR(UNSIGNED(counter)
                                    + to_unsigned(1, 6));
      END IF;
    END IF;
  END PROCESS;

  led <= result(7 DOWNTO 0);

END Structural;
